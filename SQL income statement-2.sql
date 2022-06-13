USE H_Accounting; # calling the right server
DROP PROCEDURE IF EXISTS pmusone2020_sp;# dropping the procedure
DROP TABLE IF EXISTS pmusone2020_tmp; #dropping the table

########################
### INCOME STATEMENT ###
########################

#Creating the procedure for the Income Statement
-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

	CREATE PROCEDURE pmusone2020_sp (varCalendarYear SMALLINT)
	BEGIN
  
	-- Define variables inside procedure
    DECLARE vRevenue 			DOUBLE DEFAULT 0;
    DECLARE vReturns 			DOUBLE DEFAULT 0;
    DECLARE vCOGS 			    DOUBLE DEFAULT 0;
    DECLARE vGrossprofit 		DOUBLE DEFAULT 0;
    DECLARE vSelling 			DOUBLE DEFAULT 0;
    DECLARE vAdmin 			    DOUBLE DEFAULT 0;
    DECLARE vOtherIncome		DOUBLE DEFAULT 0;
    DECLARE vOtherExp			DOUBLE DEFAULT 0;
    DECLARE vEBIT				DOUBLE DEFAULT 0;
    DECLARE vIncomeTax		    DOUBLE DEFAULT 0;
	DECLARE vOtherTax			DOUBLE DEFAULT 0;
	DECLARE vProfitLoss		    DOUBLE DEFAULT 0;

	-- Calculate the value and store them into the variables declared
    #vRevenue
	SELECT sum(COALESCE(joen.debit,0))  INTO vRevenue
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
         #restrctions
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'REV';


            
    #vReturns,refunds and discounts
	SELECT SUM(IFNULL(joen.credit,0)*-1)  INTO vReturns
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'RET';       

    #vCOGS
	SELECT SUM(IFNULL(joen.credit,0)*-1) INTO vCOGS
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'COGS';   

    #vGrossprofit
	SELECT SUM(IFNULL(joen.debit,0)-IFNULL(joen.credit,0)) INTO vGrossprofit
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
         #restrctions    
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV', 'RET', 'COGS');            

    #vSelling expenses
	SELECT SUM(IFNULL(joen.debit,0)*-1) INTO vSelling
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'SEXP';   
	
	#vAdministarrtion expenses
	SELECT SUM(IFNULL(joen.credit,0)*-1 ) INTO vAdmin
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'GEXP';   

	#vOtherIncome
	SELECT SUM(IFNULL(joen.debit,0)) INTO vOtherIncome
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OI';  

	#vOtherExp
	SELECT SUM(IFNULL(joen.debit,0)*-1 ) INTO vOtherExp
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OEXP';  
            
	#vEBIT
	SELECT SUM(IFNULL(joen.credit,0)-IFNULL(joen.debit,0)) INTO vEBIT
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV','RET', 'COGS','GEXP','SEXP','OEXP','OI');  

	#vIncomeTax
	SELECT SUM(IFNULL(joen.debit,0)*-1 ) INTO vIncomeTax
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'INCTAX';  
            
	#vOtherTax
	SELECT SUM(IFNULL(joen.debit,0)*-1) INTO vOtherTax
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OTHTAX';  

	#vProfit(Loss)
	SELECT SUM(IFNULL(joen.credit,0)-IFNULL(joen.debit,0)) INTO vProfitLoss
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.profit_loss_section_id <> 0;  

#create the Income statement table
DROP TABLE IF EXISTS pmusone2020_tmp;

	CREATE TABLE pmusone2020_tmp
		(	Sl_No INT, 
			Label VARCHAR(50), 
			Amount VARCHAR(50)
		);

	-- Insert the header for the report( Income statement)
	INSERT INTO pmusone2020_tmp 
			(Sl_No, Label, Amount)
			VALUES (1, 'Income Statement', "In USD"),
				   (2, '', ''),
				   (3, 'Revenue', format(vRevenue,0)),
                   (4, 'Returns, Refunds, Discounts', format(IFNULL(vReturns,0),0)),
                   (5, 'Cost of goods sold', format(vCOGS,0)),
                   (6, 'Gross Profit (Loss)', format(vGrossprofit, 0)),
                   (7, 'Selling Expenses',format(IFNULL(vSelling,0),0)),
                   (8, 'Administrative Expenses',format(IFNULL(vAdmin,0),0)),
                   (9, 'Other Income' , format(IFNULL(vOtherIncome,0),0)),
                   (10, 'Other Expenses', format(IFNULL(vOtherExp,0),0)),
                   (11, 'EBIT', format(IFNULL(vEBIT,0),0)),
                   (12, 'Income Tax', format(IFNULL(vIncomeTax,0),0)),
                   (13, 'Other Tax', format(IFNULL(vOtherTax,0),0)),
                   (14, 'Profit(Loss)', format(IFNULL(vProfitLoss,0),0));

END $$

DELIMITER ;

#call stored procedures for INCOME STATEMENT
CALL pmusone2020_sp(2016); # the user can change the year 
	
SELECT * FROM pmusone2020_tmp; # SHOWING THE RESULTS











