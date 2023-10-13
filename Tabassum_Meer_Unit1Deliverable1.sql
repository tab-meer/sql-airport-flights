USE AIRTRAFFIC; -- Set AirTraffic as the default schema

/*********

QUESTION 1

*********/

-- Q1.1 - How many flights were there in 2018 and 2019 separately?
SELECT 
    YEAR(FLIGHTDATE) AS YEAR, -- fetch only the year component of the dates in the flightdate column
    COUNT(*) AS NUMBER_OF_FLIGHTS  -- count the number of rows in the flights table (this is equivalent to the number of flights)
FROM
    FLIGHTS
GROUP BY YEAR  -- group by the corresponding flight year to show the number of flights per year
;

/*
|   YEAR   |  NUMBER_OF_FLIGHTS  |
|----------|---------------------|
|   2018   |      3218653        |
|   2019   |      3302708        |

Both years had relatively the same number of flights, but there was a slight increase from 2018 to 2019 (84,055 more flights in 2019).
From a business context, this is good to see as it shows growth within the airlines/travel industry.
*/


-- Q1.2 - In total, how many flights were cancelled or departed late over both years?
SELECT
	COUNT(FLIGHTS_CANCELLED) AS FLIGHTS_CANCELLED,  -- The main query counts the number of occurrences in both columns
    COUNT(FLIGHTS_DELAYED) AS FLIGHTS_DELAYED
FROM
	(SELECT  -- The subquery creates two new indicator columns, 'FLIGHTS_CANCELLED' and 'FLIGHTS_DELAYED'
		IF (CANCELLED = 1, 1, NULL) AS FLIGHTS_CANCELLED,  -- if a value in the cancelled column is equal to 1, then return 1, or return NULL
		IF (DEPDELAY > 0, 1, NULL) AS FLIGHTS_DELAYED  -- if a value in the depdelay column is greater than 0, then return 1, or return NULL 
        -- I want the values for both columns to be either 1 or NULL so that when the COUNT(column_name) function in the SELECT clause executes, it counts only the 1's, which is the correct count of number of flights. If the values were 1 or 0, then the COUNT(column_name) function would count the 0's as well which is not what we want. (Different from COUNT(*), where NULL values are counted)
	FROM 
		FLIGHTS
	WHERE  -- The WHERE clause was included for efficiency purposes as the flights table has ~6.5 million records. The IF statements will be applied to only relevant rows after this filter. 
		CANCELLED = 1
        OR DEPDELAY > 0
	) AS CANCELLED_DELAYED_FLIGHTS
;

/* 
| FLIGHTS_CANCELLED | FLIGHTS_DELAYED |
|-------------------|-----------------|
|       92363       |      2542442    |
*/

/* By exploring the dataset, I discovered that cancelled and delayed flights are not mutually exclusive. 
There are many flights that were cancelled after the airplane had already taken off. This includes flights that departed late.
This is why I decided to use a subquery to first categorize cancelled and delayed flights into separate columns, and then count the number of flights for each. 
I decided to use a subquery because I was getting inaccurate results using one simple aggregation query.
Since cancelled and delayed flights are not mutually exclusive, if a flight meets both conditions it is counted twice, once in the FLIGHTS_CANCELLED column and again in the FLIGHTS_DELAYED column. 

We can clearly see that approximately 2.5 million flights were delayed out of the approximately 6.5 million flights in the dataset. 
That is almost 40% of all flights! This is concerning as this will likely contribute towards unsatisfied and frustrated customers who might not want to fly again with these airlines. 
It will also likely lead to poor word of mouth referrals and the airlines can see a reduction in new customers/flyers. However, this problem may be attributed to the departing airport (origin airport), in which case airlines and airports need to streamline their operations cohesively to reduce flight delays. 
*/


-- Q1.3 - Show the number of flights that were cancelled broken down by the reason for cancellation.
SELECT
	CANCELLATIONREASON AS CANCELLATION_REASON,  -- return the cancellation reason column
    COUNT(*) AS NUMBER_OF_FLIGHTS  -- count the number of rows in the flights table (this is equivalent to the number of flights)
FROM 
	FLIGHTS
WHERE 
	CANCELLED = 1  -- fetch only the cancelled flights 
GROUP BY CANCELLATIONREASON  -- break down the results by grouping the flight count by the cancellation reason
ORDER BY NUMBER_OF_FLIGHTS DESC  -- order the flight count in descending order
;

/*
| CANCELLATION_REASON  | NUMBER_OF_FLIGHTS |
|----------------------|-------------------|
|       Weather        |       50225       |
|       Carrier        |       34141       |
| National Air System  |        7962       |
|       Security       |         35        |

Weather and carrier (airline) related cancellations were the most common reasons for cancelled flights. 
Although the weather is not in our control, carrier related issues likely are within our control, and this is something airlines can directly address.
Carriers (airlines) can mitigate this by routinely keeping up with aircraft maintenance, have enough employees available, updating and streamlining scheduling systems, etc.
*/


-- Q1.4 - For each month in 2019, report both the total number of flights and percentage of flights cancelled.
SELECT 
	DATE_FORMAT(FLIGHTDATE, '%Y-%m') AS DATE,  -- format the date to show the year and month together in one column
    COUNT(*) AS NUMBER_OF_FLIGHTS,  -- count the number of rows in the flights table (this is equivalent to the number of flights)
    ROUND((SUM(CANCELLED)/COUNT(*)) * 100, 2) AS PERCENT_CANCELLED  -- count the number of cancelled flights and divide it by the total number of flights, multiply by 100 to find the percentage, round to 2 decimal places. I used SUM to find the number of cancelled flights here to simplify the query and not use a subquery. This is only possible because of the unique characteristic of the cancelled column where the values are either 0 (not cancelled) or 1 (cancelled), therefore the SUM is equivalent to the total number of cancelled flights.
FROM
	FLIGHTS
WHERE 
	YEAR(FLIGHTDATE) = '2019' -- filter the table to fetch only 2019 flights
GROUP BY DATE  -- group the aggregations by the date
ORDER BY DATE  -- sort the rows by the date in ascending order
;

/*
|   DATE   | NUMBER_OF_FLIGHTS | PERCENT_CANCELLED |
|----------|-------------------|-------------------|
| 2019-01  |      262165       |       2.21        |
| 2019-02  |      237896       |       2.31        |
| 2019-03  |      283648       |       2.50        |
| 2019-04  |      274115       |       2.71        |
| 2019-05  |      285094       |       2.42        |
| 2019-06  |      282653       |       2.18        |
| 2019-07  |      291955       |       1.55        |
| 2019-08  |      290493       |       1.25        |
| 2019-09  |      268625       |       1.24        |
| 2019-10  |      283815       |       0.81        |
| 2019-11  |      266878       |       0.59        |
| 2019-12  |      275371       |       0.51        |
*/

/* Based on your results, what might you say about the cyclic nature of airline revenue?

The number of flights per month in 2019 were relatively the same, however we can see that the first half of the year experienced higher cancellations compared to the second half. 
This could be weather related as the three airlines in the dataset are based in USA, thus they would likely be flying out of and returning to the USA most of the time. 
During the first half of the year is when weather is usually the worst due to snow, ice, rain, and hurricane season. This would affect international and domestic flights, and is understandable why the first half the year experiences the most cancellations. The second half of the year covers better weather with summer and the holiday season (Thanksgiving, Christmas, and New Years). 

Airlines are likely preparing and performing the best during this time as it is usually the most important travel season for most people. Airlines might be exhausting their resources and capacity during this time, which might also be contributing to the higher number of cancelled flights in the first half of the year that follows. 

Cancelled flights also means lower revenue, so taking all these things into consideration, airlines should try their best to manage their resources and schedule effectively in order reduce cancellations later on. 
*/


/*********

QUESTION 2

*********/

-- Q2.1 - Create two new tables, one for each year (2018 and 2019) showing the total miles traveled and number of flights broken down by airline.
DROP TABLE IF EXISTS 2018_FLIGHTS;  -- allows the create table command to be reproducible
CREATE TABLE 2018_FLIGHTS AS  -- creates a working table for 2018 flights
SELECT 
	AIRLINENAME,  -- returns the airline names
    COUNT(*) AS TOTAL_FLIGHTS_2018,  -- count the number of rows in the flights table (this is equivalent to the number of flights)
    SUM(DISTANCE) AS TOTAL_MILES_TRAVELLED_2018  -- return the sum of the values in the distance column
FROM 
	FLIGHTS
WHERE YEAR
	(FLIGHTDATE) = '2018'  -- fetches only the flights dated under 2018
GROUP BY AIRLINENAME  -- group the aggregations by the airline names
ORDER BY AIRLINENAME  -- sort the rows by the airline names in alphabetical order
;

/*
|       AIRLINENAME       | TOTAL_FLIGHTS | TOTAL_MILES_TRAVELLED |
|-------------------------|---------------|-----------------------|
| American Airlines Inc.  |    916818     |       933094276       |
| Delta Air Lines Inc.    |    949283     |       842409169       |
| Southwest Airlines Co.  |   1352552     |      1012847097       |
*/

DROP TABLE IF EXISTS 2019_FLIGHTS;
CREATE TABLE 2019_FLIGHTS AS  -- creates a working table for 2019 flights
SELECT 
	AIRLINENAME,
    COUNT(*) AS TOTAL_FLIGHTS_2019,
    SUM(DISTANCE) AS TOTAL_MILES_TRAVELLED_2019
FROM 
	FLIGHTS
WHERE YEAR
	(FLIGHTDATE) = '2019'
GROUP BY AIRLINENAME
ORDER BY AIRLINENAME 
;

/*
|       AIRLINENAME       | TOTAL_FLIGHTS | TOTAL_MILES_TRAVELLED |
|-------------------------|---------------|-----------------------|
| American Airlines Inc.  |    946776     |       938328443       |
| Delta Air Lines Inc.    |    991986     |       889277534       |
| Southwest Airlines Co.  |   1363946     |      1011583832       |
*/


-- Q2.2 - Using your new tables, find the year-over-year percent change in total flights and miles traveled for each airline.
SELECT 
	2018_FLIGHTS.AIRLINENAME,
    TOTAL_FLIGHTS_2018,
    TOTAL_FLIGHTS_2019,
    ROUND(((TOTAL_FLIGHTS_2019 - TOTAL_FLIGHTS_2018) / TOTAL_FLIGHTS_2018) * 100, 2) AS PERCENT_CHANGE_TOTAL_FLIGHTS,  -- calculate the percent change in total flights. Formula used ((new value - old value) / |old value|) * 100 
    TOTAL_MILES_TRAVELLED_2018,
    TOTAL_MILES_TRAVELLED_2019,
    ROUND(((TOTAL_MILES_TRAVELLED_2019 - TOTAL_MILES_TRAVELLED_2018) / TOTAL_MILES_TRAVELLED_2018) * 100, 2) AS PERCENT_CHANGE_TOTAL_MILES_TRAVELLED  -- calculate the percent change in total miles travelled. Formula used ((new value - old value) / |old value|) * 100 
FROM
	2018_FLIGHTS 
    INNER JOIN 2019_FLIGHTS 
		ON 2018_FLIGHTS.AIRLINENAME = 2019_FLIGHTS.AIRLINENAME  -- joined the two tables on the airline name column as this is the common column between the two tables
;

/*
|       AIRLINENAME       | TOTAL_FLIGHTS_2018 | TOTAL_FLIGHTS_2019 | PERCENT_CHANGE_TOTAL_FLIGHTS | TOTAL_MILES_TRAVELLED_2018  | TOTAL_MILES_TRAVELLED_2019  | PERCENT_CHANGE_TOTAL_MILES_TRAVELLED  |
|-------------------------|--------------------|--------------------|------------------------------|-----------------------------|-----------------------------|---------------------------------------|
| American Airlines Inc.  |      916818        |      946776        |           3.27               |        933094276            |        938328443            |               0.56                    |
| Delta Air Lines Inc.    |      949283        |      991986        |           4.50               |        842409169            |        889277534            |               5.56                    |
| Southwest Airlines Co.  |     1352552        |     1363946        |           0.84               |       1012847097            |       1011583832            |              -0.12                    |
*/

/* What investment guidance would you give to the fund managers based on your results?

From the results we can see that all three airlines had a positive year-over-year change in total flights. 
This means that the number of flights in 2019 were higher than 2018, showing growth in business. Delta airlines had the greatest year-over-year change showing the most growth. 
However, the key insight is the percent change in total miles travelled. Although Delta had the greatest year-over-year change in total flights, it also had the greatest year-over-year change in total miles travelled. 
This indicates that although the business grew, the costs also likely increased as well. Some examples of costs that would've increased are fuel costs and employee wage costs as airplanes would likely be in the air longer. 

Based off these results, American Airlines looks like a better investment as it had the second largest year-over-year growth in total flights, and had a very minimal increase in year-over-year total miles travelled. This means that the airline was able to book more flights to bring in revenue, while keeping costs low. 
*/


/*********

QUESTION 3

*********/

-- Q3.1 - What are the names of the 10 most popular destination airports overall? For this question, generate a SQL query that first joins flights and airports then does the necessary aggregation.
SELECT 
	FLIGHTS.DESTAIRPORTID AS DEST_AIRPORT_ID,  -- return the destination airport id
    AIRPORTS.AIRPORTNAME AS DEST_AIRPORT_NAME,  -- return the destination airport name
    COUNT(*) AS NUMBER_OF_STOPS  -- count the number of rows in the flights table (when group by is applied, this will be equivalent to the count of each airport's occurrence, which is the number of stops at each airport)
FROM 
	FLIGHTS
    INNER JOIN AIRPORTS  -- joining the flights table with the airports table to return each airport's name
		ON FLIGHTS.DESTAIRPORTID = AIRPORTS.AIRPORTID  -- matching on the destination airport id (flights) and airport id (airports) because the question asks to return destination airports
GROUP BY
	DEST_AIRPORT_ID,  -- group by the destination airport id and airport name
    DEST_AIRPORT_NAME  
ORDER BY NUMBER_OF_STOPS DESC  -- sort the number of stops in descending order (this gives us the top 10 once limit is applied)
LIMIT 10  -- limit the result set to only 10 rows
;

/*
| DEST_AIRPORT_ID |              DEST_AIRPORT_NAME                       | NUMBER_OF_STOPS |
|-----------------|------------------------------------------------------|-----------------|
|      10397      | Hartsfield-Jackson Atlanta International             |      595527     |
|      11298      |   Dallas/Fort Worth International                    |      314423     |
|      14107      | Phoenix Sky Harbor International                     |      253697     |
|      12892      |     Los Angeles International                        |      238092     |
|      11057      | Charlotte Douglas International                      |      216389     |
|      12889      |      Harry Reid International                        |      200121     |
|      11292      |       Denver International                           |      184935     |
|      10821      | Baltimore/Washington International Thurgood Marshall |      168334     |
|      13487      | Minneapolis-St Paul International                    |      165367     |
|      13232      | Chicago Midway International                         |      165007     |
*/


-- Q3.2 - Answer the same question but using a subquery to aggregate & limit the flight data before your join with the airport information, hence optimizing your query runtime.
SELECT 
	FILTERED_AIRPORTS.DESTAIRPORTID AS DEST_AIRPORT_ID,  -- return the destination airport id
    AIRPORTS.AIRPORTNAME AS DEST_AIRPORT_NAME,  -- return the destination airport name
    FILTERED_AIRPORTS.NUMBER_OF_STOPS  -- return the number of stops
FROM
	(SELECT
		DESTAIRPORTID,  -- return the destination airport id
		COUNT(*) AS NUMBER_OF_STOPS  -- count the number of rows in the flights table (when group by is applied, this will be equivalent to the count of each airport's occurrence, which is the number of stops at each airport)
	FROM
		FLIGHTS
	GROUP BY DESTAIRPORTID -- group by the destination airport id
    ORDER BY NUMBER_OF_STOPS DESC  -- sort the number of stops in descending order (this gives us the top 10 once limit is applied)
    LIMIT 10  -- limit the result set to only 10 rows
	) AS FILTERED_AIRPORTS
	INNER JOIN AIRPORTS
		ON FILTERED_AIRPORTS.DESTAIRPORTID = AIRPORTS.AIRPORTID  -- join the flights and airports tables on the destination airport id and airport id, respectively
ORDER BY NUMBER_OF_STOPS DESC  -- sort the number of stops in descending order (need to sort again as after joining the order is reshuffled)
;

/*
| DEST_AIRPORT_ID |              DEST_AIRPORT_NAME                       | NUMBER_OF_STOPS |
|-----------------|------------------------------------------------------|-----------------|
|      10397      | Hartsfield-Jackson Atlanta International             |      595527     |
|      11298      |   Dallas/Fort Worth International                    |      314423     |
|      14107      | Phoenix Sky Harbor International                     |      253697     |
|      12892      |     Los Angeles International                        |      238092     |
|      11057      | Charlotte Douglas International                      |      216389     |
|      12889      |      Harry Reid International                        |      200121     |
|      11292      |       Denver International                           |      184935     |
|      10821      | Baltimore/Washington International Thurgood Marshall |      168334     |
|      13487      | Minneapolis-St Paul International                    |      165367     |
|      13232      | Chicago Midway International                         |      165007     |
*/

/* If done correctly, the results of these two queries are the same, but their runtime is not. In your SQL script, comment on the runtime: which is faster and why?

Runtimes:
INNER JOIN query: 11.662 sec
Subquery query: 1.602 sec

The Subquery query is much faster than the INNER JOIN query. This is because of the order of operations of queries. 
In the INNER JOIN query, the FROM and INNER JOIN clauses are being executed first, which means that all ~6.5 million rows of flights from the flights table are being joined with the corresponding airports from the airports table. After the join is complete, the query moves on to execute the GROUP BY, SELECT aggregations, ORDER BY and LIMIT clauses, respectively. That means all ~6.5 million rows are being grouped, etc, before being limited at the end to show only 10 rows. Therefore it is understandable why this query took much longer to execute. 

The Subquery query was much faster because the subquery is executed first, which is using only the flights table. 
Although there are still ~6.5 million rows, the process is much faster because the subquery is only grouping and performing a simple aggregation, which it then orders and limits respectively. Now the outer query only has to join 10 rows to the airports table, which is much smaller compared to the INNER JOIN query's ~6.5 million row joins.
*/


/*********

QUESTION 4

*********/

-- Q4.1 - A flight's tail number is the actual number affixed to the fuselage of an aircraft, much like a car license plate. As such, each airplane has a unique tail number and the number of unique tail numbers for each airline should approximate how many airplanes the airline operates in total. Using this information, determine the number of unique aircrafts each airline operated in total over 2018-2019.
SELECT
	AIRLINENAME AS AIRLINE_NAME,  -- return the airline names 
    COUNT(DISTINCT TAIL_NUMBER) AS NUMBER_OF_UNIQUE_AIRCRAFTS  -- count the number of unique tail numbers (when group by is applied this will show the count of unique aircrafts per airline)
FROM
	FLIGHTS
GROUP BY AIRLINE_NAME  -- group by the airline name
ORDER BY AIRLINE_NAME  -- sort the airline names in alphabetical order
;

/*
|       AIRLINE_NAME        | NUMBER_OF_UNIQUE_AIRCRAFTS |
|---------------------------|----------------------------|
| American Airlines Inc.    |             993            |
| Delta Air Lines Inc.      |             988            |
| Southwest Airlines Co.    |             754            |
*/


-- Q4.2 - Similarly, the total miles traveled by each airline gives an idea of total fuel costs and the distance traveled per airplane gives an approximation of total equipment costs. What is the average distance traveled per aircraft for each of the three airlines?
SELECT 
	AIRLINENAME AS AIRLINE_NAME,  -- return the airline names 
    ROUND(SUM(DISTANCE) / COUNT(DISTINCT TAIL_NUMBER), 2) AS AVG_DISTANCE_PER_AIRCRAFT  -- calculate the average distance travelled per aircraft. Formula used: (sum of distance / number of aircrafts) This is calculated for each airline once group by is applied
FROM
	FLIGHTS
GROUP BY AIRLINE_NAME  -- group by the airline name
ORDER BY AIRLINE_NAME  -- sort the airline names in alphabetical order
;

/*
|       AIRLINE_NAME        | AVG_DISTANCE_PER_AIRCRAFT |
|---------------------------|---------------------------|
| American Airlines Inc.    |        1884615.02         |
| Delta Air Lines Inc.      |        1752719.34         |
| Southwest Airlines Co.    |        2684921.66         |
*/

/* Matrix showing the percent difference of average distance per aircraft for each airline. Each row compares the airline's average distance per aircraft to the value of the airline in the column. For example, row 1 indicates that American Airlines Inc.'s average distance per aircraft was 7.13% higher than Delta Air Lines Inc., and 29.64% lower than Southwest Airlines Co.

|       AIRLINE_NAME      | American Airlines Inc. | Delta Air Lines Inc. | Southwest Airlines Co. |
|-------------------------|------------------------|----------------------|------------------------|
| American Airlines Inc.  |           0%           |         7.13%        |        -29.64%         |
| Delta Air Lines Inc.    |         -7.13%         |           0%         |        -36.74%         |
| Southwest Airlines Co.  |         29.64%         |         36.74%       |           0%           |
*/

/* Compare the three airlines with respect to your findings: how do these results impact your estimates of each airline's finances?

Based on the comparison matrix above, it is clear that Southwest Airlines Co. uses their airplanes significantly more than both, American Airlines Inc. and Delta Air Lines Inc. This has some short term and long term implications. 
Assuming that the average age of the aircraft in all 3 airlines' fleets are relatively the same, in the short term the revenue of Southwest would be higher since there are fewer aircraft that need to be maintained and kept up to date to meet regulations. In the long term however, the aircraft would depreciate and reach their end of life sooner.
On the other hand, having fewer aircraft also means that fewer flights can be scheduled at the same time, and that Southwest is more likely to be constrained by having a smaller fleet if it does want to grow in terms of number of flights it schedules in a given week. This is in Q2.2 where we saw that Southwest had the lowest year-over-year increase in number of flights booked. 
*/


/*********

QUESTION 5

*********/

-- ** For each of the following questions, consider early departures and arrivals (negative values) as on-time (0 delay) in your calculations. **

-- Q5.1.1 - Next, we will look into on-time performance more granularly in relation to the time of departure. We can break up the departure times into three categories as follows: (given case query).
DROP TABLE IF EXISTS UPDATED_FLIGHTS;
CREATE TABLE UPDATED_FLIGHTS AS  -- created an updated flights table to meet the conditions mentioned in the question. Will be using this table for the questions below
SELECT *, 
	CASE
		WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
		WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
		WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
		ELSE "4-night"
	END AS "time_of_day", 
    IF (DEPDELAY < 0, 0, DEPDELAY) AS UPDATED_DEPDELAY,  -- the question asks to consider early departures (-ve values) as on-time (0 delay) in the calculations
    IF (ARRDELAY < 0, 0, ARRDELAY) AS UPDATED_ARRDELAY  -- the question asks to consider early arrivals (-ve values) as on-time (0 delay) in the calculations
FROM 
	FLIGHTS
;

-- Q5.1.2 - Find the average departure delay for each time-of-day across the whole data set. Can you explain the pattern you see?
SELECT
	TIME_OF_DAY,  -- return the time of day column
    ROUND(AVG(UPDATED_DEPDELAY), 2) AS AVG_DEPDELAY  -- calculate the average departure delay and round it to two decimal places (when group by is applied this will show the calculation for each time of day category)
FROM 
	UPDATED_FLIGHTS  -- using the new updated flights table
GROUP BY TIME_OF_DAY  -- group by the time of day categories
ORDER BY TIME_OF_DAY  -- sort by the time of day categories in ascending order (earliest to latest, eg. morning to night)
;

/*
|  TIME_OF_DAY  | AVG_DEPDELAY |
|---------------|--------------|
|   1-morning   |     7.91     |
|  2-afternoon  |    13.66     |
|   3-evening   |    18.31     |
|    4-night    |     7.79     |
*/

/* The pattern I see is that the early morning and night time flights had the lowest average departure delay times compared to the afternoon and evening flights which had the highest average delay times. This could be because the airport isn't as busy during the morning and night time. 
Most flights depart between 12pm and 9pm (times are from the case statement in 5.1.1), causing the airports to be the busiest around then and have longer departure delays. 

It can also be linked to logistics as during those hours (12-9pm) all other businesses and workplaces are also open and running their operations. 
Thus, many different things can cause delays such as road traffic affecting supplies such as food from getting to the airport on time for the airlines to restock in between flights. 
Airlines would again have to streamline logistics and operations cohesively with airports in order to reduce delays. This can mean expanding airports to allow for more storage for supplies as an example. 
*/


-- Q5.2 - Now, find the average departure delay for each airport and time-of-day combination.
SELECT
    AIRPORTS.AIRPORTNAME,
    FILTERED_UPDATED_FLIGHTS.TIME_OF_DAY,
    FILTERED_UPDATED_FLIGHTS.AVG_DEPDELAY
FROM
	(SELECT  -- subquery to return the origin airport, time of day, and average departure delay calculation
		ORIGINAIRPORTID,
		TIME_OF_DAY,
		ROUND(AVG(UPDATED_DEPDELAY), 2) AS AVG_DEPDELAY  -- calculate the average departure delay and round it to two decimal places (when group by is applied this will show the calculation for each airport and time of day combination)
	FROM
		UPDATED_FLIGHTS
	GROUP BY 
		ORIGINAIRPORTID,  -- group by the origin airport id and time of day 
		TIME_OF_DAY
	) AS FILTERED_UPDATED_FLIGHTS
	INNER JOIN AIRPORTS  -- join the updated flights and airports tables on the origin airport id and airport id, respectively, in order to return the airport names
		ON FILTERED_UPDATED_FLIGHTS.ORIGINAIRPORTID = AIRPORTS.AIRPORTID
ORDER BY 
		AIRPORTS.AIRPORTNAME,  -- order by airport name in alphabetical order
		FILTERED_UPDATED_FLIGHTS.TIME_OF_DAY  -- order by time of day in ascending order 
;

/*
|          AIRPORTNAME              |  TIME_OF_DAY  | AVG_DEPDELAY |
|-----------------------------------|---------------|--------------|
| Akron-Canton Regional             |   1-morning   |     2.11     |
| Akron-Canton Regional             |  2-afternoon  |    12.01     |
| Akron-Canton Regional             |   3-evening   |    10.11     |
| Akron-Canton Regional             |    4-night    |     6.78     |
| Albany International              |   1-morning   |     5.63     |
| Albany International              |  2-afternoon  |     9.73     |
| Albany International              |   3-evening   |    15.37     |
| Albany International              |    4-night    |     4.59     |
| Albuquerque International Sunport |   1-morning   |     8.14     |
| Albuquerque International Sunport |  2-afternoon  |    13.62     |
|                .                  |       .       |      .       | 
|                .                  |       .       |      .       |
|                .                  |       .       |      .       |
*/


-- Q5.3 - Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights.
SELECT
    AIRPORTS.AIRPORTNAME AS AIRPORT_NAME,
    FILTERED_UPDATED_FLIGHTS.TIME_OF_DAY,
    FILTERED_UPDATED_FLIGHTS.AVG_DEPDELAY
FROM
	(SELECT
		ORIGINAIRPORTID,
		TIME_OF_DAY,
		ROUND(AVG(UPDATED_DEPDELAY), 2) AS AVG_DEPDELAY
	FROM
		UPDATED_FLIGHTS
	WHERE
		TIME_OF_DAY = '1-MORNING'  -- filter flights to return only morning flights
	GROUP BY 
		ORIGINAIRPORTID,
		TIME_OF_DAY
	HAVING
		COUNT(ORIGINAIRPORTID) >= 10000  -- filter to return only airports with at least 10,000 flights
	) AS FILTERED_UPDATED_FLIGHTS
	INNER JOIN AIRPORTS
		ON FILTERED_UPDATED_FLIGHTS.ORIGINAIRPORTID = AIRPORTS.AIRPORTID
ORDER BY 
		FILTERED_UPDATED_FLIGHTS.AVG_DEPDELAY DESC
;

/*
|          AIRPORT_NAME           |  TIME_OF_DAY  | AVG_DEPDELAY |
|---------------------------------|---------------|--------------|
| San Francisco International     |   1-morning   |     13.61    |
| Chicago O'Hare International    |   1-morning   |     11.54    |
| Dallas/Fort Worth International |  1-morning    |     11.44    |
| Los Angeles International       |   1-morning   |     10.96    |
| Seattle/Tacoma International    |   1-morning   |     10.18    |
| Chicago Midway International    |   1-morning   |     10.15    |
| Logan International             |   1-morning   |     8.93     |
| Raleigh-Durham International    |   1-morning   |     8.78     |
| Denver International            |   1-morning   |     8.73     |
| San Diego International         |   1-morning   |     8.66     |
|                .                |       .       |      .       | 
|                .                |       .       |      .       |
|                .                |       .       |      .       |
*/


-- Q5.4 - By extending the query from the previous question, name the top-10 airports (with >10000 flights) with the highest average morning delay. In what cities are these airports located?
SELECT
    AIRPORTS.CITY,  -- return the city name for where each airport is located
    AIRPORTS.AIRPORTNAME AS AIRPORT_NAME,
    FILTERED_UPDATED_FLIGHTS.TIME_OF_DAY,
    FILTERED_UPDATED_FLIGHTS.AVG_DEPDELAY
FROM
	(SELECT
		ORIGINAIRPORTID,
		TIME_OF_DAY,
		ROUND(AVG(UPDATED_DEPDELAY), 2) AS AVG_DEPDELAY
	FROM
		UPDATED_FLIGHTS
	WHERE
		TIME_OF_DAY = '1-MORNING'
	GROUP BY 
		ORIGINAIRPORTID,
		TIME_OF_DAY
	HAVING
		COUNT(ORIGINAIRPORTID) > 10000  -- filter to return only airports with over 10,000 flights
	) AS FILTERED_UPDATED_FLIGHTS
	INNER JOIN AIRPORTS
		ON FILTERED_UPDATED_FLIGHTS.ORIGINAIRPORTID = AIRPORTS.AIRPORTID
ORDER BY 
		FILTERED_UPDATED_FLIGHTS.AVG_DEPDELAY DESC  -- sort the average departure delay in descending order
LIMIT 10  -- only return the top 10 rows (top 10 airports)
;
 
/*
|          CITY           |          AIRPORT_NAME           |  TIME_OF_DAY  | AVG_DEPDELAY |
|-------------------------|---------------------------------|---------------|--------------|
| San Francisco, CA       | San Francisco International     |   1-morning   |     13.61    |
| Chicago, IL             | Chicago O'Hare International    |   1-morning   |     11.54    |
| Dallas/Fort Worth, TX   | Dallas/Fort Worth International |   1-morning   |     11.44    |
| Los Angeles, CA         | Los Angeles International       |   1-morning   |     10.96    |
| Seattle, WA             | Seattle/Tacoma International    |   1-morning   |     10.18    |
| Chicago, IL             | Chicago Midway International    |   1-morning   |     10.15    |
| Boston, MA              | Logan International             |   1-morning   |     8.93     |
| Raleigh/Durham, NC      | Raleigh-Durham International    |   1-morning   |     8.78     |
| Denver, CO              | Denver International            |   1-morning   |     8.73     |
| San Diego, CA           | San Diego International         |   1-morning   |     8.66     |
*/

/*
These results show that the top 10 airports with over 10,000 flights and the highest average departure delays are all located within the USA. 
This data can help airlines optimize their operations and logistics by working with these airports specifically to target this great flight delays issue. 
*/


/*
Based off the exploration conducted, I would recommend investing in American Airlines as it showed the best results, therefore seeming like the most risk tolerant option. 

American Airlines had managed to grow its business by booking more flights, while managing to keep its costs associated with flying low.
It also has the infrastructure to sustain its growth as it has the largest aircraft fleet. With some operational and logistics tweaks, 
American Airlines should be able to see greater growth in the future.
*/
