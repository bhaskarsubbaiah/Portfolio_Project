select location,convert(datetime,date,111),total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

---Looking at the Total Cases vs Total Deaths
--Show the likelihood dying if you contract Covid in your conuntry

select location,convert(datetime,date,111),total_cases,total_deaths,round((total_deaths/Nullif(total_cases,0))*100,2) as death_Percentage,
population from CovidDeaths
where location like'%states%'
order by 1,2

--Looking at the Total Cases Vs Population
--Show the percentage of People Got Covid
select location,convert(datetime,date,111),total_cases,population,round((total_cases/population)*100,2) as Percent_0f_Poulation_Infected,
population from CovidDeaths
where location like'%states%'
order by 1,2

--Countries at Highest Infection Rate compare to the Population

select location,population, max(total_cases) as HighestInfection_Count, max(total_cases/nullif(cast(population as float),0))*100 as Percent_Population_Infected
from CovidDeaths
group by location,population
ORDER BY Percent_Population_Infected DESC

--Showing the Countries with Highest Death Count Per Population

select location,max(total_deaths) as Total_Death_Count from CovidDeaths
where continent<> ' '
group by location
order by Total_Death_Count desc


--Let Break it Down by the Continents

select continent,max(total_deaths) as Total_Death_Count from CovidDeaths
where continent<> ' '
group by continent
order by Total_Death_Count desc

--Showing the continent with Highest Death Count per Population

select continent,max(total_deaths) as Total_Death_Count from CovidDeaths
where continent<> ' '
group by continent
order by Total_Death_Count desc

--------------------------------------------------
--Global Number date wise New _cases and Death
select convert(datetime,date,111) as date1, sum(cast(new_cases as int)) as New_Cases_1,sum(cast(new_deaths as int)) as Death_Cases_1
from CovidDeaths
where continent <> ' '
group by convert(datetime,date,111)
order by 1,2

--------------Global Number Percentage---
select convert(datetime,date,111) as date1, sum(cast(new_cases as int)) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_deaths as int))/nullif(sum(cast(new_cases as int)),0)*100 as Death_Percentage
from CovidDeaths
where continent <> ' '
group by convert(datetime,date,111)
order by 1,2
---------------------------------------------------------------------------------------------------------------------------------------

select * from CovidVaccinations

--Part 2  Joining Two table and Looking for  Total Population Vs Vaccination
select dea.continent, dea.location,convert(datetime,dea.date,111) ,dea.population,cast(vac.new_vaccinations as int),
(Rolling_People_Vaccinated)/dea.population  --As we are Not able to used this Newely Created Column here we have to make used of the CTE table
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and convert(datetime,dea.date,111)=convert(datetime,vac.date,111)
where dea.continent <> ' '
order by 2,3
------------------------------------------------------------------------------------------------------------------------------

select count(population) from CovidDeaths
where population=' '

--Used CTE 
WITH PopVsVac (continent,location,date,population2,New_vaccination,Rolling_People_Vaccinated)   -- When Creating CTE for the Table the Number of the Column should be identical in both CTE and query
as
(
select dea.continent, dea.location,convert(datetime,dea.date,111) ,case when dea.population='' then NULL ELSE dea.population END as Pop,cast(vac.new_vaccinations as int),
sum(cast(vac.new_vaccinations as int)) over( partition by dea.location order by dea.location,convert(datetime,dea.date,111)) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and convert(datetime,dea.date,111)=convert(datetime,vac.date,111)
where dea.continent <> ' '
--order by 2,3   *The Order by clause is not Allowed in the CTE table
)
select *, round(cast(Rolling_People_Vaccinated as float)/population2,2)*100 -- Please Note if we not change the datatype as float the result will come as '0'
from PopVsVac
order by 2,3

---Used for the Temp Table-- Please not if we want to do some modification in the temporary table will not happen for that we used Drop Table commands
drop table if exists #temp1
Create table #temp1
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_People_Vaccinated numeric
)
---Inserting the Data in the Temporary Table
insert into #temp1
select dea.continent, dea.location,convert(datetime,dea.date,111) ,case when dea.population='' then NULL ELSE dea.population END as Pop,cast(vac.new_vaccinations as int),
sum(cast(vac.new_vaccinations as int)) over( partition by dea.location order by dea.location,convert(datetime,dea.date,111)) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and convert(datetime,dea.date,111)=convert(datetime,vac.date,111)
where dea.continent <> ' '

-----
select *, round(cast(Rolling_People_Vaccinated as float)/population,2)*100 -- Please Note if we not change the datatype as float the result will come as '0'
from #temp1

----------------------Creating the View of the Percntage of People Vacccinated for the visualisation	-----
create view percentpopulationvaccinated as
select dea.continent, dea.location,convert(datetime,dea.date,111) as date1 ,case when dea.population='' then NULL ELSE dea.population END as Pop,cast(vac.new_vaccinations as int) as new_vaaccination,
sum(cast(vac.new_vaccinations as int)) over( partition by dea.location order by dea.location,convert(datetime,dea.date,111)) as RolllingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and convert(datetime,dea.date,111)=convert(datetime,vac.date,111)
where dea.continent <> ''






















