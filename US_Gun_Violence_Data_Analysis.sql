SELECT * FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`;

---Let's Analyze the Gun Violence Data
---First let us see what date range of the data is.

SELECT MAX(date) AS Max_date, MIN(date) AS Min_date FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`;

---It is found that the data is from 2013-01-01 to 2022-05-28
---Let us look at the count of gun violence incidents each year

SELECT COUNT(DISTINCT(incident_id)) AS Total_GunCrimes FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`;

---There were total of 471,878 gun violence crimes between 2013-01-01 and 2022-05-28

---Let's see how many gun violence crimes happened in each year
WITH GunViolence_Crimes AS (
SELECT EXTRACT(YEAR FROM date) AS YEAR, COUNT(DISTINCT(incident_id)) AS GunViolence_Crimes  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
GROUP BY EXTRACT(YEAR FROM date)
)

SELECT * FROM GunViolence_Crimes
ORDER BY GunViolence_Crimes DESC;

---Highest Gun Violence crimes reported was in 2020 (62,330). 2017 (61,401), 2016 (58,763), and 2021 (56,794) were other years with high gun crime incidents reported. From the yearly data, it looks like the 2013 data is incomplete as total count is only 278 compared to other years which is above 50,000 crimes except for 2022. 2022 also has limited data because latest date is only 2022-05-28.

---Let's calculate the average gun violence crimes per year. Since 2013 and 2022 data is assumed to be incomplete, we omit these two years for the average calculation.

WITH GunViolence_Crimes AS (
SELECT EXTRACT(YEAR FROM date) AS YEAR, COUNT(DISTINCT(incident_id)) AS GunViolence_Crimes  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
GROUP BY EXTRACT(YEAR FROM date)
)

SELECT ROUND(AVG(GunViolence_Crimes.GunViolence_Crimes)) AS Avg_GunViolence_per_year FROM GunViolence_Crimes
WHERE YEAR > 2013 AND YEAR < 2022;

---Average gun violence crimes per year is found to be 56,673. 

---Let's see how many deaths occured in this period due to gun violence.

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT YEAR, sum(n_killed) AS Deaths FROM GunViolence_Deaths
GROUP BY YEAR
ORDER BY sum(n_killed) DESC;

---The highest deaths from gun violence was reported in 2021 (20,921) followed by 2020 (19,515), 2017 (15,511) and 2019 (15,490). 

---Let's see the percentage of incidents which ended in deaths. 

WITH GunViolence_withDeaths AS (
  SELECT EXTRACT(YEAR FROM date) AS YEAR, COUNT(incident_id) AS GunViolence_Count, sum(n_killed) AS n_killed
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
  WHERE n_killed > 0
  GROUP BY EXTRACT(YEAR FROM date)
), GunViolence_withoutDeaths AS (
  SELECT EXTRACT(YEAR FROM date) AS YEAR, COUNT(incident_id) AS GunViolence_Count, sum(n_killed) AS n_killed
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
  WHERE n_killed = 0
  GROUP BY EXTRACT(YEAR FROM date)
)

SELECT wd.YEAR, wd.GunViolence_Count AS WithDeaths, wod.GunViolence_Count AS WithoutDeaths, (wd.GunViolence_Count+wod.GunViolence_Count) AS Total, ROUND((wd.GunViolence_Count/(wd.GunViolence_Count+wod.GunViolence_Count))*100, 0) AS Percentage_of_guncrimes_withDeahts FROM GunViolence_withDeaths AS wd

INNER JOIN GunViolence_withoutDeaths AS wod ON wd.YEAR = wod.YEAR
ORDER BY ROUND((wd.GunViolence_Count/(wd.GunViolence_Count+wod.GunViolence_Count))*100, 0) DESC;

---2013 (56%) data shows that year had the high percentage of incidents which ended in deaths. 2022 (39%), 2021 (33%), 2020 (29%), 2019 (26%) were other years following 2013. Omitting 2013 as we assume the data is not complete, we can clearly see that fatal incidents resulting in one or more deaths has been increasing over the years. Next we will look at the number of people killed by gun violence.

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT YEAR, sum(n_killed) AS Deaths FROM GunViolence_Deaths
GROUP BY YEAR
ORDER BY sum(n_killed) DESC;

---Most deaths occured in 2021 (20,921) followed by 2020 (19,515). 2017 (15,511), 2019 (15,490) and 2016 (15,066). We'll look at number of mass shootings happened during these years.

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT YEAR, sum(n_killed) AS Deaths, COUNTIF(MassShootings IS TRUE) AS MassShootings FROM GunViolence_Deaths
GROUP BY YEAR
ORDER BY sum(n_killed) DESC;


---We found that there were 692 Mass Shootings reported in 2021. 2020 (610), 2017 (346), 2019 (417), and 2016 (382) were other years with high count of mass shootings. Except for 2017, deaths were high with more Mass Shootings incidents. 
---Now let's look at the gun violence by states.

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT state, count(incident_id) AS GunViolence_Count FROM GunViolence_Deaths
GROUP BY state
ORDER BY count(incident_id) DESC;

---Here we can see the highest gun violence crimes occured in Illinois, California, Texas and Florida. Let's how many mass shootings occured in these states

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT state, count(incident_id) AS GunViolence_Count, COUNTIF(MassShootings IS TRUE) AS MassShootings FROM GunViolence_Deaths
GROUP BY state
ORDER BY count(incident_id) DESC;

---From the data, we can see the number of mass shootings are also high in the same states with high gun violences reported. Let's see the how many shooting deaths occured in each state.

WITH GunViolence_Deaths AS (
  SELECT DISTINCT(incident_id) AS incident_id, EXTRACT(YEAR FROM date) AS YEAR, state, n_killed, MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
)

SELECT state, count(incident_id) AS GunViolence_Count, sum(n_killed) AS Deaths, COUNTIF(MassShootings IS TRUE) AS MassShootings FROM GunViolence_Deaths
GROUP BY state
ORDER BY count(incident_id) DESC;

---We can see that more shooting deaths is highest in California (11,879), Texas (11,855), Florida (8,263) and Illinois (7,529) respectively in the highest deaths.

---Average Yearly deaths in each state

WITH GunViolence_Deaths AS (
  SELECT COUNT(DISTINCT(incident_id)) AS GunCrimes, EXTRACT(YEAR FROM date) AS YEAR, state, sum(n_killed) AS Deaths, COUNTIF(MassShootings IS TRUE) AS MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
  WHERE EXTRACT(YEAR FROM date) <> 2013 AND EXTRACT(YEAR FROM date) <> 2022
  GROUP BY EXTRACT(YEAR FROM date), state
)

SELECT state, ROUND(AVG(GunCrimes),0) AS Avg_GunCrimes, ROUND(AVG(Deaths),0) AS Avg_Deaths, ROUND(AVG(MassShootings),0) AS Avg_MassShootings FROM GunViolence_Deaths
GROUP BY state
ORDER BY AVG(GunCrimes) DESC;

---Average Gun Crimes are highest in Illinois (4,305), California (3,666), Texas (3,569) and Florida (3,207). Average Deaths from Gun Violence is highest in California (1,397), Texas (1,374), Florida (976) and Illinois (898). On average there is 45 Mass shootings in Illionois, 40 in California, 28 in Texas and 26 in Florida. 
---Let's see how these numbers are for U.S as whole.

WITH GunViolence_Deaths AS (
  SELECT COUNT(DISTINCT(incident_id)) AS GunCrimes, EXTRACT(YEAR FROM date) AS YEAR, sum(n_killed) AS Deaths, COUNTIF(MassShootings IS TRUE) AS MassShootings
  FROM `fine-proxy-235300.GunViolenceUS.GunViolenceUS`
  WHERE EXTRACT(YEAR FROM date) <> 2013 AND EXTRACT(YEAR FROM date) <> 2022
  GROUP BY EXTRACT(YEAR FROM date)
)

SELECT ROUND(AVG(GunCrimes),0) AS Avg_GunCrimes, ROUND(AVG(Deaths),0) AS Avg_Deaths, ROUND(AVG(MassShootings),0) AS Avg_MassShootings FROM GunViolence_Deaths
ORDER BY AVG(GunCrimes) DESC;

---In U.S there is an average of 56,673 gun crimes reported per year, and average of 15,921 people die from shooting and there is average of 424 Mass Shootings per year.
