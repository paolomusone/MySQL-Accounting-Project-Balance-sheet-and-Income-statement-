



#####################
### BALANCE SHEET ###
#####################
use H_Accounting;

#dropping the previous table and procedures
DROP PROCEDURE IF EXISTS pmusone2020_sp;
DROP TABLE IF EXISTS pmusone2020_tmp;

-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$
#creating the procedure
	CREATE PROCEDURE pmusone2020_sp (varCalendarYear SMALLINT)
	BEGIN
  
	-- Define variables inside procedure
    DECLARE vCurrentAssets 			DOUBLE DEFAULT 0;
    DECLARE vFixedAssets 			DOUBLE DEFAULT 0;
    DECLARE vDeferredAssets 		DOUBLE DEFAULT 0;
    DECLARE vCurrentLiabilities		DOUBLE DEFAULT 0;
    DECLARE vLongTermLiabilities 	DOUBLE DEFAULT 0;
    DECLARE vDeferredLiabilities 	DOUBLE DEFAULT 0;
    DECLARE vEquity				    DOUBLE DEFAULT 0;
    DECLARE vTotalAssets		    DOUBLE DEFAULT 0;
    DECLARE vTotalLiabilities		DOUBLE DEFAULT 0;
    DECLARE vEquityLiability		DOUBLE DEFAULT 0;

	-- Calculate the value and store them into the variables declared
    #vCurrentAssets
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vCurrentAssets
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
         #restrctions    
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CA'
            AND je.debit_credit_balanced = 1;

    #vFixedAssets
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vFixedAssets
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'FA'
            AND je.debit_credit_balanced = 1;		

    #vDeferredAssets
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vDeferredAssets
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
         #restrctions    
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DA'
            AND je.debit_credit_balanced = 1;

    #vCurrentLiabilities
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vCurrentLiabilities
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CL'
            AND je.debit_credit_balanced = 1;	

    #vLongTermLiabilities
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vLongTermLiabilities
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'LLL'
            AND je.debit_credit_balanced = 1;	

    #vDeferredLiabilities 	
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vDeferredLiabilities
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
         #restrctions    
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DL'
            AND je.debit_credit_balanced = 1;

    #vEquity	
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vEquity
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'EQ'
            AND je.debit_credit_balanced = 1;	

    #vTotalAssets
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vTotalAssets
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	

    #vTotalLiabilities
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vTotalLiabilities
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
          #restrctions   
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CL','LLL','DL')
            AND je.debit_credit_balanced = 1;	
	
        #vTotalEquityLiabibilities
	SELECT SUM(IFNULL(joen.credit,0)- IFNULL(joen.debit,0)) INTO vEquityLiability
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
        #restrctions     
		WHERE YEAR(je.entry_date) = varCalendarYear # the procedure will change based on the year chosen
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code NOT IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	
            
	-- Creating the BalanceSheet table
	CREATE TABLE pmusone2020_tmp
		(	balance_sheet_line_number INT, 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
	-- Insert the header for the report
	INSERT INTO pmusone2020_tmp 
			(balance_sheet_line_number, label, amount)
			VALUES (1, 'BALANCE SHEET', "In USD"),
				   (2, '', ''),
				   (3, 'Current Assets', format(IFNULL(vCurrentAssets, 0),0)),
                   (4, 'Fixed Assets', format(IFNULL(vFixedAssets, 0),0)),
                   (5, 'Deferred Assets', format(IFNULL(vDeferredAssets, 0),0)),
                   (6, 'Total Assets', format(IFNULL(vTotalAssets, 0),0)),
                   (7, 'Current Liabilities', format(IFNULL(vCurrentLiabilities, 0),0)),
                   (8, 'Long-term Liabilities', format(IFNULL(vLongTermLiabilities, 0),0)),
                   (9, 'Deferred Liabilities' , format(IFNULL(vDeferredLiabilities, 0),0)),
                   (10, 'Total Liabilities', format(IFNULL(vTotalLiabilities, 0),0)),
                   (11, 'Equity', format(IFNULL(vEquity, 0),0)),
                   (12, 'Total Equity and Liabilities', format(IFNULL(vEquityLiability, 0),0));
            
  END $$

DELIMITER ;          


#call stored procedures for BALANCE SHEET
CALL pmusone2020_sp(2016); # the user can change the year
	
SELECT * FROM pmusone2020_tmp;  #SHOWING THE RESULTS












  
	