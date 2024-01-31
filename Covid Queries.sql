-- Make sure data was uploaded correctly to both tables 

SELECT *
FROM covid_deaths
ORDER BY 3,4;

SELECT *
FROM covid_vaccines
ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood od dying if you contract covid in the US

SELECT 
    location, date,
	total_cases,
 	total_deaths,
	(total_deaths :: FLOAT/total_cases :: FLOAT)*100  AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL AND
location LIKE '%States%' AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population had covid by year
SELECT 
    location, 
	population,
	EXTRACT (YEAR FROM date) AS year,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases :: FLOAT/population :: FLOAT))*100  AS covid_infected_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL AND
-- location LIKE '%States%' AND 
total_cases IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY 1,2,3
ORDER BY covid_infected_percentage DESC;

-- Show countries with highest death count per population 

SELECT 
    location, 
	MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL AND
-- location LIKE '%States%' AND 
total_cases IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Similarly by continent 
-- Show continents with highest death count per population 

SELECT 
    continent, 
	MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL AND
-- location LIKE '%States%' AND 
total_cases IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Yearly big picture of new cases and deaths 

SELECT 
    EXTRACT(YEAR FROM date) AS year,
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
    (SUM(new_deaths) :: FLOAT/SUM(new_cases):: FLOAT)*100  AS new_death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL AND
total_cases IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY year
ORDER BY 1;


-- Looking at Total Population vs Vaccinations 

SELECT  
	d.continent, 
	d.location, 
	d.date,
	d.population,
	v.people_vaccinated
FROM covid_vaccines v
JOIN covid_deaths d
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL AND v.people_vaccinated IS NOT NULL
ORDER BY 2,3;

-- Common Table Expression to use rolling_total_vaccinations for calculations

WITH PopvsVac (continent, location, date, population, people_vaccinated, rolling_total_vaccinations)
AS (SELECT  
	d.continent, 
	d.location, 
	d.date,
	d.population,
	v.people_vaccinated,
	SUM(v.people_vaccinated) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_total_vaccinations
FROM covid_vaccines v
JOIN covid_deaths d
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL AND v.people_vaccinated IS NOT NULL
)
SELECT *, (rolling_total_vaccinations/population)*100 AS 
FROM PopvsVac


-- Examining Elderly 
-- Rank 10 most affected elderly population

SELECT 
	location, 
	MAX(aged_65_older)
FROM covid_vaccines
WHERE aged_65_older IS NOT NULL AND gdp_per_capita IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Effects of the boosters 


SELECT 
	location,
	MAX(total_boosters)
FROM covid_vaccines
WHERE total_boosters IS NOT NULL AND continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


