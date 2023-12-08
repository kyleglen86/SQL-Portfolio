CREATE TABLE WimHofAchievements 
(Age INT,
 Year INT,
 Event VARCHAR(100),
 Location VARCHAR(100)
);


INSERT INTO WimHofAchievements VALUES
    (48, 2007, 'Ice Endurance', 'Finland'),
    (52, 2011, 'Marathon in the Namib Desert', 'Namibia'),
    (56, 2015, 'Under Ice Longest Distance Swam', 'Netherlands'),
    (60, 2019, 'Mount Everest Run', 'Nepal'),
    (61, 2020, 'Stay in Ice Bath for 2 Hours', 'Netherlands');

SELECT * FROM WimHofAchievements;

SELECT * FROM WimHofAchievements WHERE Year > 2015;


SELECT Location, COUNT(*) as AchievementsCount
FROM WimHofAchievements
GROUP BY Location;

SELECT Location, COUNT(*) as AchievementsCount
FROM WimHofAchievements
GROUP BY Location
ORDER BY AchievementsCount DESC;

SELECT Year
FROM WimHofAchievements

SELECT DISTINCT(Event)
FROM WimHofAchievements

SELECT MAX(Year) AS YearCompleted
FROM WimHofAchievements 

SELECT MIN(Year) AS YearCompleted
FROM WimHofAchievements

SELECT AVG(Year)
FROM WimHofAchievements

SELECT *
FROM WimHofAchievements
WHERE Location = 'Finland'

SELECT *
FROM WimHofAchievements
WHERE Location <> 'Finland'

SELECT *
FROM WimHofAchievements
WHERE Age >= 56 Or Location = 'Netherlands'


SELECT *
FROM WimHofAchievements
WHERE Location LIKE 'N%a%'

SELECT *
FROM WimHofAchievements
WHERE Location IN ('Finland', 'Netherlands')

SELECT Location, COUNT(Location) AS CountLocation
FROM WimHofAchievements
WHERE Age > 52
GROUP BY Location
ORDER BY CountLocation


