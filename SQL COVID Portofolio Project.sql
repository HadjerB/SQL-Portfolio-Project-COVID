SELECT * FROM [dbo].[CovidDeaths]
ORDER BY location,date;

/* SELECT * FROM ..[CovidVaccinations (2)]
ORDER BY location,date; */

/* Looking at Total Cases vs Total Deaths */
/* Shows likelihood of dying if you contract covid in your country */

SELECT location,date,total_cases, new_cases,total_deaths, (cast(total_deaths AS float)/ (total_cases)*100) AS DeathPercentage
FROM [dbo].[CovidDeaths]
ORDER BY location,date 


/* Looking at Total Cases vs Population  */
/* Shows what percentage of population got Covid */

SELECT location,date,total_cases, population, (cast(total_cases AS float)/ (population)*100) AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
WHERE location like '%france%'
ORDER BY location,date 

/* Looking at Countries with Highest Infection Rate compared to Population */

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(cast([total_cases] AS float)/ population)*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

/* Looking at Countries with Highest Infection Rate compared to Population */

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(cast([total_cases] AS float)/ population)*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

/* Looking at Countries with the Highest Death Count per Population */

SELECT location, MAX([total_deaths]) AS TotalDeathCount  
FROM [dbo].[CovidDeaths]
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

/* Now we break things down by Continent */

/* Showing Continents with the Highest Death Count */

SELECT continent, MAX([total_deaths]) AS TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

/* GLOBAL NUMBERS  */

SELECT date, SUM([new_cases]) as total_cases, SUM([new_deaths]) as total_deaths, (SUM(cast(new_deaths as float))/SUM([new_cases]))*100 AS DeathPercentage
FROM[dbo].[CovidDeaths]
WHERE continent is NOT NULL
GROUP BY [date]
ORDER BY 1,2

/* Looking at Total Population vs Vaccinations */

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations (2)] vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea 
JOIN [dbo].[CovidVaccinations (2)] vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

/* USE CTE */

With PopVsVac (Continent,location, DATE,population,new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea 
JOIN [dbo].[CovidVaccinations (2)] vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
) 

SELECT *, (RollingPeopleVaccinated/convert(float,population))*100
FROM PopVsVac
Order by 2,3


/* TEMP TABLE */

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea 
JOIN [dbo].[CovidVaccinations (2)] vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/convert(float,population))*100
FROM #PercentPeopleVaccinated
Order by 2,3

/* Creating View to store data for later visualizations */

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea 
JOIN [dbo].[CovidVaccinations (2)] vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL

