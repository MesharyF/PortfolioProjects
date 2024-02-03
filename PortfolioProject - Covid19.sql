select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

-- ======================================================
-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidDeaths
where location like '%Arabia%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
from CovidDeaths
where location like '%Arabia%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases / population)) * 100 as PercentPopulationInfected
from CovidDeaths
--where location like '%Arabia%'
group by location,population
order by PercentPopulationInfected desc

-- Looking at Countries with Highest Death Count per Population
 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Arabia%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
/*
		[This is the correct results]
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc
*/

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing Continents with Highest Death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

/*  {MY QUERY}
select location, sum(new_cases) totalNewCases, sum(cast(new_deaths as int)) totalNewDeath
--total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidDeaths
-- where location like '%Arabia%'
where continent is  null
group by location
order by 1,2
*/

/*
select date, sum(new_cases) totalNewCases, sum(cast(new_deaths as int)) totalNewDeath,
sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from CovidDeaths
-- where location like '%Arabia%'
where continent is not null
group by date
order by 1,2
*/

select sum(new_cases) totalNewCases, sum(cast(new_deaths as int)) totalNewDeath,
sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from CovidDeaths
-- where location like '%Arabia%'
where continent is not null
--group by location
order by 1,2



-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location = 'canada'
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location = 'canada'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentOfPopulationVaccinated
from PopvsVac




-- Temp Table

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

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentOfPopulationVaccinated
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated