SELECT *
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
order by 3, 4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--order by 3, 4

--Data Selection for usage

SELECT location, date, total_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1, 2

-- Total cases vs Total deaths 
-- The percentage of people who died who had covid.
-- Shows the likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE LOCATION = 'Ghana'
order by 1, 2;


-- Looking at the total cases vs population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE LOCATION = 'Ghana'
order by 1, 2;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION = 'Ghana'
WHERE continent is not null
GROUP BY population, Location
order by PercentPopulationInfected DESC

-- Breaking it down by Continent

-- sHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULAITON

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION = 'Ghana'
WHERE continent is not null
GROUP BY continent 
order by TotalDeathCount DESC;



-- Showing the continent with the highest death count
 
 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--WHERE LOCATION = 'Ghana'
WHERE continent is not null
GROUP BY continent 
order by TotalDeathCount DESC;


-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
where continent is not null
GROUP BY date
order by 1, 2;

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
where continent is not null
--GROUP BY date
order by 1, 2;

-- Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use Cte

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


--Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated;