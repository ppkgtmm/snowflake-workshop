USE ROLE accountadmin;

SELECT util_db.public.grader(step, (actual = expected), actual, expected, description) AS graded_results
FROM (
    SELECT 'DORA_IS_WORKING' AS step,
            (SELECT 123) AS actual,
            123 AS expected,
            'Dora IS working!' AS description
);

USE ROLE sysadmin;

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_ZMD;

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_SNEAKERS;

list @UNI_KLAUS_ZMD;

SELECT $1
FROM @UNI_KLAUS_ZMD/sweatsuit_sizes.txt;

SELECT $1
FROM @uni_klaus_zmd/product_coordination_suggestions.txt;

CREATE FILE FORMAT zmd_file_format_1 
record_delimiter = '^';

SELECT $1
FROM @uni_klaus_zmd/product_coordination_suggestions.txt 
(file_format => zmd_file_format_1);

CREATE FILE FORMAT zmd_file_format_2 
field_delimiter = '^';

SELECT $10
FROM @uni_klaus_zmd/product_coordination_suggestions.txt 
(file_format => zmd_file_format_2);

CREATE OR REPLACE FILE FORMAT zmd_file_format_3
record_delimiter = '^' 
field_delimiter = '=';

CREATE VIEW zenas_athleisure_db.products.SWEATBAND_COORDINATION AS
SELECT $1 product_code, $2 has_matching_sweatsuit
FROM @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

SELECT *
FROM zenas_athleisure_db.products.SWEATBAND_COORDINATION;

CREATE OR REPLACE FILE FORMAT zmd_file_format_1 
record_delimiter = ';' 
trim_space = TRUE;

CREATE VIEW zenas_athleisure_db.products.sweatsuit_sizes AS
SELECT REPLACE($1, chr(13) || chr(10)) AS sizes_available
FROM @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
WHERE sizes_available != '';

SELECT *
FROM zenas_athleisure_db.products.sweatsuit_sizes;

CREATE OR REPLACE FILE FORMAT zmd_file_format_2 
record_delimiter = ';' 
field_delimiter = '|' 
trim_space = TRUE;

CREATE VIEW zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE AS
SELECT REPLACE($1, chr(13) || chr(10)) product_code, $2 headband_description, $3 wristband_description
FROM @UNI_KLAUS_ZMD/swt_product_line.txt
(file_format => zmd_file_format_2);

SELECT *
FROM zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE;

list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

SELECT metadata$filename, MAX(metadata$file_row_number)
FROM @uni_klaus_clothing
GROUP BY metadata$filename;

SELECT *
FROM directory(@uni_klaus_clothing);

--testing UPPER AND REPLACE functions ON directory TABLE

SELECT REPLACE(REPLACE(REPLACE(UPPER(RELATIVE_PATH), '/'), '_', ' '), '.PNG') AS product_name
FROM directory(@uni_klaus_clothing);

--create an internal TABLE for some sweat suit info

CREATE OR REPLACE TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (
    COLOR_OR_STYLE VARCHAR(25), 
    DIRECT_URL VARCHAR(200), 
    PRICE NUMBER(5, 2)
);

--fill the NEW TABLE WITH some data

INSERT INTO ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (COLOR_OR_STYLE, DIRECT_URL, PRICE)
VALUES ('90s', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/90s_tracksuit.png', 500),
       ('Burgundy', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/burgundy_sweatsuit.png', 65),
       ('Charcoal Grey', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/charcoal_grey_sweatsuit.png', 65),
       ('Forest Green', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/forest_green_sweatsuit.png', 65),
       ('Navy Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/navy_blue_sweatsuit.png', 65),
       ('Orange', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/orange_sweatsuit.png', 65),
       ('Pink', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/pink_sweatsuit.png', 65),
       ('Purple', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/purple_sweatsuit.png', 65),
       ('Red', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/red_sweatsuit.png', 65),
       ('Royal Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/royal_blue_sweatsuit.png', 65),
       ('Yellow', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/yellow_sweatsuit.png', 65);

CREATE VIEW zenas_athleisure_db.products.catalog AS
SELECT color_or_style, direct_url, price, size AS image_size, last_modified AS image_last_modified, sizes_available
FROM sweatsuits s
JOIN directory(@uni_klaus_clothing) d 
ON endswith(s.direct_url, d.relative_path)
CROSS JOIN sweatsuit_sizes;

-- ADD a TABLE to MAP the sweat suits to the sweat band sets

CREATE TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING (SWEATSUIT_COLOR_OR_STYLE VARCHAR(25), UPSELL_PRODUCT_CODE VARCHAR(10));

--populate the upsell TABLE

INSERT INTO ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING (SWEATSUIT_COLOR_OR_STYLE, UPSELL_PRODUCT_CODE)
VALUES ('Charcoal Grey', 'SWT_GRY'),
       ('Forest Green', 'SWT_FGN'),
       ('Orange', 'SWT_ORG'),
       ('Pink', 'SWT_PNK'),
       ('Red', 'SWT_RED'),
       ('Yellow', 'SWT_YLW');

-- Zena needs a single VIEW she can query for her website prototype

CREATE VIEW catalog_for_website AS
SELECT color_or_style,
       price,
       direct_url,
       size_list,
       coalesce('BONUS: ' || headband_description || ' & ' || wristband_description, 'Consider White, Black OR Grey Sweat Accessories') AS upsell_product_desc
FROM (
    SELECT color_or_style,
        price,
        direct_url,
        image_last_modified,
        image_size,
        listagg(sizes_available, ' | ') WITHIN GROUP (ORDER BY sizes_available) AS size_list
   FROM CATALOG
   GROUP BY color_or_style,
            price,
            direct_url,
            image_last_modified,
            image_size
) c
LEFT JOIN upsell_mapping u ON u.sweatsuit_color_or_style = c.color_or_style
LEFT JOIN sweatband_coordination sc ON sc.product_code = u.upsell_product_code
LEFT JOIN sweatband_product_line spl ON spl.product_code = sc.product_code
WHERE price < 200 -- high priced items LIKE vintage sweatsuits aren't a good fit for this website
AND image_size < 1000000; -- large images need to be processed to a smaller size

list @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON;

list @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET;

SELECT $1
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON 
(file_format => MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_JSON);

SELECT $1
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET 
(file_format => MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_PARQUET);

CREATE VIEW MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL AS
SELECT $1:sequence_1 AS point_id, $1:trail_name::TEXT AS trail_name, $1:latitude::NUMBER(11, 8) AS lng, $1:longitude::NUMBER(10, 8) AS lat
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET 
(file_format => MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_PARQUET);


SELECT TOP 100 lng || ' ' || lat coord_pair, 'POINT(' || coord_pair || ')' AS trail_point
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL;

CREATE OR REPLACE VIEW MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL AS
SELECT $1:sequence_1 AS point_id, $1:trail_name::TEXT AS trail_name, $1:latitude::NUMBER(11, 8) AS lng, $1:longitude::NUMBER(10, 8) AS lat, lng || ' ' || lat coord_pair
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET 
(file_format => MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_PARQUET)
ORDER BY point_id;

SELECT 'LINESTRING (' || LISTAGG(coord_pair, ',') WITHIN GROUP(ORDER BY point_id) || ')' my_linestring
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL 
-- WHERE point_id <= 10
GROUP BY trail_name;

CREATE VIEW MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.DENVER_AREA_TRAILS AS
SELECT $1:features[0]:properties:Name::TEXT AS feature_name, $1:features[0]:geometry:coordinates::TEXT AS feature_coordinates, $1:features[0]:geometry::TEXT AS geometry, $1:features[0]:properties::TEXT AS feature_properties, $1:crs:properties:name::TEXT AS specs, $1 AS whole_object
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON 
(file_format => ff_json);

SELECT 'LINESTRING (' || LISTAGG(coord_pair, ',') WITHIN GROUP(ORDER BY point_id) || ')' my_linestring, ST_LENGTH(TO_GEOGRAPHY(my_linestring)) length_of_trail
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL
GROUP BY trail_name;

SELECT feature_name, st_length(to_geography(geometry)) trail_length
FROM DENVER_AREA_TRAILS;

SELECT get_ddl('view', 'DENVER_AREA_TRAILS');

CREATE OR REPLACE VIEW DENVER_AREA_TRAILS(
    FEATURE_NAME, 
    FEATURE_COORDINATES, 
    GEOMETRY, 
    trail_length, 
    FEATURE_PROPERTIES, 
    SPECS, 
    WHOLE_OBJECT
) AS
SELECT $1:features[0]:properties:Name::TEXT AS feature_name, $1:features[0]:geometry:coordinates::TEXT AS feature_coordinates, $1:features[0]:geometry::TEXT AS geometry, st_length(to_geography(geometry)) AS trail_length, $1:features[0]:properties::TEXT AS feature_properties, $1:crs:properties:name::TEXT AS specs, $1 AS whole_object
FROM @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_GEOJSON 
(file_format => ff_json);

SELECT *
FROM DENVER_AREA_TRAILS;

CREATE VIEW DENVER_AREA_TRAILS_2 AS
SELECT trail_name AS feature_name, '{"coordinates" : [' || listagg('[' || lng || ',' || lat || ']', ',') || '], "type":"LineString"}' AS geometry, st_length(to_geography(geometry)) AS trail_length
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.CHERRY_CREEK_TRAIL
GROUP BY trail_name;

SELECT feature_name, to_geography(geometry) my_linestring, trail_length
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.DENVER_AREA_TRAILS
UNION ALL
SELECT feature_name, to_geography(geometry) my_linestring, trail_length
FROM mels_smoothie_challenge_db.trails.denver_area_trails_2;

CREATE VIEW trails_and_boundaries AS
SELECT feature_name,
       to_geography(geometry) my_linestring,
       st_xmin(my_linestring) min_eastwest,
       st_xmax(my_linestring) max_eastwest,
       st_ymin(my_linestring) min_northsouth,
       st_ymax(my_linestring) max_northsouth
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.DENVER_AREA_TRAILS
UNION ALL
SELECT feature_name,
       to_geography(geometry) my_linestring,
       st_xmin(my_linestring) min_eastwest,
       st_xmax(my_linestring) max_eastwest,
       st_ymin(my_linestring) min_northsouth,
       st_ymax(my_linestring) max_northsouth
FROM mels_smoothie_challenge_db.trails.denver_area_trails_2;

SELECT *
FROM trails_and_boundaries;

SELECT MIN(MIN_EASTWEST) western_edge,
       MIN(MIN_NORTHSOUTH) southern_edge,
       MAX(MAX_EASTWEST) eastern_edge,
       MAX(MAX_NORTHSOUTH) northen_edge
FROM trails_and_boundary;

SELECT 'POLYGON((' || MIN(MIN_EASTWEST) || ' ' || MAX(MAX_NORTHSOUTH) || ',' || MAX(MAX_EASTWEST) || ' ' || MAX(MAX_NORTHSOUTH) || ',' || MAX(MAX_EASTWEST) || ' ' || MIN(MIN_NORTHSOUTH) || ',' || MIN(MIN_EASTWEST) || ' ' || MIN(MIN_NORTHSOUTH) || '))'
FROM trails_and_boundary;

-- Melanie's LOCATION INTO a 2 Variables (mc for melanies cafe)
SET mc_lat='-104.97300245114094';

SET mc_lng='39.76471253574085';

--Confluence Park INTO a Variable (loc for LOCATION)
SET loc_lat='-105.00840763333615';

SET loc_lng='39.754141917497826';

--Test your variables to see IF they work WITH the Makepoint FUNCTION

SELECT st_makepoint($mc_lat, $mc_lng) AS melanies_cafe_point;

SELECT st_makepoint($loc_lat, $loc_lng) AS confluent_park_point;

--use the variables to calculate the distance FROM
--Melanie's Cafe to Confluent Park

SELECT st_distance(st_makepoint($mc_lat, $mc_lng) , st_makepoint($loc_lat, $loc_lng)) AS mc_to_cp;

CREATE SCHEMA mels_smoothie_challenge_db.LOCATIONS;

CREATE OR REPLACE FUNCTION mels_smoothie_challenge_db.locations.DISTANCE_TO_MC(loc_lat NUMBER(38, 32), loc_lng NUMBER(38, 32)) RETURNS FLOAT AS $$
    st_distance(
        st_makepoint('-104.97300245114094', '39.76471253574085'),
        st_makepoint(loc_lng, loc_lat)
    )
$$;

--Tivoli Center INTO the variables
SET tc_lng='-105.00532059763648';

SET tc_lat='39.74548137398218';

SELECT mels_smoothie_challenge_db.locations.DISTANCE_TO_MC($tc_lat, $tc_lng);

CREATE VIEW mels_smoothie_challenge_db.locations.COMPETITION AS
SELECT *
FROM SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_AMENITY_SUSTENANCE
WHERE (
        amenity IN ('fast_food','cafe','restaurant','juice_bar')
        AND (name ilike '%jamba%' OR name ilike '%juice%' OR name ilike '%superfruit%')
    )
    OR (cuisine LIKE '%smoothie%' OR cuisine LIKE '%juice%');

SELECT name, cuisine, st_distance(st_makepoint('-104.97300245114094', '39.76471253574085'), coordinates) distance_from_melanies
FROM competition
ORDER BY distance_from_melanies;

CREATE OR REPLACE FUNCTION mels_smoothie_challenge_db.locations.DISTANCE_TO_MC(lat_and_lng GEOGRAPHY) RETURNS FLOAT AS $$
    st_distance(
        st_makepoint('-104.97300245114094', '39.76471253574085'),
        lat_and_lng
    )
$$;

SELECT name, cuisine, mels_smoothie_challenge_db.locations.DISTANCE_TO_MC(coordinates) distance_from_melanies
FROM competition
ORDER BY distance_from_melanies;

-- Tattered Cover Bookstore McGregor Square
SET tcb_lng='-104.9956203';

SET tcb_lat='39.754874';

--this will run the FIRST version of the UDF

SELECT distance_to_mc($tcb_lat, $tcb_lng);

--this will run the second version of the UDF, bc it converts the coords
--to a geography OBJECT before passing them INTO the FUNCTION

SELECT distance_to_mc(st_makepoint($tcb_lng, $tcb_lat));

--this will run the second version bc the Sonra Coordinates COLUMN
-- CONTAINS geography objects already

SELECT name, distance_to_mc(coordinates) AS distance_to_melanies, ST_ASWKT(coordinates)
FROM SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_SHOP
WHERE shop='books' AND name LIKE '%Tattered Cover%' AND addr_street LIKE '%Wazee%';

CREATE VIEW MELS_SMOOTHIE_CHALLENGE_DB.LOCATIONS.DENVER_BIKE_SHOPS AS
SELECT name, distance_to_mc(coordinates) AS distance_to_melanies
FROM SONRA_DENVER_CO_USA_FREE.DENVER.V_OSM_DEN_SHOP_OUTDOORS_AND_SPORT_VEHICLES
WHERE shop = 'bicycle';

SELECT *
FROM MELS_SMOOTHIE_CHALLENGE_DB.LOCATIONS.DENVER_BIKE_SHOPS
ORDER BY DISTANCE_TO_MELANIES;

SELECT *
FROM mels_smoothie_challenge_db.trails.cherry_creek_trail;

ALTER VIEW mels_smoothie_challenge_db.trails.cherry_creek_trail RENAME TO mels_smoothie_challenge_db.trails.v_cherry_creek_trail;


CREATE OR REPLACE EXTERNAL TABLE mels_smoothie_challenge_db.trails.t_cherry_creek_trail (
    my_file_name TEXT(50) AS (metadata$filename::TEXT(50))
) 
LOCATION = @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET 
auto_refresh = TRUE 
file_format = (TYPE = parquet);

SELECT get_ddl('view', 'MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.V_CHERRY_CREEK_TRAIL');

CREATE OR REPLACE EXTERNAL TABLE mels_smoothie_challenge_db.trails.t_cherry_creek_trail (
    POINT_ID NUMBER AS ($1:sequence_1::NUMBER), 
    TRAIL_NAME TEXT AS ($1:trail_name::TEXT), 
    LNG NUMBER(11, 8) AS ($1:latitude::NUMBER(11, 8)), 
    LAT NUMBER(10, 8) AS ($1:longitude::NUMBER(10, 8)), 
    COORD_PAIR TEXT(50) AS (lng || ' ' || lat)
) 
LOCATION = @MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_PARQUET
auto_refresh = TRUE 
file_format = MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.FF_PARQUET;

SELECT *
FROM mels_smoothie_challenge_db.trails.t_cherry_creek_trail;

SELECT *
FROM MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.SMV_CHERRY_CREEK_TRAIL;
