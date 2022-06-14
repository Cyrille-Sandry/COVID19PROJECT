
/*

                    PORTFOLIO PROJECT ON COVID19

*/


--- DATA SETS

-- The CovidDeaths data set

-- Selecting all the columns of the CovidDeaths data set ordered by the  third and the fourth columns

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

-- The CovidVaccination data set

-- Selecting all the columns of the CovidVaccination data set ordered by the  second and the third columns

select *
from PortfolioProject.dbo.CovidVaccinations
order by 2,3;



---  SQL QUERIES 

/*
Selecting location, date, total_cases, new_cases, total_death and population from the table CovidDeath
*/

select location,
       date,
	   total_cases,
	   new_cases, 
	   total_deaths,
	   population
from PortfolioProject..CovidDeaths
order by 1,2;




/*
- Looking for total cases Vs total deaths and show the likelihood of deaying if you contract Covid in Belgium
*/

select location,
       date,
	   total_cases,
	   total_deaths,
	   cast(total_deaths as float)*100/cast(total_cases as float) as 'DeathPercentage'
from PortfolioProject..CovidDeaths
where location like '%Belgium%'
order by 1,2;


/*
- Looking at the total cases vs population and show the  percentage of population which got covid
*/

select location,
       date,
	   total_cases,
	   population,
	   round((cast(total_cases as float)/cast(population as float))*100,3) as 'CovidPercentage'
from PortfolioProject..CovidDeaths
where location like '%Belgium%'
order by 1,2;

/*
Looking at the countries with highest infection rate compare to population order by descending higherst infection percentage
*/

select location,
       population,
	   Max(cast(total_cases as float)) as 'HighestInfectionCount',
	   Max( (cast(total_cases as float)/cast(population as float))*100) as 'HighestInfectionPercentage'
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by HighestInfectionPercentage desc;


/*   Showing countries with highest deaths count per population order by descending total death   */

select location,
	   Max(cast(total_deaths as float)) as 'TotalDeathCount'
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;


/* Shows the top 5 countries with highest deaths count per population in the world  */

with cte as
(
select top 5  *,
    ROW_NUMBER() over (order by tab.TotalDeathCount desc) as rn
from (select location,
	 Max(cast(total_deaths as float)) as 'TotalDeathCount'
from PortfolioProject..CovidDeaths
where continent is not null
group by location
) tab
)
select  location,
        TotalDeathCount
from cte
where rn in (1,2,3,4,5);




/* Showing continent with highest deaths count per population */

select continent,
	   Max(cast(total_deaths as float)) as 'TotalDeathCount'
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


/* Select distinct continent  */

select distinct continent
from PortfolioProject..CovidDeaths;

/* Show the continent with highest deaths count per population in the world  */

with cte as
(
select top 1  *,
    ROW_NUMBER() over (order by tab.TotalDeathCount desc) as rn
from (select continent,
	   Max(cast(total_deaths as float)) as 'TotalDeathCount'
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
) tab
)
select  continent,
        TotalDeathCount
from cte
where rn=1;



/*

                GLOBAL NUMBER


*/


-- Showing daily world cases, daily world deaths and daily world death percentage


select  date,
	   sum(cast(total_cases as float) ) as 'WorldDailyCases',
	   sum(cast(new_deaths as int)) as 'WorldDailyDeaths',
	   round(sum(cast(new_deaths as int))/sum(cast(total_cases as float))*100,3) as 'WorldDailyDeathPercentatge'
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;


-- Showing the day where people in the world was must infected by Covid19

with cte as
(
select top 1  *,
    ROW_NUMBER() over (order by tab.WorldDailyCases desc) as rn
from (select  date,
	   sum(cast(total_cases as float) ) as 'WorldDailyCases',
	   sum(cast(new_deaths as int)) as 'WorldDailyDeaths',
	   round(sum(cast(new_deaths as int))/sum(cast(total_cases as float))*100,5) as 'WorldDailyDeathPercentatge'
from PortfolioProject..CovidDeaths
where continent is not null
group by date
) tab
)
select concat(day(date),'/', month(date),'/', year(date)) as 'Date',
       WorldDailyCases,
	   WorldDailyDeaths,
	   WorldDailyDeathPercentatge
from cte
where rn=1;


-- Showing the day with highest Covid death 

with cte as
(
select top 1  *,
    ROW_NUMBER() over (order by tab.WorldDailyDeaths desc) as rn
from (select  date,
	   sum(cast(total_cases as float) ) as 'WorldDailyCases',
	   sum(cast(new_deaths as int)) as 'WorldDailyDeaths',
	   round(sum(cast(new_deaths as int))/sum(cast(total_cases as float))*100,5) as 'WorldDailyDeathPercentatge'
from PortfolioProject..CovidDeaths
where continent is not null
group by date
) tab
)
select concat(day(date),'/', month(date),'/', year(date)) as 'Date',
       WorldDailyCases,
	   WorldDailyDeaths,
	   WorldDailyDeathPercentatge
from cte
where rn=1;






--- Death percentage accross the world

select sum(new_cases ) as 'WorldTotalCases',
	   sum(cast(new_deaths as int)) as 'WorldTotalDeaths',
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as 'WorldTotalDeathPercentatge'
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


/*
          
		    JOIN TABLE

*/


--- Joining CovidDeaths and CovidVaccination tables in order to look at the  total population vs total vaccination

select death.continent,
       death.location,
	   death.date,
	   death.population,
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths  death
join PortfolioProject..CovidVaccinations vac
on (death.location=vac.location) and (death.date=vac.date)
where death.continent is not null
order by 2,3;






/*

 USE CTE

*/


With PopvsVac (Continent, Location, Date, Population, New_vaccinantion, RollingPeopleVaccinated)
as 
(
select death.continent,
       death.location,
	   death.date,
	   death.population,
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths  death
join PortfolioProject..CovidVaccinations vac
on (death.location=vac.location) and (death.date=vac.date)
where death.continent is not null
)
select *,
       (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from popvsVac
order by 2,3;






/*     TEMP TABLE  */


drop table  if exists #PercentPopulationVaccined

create table #PercentPopulationVaccined(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccined numeric
)

insert into #PercentPopulationVaccined
select death.continent,
       death.location,
	   death.date,
	   death.population,
	   vac.new_vaccinations, 
	   sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths  death
join PortfolioProject..CovidVaccinations vac
on (death.location=vac.location) and (death.date=vac.date)
where death.continent is not null


select *,  
       (RollingPeopleVaccined/Population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccined
order by 2,3;


 
/*            VIEWS FOR DATA VISUALIZATION   */

-- Create a view to store data for latter visualization

create view PercentPopulationVaccined as
select death.continent, 
       death.location, 
	   death.date,
	   death.population, 
	   vac.new_vaccinations,
	   sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, vac.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
on death.location=vac.location and death.date=vac.date
where death.continent is not null

select *
from PercentPopulationVaccined;




/* SOME TABLES FOR DATA VISUALIZATION IN TABLEAU  */


-- Tables for visualisation in tableau


---1


select sum(new_cases ) as 'WorldTotalCases',
	   sum(cast(new_deaths as int)) as 'WorldTotalDeaths',
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as 'WorldTotalDeathPercentatge'
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;





---2


select location,
       sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount;



---3


select location,
       population,
	   Max(total_cases) as 'HighestInfectionCount',
	  Max( (total_cases/population)*100) as 'PercentPopulationInfected'
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;



---4


select location,
       population,
	   date,
	   Max(total_cases) as 'HighestInfectionCount',
	  Max( (total_cases/population)*100) as 'PercentPopulationInfected'
from PortfolioProject..CovidDeaths
--where continent is not null
group by location, population,date
order by PercentPopulationInfected desc;






























