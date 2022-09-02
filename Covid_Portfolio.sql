SELECT *
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM Covid_Portfolio..Covid_Vaccinations
ORDER BY 3,4

-- Data we are using

SELECT Location, date, total_cases, total_deaths, population
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Percent_Died 
FROM Covid_Portfolio..Covid_Deaths
WHERE LOCATION like '%Kingdom%' AND continent IS NOT NULL
ORDER BY 1,2 DESC
-- Likelihood of dying from covid infection in United Kingdom.

-- Looking at Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Percent_Infected 
FROM Covid_Portfolio..Covid_Deaths
WHERE LOCATION like '%Kingdom%' AND continent IS NOT NULL
ORDER BY 1,2
-- Percentage of population infected by covid (that has been tested).

-- Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 AS Percent_Population_Infected
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Percent_Population_Infected DESC

-- Countries with highest death count

SELECT Location, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count_Country
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Highest_Death_Count_Country DESC

-- Continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count_Continent
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count_Continent DESC

-- GLOBAL NUMBERS
-- Infections, Deaths, Death percentage daily across the world
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Percent_Died
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Overall Infections, Deaths, Death percentage across the world
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Percent_Died
FROM Covid_Portfolio..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total population vs vaccinations

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Count_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
	death.date) AS Rolling_Count_Vaccinated
FROM Covid_Portfolio..Covid_Deaths AS death
JOIN Covid_Portfolio..Covid_Vaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL

SELECT *, (Rolling_Count_Vaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for visualization

CREATE VIEW Percent_Population_Vaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
	death.date) AS Rolling_Count_Vaccinated
FROM Covid_Portfolio..Covid_Deaths AS death
JOIN Covid_Portfolio..Covid_Vaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL