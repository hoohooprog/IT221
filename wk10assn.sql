/*
1. SELECT the last name, first name, and email for each student in section 1. Add the literal string
“Section 1” to identify them, then use UNION to combine them with all the students in section 2.
2. Return the last name, first name and email for every student in section year 2019 who is also in
section year 2020
3. Use the same queries as in exercise 2, but return the names of the students who were in section
year 2019 but not in section year 2020.
4. Show the Section year, quarter key, student key and the final grade for each student along with
average final grade partitioned by section year and sorted by quarter
5. Use the ROW_NUMBER function to return the row numbers for section year, section key,
student key and final grade for section 29 ordered by final grade.
6. Use a ROW_NUMBER and a sub query to return rows 7, 8 and 9 from the query used in exercise 5.
7. Return section year, section key, student key, final grade and rank for sections between 29 and
35, partitioned by section key and ordered by the final grade descending.
8. Run the same query as in exercise 7 but use DENSE_RANK().
9. Use the same query as in exercise 7 but order by final grade without DESC and return the FIRST
_VALUE instead of RANK.
*/

/*
1. SELECT the last name, first name, and email for each student in section 1. Add the literal string
“Section 1” to identify them, then use UNION to combine them with all the students in section 2.
*/

SELECT lastname, firstname, email, studentkey, 'Section 1' "section"
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
WHERE sectionkey = 1
UNION
SELECT lastname, firstname, email, studentkey, 'Section 2'
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
WHERE sectionkey = 2 
ORDER BY STUDENTKEY ASC;

/*
2. Return the last name, first name and email for every student in section year 2019 who is also in
section year 2020
*/
SELECT lastname, firstname, email
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
JOIN coursesection USING (sectionkey)
WHERE sectionyear = 2019
INTERSECT
SELECT lastname, firstname, email
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
JOIN coursesection USING (sectionkey)
WHERE sectionyear = 2020;

/*
3. Use the same queries as in exercise 2, but return the names of the students who were in section
year 2019 but not in section year 2020.
*/
SELECT lastname, firstname, email
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
JOIN coursesection USING (sectionkey)
WHERE sectionyear = 2019
EXCEPT
SELECT lastname, firstname, email
FROM person
JOIN student USING (personkey)
JOIN roster USING (studentkey)
JOIN coursesection USING (sectionkey)
WHERE sectionyear = 2020;

/*
4. Show the Section year, quarter key, student key and the final grade for each student along with
average final grade partitioned by section year and sorted by quarter
*/
-- tables: quarter(quarterkey), coursesection(quarterkey,sectionkey,section year), roster(sectionkey, finalgrade, studentkey)
-- additional: average final grade by section year and sorted by quarter

SELECT sectionyear, quarterkey, studentkey, finalgrade, AVG(finalgrade) OVER (PARTITION BY sectionyear ORDER BY quarterkey)
FROM quarter
JOIN coursesection USING (quarterkey)
JOIN roster USING (sectionkey);

/*
5. Use the ROW_NUMBER function to return the row numbers for section year, section key,
student key and final grade for section 29 ordered by final grade.
*/
-- starting from the lowest final grade in section 29
SELECT
	sectionyear,
	sectionkey,
	studentkey,
	finalgrade,
	ROW_NUMBER () OVER (
		ORDER BY
			finalgrade
	)
FROM coursesection
JOIN roster USING (sectionkey)
WHERE sectionkey = 29;


/*
6. Use a ROW_NUMBER and a sub query to return rows 7, 8 and 9 from the query used in exercise 5.
*/
SELECT *
FROM
(SELECT
	sectionyear,
	sectionkey,
	studentkey,
	finalgrade,
	ROW_NUMBER () OVER (
		ORDER BY
			finalgrade
	)
FROM coursesection
JOIN roster USING (sectionkey)
WHERE sectionkey = 29) lowestFinalGrade
WHERE ROW_NUMBER BETWEEN 7 and 9;

/*
7. Return section year, section key, student key, final grade and rank for sections between 29 and
35, partitioned by section key and ordered by the final grade descending.
*/
-- show the ranks of students in their respective sections 
SELECT sectionyear, sectionkey, studentkey, finalgrade,
RANK() OVER (PARTITION BY sectionkey ORDER BY finalgrade DESC)
FROM coursesection
JOIN roster USING (sectionkey)
WHERE sectionkey BETWEEN 29 AND 35;

/*
8. Run the same query as in exercise 7 but use DENSE_RANK().
*/
-- SHOW THE RANKS OF STUDENTS IN THEIR RESPECTIVE SECTIONS BUT WITHOUT CONCERN TO MULTIPLE
-- STUDENTS PER RANK
SELECT sectionyear, sectionkey, studentkey, finalgrade,
DENSE_RANK() OVER (PARTITION BY sectionkey ORDER BY finalgrade DESC)
FROM coursesection
JOIN roster USING (sectionkey)
WHERE sectionkey BETWEEN 29 AND 35;

/*
9. Use the same query as in exercise 7 but order by final grade without DESC and return the FIRST
_VALUE instead of RANK.
*/
-- added another column called first_value to remind the lowest scorer of each section
SELECT sectionyear, sectionkey, studentkey, finalgrade,
FIRST_VALUE(finalgrade) OVER (PARTITION BY sectionkey ORDER BY finalgrade)
FROM coursesection
JOIN roster USING (sectionkey)
WHERE sectionkey BETWEEN 29 AND 35;


