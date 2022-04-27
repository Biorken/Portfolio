CREATE TABLE #temp_Employee (
EmployeeID INT,
JobTitle VARCHAR(100),
Salary INT
);

SELECT *
CREATE TABLE EmployeeErrors (
EmployeeID VARCHAR(50)
,FirstName VARCHAR(50)
,LastName VARCHAR(50)
);

INSERT INTO EmployeeErrors VALUES
('1001 ', 'Jimbo', 'Halbert')
,(' 1002', 'Pamela', 'Beasely')
,('1005', 'Toby', 'Flenderson - Fired');

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--LOOKING AT TOTAL CASES VS TOTAL DEATHS

--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID-19 IN THE UNITED KINGDOM.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%U%Kingdom%'
ORDER BY 1,2;


--LOOKING AT TOTAL CASES VS POPULATION

--SHOWS WHAT PERCENTAGE OF POPULATION CONTRACTED COVID-19 IN THE UNITED KINGDOM.
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS InfectedPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%U%Kingdom%'
ORDER BY 1,2;

--LOOKING AT COUNTRIES WITH HIGHEST IFECTION RATE COMPARED TO POPULATION

--SHOWS TOTAL NUMBER OF INFECTED CITIZENS FOR EACH COUNTRY, LISTED HIGHEST TO LOWEST PERCENTAGE.
SELECT Location, Population, MAX(total_cases) AS HighstInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

--SHOWING DEATHCOUNT PER COUNTRY
SELECT Location, max(cast(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION.
SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--SHOWING GLOBAL STATISTICS

--SHOWING THE GLOBAL DEATH RATE AS A PERCATAGE.
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--SHOWING THE GLOBAL DEATH RATE EACH DAY FROM 2022-01-01 TO 2022-02-05 AS A PERCENTAGE.
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CONVERT(INT,new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--USING CTE

WITH PopVsVac (continent, Location, date, population, New_Vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinationCount/population)*100
FROM PopVsVac;



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date;


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


--TABLEAU TABLES

--1
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CONVERT(INT,new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--2
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('world', 'European Union', 'International', 'upper middle income', 'high income', 'lower middle income', 'low income')
GROUP BY location
ORDER BY TotalDeathCount DESC;

--3
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;