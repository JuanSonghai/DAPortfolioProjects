select *
From [Portfolio Project1]..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From [Portfolio Project1]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using 

Select Location, Date, total_cases, new_cases, total_deaths, population
From [Portfolio Project1]..CovidDeaths
Order by 1,2



-- Look at Total Cases vs Total Deaths
-- Shows likelihood of Deaths if Covid is contracted in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project1]..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that got covid
Select Location, Date, total_cases, population, (total_cases/population)*100 as ContractingPercentage
From [Portfolio Project1]..CovidDeaths
--Where location like '%states%'
Order by 1,2


--Countires with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentofPopulationInfected
From [Portfolio Project1]..CovidDeaths
-- Where location like '%states%'
Group by Location, Population
Order by PercentofPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select Location, MAX (cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project1]..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount Desc

--------------------BROKEN DOWN BY CONTINENT --------------------------



Select location, MAX (cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project1]..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount Desc


-- Showing the Continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Project1]..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Global Numbers-- 

Select Date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project1]..CovidDeaths
Where continent is not null
Group by Date
Order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project1]..CovidDeaths
Where continent is not null
Order by 1,2

------------- Joining The Tables----------
Select *
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--------------- Looking at Total Population vs Vaccination--------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



------------- USE CTE---------------------

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingVaccinatedCount/Population) * 100
From PopvsVac
 



------------------------TEMP TABLE------------------------------------
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingVaccinatedCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
Select *, (RollingVaccinatedCount/Population) * 100
From #PercentPopulationVaccinated



------------------------CREATING VIEW TO STORE DATA FOR LATER VISUALS----------------------

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM( cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinatedCount
From [Portfolio Project1]..CovidDeaths dea
Join [Portfolio Project1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated