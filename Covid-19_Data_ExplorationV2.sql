-- How many total cases, new cases, population and total deaths per day for each country.
SELECT 
  Location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population 
FROM 
  dbo.CovidDeaths 
WHERE 
  continent IS NOT NUll 
ORDER BY 
  1, 2 
  
  
  -- Total cases vs total deaths
  -- How many people are dying because of Covid-19 in India each day?
  -- Death rate related to Covid-19 cases in a country.
SELECT 
  continent AS Continent, 
  Location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths / total_cases) * 100 AS Death_Percentage 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  location like '%Ind%' 
  AND continent IS NOT NUll 
ORDER BY 
  1, 2 
  
  
  -- Total cases vs total Population
  -- How much percent of the population is infected for Covid-19?
SELECT 
  continent AS Continent, 
  Location, 
  date, 
  total_cases, 
  population, 
  (total_cases / population) * 100 AS Population_Percentage 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths --Where location like '%Ind%', for any specific country.
WHERE 
  continent IS NOT NUll 
ORDER BY 
  2, 3
  
  
  -- Which country have the highest infection rate compared to the population?
SELECT 
  continent AS Continent, 
  Location, 
  MAX(total_cases) As MaximumCases, 
  population, 
  MAX(
    (total_cases / population)
  ) * 100 AS HighestPopulationPercentInfected 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS NOT NUll 
GROUP BY 
  continent, 
  location, 
  population 
HAVING 
  population > 30000000 
ORDER BY 
  HighestPopulationPercentInfected desc;
--Insight: USA has the highest infected population of nearly 10% of the population infected ignoring the countries with
--higher infection percent with smaller population.
--Tanzania with population 59734213, have only 509 total cases.



-- Countries with highest death count
-- Which country have recorded maximum deaths related to Covid-19?
SELECT 
  continent AS Continent, 
  Location, 
  MAX(
    CAST(total_deaths as int)
  ) As MaximumDeaths -- total_deaths have a different datatype so need to change the datatype to perform MAX function correctly.
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS NOT NUll 
GROUP BY 
  continent, 
  location --having population > 30000000 
ORDER BY 
  MaximumDeaths desc;


-- Continent with maximum deaths
-- Which Continent have recorded maximum deaths related to Covid-19, which has recorded least?
SELECT 
  continent AS Continent, 
  MAX(
    CAST(total_deaths as int)
  ) As MaximumDeaths, 
  SUM(population) As TotalPopulation 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS not NUll 
GROUP BY 
  continent 
ORDER BY 
  MaximumDeaths desc;
--Insights: North America has recorded maximum deaths wheras oceania have recorded minimum.
--It is important to note that Asia have significantly high number of population compared to North America.



-- Worldwide numbers per day
-- How much did the cases, deaths increase day by day across the world?
-- How much percent of people died in the world every day because of Covid-19?
SELECT 
  date, 
  SUM(new_cases) AS TotalCases, 
  SUM(
    CAST(new_deaths AS int)
  ) As TotalDeaths, 
  SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS Death_Percentage 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS NOT NUll 
GROUP BY 
  date 
ORDER BY 
  1,2 
  
  
  -- Worldwide numbers in Total
  -- How many total cases have been registered so far in total?
  -- How many total deaths have been confirmed in total?
SELECT 
  SUM(new_cases) AS TotalCases, 
  SUM(
    CAST(new_deaths AS int)
  ) As TotalDeaths, 
  SUM(
    CAST(new_deaths AS int)
  ) / SUM(new_cases) * 100 AS Death_Percentage 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS NOT NUll 
ORDER BY 
  1, 2 
-- Insights:Around 2 out of every 100 Covid-19 patients, dies because of the virus.



-- What is the reproduction rate of the virus in each Country each day?
SELECT 
  continent, 
  location, 
  date, 
  CAST(total_cases AS int) AS TotalCases, 
  CAST(reproduction_rate AS float) AS ReproductionRate 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS NOT NULL 
ORDER BY 
  1,2,3
  
  
  
  --Binning Handwashing_facility data in to groups
  --How is the handwashing facility of each nation(High, medium, or low)
SELECT 
  location AS Location, 
  AVG(handwashing_facilities) As Avg_handwash, 
  CASE WHEN AVG(handwashing_facilities) < 30 THEN 'Low' WHEN AVG(handwashing_facilities) >= 30 
  AND AVG(handwashing_facilities) < 70 THEN 'Medium' WHEN AVG(handwashing_facilities) >= 70 
  AND AVG(handwashing_facilities) <= 100 THEN 'High' Else 'Unknown' END AS Handwashing_facilities_Group 
FROM 
  [CovidDataAnalysis].[dbo].[CovidVaccination] 
GROUP BY 
  location 
ORDER BY 
  Avg_handwash DESC
  
  
  
  
  --Population VS Tests
  --How many new tests are done every day in INDIA
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_tests AS NewTests 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
  AND dea.location = 'India' 
ORDER BY 
  2,3 
  
  
  
  -- Population vs Total Tests
  -- How many tests aredone in INDIA overall?
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_tests AS NewTests, 
  SUM(
    Convert(int, vac.new_tests)
  ) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfNewTests 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
  AND dea.location = 'India' 
ORDER BY 
  2,3
  --Insight: In India till 4th May, 2021 287,937,672 of test have been done.
  
  
  
  -- Percentage of population tested
  -- CTE 
  WITH PopVsTests(
    continent, location, date, population, new_tests, RunnningTotalOfNewTests)
	AS (
    SELECT 
      dea.continent, 
      dea.location, 
      dea.date, 
      dea.population, 
      vac.new_tests AS NewTests, 
      SUM(
        Convert(int, vac.new_tests)
      ) OVER (
        PARTITION BY dea.location 
        ORDER BY 
          dea.location, 
          dea.date
      ) AS RunnningTotalOfNewTests 
    From 
      [CovidDataAnalysis].dbo.CovidDeaths dea 
      JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
      AND dea.date = vac.date 
    WHERE 
      dea.continent IS NOT NULL 
      AND dea.location = 'India'
  ) 
SELECT 
  *, 
  (
    RunnningTotalOfNewTests / population
  ) * 100 As PercentPopulationTested 
FROM 
  PopVsTests 
  --Insights: In India around 20% of the population have been tested for Covid-19.
  
  
  -- Temp Table
DROP 
  TABLE IF EXISTS #PercentTests 
  CREATE TABLE #PercentTests
  (
    Continent nvarchar(255), 
    location nvarchar(255), 
    date DATETIME, 
    population numeric, 
    new_tests numeric, 
    RunnningTotalOfNewTests numeric
  ) 
  INSERT INTO #PercentTests
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations AS NewVaccination, 
  SUM(Convert(int, vac.new_tests)) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfNewTests 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL AND dea.location = 'India'
SELECT 
  *, (RunnningTotalOfNewTests / population) * 100 As PercentPopulationTested 
FROM 
  #PercentTests
  
  
  
  
  -- Create View for PercentPopulationTested
  CREATE VIEW PercentTests AS 
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_tests AS NewTests, 
  SUM(
    Convert(int, vac.new_tests)
  ) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfNewTests 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL --AND dea.location = 'India'
SELECT 
  *, 
  (
    RunnningTotalOfNewTests / population
  ) * 100 As PercentPopulationTested 
FROM 
  PercentTests 
  
  
  --Population vs vaccination
  --How many people are getting vaccinated in INDIA everyday?
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations AS NewVaccinations 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL AND dea.location = 'India'
ORDER BY 
  2,3 
  
  
  
  -- Population Vs Total vaccination
  -- How many people are vaccinated in INDIA?
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations AS NewVaccination, 
  SUM(
    Convert(int, vac.new_vaccinations)
  ) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfPeopleVaccinated 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
  AND dea.location = 'India' 
ORDER BY 
  2, 3 
  --Insights:Till May 4, 2021 total of 14,83,38,878 people are already vaccinated
  --Percentage of people vaccinated in a country
 
 
 
 --CTE
  WITH popVsVac(
    continent, location, date, population, 
    new_vaccinations, RunnningTotalOfPeopleVaccinated
  ) AS (
    SELECT 
      dea.continent, 
      dea.location, 
      dea.date, 
      dea.population, 
      vac.new_vaccinations AS NewVaccination, 
      SUM(
        Convert(int, vac.new_vaccinations)
      ) OVER (
        PARTITION BY dea.location 
        ORDER BY 
          dea.location, 
          dea.date
      ) AS RunnningTotalOfPeopleVaccinated 
    FROM 
      [CovidDataAnalysis].dbo.CovidDeaths dea 
      JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
      AND dea.date = vac.date 
    WHERE 
      dea.continent IS NOT NULL 
      AND dea.location IN ('India', 'united states')     
      ) 
SELECT 
  *, 
  (
    RunnningTotalOfPeopleVaccinated / population
  ) * 100 AS PercentVaccinated 
FROM 
  popVsVac 
  --Insights: In India with the population of 1.3B around 14,83,38,878 doses of vaccine is used so far.
  -- Whereas for US which have a population of around 328M,  23,52,00,191 doses of vaccine is given so far.
  
  
  --Temp Table
DROP 
  TABLE IF EXISTS #PercentVaccination 
  CREATE TABLE #PercentVaccination
  (
    Continent nvarchar(255), 
    location nvarchar(255), 
    date DATETIME, 
    population numeric, 
    new_vaccination numeric, 
    RunnningTotalOfPeopleVaccinated numeric
  ) INSERT INTO #PercentVaccination
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations AS NewVaccination, 
  SUM(
    Convert(int, vac.new_vaccinations)
  ) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfPeopleVaccinated 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL AND dea.location = 'India'
SELECT 
  *, 
  (
    RunnningTotalOfPeopleVaccinated / population
  ) * 100 AS PercentVaccinated 
FROM 
  #PercentVaccination
  
  
  
  -- Create View for PercentPopulationVaccinated
  CREATE VIEW PercentVaccinationView AS 
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations AS NewVaccinations, 
  SUM(
    Convert(int, vac.new_vaccinations)
  ) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RunnningTotalOfNewVaccinations 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths dea 
  JOIN [CovidDataAnalysis].[dbo].[CovidVaccination] vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
SELECT 
  *, 
  (
    RunnningTotalOfNewVaccinations / population
  ) * 100 As PercentPopulationVaccinated 
FROM 
  PercentVaccinationView 
WHERE 
  location = 'India' 
  
  
  
  --Views for Worldwide numbers
   
  --Maximum Deaths
  CREATE VIEW WorldWideDeaths AS 
SELECT 
  continent AS Continent, 
  MAX(
    CAST(total_deaths as int)
  ) As MaximumDeaths 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS not NUll 
GROUP BY 
  continent 
SELECT 
  * 
FROM 
  WorldWideDeaths 
  
  
  -- Maximum New Cases
  CREATE VIEW WorldWideCases AS 
SELECT 
  continent AS Continent, 
  MAX(
    CAST(total_cases as int)
  ) As MaximumCases 
FROM 
  [CovidDataAnalysis].dbo.CovidDeaths 
WHERE 
  continent IS not NUll 
GROUP BY 
  continent 
SELECT 
  * 
FROM 
  WorldWideCases
