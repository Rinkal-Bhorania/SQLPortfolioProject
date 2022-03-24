SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Covidvaccination
--ORDER BY 3,4
-- needed data from the coviddeath table
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeath
Order by 1,2

-- show total cases vs total deaths in the USA
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

-- show the percentage of population got covid in the usa
select location,date,total_cases,population,(total_cases/population) *100 as PercentPopulationInfect
from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

-- show country with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
group by location,population
order by PercentPopulationInfected desc


-- show country with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
GROUP BY location
order by TotalDeathCount desc

--show continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeath
where continent is not null
GROUP BY date
order by 1,2


-- total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3




--- use cte

with PopvsVac 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population) *100 
from PopvsVac

--Create view for visualization
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 