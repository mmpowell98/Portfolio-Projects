CREATE DATABASE care_expediture;
--AMOUNT ($BILLIONS)
CREATE TABLE amount_billions (
 			"Year" INT,
 			"Total" NUMERIC(19,2),
 			"Out of Pocket" NUMERIC(19,2),
 			"Health Insurance" NUMERIC(19,2),
 			"Private Health Insurance" NUMERIC(19,2),
 			"Medicare" NUMERIC(19,2),
 			"Medicaid" NUMERIC(19,2),	
 			"Other Health Insurance Programs" NUMERIC(19,2),
 			"Other Third Party Payers" NUMERIC(19,2)
            );
COPY amount_billions FROM '/Users/morganpowell/Desktop/Portfolio/SQL/HospitalCareExpenditures/Amount_Billions.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM amount_billions;
-- PERCENT CHANGE
CREATE TABLE percent_change (
 			"Year" INT,
 			"Total" NUMERIC(19,2),
 			"Out of Pocket" NUMERIC(19,2),
 			"Health Insurance" NUMERIC(19,2),
 			"Private Health Insurance" NUMERIC(19,2),
 			"Medicare" NUMERIC(19,2),
 			"Medicaid" NUMERIC(19,2),	
 			"Other Health Insurance Programs" NUMERIC(19,2),
 			"Other Third Party Payers" NUMERIC(19,2)
            ); 
COPY percent_change FROM '/Users/morganpowell/Desktop/Portfolio/SQL/HospitalCareExpenditures/Average_Annual_%_Change.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM percent_change;
--PERCENT DISTRIBUTION
CREATE TABLE percent_distribution (
 			"Year" INT,
 			"Total" NUMERIC(19,2),
 			"Out of Pocket" NUMERIC(19,2),
 			"Health Insurance" NUMERIC(19,2),
 			"Private Health Insurance" NUMERIC(19,2),
 			"Medicare" NUMERIC(19,2),
 			"Medicaid" NUMERIC(19,2),	
 			"Other Health Insurance Programs" NUMERIC(19,2),
 			"Other Third Party Payers" NUMERIC(19,2)
            ); 
COPY percent_distribution FROM '/Users/morganpowell/Desktop/Portfolio/SQL/HospitalCareExpenditures/Percent_Distribution.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM percent_distribution;
-- WHAT YEAR WAS HEALTH EXPENDITURE THE HIGHEST?
SELECT * FROM amount_billions
WHERE
  "Total" = (
    SELECT
      MAX ("Total")
    FROM
      amount_billions
  ); --2023 HAD THE HIGHEST TOTAL HEALTH EXPENDITURE (1,519.7 BILLION)
--WHAT PLAN HAD HIGHEST EXPENDITURE IN 2023
SELECT "Year","Out of Pocket","Private Health Insurance","Medicare","Medicaid","Other Health Insurance Programs","Other Third Party Payers", GREATEST("Out of Pocket","Private Health Insurance","Medicare","Medicaid","Other Health Insurance Programs","Other Third Party Payers") AS max_value_in_row
FROM amount_billions
WHERE "Year"=2023; --PRIVATE HEALTH INSURANCE HAD THE HIGHEST EXPENDITURE IN 2023 (559.4 BILLION)
--WHAT YEAR HAD THE HIGHEST TOTAL PERCENT CHANGE FROM THE PREVIOUS YEAR
SELECT "Year", "Total" AS greatest_percent_change FROM percent_change
WHERE
  "Total" = (
    SELECT
      MAX ("Total")
    FROM
      percent_change
  ); -- 1970-1980 HAD THE HIGHEST AVERAGE ANNUAL PERCENT CHANGE IN TOTAL HEALTHCARE EXPENDITURE (14%)
 -- IN 1980, WHAT WAS THE PERCENT DISTIBUTION OF MEDICAID, MEDICARE AND PRIVATE HEALTH INSURANCE
 SELECT "Medicaid", "Medicare", "Private Health Insurance" FROM percent_distribution
 WHERE "Year" = 1980; --35.9% PRIVATE, 26.1% MEDICARE, 9,2% MEDICAID
