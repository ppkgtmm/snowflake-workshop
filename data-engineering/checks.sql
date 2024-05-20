-- DO NOT EDIT THIS CODE
SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW01' AS step,(
            SELECT
                COUNT(*)
            FROM
                ags_game_audience.raw.logs
            WHERE
                is_timestamp_ntz(to_variant(datetime_iso8601)) = TRUE
        ) AS actual,
        250 AS expected,
        'Project DB AND Log FILE SET Up Correctly' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW02' AS step,(
            SELECT
                SUM(tally)
            FROM(
                    SELECT
                        (COUNT(*) * -1) AS tally
                    FROM
                        ags_game_audience.raw.logs
                    UNION all
                    SELECT
                        COUNT(*) AS tally
                    FROM
                        ags_game_audience.raw.game_logs
                )
        ) AS actual,
        250 AS expected,
        'View IS filtered' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW03' AS step,(
            SELECT
                COUNT(*)
            FROM
                ags_game_audience.enhanced.logs_enhanced
            WHERE
                dow_name = 'Sat'
                AND tod_name = 'Early evening'
                AND gamer_name LIKE '%prajina'
        ) AS actual,
        2 AS expected,
        'Playing the game ON a Saturday evening' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW04' AS step,(
            SELECT
                COUNT(*) / iff (COUNT(*) = 0, 1, COUNT(*))
            FROM
                TABLE(
                    ags_game_audience.information_schema.task_history (task_name => 'LOAD_LOGS_ENHANCED')
                )
        ) AS actual,
        1 AS expected,
        'Task EXISTS AND has been run at least once' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW05' AS step,(
            SELECT
                MAX(tally)
            FROM
                (
                    SELECT
                        CASE
                            WHEN SCHEDULED_FROM = 'SCHEDULE'
                            AND STATE = 'SUCCEEDED' THEN 1
                            ELSE 0
                        END AS tally
                    FROM
                        TABLE(
                            ags_game_audience.information_schema.task_history (task_name => 'GET_NEW_FILES')
                        )
                )
        ) AS actual,
        1 AS expected,
        'Task succeeds FROM schedule' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW06' AS step,(
            SELECT
                CASE
                    WHEN pipe_status:executionState::TEXT = 'RUNNING' THEN 1
                    ELSE 0
                END
            FROM(
                    SELECT
                        parse_json(
                            SYSTEM$PIPE_STATUS('ags_game_audience.raw.PIPE_GET_NEW_FILES')
                        ) AS pipe_status
                )
        ) AS actual,
        1 AS expected,
        'Pipe EXISTS AND IS RUNNING' AS description
);

SELECT
    GRADER(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
    SELECT
        'DNGW07' AS step,(
            SELECT
                COUNT(*) / COUNT(*)
            FROM
                snowflake.account_usage.query_history
            WHERE
                query_text LIKE '%case WHEN game_session_length < 10%'
        ) AS actual,
        1 AS expected,
        'Curated Data Lesson completed' AS description
);
