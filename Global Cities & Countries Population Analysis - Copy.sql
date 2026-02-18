-- =====================================================
-- 1️⃣ ENABLE LOCAL INFILE (Run this first)
-- =====================================================

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';


-- =====================================================
-- 2️⃣ CREATE DATABASE
-- =====================================================

CREATE DATABASE IF NOT EXISTS urban_analytics;
USE urban_analytics;


-- =====================================================
-- 3️⃣ COUNTRIES RAW TABLE
-- =====================================================

DROP TABLE IF EXISTS countries_raw;

CREATE TABLE countries_raw (
    Code CHAR(3),
    Name VARCHAR(100),
    Continent VARCHAR(50),
    Region VARCHAR(100),
    SurfaceArea FLOAT,
    IndepYear INT,
    Population BIGINT,
    LifeExpectancy FLOAT,
    GNP FLOAT,
    GNPOld FLOAT
);

-- =====================================================
-- 4️⃣ LOAD COUNTRIES DATA
-- =====================================================

USE urban_analytics;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/worldcities_trimmed.csv'
INTO TABLE cities_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(city, country, iso2, iso3, admin_name, population, latitude, longitude);

SELECT COUNT(*) FROM cities_raw;

SELECT COUNT(*) AS countries_raw_count FROM countries_raw;


-- =====================================================
-- 5️⃣ CREATE CLEAN COUNTRIES TABLE
-- =====================================================

DROP TABLE IF EXISTS countries_clean;

CREATE TABLE countries_clean AS
SELECT
    Code AS country_code,
    Name AS country_name,
    Continent,
    Region,
    Population,
    SurfaceArea
FROM countries_raw
WHERE Population > 0
  AND SurfaceArea > 0;

SELECT COUNT(*) AS countries_clean_count FROM countries_clean;


-- =====================================================
-- 6️⃣ CITIES RAW TABLE
-- =====================================================

DROP TABLE IF EXISTS cities_raw;

CREATE TABLE cities_raw (
    city VARCHAR(100),
    country VARCHAR(100),
    iso2 CHAR(2),
    iso3 CHAR(3),
    admin_name VARCHAR(100),
    population BIGINT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

-- =====================================================
-- 7️⃣ LOAD CITIES DATA
-- =====================================================

USE urban_analytics;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/worldcities_trimmed.csv'
INTO TABLE cities_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(city, country, iso2, iso3, admin_name, @population, latitude, longitude)
SET population = NULLIF(@population, '');

SELECT COUNT(*) AS total_rows FROM cities_raw;

-- =====================================================
-- CREATE CLEAN CITIES TABLE
-- =====================================================

DROP TABLE IF EXISTS cities_clean;

CREATE TABLE cities_clean AS
SELECT
    city,
    country,
    iso2,
    iso3,
    admin_name,
    population,
    latitude,
    longitude
FROM cities_raw
WHERE population IS NOT NULL
  AND population > 0
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL;

-- Check result
SELECT COUNT(*) AS cities_clean_count FROM cities_clean;
