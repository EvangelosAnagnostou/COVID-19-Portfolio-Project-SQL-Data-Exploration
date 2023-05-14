/*

Covid-19 Data Exploration

*/




-- Select data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, Population 
from Project..CovidDeaths
Order by 1,2;




-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying of COVID in Greece

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Project..CovidDeaths
where Location = 'Greece'
Order by 1,2;




-- Total Cases vs Population
-- Shows what percentage of Greek population infected with Covid

Select Location, Date, Population, total_cases, (total_cases/Population)*100 as Percent_of_Population_Infected
from Project..CovidDeaths
where location = 'Greece'
Order by 1,2




-- Countries with Highest Infection Rate compared to Population

Select Location, Population, max(total_cases) as Highest_Infection_Count, 
max((total_cases/population))*100 as Percent_of_Population_Infected
from Project..CovidDeaths
Group by Location, Population
Order by Percent_of_Population_Infected desc;




-- Breaking things down by Continent
-- Showing Countries with the highest death count per polulation

Select Location, Max(cast(total_deaths as int)) as Total_Death_Count
from Project..CovidDeaths
where Continent not like ''
and Location not in ('Upper middle Income', 'High Income', 'Lower Middle Income',
'Low Income', 'World', 'European Union', 'International')
Group by Location
Order by Total_Death_Count desc




-- Showing total deaths of each Continent

Select Location, Max(cast(total_deaths as int)) as Total_Death_Count
from Project..CovidDeaths
where Continent is null
and Location not in ('Upper middle Income', 'High Income', 'Lower Middle Income',
'Low Income', 'World', 'European Union', 'International')
Group by Location
Order by Total_Death_Count desc




-- Global numbers
-- Daily percentage of deaths of infected people globally

Select Date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Project..CovidDeaths
where Continent is not null
Group by Date
Order by 1,2




-- Joining tables to get total population vs vaccinations
-- Get new vaccinations and rolling count of people vaccinated by day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
from Project..CovidDeaths dea
Join Project..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent not like ''
Order by 2,3




-- With CTE to perform calculations on Partition By in previous query

With Pop_Vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
from Project..CovidDeaths dea
Join Project..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, 
(Rolling_People_Vaccinated/Population)*100 as Percentage_Rolling_People_Vaccinated from Pop_Vs_Vac