SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data 

SELECT Location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs Total Deaths In United States

SELECT Location,
date,
total_cases,
total_deaths,
ROUND((total_deaths/total_cases)*100,2) as Deathprcnt
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Total cases vs Population in United States

SELECT Location,
date,
total_cases,
population,
ROUND((total_cases/population)*100,4) as cases_per_pop
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Countries w/ highest infection rate compared to population

SELECT Location,
population,
MAX(total_cases) as highestcases,
ROUND((MAX(total_cases)/population)*100,4) as cases_per_pop
FROM PortfolioProject..CovidDeaths
GROUP by location, population
order by cases_per_pop DESC

-- Countries w/ highest death percentage

SELECT Location,
MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP by location
order by TotalDeathCount DESC

-- Deaths by continent

SELECT continent,
MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP by continent
order by TotalDeathCount DESC

-- Global Numbers
SELECT
--date,
SUM(new_cases) as totalcases,
SUM(cast(new_deaths as int)) as totaldeaths,
ROUND(SUM(cast(new_deaths as int))/sum(new_cases)*100,4) as deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--group by date
order by 1,2

-- Total population vs vaccination

SELECT cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_vaccination
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
ORDER BY 2,3

--CTE
WITH PopVsVac (Continent, location, date, population, new_vaccinations, rolling_vaccination)
as(
SELECT cd.continent,
cd.location,
cd.date,
cd.population,
cv.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_vaccination
FROM PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--ORDER BY 2,3
)

SELECT *, ROUND((rolling_vaccination/population)*100,4) as Rolling_Percent
FROM PopVsVac


