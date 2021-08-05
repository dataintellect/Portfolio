--Parent Table
select * from [InternationalCovid19Cases]

-- Creating a view with the country names and their acronyms
create view countries as
select distinct(name_en),id 
from [InternationalCovid19Cases]

--  Checking the contents of the view
select * from countries
order by name_en

-- Creating a view with only necessary data from the Parent table
create view covid_info as
select id, date, cases, deaths 
from [InternationalCovid19Cases]

-- Checking the contents of the view
select * from covid_info

-- Altering the view to include date parts column
Alter view covid_info as
select id as CountryId, 
	date as Date,
	datepart(year, date) as YearOfDate,
	datename(month,date) as MonthOfDate,
	datepart(day,date) as DayOfDate,
	cases as NumberOfCases, 
	deaths as NumberOfDeaths 
from [InternationalCovid19Cases]

-- Fetching the details when there were highest number of cases in the world with joins
	
select countries.name_en as Country,
	NumberOfCases,
	MonthOfDate,
	DayOfDate,
	YearOfDate		
from covid_info, countries
where CountryId = countries.id and 
	NumberOfCases = 
	(
	select MAX(numberofcases) 
	from covid_info
	)

-- Fetching the date with top 10 highest number of cases in the world

select Top 10 countries.name_en as Country,
	NumberOfCases,
	MonthOfDate,
	DayOfDate,
	YearOfDate		
from covid_info, countries
where CountryId = countries.id  
	order by NumberOfCases desc

-- Creating a view with the top ten number of cases

create view top_10_view as
select Top 10 countries.name_en as Country,
	NumberOfCases,
	MonthOfDate,
	DayOfDate,
	YearOfDate		
from covid_info, countries
where CountryId = countries.id  
	order by NumberOfCases desc

	-- Altering the view to include the rowid

alter view top_10_view as 
	select Top 10 countries.name_en as Country,
	ROW_NUMBER() over(order by CountryId  asc)  as rowid,
	NumberOfCases,
	MonthOfDate,
	DayOfDate,
	YearOfDate		
from covid_info, countries
where CountryId = countries.id  
	order by NumberOfCases desc 

--Checking the view

select * from top_10_view order by NumberOfCases asc
	
-- Calculating the percent difference between the number of cases in the top 10 

select
	Country,
	MonthOfDate,
	DayOfDate,
	YearOfDate,
	cast((NumberOfCases - LAG(NumberOfCases) over (order by NumberOfCases)) as float)*
	100/LAG(NumberOfCases) over (order by NumberOfCases) as PercentChange
from top_10_view
order by NumberOfCases asc

-- Creating a view with calculations for the %Difference

drop view percentchange_view

create view PercentChange_view as
select *, "DifferenceInCases" = 
			Case 
				when NumberOfCases = 0 then 0
				when NumberOfCases > 0 then 
					cast((NumberOfCases - LAG(NumberOfCases) over (order by NumberOfCases)) as float)
			end,
		"PreviousDayCasesValue" = LAG(NumberOfCases) over (order by NumberOfCases),
		"PreviousDayDeathValue" = LAG(NumberOfDeaths) over (order by NumberOfDeaths),
		"DifferenceInDeaths" = 
			Case 
				when NumberOfDeaths = 0 then 0
				when NumberOfDeaths > 0 then 
					cast((NumberOfDeaths - LAG(NumberOfDeaths) over (order by NumberOfDeaths)) as float)
			end
from covid_info

-- Calculating % Difference 
select *, "PercentDifferenceInCases"=
			case
				when DifferenceInCases = 0 then 0
				when DifferenceInCases > 0 then 
					case 
						when PreviousDayCasesValue = 0 then 0
						when PreviousDayCasesValue > 0 then 
							(DifferenceInCases/PreviousDayCasesValue)*100
					end
			end,
	"PercentDifferenceInDeaths"=
		case
			when DifferenceInDeaths = 0 then 0
			when DifferenceInDeaths > 0 then 
			case 
				when PreviousDayDeathValue = 0 then 0
				when PreviousDayDeathValue > 0 then 
					(DifferenceInDeaths/PreviousDayDeathValue)*100
			end
	end
from PercentChange_view
order by CountryId 

-- Creating a view with the details for highest rate of cases and death calculations
drop view highest_info_view
create view Highest_info_view
as
select CountryId,DayOfDate,MonthOfDate,YearOfDate, 
countries.name_en as CountryName,
"PercentDifferenceInCases"=
			case
				when DifferenceInCases = 0 then 0
				when DifferenceInCases > 0 then 
					case 
						when PreviousDayCasesValue = 0 then 0
						when PreviousDayCasesValue > 0 then 
							(DifferenceInCases/PreviousDayCasesValue)*100
					end
			end,
	"PercentDifferenceInDeaths"=
		case
			when DifferenceInDeaths = 0 then 0
			when DifferenceInDeaths > 0 then 
			case 
				when PreviousDayDeathValue = 0 then 0
				when PreviousDayDeathValue > 0 then 
					(DifferenceInDeaths/PreviousDayDeathValue)*100
			end
	end
from PercentChange_view , countries
where CountryId = countries.id




	







 
	








