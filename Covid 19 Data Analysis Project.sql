-- Select the data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Displays the likelihood of dying if you contract Covid in South Africa

SELECT location, date, total_cases, total_deaths, (convert( float, total_deaths)/NULLIF(convert(float, total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1, 2

-- Total Cases vs Population
-- Displays what percentage of population got Covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1, 2

-- Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  (MAX(total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectedPercentage Desc

-- Showing the total deaths in continents

SELECT continent, MAX(Convert(int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc

-- Showing Countries with Highest Death Count per population

SELECT location, MAX(Convert(int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount Desc

-- Global death percentage

SELECT SUM(new_cases) as TotalCases, SUM(convert(int, new_deaths)) as TotalDeaths, SUM(convert(int, new_deaths))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
, SUM(Convert(bigint, Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Deaths
Join PortfolioProject.dbo.CovidVaccinations AS Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
ORDER BY 2,3

-- Temp Table to calculate Total Population vs Vaccinations

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinate numeric
)

INSERT INTO #PercentaPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
, SUM(Convert(bigint, Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Deaths
Join PortfolioProject.dbo.CovidVaccinations AS Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View for later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
, SUM(Convert(bigint, Vaccinations.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS RollingPeaopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Deaths
Join PortfolioProject.dbo.CovidVaccinations AS Vaccinations
	On Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
