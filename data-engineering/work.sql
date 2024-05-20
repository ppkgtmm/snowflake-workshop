ALTER USER PKGTM1998
SET default_role = 'SYSADMIN';

ALTER USER PKGTM1998
SET default_warehouse = 'COMPUTE_WH';

ALTER USER PKGTM1998
SET default_namespace = 'UTIL_DB.PUBLIC';

USE ROLE accountadmin;

CREATE OR REPLACE api integration dora_api_integration 
api_provider = aws_api_gateway 
api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole' 
enabled = TRUE 
api_allowed_prefixes = ('https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora');

SHOW integrations;

USE ROLE accountadmin;

CREATE OR REPLACE EXTERNAL FUNCTION util_db.public.grader (step VARCHAR, passed BOOLEAN, actual INTEGER, expected INTEGER, description VARCHAR) RETURNS variant 
api_integration = dora_api_integration 
context_headers = (CURRENT_TIMESTAMP, current_account, current_statement, current_account_name) AS 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader';

USE ROLE accountadmin;

SELECT util_db.public.grader(step, (actual = expected), actual, expected, description) AS graded_results
FROM
  (SELECT 'DORA_IS_WORKING' AS step,
     (SELECT 123) AS actual,
          123 AS expected,
          'Dora IS working!' AS description);

list @uni_kishore;

SELECT $1
FROM @uni_kishore/kickoff (file_format => ff_json_logs);

COPY INTO game_logs
FROM @uni_kishore/kickoff file_format = ff_json_logs;

CREATE VIEW logs AS
SELECT raw_log:agent::TEXT agent, raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601, raw_log:user_event::TEXT user_event, raw_log:user_login::TEXT user_login, raw_log
FROM game_logs;

SELECT *
FROM logs;

SELECT CURRENT_TIMESTAMP();

--what TIME ZONE IS your account(and/or session) currently SET to? IS it -0700?

SELECT CURRENT_TIMESTAMP();

--worksheets ARE sometimes called sessions -- we'll be changing the worksheet TIME ZONE
 
ALTER SESSION
SET timezone = 'UTC';

SELECT CURRENT_TIMESTAMP();

--how did the TIME differ after changing the TIME ZONE for the worksheet?

ALTER SESSION
SET timezone = 'Africa/Nairobi';

SELECT CURRENT_TIMESTAMP();

ALTER SESSION
SET timezone = 'Pacific/Funafuti';

SELECT CURRENT_TIMESTAMP();

ALTER SESSION
SET timezone = 'Asia/Shanghai';

SELECT CURRENT_TIMESTAMP();

--show the account parameter called timezone
 SHOW PARAMETERS LIKE 'timezone';

COPY INTO game_logs
FROM @uni_kishore/updated_feed file_format = ff_json_logs;

CREATE OR REPLACE VIEW logs AS
SELECT raw_log:ip_address::TEXT ip_address, raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601, raw_log:user_event::TEXT user_event, raw_log:user_login::TEXT user_login, raw_log
FROM game_logs
WHERE raw_log:agent IS NULL;

SELECT *
FROM logs
WHERE user_login ilike '%prajina%';

SELECT parse_ip('100.41.16.160', 'inet'):host::TEXT HOST, parse_ip('100.41.16.160', 'inet'):ipv4::NUMBER ipv4;

CREATE SCHEMA ENHANCED;

SELECT logs.*, loc.city, loc.region, loc.country, loc.timezone
FROM ipinfo_geoloc.demo.location loc
JOIN AGS_GAME_AUDIENCE.RAW.LOGS logs
WHERE parse_ip(logs.ip_address, 'inet'):ipv4 BETWEEN start_ip_int AND end_ip_int;

--a Look Up TABLE to convert FROM HOUR NUMBER to "time of DAY name"

CREATE TABLE ags_game_audience.raw.time_of_day_lu (HOUR NUMBER, tod_name VARCHAR(25));

--insert statement to ADD all 24 ROWS to the TABLE

INSERT INTO time_of_day_lu
VALUES (6, 'Early morning'),
       (7, 'Early morning'),
       (8, 'Early morning'),
       (9, 'Mid-morning'),
       (10, 'Mid-morning'),
       (11, 'Late morning'),
       (12, 'Late morning'),
       (13, 'Early afternoon'),
       (14, 'Early afternoon'),
       (15, 'Mid-afternoon'),
       (16, 'Mid-afternoon'),
       (17, 'Late afternoon'),
       (18, 'Late afternoon'),
       (19, 'Early evening'),
       (20, 'Early evening'),
       (21, 'Late evening'),
       (22, 'Late evening'),
       (23, 'Late evening'),
       (0, 'Late at night'),
       (1, 'Late at night'),
       (2, 'Late at night'),
       (3, 'Toward morning'),
       (4, 'Toward morning'),
       (5, 'Toward morning');

SELECT tod_name, listagg(HOUR, ',')
FROM time_of_day_lu
GROUP BY tod_name;

CREATE TABLE ags_game_audience.enhanced.logs_enhanced AS
SELECT logs.ip_address,
       logs.user_login GAMER_NAME,
       logs.user_event GAME_EVENT_NAME,
       logs.datetime_iso8601 GAME_EVENT_UTC,
       city,
       region,
       country,
       timezone GAMER_LTZ_NAME,
       convert_timezone('UTC', timezone, datetime_iso8601) GAME_EVENT_LTZ,
       dayname(convert_timezone('UTC', timezone, datetime_iso8601)) DOW_NAME,
       tod_name
FROM ipinfo_geoloc.demo.location loc
JOIN AGS_GAME_AUDIENCE.RAW.LOGS logs ON loc.join_key = ipinfo_geoloc.public.to_join_key(logs.ip_address)
AND ipinfo_geoloc.public.to_int(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
JOIN time_of_day_lu tod ON tod.hour = HOUR(convert_timezone('UTC', timezone, datetime_iso8601));

SELECT *
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

USE ROLE accountadmin;

--You have to run this grant OR you won't be able to test your tasks while IN SYSADMIN role
 --this IS TRUE even IF SYSADMIN owns the task!!
GRANT EXECUTE task ON account TO ROLE SYSADMIN;

USE ROLE sysadmin;

EXECUTE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

SHOW tasks IN account;

DESCRIBE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
warehouse = COMPUTE_WH
schedule = '5 minute' AS 
TRUNCATE TABLE ags_game_audience.enhanced.LOGS_ENHANCED;

INSERT INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
SELECT logs.ip_address,
       logs.user_login GAMER_NAME,
       logs.user_event GAME_EVENT_NAME,
       logs.datetime_iso8601 GAME_EVENT_UTC,
       city,
       region,
       country,
       timezone GAMER_LTZ_NAME,
       convert_timezone('UTC', timezone, datetime_iso8601) GAME_EVENT_LTZ,
       dayname(convert_timezone('UTC', timezone, datetime_iso8601)) DOW_NAME,
       tod_name
FROM ipinfo_geoloc.demo.location loc
JOIN AGS_GAME_AUDIENCE.RAW.LOGS logs ON loc.join_key = ipinfo_geoloc.public.to_join_key(logs.ip_address)
AND ipinfo_geoloc.public.to_int(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
JOIN time_of_day_lu tod ON tod.hour = HOUR(convert_timezone('UTC', timezone, datetime_iso8601));

SELECT COUNT(*)
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

EXECUTE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

SELECT COUNT(*)
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

--first we dump all the ROWS out of the TABLE
TRUNCATE TABLE ags_game_audience.enhanced.LOGS_ENHANCED;

--then we put them all back IN

INSERT INTO ags_game_audience.enhanced.LOGS_ENHANCED (
    SELECT logs.ip_address, logs.user_login AS GAMER_NAME, logs.user_event AS GAME_EVENT_NAME, logs.datetime_iso8601 AS GAME_EVENT_UTC, city, region, country, timezone AS GAMER_LTZ_NAME, CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz, DAYNAME(game_event_ltz) AS DOW_NAME, TOD_NAME
    FROM ags_game_audience.raw.LOGS logs
    JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
);

CREATE TABLE ags_game_audience.enhanced.LOGS_ENHANCED_UF clone ags_game_audience.enhanced.LOGS_ENHANCED;

MERGE INTO ENHANCED.LOGS_ENHANCED e USING RAW.LOGS r ON r.user_login = e.GAMER_NAME
AND r.datetime_iso8601 = e.game_event_utc
AND r.user_event = e.game_event_name 
WHEN MATCHED THEN
UPDATE
SET IP_ADDRESS = 'Hey I updated matching rows!';

SELECT *
FROM ENHANCED.LOGS_ENHANCED;

TRUNCATE TABLE ENHANCED.LOGS_ENHANCED;

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
warehouse = 'COMPUTE_WH' 
schedule = '5 minute' AS
MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
    SELECT logs.ip_address,
          logs.user_login AS GAMER_NAME,
          logs.user_event AS GAME_EVENT_NAME,
          logs.datetime_iso8601 AS GAME_EVENT_UTC,
          city,
          region,
          country,
          timezone AS GAMER_LTZ_NAME,
          CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz,
          DAYNAME(game_event_ltz) AS DOW_NAME,
          TOD_NAME
   FROM ags_game_audience.raw.LOGS logs
   JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
   AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
   JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
   ) r ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME)
VALUES (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME);

EXECUTE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

CREATE OR REPLACE TABLE AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS (RAW_LOG VARIANT);

COPY INTO AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE file_format = AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS;

SELECT COUNT(1)
FROM AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
-- warehouse = 'COMPUTE_WH'
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
schedule = '5 minute' AS 
COPY INTO AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE 
file_format = AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS;

EXECUTE task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES;

CREATE OR REPLACE VIEW AGS_GAME_AUDIENCE.RAW.PL_LOGS(IP_ADDRESS, DATETIME_ISO8601, USER_EVENT, USER_LOGIN, RAW_LOG) AS
SELECT raw_log:ip_address::TEXT ip_address, raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601, raw_log:user_event::TEXT user_event, raw_log:user_login::TEXT user_login, raw_log
FROM AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
WHERE raw_log:agent IS NULL;

SELECT *
FROM AGS_GAME_AUDIENCE.RAW.PL_LOGS;

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED 
-- warehouse = 'COMPUTE_WH'
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
-- schedule = '5 minute'
AFTER AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES AS
MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
    SELECT logs.ip_address,
          logs.user_login AS GAMER_NAME,
          logs.user_event AS GAME_EVENT_NAME,
          logs.datetime_iso8601 AS GAME_EVENT_UTC,
          city,
          region,
          country,
          timezone AS GAMER_LTZ_NAME,
          CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz,
          DAYNAME(game_event_ltz) AS DOW_NAME,
          TOD_NAME
   FROM ags_game_audience.raw.pl_logs logs
   JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
   AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
   JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
   ) r 
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME)
VALUES (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME);

EXECUTE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

SELECT *
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

TRUNCATE TABLE ENHANCED.LOGS_ENHANCED;

--Turning ON a task IS done WITH a RESUME command

ALTER task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;

ALTER task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;

--Turning OFF a task IS done WITH a SUSPEND command

ALTER task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;

ALTER task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;

SELECT COUNT(*)
FROM AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;

SELECT COUNT(*)
FROM AGS_GAME_AUDIENCE.RAW.PL_LOGS;

SELECT COUNT(*)
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

USE ROLE accountadmin;

GRANT EXECUTE MANAGED TASK ON account TO SYSADMIN;

--switch back to sysadmin
 USE ROLE sysadmin;

CREATE TABLE ED_PIPELINE_LOGS AS
SELECT METADATA$FILENAME AS log_file_name, --new metadata COLUMN
       METADATA$FILE_ROW_NUMBER AS log_file_row_id, --new metadata COLUMN
       CURRENT_TIMESTAMP(0) AS load_ltz, --new LOCAL TIME of load
       get($1, 'datetime_iso8601')::timestamp_ntz AS DATETIME_ISO8601,
       get($1, 'user_event')::TEXT AS USER_EVENT,
       get($1, 'user_login')::TEXT AS USER_LOGIN,
       get($1, 'ip_address')::TEXT AS IP_ADDRESS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE (file_format => 'ff_json_logs');


CREATE OR REPLACE TABLE AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS (
    LOG_FILE_NAME VARCHAR(100), 
    LOG_FILE_ROW_ID NUMBER(18, 0), 
    LOAD_LTZ TIMESTAMP_LTZ(0), 
    DATETIME_ISO8601 TIMESTAMP_NTZ(9), 
    USER_EVENT VARCHAR(25), 
    USER_LOGIN VARCHAR(100), 
    IP_ADDRESS VARCHAR(100)
);

COPY INTO AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS
FROM (
    SELECT METADATA$FILENAME AS log_file_name, --new metadata COLUMN
          METADATA$FILE_ROW_NUMBER AS log_file_row_id, --new metadata COLUMN
          CURRENT_TIMESTAMP(0) AS load_ltz, --new LOCAL TIME of load
          get($1, 'datetime_iso8601')::timestamp_ntz AS DATETIME_ISO8601,
          get($1, 'user_event')::TEXT AS USER_EVENT,
          get($1, 'user_login')::TEXT AS USER_LOGIN,
          get($1, 'ip_address')::TEXT AS IP_ADDRESS
   FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
) 
file_format = 'ff_json_logs';


CREATE OR REPLACE PIPE PIPE_GET_NEW_FILES
auto_ingest = TRUE 
aws_sns_topic = 'arn:aws:sns:us-west-2:321463406630:dngw_topic' AS 
COPY INTO ED_PIPELINE_LOGS
FROM (
    SELECT METADATA$FILENAME AS log_file_name,
          METADATA$FILE_ROW_NUMBER AS log_file_row_id,
          CURRENT_TIMESTAMP(0) AS load_ltz,
          get($1, 'datetime_iso8601')::timestamp_ntz AS DATETIME_ISO8601,
          get($1, 'user_event')::TEXT AS USER_EVENT,
          get($1, 'user_login')::TEXT AS USER_LOGIN,
          get($1, 'ip_address')::TEXT AS IP_ADDRESS
   FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
) 
file_format = (format_name = ff_json_logs);


CREATE TABLE AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED_BACKUP
clone AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

TRUNCATE TABLE AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED 
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' 
schedule = '5 minutes' 
-- after AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
AS
MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
    SELECT logs.ip_address,
          logs.user_login AS GAMER_NAME,
          logs.user_event AS GAME_EVENT_NAME,
          logs.datetime_iso8601 AS GAME_EVENT_UTC,
          city,
          region,
          country,
          timezone AS GAMER_LTZ_NAME,
          CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz,
          DAYNAME(game_event_ltz) AS DOW_NAME,
          TOD_NAME
    FROM ags_game_audience.raw.ED_PIPELINE_LOGS logs
    JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
   ) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME)
VALUES (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME);

ALTER task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;

SELECT parse_json(SYSTEM$PIPE_STATUS('ags_game_audience.raw.PIPE_GET_NEW_FILES'));

ALTER task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

--create a stream that will keep track of changes to the TABLE

CREATE OR REPLACE stream ags_game_audience.raw.ed_cdc_stream ON TABLE AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS;

--look at the stream you created
SHOW streams;

--check to see IF ANY changes ARE pending (expect FALSE the FIRST TIME you run it)
 --after the Snowpipe loads a NEW FILE, expect to see TRUE

SELECT system$stream_has_data('ed_cdc_stream');

ALTER task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

--query the stream

SELECT *
FROM ags_game_audience.raw.ed_cdc_stream;

--check to see IF ANY changes ARE pending

SELECT system$stream_has_data('ed_cdc_stream');

--if your stream remains EMPTY for more than 10 minutes, make sure your PIPE IS running

SELECT SYSTEM$PIPE_STATUS('PIPE_GET_NEW_FILES');

MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
    SELECT cdc.ip_address,
          cdc.user_login AS GAMER_NAME,
          cdc.user_event AS GAME_EVENT_NAME,
          cdc.datetime_iso8601 AS GAME_EVENT_UTC,
          city,
          region,
          country,
          timezone AS GAMER_LTZ_NAME,
          CONVERT_TIMEZONE('UTC', timezone, cdc.datetime_iso8601) AS game_event_ltz,
          DAYNAME(game_event_ltz) AS DOW_NAME,
          TOD_NAME
   FROM ags_game_audience.raw.ed_cdc_stream cdc
   JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
   AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) BETWEEN start_ip_int AND end_ip_int
   JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
   ) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME)
VALUES (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME);

SELECT *
FROM ags_game_audience.raw.ed_cdc_stream;

SELECT *
FROM ENHANCED.LOGS_ENHANCED;

--Create a NEW task that uses the MERGE you just tested

CREATE OR REPLACE task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
SCHEDULE = '5 minutes'
WHEN system$stream_has_data('ags_game_audience.raw.ed_cdc_stream') AS
MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e USING (
    SELECT cdc.ip_address,
          cdc.user_login AS GAMER_NAME,
          cdc.user_event AS GAME_EVENT_NAME,
          cdc.datetime_iso8601 AS GAME_EVENT_UTC,
          city,
          region,
          country,
          timezone AS GAMER_LTZ_NAME,
          CONVERT_TIMEZONE('UTC', timezone, cdc.datetime_iso8601) AS game_event_ltz,
          DAYNAME(game_event_ltz) AS DOW_NAME,
          TOD_NAME
    FROM ags_game_audience.raw.ed_cdc_stream cdc
    JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
) r 
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME)
VALUES (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME);

--Resume the task so it IS running

ALTER task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED resume;

ALTER pipe AGS_GAME_AUDIENCE.RAW.PIPE_GET_NEW_FILES
SET pipe_execution_paused = TRUE;

ALTER task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED suspend;

SELECT GAMER_NAME, listagg(GAME_EVENT_LTZ, ' / ') AS login_and_logout
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
GROUP BY gamer_name;

SELECT gamer_name, game_event_ltz AS login, lead(game_event_ltz) OVER(PARTITION BY gamer_name ORDER BY game_event_ltz) AS logout, coalesce(datediff('mi', login, logout), 0) AS game_session_length
FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
ORDER BY game_session_length DESC;
