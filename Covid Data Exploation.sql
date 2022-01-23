/* 
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Fuctions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Checking that data is imported correctly

Select *
From CovidDataProject..CovidDeaths
order by 3,4

Select *
From CovidDataProject..CovidVacs
order by 3,4


--Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDataProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths in the US
-- Shows likelihood of dying from covid in the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as Death_Percentage
From CovidDataProject..CovidDeaths
Where location = 'United States'
order by 1,2


-- Total Cases vs Population
-- Shows Percentage of Population that has had covid

Select Location, date, population, total_cases, (total_cases/population)*100  as Percent_Infected
From CovidDataProject..CovidDeaths
order by 1,2


-- Countries with Highested Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From CovidDataProject..CovidDeaths
Group by Location, Population
order by Percent_Population_Infected desc


-- Countries sorted by Highest Death Count

Select Location, max(population) as Population, MAX(cast(total_deaths as int)) as Total_Death_Count
From CovidDataProject..CovidDeaths
Where continent is not null 
Group by Location
Order by Total_Death_Count desc


-- Continents sorted by Highest Death Count

Select location, max(population) as Population, MAX(cast(total_deaths as int)) as Total_Death_Count
From CovidDataProject..CovidDeaths
Where continent is null
	AND Location not like 'Upper middle income'
	AND Location not like 'High income'
	AND Location not like 'Lower middle income'
	AND Location not like 'Low income'
	AND Location not like 'European Union'
Group by location
Order by Total_Death_Count desc


-- Global Number of Cases vs Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From CovidDataProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs Vaccinations
-- Shows % of Population that has recieved at least one dose of the Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_#_of_Vaccinations
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to perform calculation on partition in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_#_of_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_#_of_Vaccinations
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Rolling_#_of_Vaccinations/Population)*100 as Percent_Pop_Vaccinated
From PopvsVac


-- Using Temp Table to perform calculation on partition in the previous query

Drop Table if exists #PercentPopVac
Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_#_of_Vaccinations numeric
)

Insert into #PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_#_of_Vaccinations
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (Rolling_#_of_Vaccinations/Population)*100 as Percent_Pop_Vaccinated
From #PercentPopVac


-- Creating a View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_#_of_Vaccinations
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
