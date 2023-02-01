SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select the data that we will use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the probability of dying from covid in each country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of the population who has contracted covid

SELECT continent, location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%kingdom%'
ORDER BY 1,2

-- Looking at Countries with highest rate of infection from covid

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with highest rate of covid deaths from contracting covid

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Breakdown by continent

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
-- GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

WITH PopvsVac (continent, location, date, population, new_vaccinatons, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Use CTE

WITH PopvsVac (continent, location, date, population, RollingPeopleVaccinated)
AS 

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3


CREATE VIEW ContinentDeathCount AS
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
-- ORDER BY TotalDeathCount DESC
