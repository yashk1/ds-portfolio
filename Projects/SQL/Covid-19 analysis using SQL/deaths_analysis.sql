select * from public."CovidDeaths"

select 
	continent,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from public."CovidDeaths"
where continent is not null

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select
	continent,
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases) *100 as DeathPerc
from public."CovidDeaths"
where location like '%States%'
order by 1,2

-- Looking at total_cases vs Population
-- shows percentage of population that got covid
select
	continent,
	date, 
	total_cases, 
	population,
	(total_cases/population) *100 as PercentPopulationInfected
from public."CovidDeaths"
where location like '%States%'
order by 1,2

--Lookng at countries with total cases from Februrary 2020 - July 2022

select 
	continent,
	max(total_cases) as total
from public."CovidDeaths"
group by continent
order by total DESC

--

select distinct location from public."CovidDeaths"
order by 1 desc

--showing countries with highest death count wrt population
select
	continent,
	max(total_deaths) as totaldeathcount
from public."CovidDeaths"
where continent is not null
group by 1
order by 2 DESC

-- LETS BREAK IT DOWN BY CONTINENT
-- showing continents with the highest death count per population
select 
	continent,
	max(total_deaths) as totaldeaths
from public."CovidDeaths"
where continent is not null
group by continent
order by totaldeaths DESC

-- GLOBAL NUMBERS
-- 
select 
	sum(new_cases) as newcases,
	sum(new_deaths) as newdeaths,
	(sum(new_deaths)/sum(new_cases)) *100as deathpercentage
from public."CovidDeaths"
where continent is not NULL
--group by 1
order by 1 DESC


--
--Joining vaccination table

select
	*
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date


--looking at total population vs vaccinations
select
	d.continent, d.location, d.date, d.population, v.new_vaccinations
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date
where d.continent is not null
order by d.location, d.date


--Rolling total of new_vaccinations by Locations
select
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations::integer) over(partition by d.location order by d.location, d.date) 
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date
where d.continent is not null
order by d.location, d.date

-- CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
select
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date
where d.continent is not null
--order by d.location, d.date
)
select * , (RollingPeopleVaccinated / Population)*100
from PopvsVac




--TEMP Table
Create table PercPopulationVacc_temp
(continent character varying (100),
 location character varying(100),
 date date,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
);

INSERT into PercPopulationVacc_temp
select
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date
where d.continent is not null
--order by d.location, d.date


select * , (RollingPeopleVaccinated / Population)*100
from PercPopulationVacc_temp




--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as(
select
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from public."CovidDeaths" d inner join public."Vaccination" v
on d.location  = v.location and d.date = v.date
where d.continent is not null
) 
