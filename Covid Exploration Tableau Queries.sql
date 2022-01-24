/*

Queries used for Tableau Viz

*/

-- Global Number of Cases vs Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From CovidDataProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Continents sorted by Highest Death Count

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From CovidDataProject..CovidDeaths
Where continent is null
	AND Location not in ('Upper middle income','High income','Lower middle income','Low income','European Union','World', 'International')
Group by location
Order by Total_Death_Count desc

-- Countries with Highested Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From CovidDataProject..CovidDeaths
Group by Location, Population
order by Percent_Population_Infected desc

-- Countries with Highested Infection Rate compared to Population
-- Including Individual Dates

Select Location, Population, date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From CovidDataProject..CovidDeaths
Group by Location, Population, date
order by Percent_Population_Infected desc
