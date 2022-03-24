-- 1. Return everything from the certificate table
SELECT * FROM certificate;

-- 2. Return the first name, last name, and email from everyone
-- in the person table. Alias the first name and last name columns
-- as "First" and "Last"
SELECT firstname AS "First", lastname AS "Last"
FROM person;

-- 3. Return the same as for question 2, but sort it by last name in descending order.
SELECT firstname AS "First", lastname AS "Last"
FROM person
ORDER BY "Last" desc;

-- 4. Return the last name, first name, email, and city for everyone who lives in Seattle
SELECT lastname, firstname, email, city 
FROM person
WHERE city = 'Seattle';

SELECT dateadded
FROM person;

-- 5. Return the same as for question 4, but only for those added in February 2021
SELECT lastname, firstname, email, city
FROM person
WHERE city = 'Seattle' AND (dateadded BETWEEN '2021-02-01' AND '2021-02-28');

-- 6. Who are the people in the database who live in Washington(WA),
-- Oregon(OR), or Cali (CA)?
SELECT lastname, firstname, state
FROM person
WHERE state IN ('OR','WA','CA');

-- 7. Which instructional areas of the database don’t have a description?
SELECT *
FROM instructionalarea
WHERE description IS NULL;

-- 8. Which instructional areas of the database do have a description?
SELECT *
FROM instructionalarea
WHERE description IS NOT NULL;

-- 9. List all the people whose last names have a double n (nn) somewhere in
-- the last name.
SELECT *
FROM person
WHERE lastname LIKE '%nn%';

-- 10. Which courses have Python in the course description?
SELECT *
FROM course
WHERE coursedescription LIKE '%Python%';

-- 11. Using the roster table, list only unduplicated students for sections 77
-- through 100.

-- unduplicated studentkey for sectionkey 77 and 100
SELECT DISTINCT(studentkey)
FROM roster
WHERE sectionkey = '77' OR sectionkey = '100';

-- undup stdkey for sectkeys 77 THRU 100
SELECT DISTINCT(studentkey)
FROM roster
WHERE sectionkey BETWEEN '77' AND '100';

-- counts of stdkey appearing in sectkeys 77 thru 100
SELECT studentkey, count(*)
FROM roster
WHERE sectionkey BETWEEN '77' AND '100'
GROUP BY studentkey
ORDER BY count(*) DESC;

-- ?? count number of students that only appear in 1 sectkey ?? nested query?

-- ?? how about finding studentkeys that are duplicates ?? USE INNER JOIN IF DIFFERENT TABLE
-- https://stackoverflow.com/questions/28156795/how-to-find-duplicate-records-in-postgresql
-- "group by" function aggregates distinct studentkeys, ie keys that can be found in either sections
-- hence storing table  "virtually" as (key,value) pairs
-- HAVING condition only shows studentkeys with values more than 1

SELECT 
	studentkey, count(*)
FROM roster
WHERE sectionkey = '77' OR sectionkey = '100'
GROUP BY studentkey
HAVING count(*)>1;

-- students that only appear in either(non inclusive) table
SELECT studentkey
FROM roster
WHERE sectionkey = '77' OR sectionkey = '100'
GROUP BY studentkey
HAVING COUNT(*) = 1;


-- 12. Use CASE to determine the letter grade for each student in section
-- It should use the breakdown given in the table below. Return the
-- sectionkey, the studentkey, the final grade, and the letter grade.
-- 3.5 to 4 A
-- 3.0 to 3.49 B
-- 2.5 to 2.99 C
-- 2.0 to 2.49 D
-- < 2 F

SELECT sectionkey, studentkey, finalgrade,
	CASE
		WHEN finalgrade BETWEEN 3.5 AND 4 THEN 'A'
		WHEN finalgrade BETWEEN 3.0 AND 3.49 THEN 'B'
		WHEN finalgrade BETWEEN 2.5 AND 2.99 THEN 'C'
		WHEN finalgrade BETWEEN 2.0 AND 2.49 THEN 'D'
		ELSE 'F'
	END AS "letter grade"
FROM roster
ORDER BY "sectionkey" DESC;