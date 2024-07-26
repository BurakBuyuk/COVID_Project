SELECT * 
FROM Covid..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM Covid..CovidVaccinations
ORDER BY 3,4

--Kullanacaðýmýz verilerin seçilmesi

SELECT location, date , total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths

SELECT location, date , total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE location like '%turkey%'
ORDER BY 1,2
  
--Total Cases vs Population

SELECT location, date , total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM Covid..CovidDeaths
WHERE location like '%turkey%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

 --LET's BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing contintents with the highest death count per population
 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date , SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
--WHERE location like '%turkey%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT TOP 10 * FROM CovidDeaths
SELECT TOP 10 * FROM  CovidVaccinations

SELECT * FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
,dea.Date)
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
,dea.Date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
,dea.Date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
,dea.Date) as RollingPeopleVaccinated
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM  PercentPopulationVaccinated 
