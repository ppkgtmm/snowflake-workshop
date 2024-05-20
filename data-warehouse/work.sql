SELECT 'hello';

SELECT 'hello' AS "Greeting";

SHOW databases;

SHOW schemas;

CREATE OR REPLACE TABLE ROOT_DEPTH (ROOT_DEPTH_ID NUMBER(1), ROOT_DEPTH_CODE TEXT(1), ROOT_DEPTH_NAME TEXT(7), UNIT_OF_MEASURE TEXT(2), RANGE_MIN NUMBER(2), RANGE_MAX NUMBER(2));

ALTER TABLE GARDEN_PLANTS.FLOWERS.ROOT_DEPTH RENAME TO GARDEN_PLANTS.VEGGIES.ROOT_DEPTH;

-- USE WAREHOUSE COMPUTE_WH;

INSERT INTO ROOT_DEPTH (ROOT_DEPTH_ID, ROOT_DEPTH_CODE, ROOT_DEPTH_NAME, UNIT_OF_MEASURE, RANGE_MIN, RANGE_MAX)
VALUES (1, 'S', 'Shallow', 'cm', 30, 45);

SELECT *
FROM GARDEN_PLANTS.VEGGIES.ROOT_DEPTH;

INSERT INTO ROOT_DEPTH (ROOT_DEPTH_ID, ROOT_DEPTH_CODE, ROOT_DEPTH_NAME, UNIT_OF_MEASURE, RANGE_MIN, RANGE_MAX)
VALUES (2, 'M', 'Medium', 'cm', 45, 60), (3, 'D', 'Deep', 'cm', 60, 90);

CREATE TABLE garden_plants.veggies.vegetable_details (plant_name TEXT(25), root_depth_code TEXT(1));

SELECT *
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS
LIMIT 10;

SELECT *
FROM GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;

CREATE FILE FORMAT garden_plants.veggies.PIPECOLSEP_ONEHEADROW TYPE = 'CSV' field_delimiter = '|' skip_header = 1;

CREATE FILE FORMAT garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW TYPE = 'CSV' skip_header = 1 field_optionally_enclosed_by = '"';

SELECT *
FROM garden_plants.veggies.vegetable_details;

DELETE
FROM garden_plants.veggies.vegetable_details
WHERE plant_name = 'Spinach' AND root_depth_code = 'D';

SHOW FILE formats IN account;

USE ROLE accountadmin;

CREATE OR REPLACE api integration dora_api_integration api_provider = aws_api_gateway api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole' enabled = TRUE api_allowed_prefixes = ('https:--awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora');

USE ROLE accountadmin;

CREATE OR REPLACE EXTERNAL FUNCTION util_db.public.grader(step VARCHAR , passed BOOLEAN , actual INTEGER , expected INTEGER , description VARCHAR) RETURNS variant api_integration = dora_api_integration context_headers = (CURRENT_TIMESTAMP, current_account, current_statement, current_account_name) AS 'https:--awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader';

USE ROLE accountadmin;

USE DATABASE util_db;

USE SCHEMA PUBLIC;

SELECT grader(step, (actual = expected), actual, expected, description) AS graded_results
FROM
  (SELECT 'DORA_IS_WORKING' AS step ,
     (SELECT 123) AS actual ,
          123 AS expected ,
          'Dora IS working!' AS description);

SHOW functions IN account;

SELECT *
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA;

SELECT *
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME IN ('FLOWERS','FRUITS','VEGGIES');

SELECT COUNT(*) AS SCHEMAS_FOUND,
       '3' AS SCHEMAS_EXPECTED
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME IN ('FLOWERS','FRUITS','VEGGIES');

--You can run this code, OR you can USE the DROP lists IN your worksheet to get the context settings right.
USE DATABASE UTIL_DB;

USE SCHEMA PUBLIC;

USE ROLE ACCOUNTADMIN;

list @UTIL_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET;

list @UTIL_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET/this_;

list @UTIL_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET/THIS_;

CREATE OR REPLACE TABLE garden_plants.veggies.vegetable_details_soil_type (plant_name TEXT(25), soil_type NUMBER(1));

COPY INTO garden_plants.veggies.vegetable_details_soil_type
FROM @UTIL_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET files = ('VEG_NAME_TO_SOIL_TYPE_PIPE.txt') file_format = (format_name = GARDEN_PLANTS.VEGGIES.PIPECOLSEP_ONEHEADROW);

SELECT $1
FROM @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv;

SELECT $1,$2,$3
FROM @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv (file_format => garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW);

SELECT $1,$2,$3
FROM @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv (file_format => garden_plants.veggies.PIPECOLSEP_ONEHEADROW);

CREATE OR REPLACE FILE FORMAT garden_plants.veggies.L8_CHALLENGE_FF TYPE = CSV FIELD_DELIMITER = '\t' SKIP_HEADER = 1;

SELECT $1,$2,$3
FROM @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv (file_format => garden_plants.veggies.L8_CHALLENGE_FF);

CREATE OR REPLACE TABLE GARDEN_PLANTS.VEGGIES.LU_SOIL_TYPE(SOIL_TYPE_ID NUMBER, SOIL_TYPE TEXT(15), SOIL_DESCRIPTION TEXT(75));

COPY INTO GARDEN_PLANTS.VEGGIES.LU_SOIL_TYPE
FROM @util_db.public.like_a_window_into_an_s3_bucket files = ('LU_SOIL_TYPE.tsv') file_format = (format_name = garden_plants.veggies.L8_CHALLENGE_FF);

SELECT *
FROM GARDEN_PLANTS.VEGGIES.LU_SOIL_TYPE;

CREATE OR REPLACE TABLE GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS_PLANT_HEIGHT(plant_name TEXT(25), UOM TEXT(1), Low_End_of_Range NUMBER(2), High_End_of_Range NUMBER(2));

COPY INTO GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS_PLANT_HEIGHT
FROM @util_db.public.like_a_window_into_an_s3_bucket files = ('veg_plant_height.csv') file_format = (format_name = GARDEN_PLANTS.VEGGIES.COMMASEP_DBLQUOT_ONEHEADROW);

USE ROLE sysadmin;

-- CREATE a NEW DATABASE AND SET the context to USE the NEW DATABASE

CREATE DATABASE LIBRARY_CARD_CATALOG COMMENT = 'DWW Lesson 9 ';

USE DATABASE LIBRARY_CARD_CATALOG;

-- CREATE Author TABLE

CREATE OR REPLACE TABLE AUTHOR (AUTHOR_UID NUMBER ,FIRST_NAME VARCHAR(50) , MIDDLE_NAME VARCHAR(50) , LAST_NAME VARCHAR(50));

-- INSERT the FIRST two authors INTO the Author TABLE

INSERT INTO AUTHOR(AUTHOR_UID, FIRST_NAME, MIDDLE_NAME, LAST_NAME)
VALUES (1, 'Fiona', '','Macdonald'), (2, 'Gian','Paulo','Faleschini');

-- Look at your TABLE WITH it's NEW ROWS

SELECT * FROM AUTHOR;

USE ROLE sysadmin;

CREATE OR REPLACE SEQUENCE SEQ_AUTHOR_UID
START = 1 INCREMENT BY = 1 COMMENT = 'Use this to fill IN AUTHOR_UID';

--See how the nextval FUNCTION works

SELECT SEQ_AUTHOR_UID.nextval;

SHOW SEQUENCES;

USE ROLE sysadmin;

--Drop AND recreate the counter (SEQUENCE) so that it starts at 3
-- THEN we'll ADD the other author records to our author TABLE

CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_AUTHOR_UID" 
START 3 INCREMENT 1 COMMENT = 'Use this to fill IN the AUTHOR_UID every TIME you ADD a row';

--Add the remaining author records AND USE the nextval FUNCTION instead
--of putting IN the numbers

INSERT INTO AUTHOR(AUTHOR_UID, FIRST_NAME, MIDDLE_NAME, LAST_NAME)
VALUES (SEQ_AUTHOR_UID.nextval, 'Laura', 'K','Egendorf') ,
       (SEQ_AUTHOR_UID.nextval, 'Jan', '','Grover') ,
       (SEQ_AUTHOR_UID.nextval, 'Jennifer', '','Clapp') ,
       (SEQ_AUTHOR_UID.nextval, 'Kathleen', '','Petelinsek');

USE DATABASE LIBRARY_CARD_CATALOG;

-- CREATE a NEW SEQUENCE, this one will be a counter for the book TABLE

CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_BOOK_UID"
START 1 INCREMENT 1 COMMENT = 'Use this to fill IN the BOOK_UID everytime you ADD a row';

-- CREATE the book TABLE AND USE the NEXTVAL AS the
-- DEFAULT VALUE EACH TIME a ROW IS added to the TABLE

CREATE OR REPLACE TABLE BOOK (BOOK_UID NUMBER DEFAULT SEQ_BOOK_UID.nextval , TITLE VARCHAR(50) , YEAR_PUBLISHED NUMBER(4, 0));

-- INSERT records INTO the book TABLE
-- You don't have to list anything for the
-- BOOK_UID field because the DEFAULT setting
-- will take care of it for you

INSERT INTO BOOK(TITLE, YEAR_PUBLISHED) 
VALUES ('Food',2001), ('Food',2006), ('Food',2008), ('Food',2016), ('Food',2015);

-- CREATE the relationships TABLE
-- this IS sometimes called a "Many-to-Many table"

CREATE TABLE BOOK_TO_AUTHOR (BOOK_UID NUMBER ,AUTHOR_UID NUMBER);

--Insert ROWS of the known relationships

INSERT INTO BOOK_TO_AUTHOR(BOOK_UID, AUTHOR_UID)
VALUES (1,1),-- This ROW links the 2001 book to Fiona Macdonald
       (1,2),-- This ROW links the 2001 book to Gian Paulo Faleschini
       (2,3),-- Links 2006 book to Laura K Egendorf
       (3,4),-- Links 2008 book to Jan Grover
       (4,5),-- Links 2016 book to Jennifer Clapp
       (5,6); -- Links 2015 book to Kathleen Petelinsek

--Check your work BY joining the 3 tables together
--You should get 1 ROW for every author

SELECT *
FROM book_to_author ba
JOIN author a ON ba.author_uid = a.author_uid
JOIN book b ON b.book_uid=ba.book_uid;

-- JSON DDL Scripts
USE LIBRARY_CARD_CATALOG;

-- CREATE an Ingestion TABLE for JSON Data

CREATE TABLE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_JSON (RAW_AUTHOR VARIANT);

--Create FILE FORMAT for JSON Data

CREATE OR REPLACE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT TYPE = 'JSON' COMPRESSION = 'AUTO' ENABLE_OCTAL = FALSE ALLOW_DUPLICATE = FALSE STRIP_OUTER_ARRAY = TRUE STRIP_NULL_VALUES = FALSE IGNORE_UTF8_ERRORS = FALSE;

list @util_db.public.like_a_window_into_an_s3_bucket;

COPY INTO LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_JSON
FROM @util_db.public.like_a_window_into_an_s3_bucket files = ('author_with_header.json') file_format = (format_name = LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT);

SELECT *
FROM author_ingest_json;

SELECT raw_author:AUTHOR_UID
FROM author_ingest_json;


SELECT raw_author:AUTHOR_UID::TEXT, raw_author:FIRST_NAME::TEXT, raw_author:LAST_NAME::TEXT, raw_author:MIDDLE_NAME::TEXT
FROM author_ingest_json;

-- CREATE an Ingestion TABLE for the NESTED JSON Data

CREATE OR REPLACE TABLE LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON ("RAW_NESTED_BOOK" VARIANT);

COPY INTO LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON
FROM @util_db.public.like_a_window_into_an_s3_bucket files = ('json_book_author_nested.json') file_format = (format_name = LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT);

--a few simple queries

SELECT RAW_NESTED_BOOK
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:authors
FROM NESTED_INGEST_JSON;

SELECT VALUE:first_name
FROM NESTED_INGEST_JSON,
LATERAL FLATTEN(RAW_NESTED_BOOK:authors);

SELECT VALUE:first_name
FROM nested_ingest_json,
TABLE(flatten(raw_nested_book:authors));

SELECT VALUE:first_name::TEXT first_nm, VALUE:last_name::TEXT last_nm
FROM NESTED_INGEST_JSON,
LATERAL FLATTEN(RAW_NESTED_BOOK:authors);

--Create a NEW DATABASE to hold the Twitter FILE

CREATE DATABASE SOCIAL_MEDIA_FLOODGATES COMMENT = "There\'s so much data FROM social media - flood warning";

USE DATABASE SOCIAL_MEDIA_FLOODGATES;

--Create a TABLE IN the NEW DATABASE

CREATE TABLE SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST ("RAW_STATUS" VARIANT) COMMENT = 'Bring IN tweets, one ROW per tweet OR status entity';

--Create a JSON FILE FORMAT IN the NEW DATABASE

CREATE FILE FORMAT SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT TYPE = 'JSON' COMPRESSION = 'AUTO' ENABLE_OCTAL = FALSE ALLOW_DUPLICATE = FALSE STRIP_OUTER_ARRAY = TRUE STRIP_NULL_VALUES = FALSE IGNORE_UTF8_ERRORS = FALSE;

COPY INTO SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST
FROM @UTIL_DB.PUBLIC.LIKE_A_WINDOW_INTO_AN_S3_BUCKET files = ('nutrition_tweets.json') file_format = SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT;

SELECT raw_status:entities:hashtags[0].text
FROM tweet_ingest
WHERE raw_status:entities:hashtags[0].text IS NOT NULL;

SELECT raw_status:created_at::DATE
FROM tweet_ingest
ORDER BY raw_status:created_at::DATE;

SELECT raw_status:USER:ID user_id, raw_status:ID tweet_id, VALUE:TEXT::TEXT hashtag_text
FROM tweet_ingest,
LATERAL flatten(raw_status:entities:hashtags);

CREATE OR REPLACE VIEW SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED AS
SELECT raw_status:USER:ID user_id, raw_status:ID tweet_id, VALUE:TEXT::TEXT hashtag_text
FROM tweet_ingest,
LATERAL flatten(raw_status:entities:hashtags);
