--Sharar Sifat
--COVID-19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Selecting data that we will use
Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2 


--Let's look at total cases vs total deaths
--Shows what percentage of Canadians have died through contracting covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
From PortfolioProject..CovidDeaths 
WHERE Location='Canada' and continent is not null
order by 1,2 


--Let's take a look at total cases vs the population
--Shows what percentage of Canadians have gotten covid
Select Location, date, total_cases, population, (total_cases/population)*100 as covid_percentage 
From PortfolioProject..CovidDeaths 
WHERE Location='Canada'
order by 1,2 


--Countries with highest infection rate compared to population size
Select Location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as covid_percentage 
From PortfolioProject..CovidDeaths 
--WHERE Location='Canada'
group by Location, population
order by covid_percentage desc



--Countries with highest death count per capita
Select Location, max(convert(int,total_deaths)) as total_death_count
From PortfolioProject..CovidDeaths 
WHERE continent != 'null'
group by Location
order by total_death_count desc


--Continents with highest death count per capita
Select continent, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths 
WHERE continent is not null
group by continent
order by total_death_count desc


--Global covid mortality rate
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select die.continent, die.location, die.date, die.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by die.Location Order by die.location, die.Date) as vaccinated_people
--, (vaccinated_people/population)*100
From PortfolioProject..CovidDeaths die
Join PortfolioProject..CovidVaccinations vacc
	On die.location = vacc.location
	and die.date = vacc.date
where die.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, vaccinated_people)
as
(
Select die.continent, die.location, die.date, die.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by die.Location Order by die.location, die.Date) as vaccinated_people
--, (vaccinated_people/population)*100
From PortfolioProject..CovidDeaths die
Join PortfolioProject..CovidVaccinations vacc
	On die.location = vacc.location
	and die.date = vacc.date
where die.continent is not null 
--order by 2,3
)
Select *, (vaccinated_people/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
vaccinated_people numeric
)

Insert into #PercentPopulationVaccinated
Select die.continent, die.location, die.date, die.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by die.Location Order by die.location, die.Date) as vaccinated_people
--, (vaccinated_people/population)*100
From PortfolioProject..CovidDeaths die
Join PortfolioProject..CovidVaccinations vacc
	On die.location = vacc.location
	and die.date = vacc.date
--where dea.continent is not null 
--order by 2,3

Select *, (vaccinated_people/Population)*100
From #PercentPopulationVaccinated

go


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select die.continent, die.location, die.date, die.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by die.Location Order by die.location, die.Date) as vaccinated_people
--, (vaccinated_people/population)*100
From PortfolioProject..CovidDeaths die
Join PortfolioProject..CovidVaccinations vacc
	On die.location = vacc.location
	and die.date = vacc.date
where die.continent is not null 











