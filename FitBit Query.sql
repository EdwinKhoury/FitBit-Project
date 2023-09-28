
--1) Count the number of unique IDs in each table

SELECT COUNT(DISTINCT daily_activity.Id) AS Unique_act_ID, 
	   COUNT(DISTINCT daily_sleep.Id) AS Unique_sleep_ID,
	   COUNT(DISTINCT steps_per_hour.Id) AS Unique_step_ID,
	   COUNT(DISTINCT weight_info.Id) AS Unique_weight_ID
FROM FitbitProject..daily_activity
FULL JOIN FitbitProject..daily_sleep
	ON daily_activity.Id = daily_sleep.Id
FULL JOIN FitbitProject..steps_per_hour
	ON daily_activity.Id = steps_per_hour.Id
FULL JOIN FitbitProject..weight_info
	ON daily_activity.Id = weight_info.Id
--There are 33 unique IDs for the activity logs as well as the steps
--24 unique IDs for the sleep logs and only 8 for the weights info

	
----------------

	
--2) Count the number of users that overlap in each table

SELECT COUNT(DISTINCT daily_activity.Id) AS Unique_act_ID, 
	   COUNT(DISTINCT daily_sleep.Id) AS Unique_sleep_ID,
	   COUNT(DISTINCT steps_per_hour.Id) AS Unique_step_ID,
	   COUNT(DISTINCT weight_info.Id) AS Unique_weight_ID
FROM FitbitProject..daily_activity
JOIN FitbitProject..daily_sleep
	ON daily_activity.Id = daily_sleep.Id
JOIN FitbitProject..steps_per_hour
	ON daily_activity.Id = steps_per_hour.Id
JOIN FitbitProject..weight_info
	ON daily_activity.Id = weight_info.Id
--There are only 6 unique IDs that overlap in the 4 different tables

	
----------------

	
--3) Verify that the IDs are consistent across the tables and show which are shared or absent from tables 

SELECT DISTINCT daily_activity.Id AS Unique_act_ID, daily_sleep.Id AS Unique_sleep_ID, steps_per_hour.Id AS Unique_step_ID, weight_info.Id AS Unique_weight_ID
FROM FitbitProject..daily_activity
FULL JOIN FitbitProject..daily_sleep
	ON daily_activity.Id = daily_sleep.Id
FULL JOIN FitbitProject..steps_per_hour
	ON daily_activity.Id = steps_per_hour.Id
FULL JOIN FitbitProject..weight_info
	ON daily_activity.Id = weight_info.Id

	
----------------

	
--4) Verify only the IDs that overlap in the 4 tables 

SELECT DISTINCT daily_activity.Id AS Unique_act_ID, daily_sleep.Id AS Unique_sleep_ID, steps_per_hour.Id AS Unique_step_ID, weight_info.Id  AS Unique_weight_ID
FROM FitbitProject..daily_activity
JOIN FitbitProject..daily_sleep
	ON daily_activity.Id = daily_sleep.Id
JOIN FitbitProject..steps_per_hour
	ON daily_activity.Id = steps_per_hour.Id
JOIN FitbitProject..weight_info
	ON daily_activity.Id = weight_info.Id

	
----------------

	
--5) Average activity stats

SELECT DISTINCT Id,
	COUNT (Id) AS Logs,
	AVG (Totalsteps) AS avg_steps,
	AVG (Totaldistance) AS avg_dist,
	AVG (VeryActiveMinutes) AS avg_very_min,
	AVG (FairlyActiveminutes)AS avg_fairly_min,
	AVG (LightlyActiveMinutes) AS avg_lightly_min,
	AVG (SedentaryMinutes) AS avg_sed_min,
	AVG (Calories) AS avg_cal
FROM FitbitProject..daily_activity                                 --save the result as a table: avg_act_by_ID
GROUP BY Id
ORDER BY Id
--Of all the users, 21 out of the 33 tracked their data every day of the month
--The 7,000 steps bar was achieved by 20 users 
--20 users are getting at least 20 min of a combination of very and fairly level of activity. 
--Many exceed 20 minutes with 6 users getting over an hour of this level of activity on average.

	
----------------

	
--6) Average sleep stats 

SELECT Distinct Id,
	COUNT (Id) AS Logs,
	AVG (TotalMinutesAsleep) AS avg_asleep_min,
	SUM (TotalMinutesAsleep) AS total_asleep_min,
	AVG (TotalTimeInBed) AS avg_awake_min,
	SUM (TotalTimeInBed) AS total_awake_min
FROM FitbitProject..daily_sleep
GROUP BY Id                                                      --save the result as a table: avg_sleep_by_ID
ORDER BY Id
--Only 3 users logged in and tracked their sleep every day of the month
--12 of the users got 7 hours of sleep and more. 

	
----------------

	
--7) Merge the average activity and sleep table into one

SELECT *
FROM FitbitProject..avg_act_by_ID
JOIN FitbitProject..avg_sleep_by_ID
	ON avg_act_by_ID.Id = avg_sleep_by_ID.Id                      --save the result as a table: avg_act_sleep_by_ID
ORDER BY avg_act_by_ID.Id

	
----------------

	
--8) Find the days where the most and least activity take place on 

DROP TABLE IF exists avg_activity_per_day
CREATE TABLE avg_activity_per_day                            -- save the result as a table: avg_act_per_day
(
day_of_week nvarchar(255),
logs float,
avg_steps float,
avg_very_act_min float,
avg_fairly_act_min float,
avg_lightly_act_min float ,
avg_sedentary_min float,
avg_total_dist float,
avg_calories_burned float
)

SELECT 
	CASE DATEPART(weekday, ActivityDate)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END AS day_of_week,
	   COUNT (Id) AS logs,
	   AVG (TotalSteps) AS avg_steps,
	   AVG (VeryActiveMinutes) AS avg_very_act_min,
	   AVG (FairlyActiveMinutes) AS avg_fairly_act_min,
	   AVG (LightlyActiveMinutes) AS avg_lightly_act_min,
	   AVG (SedentaryMinutes) AS avg_sedentary_min,
	   AVG (TotalDistance) AS avg_total_dist,
	   AVG (Calories) AS avg_calories_burned
FROM FitbitProject..daily_activity
GROUP BY 
	CASE Datepart(weekday, ActivityDate)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END
ORDER BY avg_steps
-- Sunday is the only day of the week with an average number of steps less than 7,000
-- On Tuesdays and Saturdays, the average number of steps made by the users exceeds 8,000
--Users are walking on average more than 5 Km every day of the week.
--The average amount of calories burnt every day revolves around 2300 calories, with only Sundays and Thursdays with less than 2,300 calories.
--The most sedentary day is Mondays with an average duration of 1,028 minutes. The least sedentary day is Thursdays with 962 minutes. 

	
----------------

	
--9) Find the days where the most and least sleep take place on 

DROP TABLE IF exists avg_sleep_per_day
CREATE TABLE avg_sleep_per_day                            -- save the result as a table: avg_sleep_per_day
(
day_of_week nvarchar(255),
logs float,
avg_hrs_awake_in_bed float,
avg_hrs_asleep float,
)

SELECT 
	CASE DATEPART(weekday, SleepDay)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END AS day_of_week,
	   COUNT (Id) AS logs,
	   Avg(TotalTimeInBed)/60 AS avg_hrs_awake_in_bed,
	   Avg(TotalMinutesAsleep)/60 AS avg_hrs_asleep

FROM FitbitProject..daily_sleep
GROUP BY	
	CASE DATEPART(weekday, SleepDay)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END 
--Users get an average sleeping time of 7 hours on Saturdays, Sundays, and Wednesdays. 
--For the rest of the week, users sleep on average 6.7 hours
--Sundays are the days with the most hours awake in bed with 8.39 hours. 

	
----------------

	
--10-a) Activity trends over time 

SELECT DISTINCT Id, ActivityDate,
	AVG (Totalsteps) AS avg_steps,
	AVG (Totaldistance) AS avg_dist,
	AVG (VeryActiveMinutes) AS avg_very_min,
	AVG (FairlyActiveminutes)AS avg_fairly_min,
	AVG (LightlyActiveMinutes) AS avg_lightly_min,
	AVG (SedentaryMinutes) AS avg_sed_min,
	AVG (Calories) AS avg_cal
FROM FitbitProject..daily_activity                               
GROUP BY ActivityDate, Id
ORDER BY ActivityDate, Id

	
----------------

	
--10-b) Logging trend of the users for the activities

SELECT DISTINCT ActivityDate,
	COUNT (Id) AS Logs
FROM FitbitProject..daily_activity                               
GROUP BY ActivityDate
ORDER BY ActivityDate
--With time, the number of logs seems to decrease: users commit less and less to logging

----------------

--10-c) Average steps per day over time 

SELECT DISTINCT ActivityDate,
	AVG (Totalsteps) AS avg_steps,
	AVG (Calories) AS avg_cal
FROM FitbitProject..daily_activity                               
GROUP BY ActivityDate
ORDER BY ActivityDate

	
----------------

	
--11-a) Sleep trends over time 	

SELECT DISTINCT Id, SleepDay,
	COUNT (Id) AS Logs,
	AVG (TotalMinutesAsleep)/60 AS avg_asleep_hrs,
	AVG (TotalTimeInBed)/60 AS avg_awake_hrs
FROM FitbitProject..daily_sleep
GROUP BY SleepDay, Id                                                      
ORDER BY SleepDay, Id

	
----------------

	
--11-b) Logging trend of the users for the activities

SELECT DISTINCT SleepDay,
	COUNT (Id) AS Logs
FROM FitbitProject..daily_sleep
GROUP BY SleepDay                                                   
ORDER BY SleepDay
--Of the 24 users that have unique IDs for the sleeping data, there are only 13 to 17 logs per day

	
----------------

	
--11-c) Correlation between the average sleeping hours and the average hours spent awake in bed per ID

SELECT DISTINCT  Id,
	AVG (TotalMinutesAsleep)/60 AS avg_asleep_hrs,
	AVG (TotalTimeInBed)/60 AS avg_awake_hrs
FROM FitbitProject..daily_sleep
GROUP BY  Id                                                    
ORDER BY  Id
--The longer users sleep, the more time awake they will experience throughout their sleep cycles.

	
----------------

	
--11-d) Average sleeping hours and average hours spent awake in bed over time

SELECT DISTINCT  SleepDay,
	AVG (TotalMinutesAsleep)/60 AS avg_asleep_hrs,
	AVG (TotalTimeInBed)/60 AS avg_awake_hrs
FROM FitbitProject..daily_sleep
GROUP BY  SleepDay                                                    
ORDER BY  SleepDay

	
----------------

	
--12) Variation of steps per day

DROP TABLE IF exists avg_step_per_day
CREATE TABLE avg_step_per_day                            -- save the result as a table: avg_step_per_day
(
day_of_week nvarchar(255),
avg_steps float
)

SELECT 	
	CASE DATEPART(weekday, ActivityDate)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END AS day_of_week,
	   Avg(TotalSteps) AS avg_steps
	  
FROM FitbitProject..daily_activity
GROUP BY 	
	CASE DATEPART(weekday, ActivityDate)                                             
		WHEN 1 THEN 'Sun'
		WHEN 2 THEN 'Mon'
		WHEN 3 THEN 'Tues'
		WHEN 4 THEN 'Wed'
		WHEN 5 THEN 'Thurs'
		WHEN 6 THEN 'Fri'
		WHEN 7 THEN 'Sat'
	END 



