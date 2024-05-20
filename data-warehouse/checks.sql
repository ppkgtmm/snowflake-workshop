--Remember that every TIME you run a DORA CHECK, the context needs to be SET to the below settings. 
USE DATABASE UTIL_DB;

USE SCHEMA PUBLIC;

USE role ACCOUNTADMIN;

--Do NOT EDIT ANYTHING BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT
 'DWW01' AS step
 ,( SELECT COUNT(*)  
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA 
   WHERE schema_name IN ('FLOWERS','VEGGIES','FRUITS')) AS actual
  ,3 AS expected
  ,'Created 3 Garden Plant schemas' AS description
); 

--Do NOT EDIT ANYTHING BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW02' AS step 
 ,( SELECT COUNT(*) 
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA 
   WHERE schema_name = 'PUBLIC') AS actual 
 , 0 AS expected 
 ,'Deleted PUBLIC schema.' AS description
); 

-- DO NOT EDIT ANYTHING BELOW THIS LINE 
-- Remember to SET your WORKSHEET context (DO NOT ADD context to the grader call)
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW03' AS step 
 ,( SELECT COUNT(*) 
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   WHERE table_name = 'ROOT_DEPTH') AS actual 
 , 1 AS expected 
 ,'ROOT_DEPTH TABLE Exists' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW04' AS step
 ,( SELECT COUNT(*) AS SCHEMAS_FOUND 
   FROM UTIL_DB.INFORMATION_SCHEMA.SCHEMATA) AS actual
 , 2 AS expected
 , 'UTIL_DB Schemas' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW05' AS step
 ,( SELECT COUNT(*) 
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   WHERE table_name = 'VEGETABLE_DETAILS') AS actual
 , 1 AS expected
 ,'VEGETABLE_DETAILS Table' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM ( 
 SELECT 'DWW06' AS step 
,( SELECT ROW_COUNT 
  FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
  WHERE table_name = 'ROOT_DEPTH') AS actual 
, 3 AS expected 
,'ROOT_DEPTH ROW count' AS description
);  

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW07' AS step
 ,( SELECT ROW_COUNT 
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   WHERE table_name = 'VEGETABLE_DETAILS') AS actual
 , 41 AS expected
 , 'VEG_DETAILS ROW count' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM ( 
   SELECT 'DWW08' AS step 
   ,( SELECT COUNT(*) 
     FROM GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
     WHERE FIELD_DELIMITER =',' 
     AND FIELD_OPTIONALLY_ENCLOSED_BY ='"') AS actual 
   , 1 AS expected 
   , 'File FORMAT 1 Exists' AS description 
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW09' AS step
 ,( SELECT COUNT(*) 
   FROM GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
   WHERE FIELD_DELIMITER ='|' 
   ) AS actual
 , 1 AS expected
 ,'File FORMAT 2 Exists' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
 SELECT 'DWW10' AS step
  ,( SELECT COUNT(*) 
    FROM UTIL_DB.INFORMATION_SCHEMA.stages
    WHERE stage_url='s3://uni-lab-files' 
    AND stage_type='External Named') AS actual
  , 1 AS expected
  , 'External stage created' AS description
);

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT 'DWW11' AS step
  ,( SELECT ROW_COUNT 
    FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
    WHERE table_name = 'VEGETABLE_DETAILS_SOIL_TYPE') AS actual
  , 42 AS expected
  , 'Veg Det Soil TYPE Count' AS description
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
      SELECT 'DWW12' AS step 
      ,( SELECT ROW_COUNT 
        FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
        WHERE table_name = 'VEGETABLE_DETAILS_PLANT_HEIGHT') AS actual 
      , 41 AS expected 
      , 'Veg Detail Plant Height Count' AS description   
); 

--Set your worksheet DROP list role to ACCOUNTADMIN
--Set your worksheet DROP list DATABASE AND SCHEMA to the LOCATION of your GRADER FUNCTION

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
     SELECT 'DWW13' AS step 
     ,( SELECT ROW_COUNT 
       FROM GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
       WHERE table_name = 'LU_SOIL_TYPE') AS actual 
     , 8 AS expected 
     ,'Soil TYPE Look Up Table' AS description   
); 

-- SET your worksheet DROP lists
-- DO NOT EDIT THE CODE 
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM ( 
     SELECT 'DWW14' AS step 
     ,( SELECT COUNT(*) 
       FROM GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
       WHERE FILE_FORMAT_NAME='L8_CHALLENGE_FF' 
       AND FIELD_DELIMITER = '\t') AS actual 
     , 1 AS expected 
     ,'Challenge FILE FORMAT Created' AS description  
);

-- SET your worksheet DROP lists
-- DO NOT EDIT THE CODE 
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
     SELECT 'DWW15' AS step 
     ,( SELECT COUNT(*) 
      FROM LIBRARY_CARD_CATALOG.PUBLIC.Book_to_Author ba 
      JOIN LIBRARY_CARD_CATALOG.PUBLIC.author a 
      ON ba.author_uid = a.author_uid 
      JOIN LIBRARY_CARD_CATALOG.PUBLIC.book b 
      ON b.book_uid=ba.book_uid) AS actual 
     , 6 AS expected 
     , '3NF DB was Created.' AS description  
); 

-- SET your worksheet DROP lists. DO NOT EDIT THE DORA CODE.
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
(
  SELECT 'DWW16' AS step
  ,( SELECT ROW_COUNT 
    FROM LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
    WHERE table_name = 'AUTHOR_INGEST_JSON') AS actual
  ,6 AS expected
  ,'Check NUMBER of rows' AS description
);

-- SET your worksheet DROP lists. DO NOT EDIT THE DORA CODE.
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (   
     SELECT 'DWW17' AS step 
      ,( SELECT ROW_COUNT 
        FROM LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
        WHERE table_name = 'NESTED_INGEST_JSON') AS actual 
      , 5 AS expected 
      ,'Check NUMBER of rows' AS description  
); 

-- SET your worksheet DROP lists. DO NOT EDIT THE DORA CODE.
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
(
   SELECT 'DWW18' AS step
  ,( SELECT ROW_COUNT 
    FROM SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.TABLES 
    WHERE table_name = 'TWEET_INGEST') AS actual
  , 9 AS expected
  ,'Check NUMBER of rows' AS description  
); 

-- SET your worksheet DROP lists. DO NOT EDIT THE DORA CODE.

SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
(
  SELECT 'DWW19' AS step
  ,( SELECT COUNT(*) 
    FROM SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.VIEWS 
    WHERE table_name = 'HASHTAGS_NORMALIZED') AS actual
  , 1 AS expected
  ,'Check NUMBER of rows' AS description
); 
