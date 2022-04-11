--Exploring coivd data

select * 
from covid_data
where continent is not null
order by 3,4

select location,date,total_cases,total_deaths,new_cases,population
from covid_data
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percent
from covid_data
where 
location = 'India'
order by 1,2


select location,date,total_cases,population,(total_cases/population)*100 as infected_percent
from covid_data
where 
location = 'India'
order by 1,2


select location,population,max(total_cases)as total_cases,max((total_cases/population))*100 as infected_percent
from covid_data
where continent is not null
group by location, population
order by infected_percent desc

-- Percentage of deaths by country
select location,population,max(cast(total_deaths as int))as total_death, max((total_deaths/population))*100 as death_percent
from covid_data
where continent is not null
group by location, population
order by death_percent desc

_-- Percentage of population infected
select location,population,max(total_cases)as highest_infection,max((total_cases/population))*100 as infected_percent
from covid_data
where continent is not null
group by population, location
order by infected_percent desc


select APPROX_COUNT_DISTINCT(continent)
from covid_data
where continent is not null

-- Total Cases by Continent
select  continent, max(total_cases) as total_case
from covid_data
where continent is not null
group by continent

-- Calculating deaths by country
select location, max(cast(total_deaths as int)) as total_death
from covid_data
where continent is not null
group by location
order by total_death desc

 
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int )) as total_deaths
from covid_data
where continent is not null
group by  date 

 
select location,sum(new_cases) as total_cases,sum(cast(new_deaths as int )) as total_deaths
from covid_data
where continent is not null
group by  location
order by 3 desc

--Death Percet
select date ,sum(new_cases) as total_cases , sum (cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from covid_data
where continent is not null
group by date
order by 1,2

--Vaccination data
select *
from covid_vax

--Using join

select data.continent, data.location,data.date ,data.population,vax.new_vaccinations, vax.total_vaccinations
from covid_data data
join covid_vax vax
on data.location = vax.location
and data.date =vax.date 
order by 2,3

-- Percentage of population vaccinated increasing by date

select data.continent, data.location,data.date ,data.population,vax.new_vaccinations, sum(cast(vax.new_vaccinations as bigint)) over (partition by data.location order by data.location, data.date) as total_vaccination_continuous
from covid_data data
join covid_vax vax
on data.location = vax.location
and data.date =vax.date 
order by 2,3



--Using CTE

with popvsvax (continent, location, date, population, new_vaccinations, total_vaccination_continuous)
as
(
select data.continent, data.location,data.date ,data.population,vax.new_vaccinations, sum(cast(vax.new_vaccinations as bigint)) over (partition by data.location order by data.location, data.date) as total_vaccination_continuous
from covid_data data
join covid_vax vax
on data.location = vax.location
and data.date =vax.date 
where data.continent is not null
)
select *, (total_vaccination_continuous/population)*100 as vaccinated_percent
from popvsvax

-- Temp Table

create table vaccinated_population
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
total_vaccination_continuous numeric
)
insert into vaccinated_population
select data.continent, data.location,data.date ,data.population,vax.new_vaccinations, sum(cast(vax.new_vaccinations as bigint)) over (partition by data.location order by data.location, data.date) as total_vaccination_continuous
from covid_data data
join covid_vax vax
on data.location = vax.location
and data.date =vax.date 
where data.continent is not null

select * 
from vaccinated_population
order by 2,3 

-- Max vaccinated
select location, max(total_vaccination_continuous) as total_vaccinated
from vaccinated_population
group by location
order by 2 desc

-- Create View for Visualization
create view vaccinated_population_percent as
select data.continent, data.location,data.date ,data.population,vax.new_vaccinations, sum(cast(vax.new_vaccinations as bigint)) over (partition by data.location order by data.location, data.date) as total_vaccination_continuous
from covid_data data
join covid_vax vax
on data.location = vax.location
and data.date =vax.date 
where data.continent is not null






