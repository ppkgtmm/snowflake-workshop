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
        'DLKW01' AS step,(
            SELECT
                COUNT(*)
            FROM
                ZENAS_ATHLEISURE_DB.INFORMATION_SCHEMA.STAGES
            WHERE
                stage_url ilike ('%/clothing%')
                OR stage_url ilike ('%/zenas_metadata%')
                OR stage_url LIKE ('%/sneakers%')
        ) AS actual,
        3 AS expected,
        'Stages for Klaus bucket look good' AS description
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
        'DLKW02' AS step,(
            SELECT
                SUM(tally)
            FROM
                (
                    SELECT
                        COUNT(*) AS tally
                    FROM
                        ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
                    WHERE
                        LENGTH(product_code) > 7
                    UNION
                    SELECT
                        COUNT(*) AS tally
                    FROM
                        ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
                    WHERE
                        LEFT(sizes_available, 2) = CHAR(13) || CHAR(10)
                )
        ) AS actual,
        0 AS expected,
        'Leave data WHERE it lands.' AS description
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
        'DLKW03' AS step,(
            SELECT
                COUNT(*)
            FROM
                ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG
        ) AS actual,
        198 AS expected,
        'Cross-joined VIEW exists' AS description
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
        'DLKW04' AS step,(
            SELECT
                COUNT(*)
            FROM
                zenas_athleisure_db.products.catalog_for_website
            WHERE
                upsell_product_desc LIKE '%NUS:%'
        ) AS actual,
        6 AS expected,
        'Relentlessly resourceful' AS description
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
        'DLKW05' AS step,(
        SELECT
            SUM(tally)
        FROM
            (
                SELECT
                    COUNT(*) AS tally
                FROM
                    mels_smoothie_challenge_db.information_schema.stages
                UNION all
                SELECT
                    COUNT(*) AS tally
                FROM
                    mels_smoothie_challenge_db.information_schema.file_formats
            )
    ) AS actual,
    4 AS expected,
    "Camila\'s Trail Data IS Ready to Query" AS description
);

SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results 
FROM (
    SELECT
    'DLKW06' AS step,
    (
        SELECT COUNT(*) AS tally
        FROM mels_smoothie_challenge_db.information_schema.views 
        WHERE table_name IN ('CHERRY_CREEK_TRAIL','DENVER_AREA_TRAILS')
    ) AS actual,
    2 AS expected,
    "Mel\'s views ON the geospatial data FROM Camila" AS description
); 

SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results 
FROM (
    SELECT
    'DLKW07' AS step,
    ( 
        SELECT round(MAX(max_northsouth))
        FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_AND_BOUNDARIES
    ) AS actual,
    40 AS expected,
    'Trails Northern Extent' AS description
); 

SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results
FROM (
  SELECT
    'DLKW08' AS step,
    (  
        SELECT TRUNCATE(distance_to_melanies)
        FROM mels_smoothie_challenge_db.locations.denver_bike_shops
        WHERE name LIKE '%Mojo%'
    ) AS actual,
    14084 AS expected,
    'Bike Shop VIEW Distance Calc works' AS description
); 

SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
(
    SELECT
    'DLKW09' AS step,
    (   
        SELECT ROW_COUNT
        FROM mels_smoothie_challenge_db.information_schema.tables
        WHERE table_schema = 'TRAILS'
        AND table_name = 'SMV_CHERRY_CREEK_TRAIL'
    ) AS actual,
    3526 AS expected,
    'Secure Materialized VIEW Created' AS description
);
