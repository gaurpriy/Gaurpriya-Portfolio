Select *
from CovidDeaths$
where continent is not null
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

select location, date,total_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

--total cases vs total deaths

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location = 'India'
order by 1,2

--Shows rough estimates of how many people died.

-- Total cases in percentage of population

select location,date,total_cases, population, (total_cases/population)*100 as CasePercentage
from CovidDeaths$
where location = 'India'
order by 1,2

-- Counrty with highest infection rate compared to population

select location,max(total_cases) as max_cases, population,max((total_cases/population))*100 as CasePercentage
from CovidDeaths$
where continent is not null
group by location, population
order by CasePercentage desc

-- Countries with maximum deaths


select location,max(cast(total_deaths as int) ) as max_deaths, population,max((total_deaths/population))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by location, population
order by 2 desc

-- group by continent

--select location,max(cast(total_deaths as int) ) as max_deaths
--from CovidDeaths$
--where continent is null
--group by location
--order by 2 desc

select continent,max(cast(total_deaths as int) ) as max_deaths
from CovidDeaths$
where continent is not null
group by continent
order by 2 desc

-- GLOBAL

select date, sum(new_cases) as Number_Cases, sum(cast(new_deaths as int)) as Number_Deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2

-- TOTAL

select sum(new_cases) as Number_Cases, sum(cast(new_deaths as int)) as Number_Deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from CovidDeaths$
where continent is not null
order by 1,2

-- COVID VACCINATION

--select *
--from CovidVaccinations$

-- JOIN 

select *
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date

-- Total Population vs Total Vaccination

select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location)
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Instead of CAST we can also use CONVERT


select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as sum_vaccination
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- We use CTE for People vaccinated/ total population

with tp_pv (continent, location,date, population, new_vaccinations, sum_vaccination) 
as
(
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as sum_vaccination
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select continent,location,population,new_vaccinations, (sum_vaccination/population)*100 as Percentage_Vaccinated
from tp_pv

-- Maximum

with tp_pv (continent, location, population, new_vaccinations, sum_vaccination) 
as
(
select cd.continent, cd.location, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as sum_vaccination
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select continent,location,population, max((sum_vaccination/population))*100 as MaxPercentage_Vaccinated
from tp_pv
group by location, continent, population

-- Temp Tables

Drop table if exists #PopulationVaccinated
create table #PopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_vaccination numeric
)

insert into #PopulationVaccinated
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as sum_vaccination
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (sum_vaccination/population)*100 as Percentage_Vaccinated
from #PopulationVaccinated

-- Create view

create view PopulationVaccinated as
select cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as sum_vaccination
from CovidDeaths$ cd
join CovidVaccinations$ cv
   on cd.location = cv.location
   and cd.date = cv.date
where cd.continent is not null
--order by 2,3


