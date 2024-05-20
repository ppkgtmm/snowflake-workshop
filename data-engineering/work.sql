alter user PKGTM1998
set
    default_role = 'SYSADMIN';
alter user PKGTM1998
set
    default_warehouse = 'COMPUTE_WH';
alter user PKGTM1998
set
    default_namespace = 'UTIL_DB.PUBLIC';
use role accountadmin;
create
    or replace api integration dora_api_integration api_provider = aws_api_gateway api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole' enabled = true api_allowed_prefixes = (
        'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora'
    );
show integrations;
use role accountadmin;
create
    or replace external function util_db.public.grader(
        step varchar,
        passed boolean,
        actual integer,
        expected integer,
        description varchar
    ) returns variant api_integration = dora_api_integration context_headers = (
        current_timestamp,
        current_account,
        current_statement,
        current_account_name
    ) as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader';
use role accountadmin;
select
    util_db.public.grader(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) as graded_results
from
    (
        SELECT
            'DORA_IS_WORKING' as step,(
                select
                    123
            ) as actual,
            123 as expected,
            'Dora is working!' as description
    );
list @uni_kishore;
select
    $1
from
    @uni_kishore/kickoff (file_format => ff_json_logs);
copy into game_logs
from
    @uni_kishore/kickoff file_format = ff_json_logs;
create view logs as
select
    raw_log:agent::text agent,
    raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601,
    raw_log:user_event::text user_event,
    raw_log:user_login::text user_login,
    raw_log
from
    game_logs;
select
    *
from
    logs;

select
    current_timestamp();
    --what time zone is your account(and/or session) currently set to? Is it -0700?
select
    current_timestamp();
    --worksheets are sometimes called sessions -- we'll be changing the worksheet time zone
    alter session
set
    timezone = 'UTC';
select
    current_timestamp();
    --how did the time differ after changing the time zone for the worksheet?
    alter session
set
    timezone = 'Africa/Nairobi';
select
    current_timestamp();
alter session
set
    timezone = 'Pacific/Funafuti';
select
    current_timestamp();
alter session
set
    timezone = 'Asia/Shanghai';
select
    current_timestamp();
    --show the account parameter called timezone
    show parameters like 'timezone';
COPY INTO game_logs
FROM
    @uni_kishore/updated_feed file_format = ff_json_logs;
create
    or replace view logs as
select
    raw_log:ip_address::text ip_address,
    raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601,
    raw_log:user_event::text user_event,
    raw_log:user_login::text user_login,
    raw_log
from
    game_logs
where
    raw_log:agent is null;
select
    *
from
    logs
where
    user_login ilike '%prajina%';

select
    parse_ip('100.41.16.160', 'inet'):host::text host,
    parse_ip('100.41.16.160', 'inet'):ipv4::number ipv4;
create schema ENHANCED;
select
    logs.*,
    loc.city,
    loc.region,
    loc.country,
    loc.timezone
from
    ipinfo_geoloc.demo.location loc
    join AGS_GAME_AUDIENCE.RAW.LOGS logs
where
    parse_ip(logs.ip_address, 'inet'):ipv4 between start_ip_int
    and end_ip_int;
    --a Look Up table to convert from hour number to "time of day name"
    create table ags_game_audience.raw.time_of_day_lu (hour number, tod_name varchar(25));
    --insert statement to add all 24 rows to the table
insert into
    time_of_day_lu
values
    (6, 'Early morning'),
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
select
    tod_name,
    listagg(hour, ',')
from
    time_of_day_lu
group by
    tod_name;
create table ags_game_audience.enhanced.logs_enhanced as
select
    logs.ip_address,
    logs.user_login GAMER_NAME,
    logs.user_event GAME_EVENT_NAME,
    logs.datetime_iso8601 GAME_EVENT_UTC,
    city,
    region,
    country,
    timezone GAMER_LTZ_NAME,
    convert_timezone('UTC', timezone, datetime_iso8601) GAME_EVENT_LTZ,
    dayname(
        convert_timezone('UTC', timezone, datetime_iso8601)
    ) DOW_NAME,
    tod_name
from
    ipinfo_geoloc.demo.location loc
    join AGS_GAME_AUDIENCE.RAW.LOGS logs on loc.join_key = ipinfo_geoloc.public.to_join_key(logs.ip_address)
    and ipinfo_geoloc.public.to_int(logs.ip_address) between start_ip_int
    and end_ip_int
    join time_of_day_lu tod on tod.hour = hour(
        convert_timezone('UTC', timezone, datetime_iso8601)
    );
select
    *
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

use role accountadmin;
--You have to run this grant or you won't be able to test your tasks while in SYSADMIN role
    --this is true even if SYSADMIN owns the task!!
    grant execute task on account to role SYSADMIN;
use role sysadmin;
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
show tasks in account;
describe task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
create
    or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED warehouse = COMPUTE_WH schedule = '5 minute' as truncate table ags_game_audience.enhanced.LOGS_ENHANCED;
INSERT INTO
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
select
    logs.ip_address,
    logs.user_login GAMER_NAME,
    logs.user_event GAME_EVENT_NAME,
    logs.datetime_iso8601 GAME_EVENT_UTC,
    city,
    region,
    country,
    timezone GAMER_LTZ_NAME,
    convert_timezone('UTC', timezone, datetime_iso8601) GAME_EVENT_LTZ,
    dayname(
        convert_timezone('UTC', timezone, datetime_iso8601)
    ) DOW_NAME,
    tod_name
from
    ipinfo_geoloc.demo.location loc
    join AGS_GAME_AUDIENCE.RAW.LOGS logs on loc.join_key = ipinfo_geoloc.public.to_join_key(logs.ip_address)
    and ipinfo_geoloc.public.to_int(logs.ip_address) between start_ip_int
    and end_ip_int
    join time_of_day_lu tod on tod.hour = hour(
        convert_timezone('UTC', timezone, datetime_iso8601)
    );
select
    count(*)
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
select
    count(*)
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
    --first we dump all the rows out of the table
    truncate table ags_game_audience.enhanced.LOGS_ENHANCED;
    --then we put them all back in
INSERT INTO
    ags_game_audience.enhanced.LOGS_ENHANCED (
        SELECT
            logs.ip_address,
            logs.user_login as GAMER_NAME,
            logs.user_event as GAME_EVENT_NAME,
            logs.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.LOGS logs
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    );
create table ags_game_audience.enhanced.LOGS_ENHANCED_UF clone ags_game_audience.enhanced.LOGS_ENHANCED;
MERGE INTO ENHANCED.LOGS_ENHANCED e USING RAW.LOGS r ON r.user_login = e.GAMER_NAME
    and r.datetime_iso8601 = e.game_event_utc
    and r.user_event = e.game_event_name
    WHEN MATCHED THEN
UPDATE
SET
    IP_ADDRESS = 'Hey I updated matching rows!';
select
    *
from
    ENHANCED.LOGS_ENHANCED;
truncate table ENHANCED.LOGS_ENHANCED;
create
    or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED warehouse = 'COMPUTE_WH' schedule = '5 minute' as MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
        SELECT
            logs.ip_address,
            logs.user_login as GAMER_NAME,
            logs.user_event as GAME_EVENT_NAME,
            logs.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.LOGS logs
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    ) r ON r.GAMER_NAME = e.GAMER_NAME
    and r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
    and r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
    WHEN NOT MATCHED THEN
insert
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    )
values
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    );
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

create
    or replace TABLE AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS (RAW_LOG VARIANT);
copy into AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
from
    @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE file_format = AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS;
select
    count(1)
from
    AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;
create
    or replace task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES -- warehouse = 'COMPUTE_WH'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' schedule = '5 minute' as copy into AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
from
    @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE file_format = AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS;
execute task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES;
create
    or replace view AGS_GAME_AUDIENCE.RAW.PL_LOGS(
        IP_ADDRESS,
        DATETIME_ISO8601,
        USER_EVENT,
        USER_LOGIN,
        RAW_LOG
    ) as
select
    raw_log:ip_address::text ip_address,
    raw_log:datetime_iso8601::timestamp_ntz datetime_iso8601,
    raw_log:user_event::text user_event,
    raw_log:user_login::text user_login,
    raw_log
from
    AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS
where
    raw_log:agent is null;
select
    *
from
    AGS_GAME_AUDIENCE.RAW.PL_LOGS;
create
    or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED -- warehouse = 'COMPUTE_WH'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' -- schedule = '5 minute'
after
    AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES as MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
        SELECT
            logs.ip_address,
            logs.user_login as GAMER_NAME,
            logs.user_event as GAME_EVENT_NAME,
            logs.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.pl_logs logs
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    ) r ON r.GAMER_NAME = e.GAMER_NAME
    and r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
    and r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
    WHEN NOT MATCHED THEN
insert
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    )
values
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    );
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
select
    *
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
truncate table ENHANCED.LOGS_ENHANCED;
    --Turning on a task is done with a RESUME command
    alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;
    --Turning OFF a task is done with a SUSPEND command
    alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;
list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;
select
    count(*)
from
    AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;
select
    count(*)
from
    AGS_GAME_AUDIENCE.RAW.PL_LOGS;
select
    count(*)
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
use role accountadmin;
grant EXECUTE MANAGED TASK on account to SYSADMIN;
    --switch back to sysadmin
    use role sysadmin;

create table ED_PIPELINE_LOGS as
SELECT
    METADATA$FILENAME as log_file_name --new metadata column
,
    METADATA$FILE_ROW_NUMBER as log_file_row_id --new metadata column
,
    current_timestamp(0) as load_ltz --new local time of load
,
    get($1, 'datetime_iso8601')::timestamp_ntz as DATETIME_ISO8601,
    get($1, 'user_event')::text as USER_EVENT,
    get($1, 'user_login')::text as USER_LOGIN,
    get($1, 'ip_address')::text as IP_ADDRESS
FROM
    @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE (file_format => 'ff_json_logs');
create
    or replace TABLE AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS (
        LOG_FILE_NAME VARCHAR(100),
        LOG_FILE_ROW_ID NUMBER(18, 0),
        LOAD_LTZ TIMESTAMP_LTZ(0),
        DATETIME_ISO8601 TIMESTAMP_NTZ(9),
        USER_EVENT VARCHAR(25),
        USER_LOGIN VARCHAR(100),
        IP_ADDRESS VARCHAR(100)
    );
copy into AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS
from
    (
        SELECT
            METADATA$FILENAME as log_file_name --new metadata column
,
            METADATA$FILE_ROW_NUMBER as log_file_row_id --new metadata column
,
            current_timestamp(0) as load_ltz --new local time of load
,
            get($1, 'datetime_iso8601')::timestamp_ntz as DATETIME_ISO8601,
            get($1, 'user_event')::text as USER_EVENT,
            get($1, 'user_login')::text as USER_LOGIN,
            get($1, 'ip_address')::text as IP_ADDRESS
        FROM
            @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
    ) file_format = 'ff_json_logs';
CREATE
    OR REPLACE PIPE PIPE_GET_NEW_FILES auto_ingest = true aws_sns_topic = 'arn:aws:sns:us-west-2:321463406630:dngw_topic' AS COPY INTO ED_PIPELINE_LOGS
FROM
    (
        SELECT
            METADATA$FILENAME as log_file_name,
            METADATA$FILE_ROW_NUMBER as log_file_row_id,
            current_timestamp(0) as load_ltz,
            get($1, 'datetime_iso8601')::timestamp_ntz as DATETIME_ISO8601,
            get($1, 'user_event')::text as USER_EVENT,
            get($1, 'user_login')::text as USER_LOGIN,
            get($1, 'ip_address')::text as IP_ADDRESS
        FROM
            @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
    ) file_format = (format_name = ff_json_logs);
create table AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED_BACKUP clone AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
TRUNCATE TABLE AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;
create
    or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' schedule = '5 minutes' -- after AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
    as MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
        SELECT
            logs.ip_address,
            logs.user_login as GAMER_NAME,
            logs.user_event as GAME_EVENT_NAME,
            logs.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.ED_PIPELINE_LOGS logs
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    ) r ON r.GAMER_NAME = e.GAMER_NAME
    and r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
    and r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
    WHEN NOT MATCHED THEN
insert
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    )
values
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    );
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;
select
    parse_json(
        SYSTEM$PIPE_STATUS('ags_game_audience.raw.PIPE_GET_NEW_FILES')
    );
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;
    --create a stream that will keep track of changes to the table
    create
    or replace stream ags_game_audience.raw.ed_cdc_stream on table AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS;
    --look at the stream you created
    show streams;
    --check to see if any changes are pending (expect FALSE the first time you run it)
    --after the Snowpipe loads a new file, expect to see TRUE
select
    system$stream_has_data('ed_cdc_stream');
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;
    --query the stream
select
    *
from
    ags_game_audience.raw.ed_cdc_stream;
    --check to see if any changes are pending
select
    system$stream_has_data('ed_cdc_stream');
    --if your stream remains empty for more than 10 minutes, make sure your PIPE is running
select
    SYSTEM$PIPE_STATUS('PIPE_GET_NEW_FILES');
MERGE INTO ENHANCED.LOGS_ENHANCED e USING (
        SELECT
            cdc.ip_address,
            cdc.user_login as GAMER_NAME,
            cdc.user_event as GAME_EVENT_NAME,
            cdc.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, cdc.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.ed_cdc_stream cdc
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    ) r ON r.GAMER_NAME = e.GAMER_NAME
    and r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
    and r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
    WHEN NOT MATCHED THEN
insert
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    )
values
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    );
select
    *
from
    ags_game_audience.raw.ed_cdc_stream;
select
    *
from
    ENHANCED.LOGS_ENHANCED;
    --Create a new task that uses the MERGE you just tested
    create
    or replace task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL' SCHEDULE = '5 minutes'
    when system$stream_has_data('ags_game_audience.raw.ed_cdc_stream') as MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e USING (
        SELECT
            cdc.ip_address,
            cdc.user_login as GAMER_NAME,
            cdc.user_event as GAME_EVENT_NAME,
            cdc.datetime_iso8601 as GAME_EVENT_UTC,
            city,
            region,
            country,
            timezone as GAMER_LTZ_NAME,
            CONVERT_TIMEZONE('UTC', timezone, cdc.datetime_iso8601) as game_event_ltz,
            DAYNAME(game_event_ltz) as DOW_NAME,
            TOD_NAME
        from
            ags_game_audience.raw.ed_cdc_stream cdc
            JOIN ipinfo_geoloc.demo.location loc ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
            AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) BETWEEN start_ip_int
            AND end_ip_int
            JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU tod ON HOUR(game_event_ltz) = tod.hour
    ) r ON r.GAMER_NAME = e.GAMER_NAME
    AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
    AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
    WHEN NOT MATCHED THEN
INSERT
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    )
VALUES
    (
        IP_ADDRESS,
        GAMER_NAME,
        GAME_EVENT_NAME,
        GAME_EVENT_UTC,
        CITY,
        REGION,
        COUNTRY,
        GAMER_LTZ_NAME,
        GAME_EVENT_LTZ,
        DOW_NAME,
        TOD_NAME
    );
    --Resume the task so it is running
    alter task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED resume;

alter pipe AGS_GAME_AUDIENCE.RAW.PIPE_GET_NEW_FILES
set
    pipe_execution_paused = true;
alter task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED suspend;
select
    GAMER_NAME,
    listagg(GAME_EVENT_LTZ, ' / ') as login_and_logout
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
group by
    gamer_name;
select
    gamer_name,
    game_event_ltz as login,
    lead(game_event_ltz) over(
        partition by gamer_name
        order by
            game_event_ltz
    ) as logout,
    coalesce(datediff('mi', login, logout), 0) as game_session_length
from
    AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
order by
    game_session_length desc;
