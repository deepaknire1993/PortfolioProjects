SELECT *
FROM portfolioproject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

/* Data that we are looking for*/
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

/*Looking at the total cases vs Total Deaths. Shows likelyhood of Death if you infect Covid */
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/CONVERT(float, total_cases))*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

--Total  cases vs population
--Shows the %age of the population got the Covid
SELECT location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 as PercentagePopulationInfected
FROM portfolioproject..CovidDeaths
ORDER BY 1, 2

--Countries with Highest Infection Rate Compared to population - 3
SELECT location, population, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 as MaxPercentagePopulationInfected
FROM portfolioproject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY MaxPercentagePopulationInfected DESC

--Based on Date - 4

SELECT location, population, date, MAX(CAST(total_cases AS int)) AS HighestInfectionCount, MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 as PercentagePopulationInfected
FROM portfolioproject.dbo.CovidDeaths
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected DESC

--Countries with Highest Death Count Per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAK DOWN BY CONTINENTS
--CONTINENTS with Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--EU is part of Europe AND also base on Location - 2

SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is NULL
AND location NOT IN('World','International','European Union','High income','Upper middle income','Lower middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC	

--GLOBAL NUMBERS - 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE continent is not NULL 
--GROUP BY date
ORDER BY 1, 2

--

--EXPLORING COVID VACCINATION DATA
--Looking at the Total Population vs Vaccination
--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) --Since we cannot use Alias to Devide
FROM portfolioproject.dbo.CovidDeaths dea
JOIN portfolioproject.dbo.CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
population numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) --Since we cannot use Alias to Devide
FROM portfolioproject.dbo.CovidDeaths dea
JOIN portfolioproject.dbo.CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/NULLIF(population,0))*100
FROM #PercentPopulationVaccinated 

--CREATING VIEW For Data Visualization

use portfolioproject;
CREATE View PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) --Since we cannot use Alias to Divide
FROM portfolioproject.dbo.CovidDeaths dea
JOIN portfolioproject.dbo.CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated 

