Select * from [Portoflio Project]..CovidDeaths$
where continent is not null
order by 3,4



--Select * from [Portoflio Project]..CovidVaccinations$
--order by 3,4 

 -- select the data that we are going to be using

 Select location, date, total_cases, new_cases,total_deaths, population 
 from [Portoflio Project]..CovidDeaths$
 where continent is not null
 order by 1,2

 -- Looking at total Cases vs Total Deaths
 -- show likelihood of dying if you contract covid in your country

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from [Portoflio Project]..CovidDeaths$
 where location like '%states%'
 order by 1,2

 -- total cases vs population
 -- show what percentage of population got covid	

 Select location, date, population, total_cases, (total_cases/population)*100 as PersonPopulationInfected
 from [Portoflio Project]..CovidDeaths$
 where location like '%states%'
 order by 1,2


 -- looking at Countries with highest infection rate compared  to Population


Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100
as Percentagepopulationinfected
from [Portoflio Project]..CovidDeaths$
--where location like '%states%'
group by location, population 
order by Percentagepopulationinfected desc


-- showing countries with highest Death count per population


Select location, Max(cast(total_deaths as int)) as TotalDeathcount
from [Portoflio Project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathcount desc


-- Lets break thing down by continent
-- showing continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathcount
from [Portoflio Project]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathcount desc


--Global Numbers


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portoflio Project]..CovidDeaths$
where continent is not null
group by date
order by 1,2

--total cases vs total deaths

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portoflio Project]..CovidDeaths$
where continent is not null
--group by date
order by 1,2




--Covid Vaccination Table Start

select * from [Portoflio Project]..CovidVaccinations$


--Join
--Looking at total population vs vaccination

select  dea.continent, dea.location, dea.date, dea.population	, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from [Portoflio Project]..CovidDeaths$ dea
join [Portoflio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--Using CTE

With PopvsVac (continent, location, date, population, New_vaccination, Rollingpeoplevaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population	, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from [Portoflio Project]..CovidDeaths$ dea
join [Portoflio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (Rollingpeoplevaccinated/population)*100 
from PopvsVac



--Temp Table



create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population	, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from [Portoflio Project]..CovidDeaths$ dea
join [Portoflio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (Rollingpeoplevaccinated/population)*100 
from #percentPopulationVaccinated




--creating view to store data for later visualization

create view percentPopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population	, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
from [Portoflio Project]..CovidDeaths$ dea
join [Portoflio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3