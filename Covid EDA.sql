use CovidDB;

select * 
from [dbo].[CovidDeaths] 

-------Selected Columns 

select [location],[date],[total_cases],[new_cases],[total_deaths],[new_deaths],[population]
from [dbo].[CovidDeaths]

--Split date into Day ,Month , Year

ALTER TABLE [CovidDeaths]
ADD Day INT NULL,
    Month INT NULL,
	Year INT NULL; 

UPDATE [CovidDeaths]
SET Day =DAY(date),
    Month=Month(date),
    Year=YEAR(date);

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths int NULL;
ALTER TABLE CovidDeaths
ALTER COLUMN [new_deaths] int NULL;
ALTER TABLE CovidDeaths
ALTER COLUMN date date NULL;

SELECT [location],[date],[total_cases],[new_cases],[total_deaths],[new_deaths],[population] , Day , Month , Year 
from [CovidDeaths]
WHERE continent IS NOT NULL;


--Total Cases Vs Total Deaths per each Country
SELECT location , SUM(total_cases) AS Total_Cases , SUM(total_deaths) AS Total_Deaths,
                  ROUND( (SUM(total_deaths)/SUM(total_cases))*100 , 2) AS DeathCasesPercentage
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY 1;

--Total deaths to total cases in the United States within date
select [date],[total_cases],[total_deaths],ROUND( ([total_deaths] / [total_cases] )*100,2) AS DeathPercentage
from [dbo].[CovidDeaths]
WHERE [location] = 'United States' AND continent IS NOT NULL 
order by 1,2;

--Total cases to population 
select [location],[date],[total_cases],[population],ROUND( ([total_cases] / [population] )*100,2)  AS 'Infection rate'
from [dbo].[CovidDeaths]
WHERE continent IS NOT NULL  
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
select [location],[population],MAX([total_cases]) AS 'Highest infected cases',
        ROUND(MAX( ([total_cases] / [population] ) )*100,2)  AS 'Percent population Infected'
from [dbo].[CovidDeaths]
WHERE continent IS NOT NULL  
GROUP BY [location],[population]
ORDER BY (MAX( ([total_cases] / [population] ) )*100) DESC;

--Countries with highest deaths count  
SELECT location ,  MAX(total_deaths) AS 'Highest deaths count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY 2 DESC;

--Continents with highest deaths count  
SELECT continent , max(total_deaths) AS 'Total deaths count'
FROM CovidDeaths
WHERE continent IS Not NULL
GROUP BY continent 
ORDER BY 2 DESC;

-- Total new cases and Total new deaths for each year
SELECT Year , SUM (new_cases) AS 'Total new cases',SUM (new_deaths) AS 'Total new deaths', 
              ROUND( (SUM (new_deaths)/SUM (new_cases))*100  , 2)  AS DeathPercentage
FROM [CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY CUBE(Year)
ORDER BY 1 ;

--Total deaths per each month 
SELECT Month , SUM (total_deaths) AS 'Total deaths'
FROM [CovidDeaths]
GROUP BY Month
ORDER BY 2 DESC ;

--Total new cases to Total population per each country
SELECT location,SUM(new_cases) AS 'Total new cases' ,SUM(population) AS 'Total Population' 
FROM [CovidDeaths]
GROUP BY location 

-- Running Total new vaccinations per each country

ALTER TABLE [CovidVaccinations]
ALTER COLUMN new_vaccinations INT NULL;

SELECT cd.continent,cd.location , cd.date ,cd.population,cv.new_vaccinations, 
       SUM(cv.new_vaccinations) OVER( PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS Total_new_vacc
FROM [dbo].[CovidDeaths] AS cd INNER JOIN [dbo].[CovidVaccinations] cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

-- Percentage of Vaccine availability to popualtion 
WITH VacVsPop(Continent,Country,Date,Population,[New Vaccinations],[Running Total New Vaccination])
AS
(
SELECT cd.continent,cd.location , cd.date ,cd.population,cv.new_vaccinations, 
       SUM(cv.new_vaccinations) OVER( PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS Total_new_vacc
FROM [dbo].[CovidDeaths] AS cd INNER JOIN [dbo].[CovidVaccinations] cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 
)
SELECT *,ROUND( ([Running Total New Vaccination]/Population)*100,2) AS Vaccine_Avail_to_Pop
FROM VacVsPop;

--Temp Table 
DROP TABLE IF EXISTS #popvac
CREATE TABLE #popvac(
Continent NVARCHAR(50),
Location NVARCHAR(50),
Date DATE,
Population INT,
[New Vaccinations] INT,
[Running Total New Vaccination] FLoat
);

GO
INSERT INTO #PopvsVacc
SELECT cd.continent,cd.location , cd.date ,cd.population,cv.new_vaccinations, 
       SUM(cv.new_vaccinations) OVER( PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS Total_new_vacc
FROM [dbo].[CovidDeaths] AS cd INNER JOIN [dbo].[CovidVaccinations] cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 
GO
SELECT * ,ROUND( ([Running Total New Vaccination]/Population)*100,3)  AS Vacc_Avail_to_Pop
FROM #PopvsVacc
ORDER BY 2,3

-- View
CREATE VIEW PopvsVacc
AS 
SELECT cd.continent,cd.location , cd.date ,cd.population,cv.new_vaccinations, 
       SUM(cv.new_vaccinations) OVER( PARTITION BY cd.location ORDER BY cd.location,cd.date ) AS Total_new_vacc
FROM [dbo].[CovidDeaths] AS cd INNER JOIN [dbo].[CovidVaccinations] cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 

SELECT * FROM PopvsVacc






