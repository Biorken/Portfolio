CREATE TABLE #temp_Employee (
EmployeeID int,
JobTitle varchar(100),
Salary int
)

SELECT *
CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

INSERT INTO EmployeeErrors Values
('1001 ', 'Jimbo', 'Halbert')
,(' 1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Looking at Total Cases vs Total Deaths

--Shows Likelihood of dying if you contract Covid-19 in the United Kingdom.
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%U%Kingdom%'
order by 1,2


--Looking at Total Cases vs Population

--Shows what percentage of Population contracted Covid-19 in the United Kingdom.
Select Location, date, Population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%U%Kingdom%'
order by 1,2

--Looking at Countries with Highest Ifection Rate compared to Population

--Shows total number of infected citizens for each country, listed highest to lowest percentage.
Select Location, Population, MAX(total_cases) as HighstInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage 
from PortfolioProject..CovidDeaths
group by location, population
order by InfectedPercentage desc

--Showing DeathCount per Country
Select Location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population.
Select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


--Showing Global 

--Showing the Global death rate as a percatage.
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Showing the global death rate each day from 2022-01-01 to 2022-02-05 as a percentage.
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(convert(int,new_deaths))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


--Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE

with PopVsVac (continent, Location, date, population, New_Vaccinations, RollingVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinationCount/population)*100
from PopVsVac



--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated