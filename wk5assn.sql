/*
For all of these, use subqueries even where a JOIN would make more sense.

1.       What are the course names for the courses in Certificate 3?

2.       Who were the people added first to the person table? (You could sort, but use a subquery. 
		 The MIN () function will return the earliest date)

3.       Return all the students (just their key for now) who are not in any roster.

4-5. Create a query using the roster table that returns these results. 
	(I am only showing the top 6 results-there are actually 67 rows returned. The field averaged is finalgrade. 
	 I rounded the results to two decimal points. I also removed all nulls with HAVING AVG(finalgrade) IS NOT NULL. 
	 The difference is the grouped average subtracted form the total table average. 
	 A negative result means that the section grades were higher than average, 
	 a positive result that they were below the school average.)
	 
6.  Use a table expression to get the student key, last name, first name and email from all the   students in section 30.

7. Redo number 6 as a Common table expression.

8. Create a Common table expression that shows each instructors name and specialty area.

9-10.   Create a correlated subquery that shows which students had grades less than the average grades for each section.

*/


/*
1. what are the course names for the courses in Certificate 3?
*/
-- tables: course(coursekey, coursename), certificatecourse(certificatekey, coursekey), 
-- 		   certificate(certificatekey, certificatename)

/*
SELECT course.coursename, course.coursekey
FROM course
WHERE course.coursekey IN (SELECT certificatecourse.coursekey, certificate.certificatename
	   FROM certificatecourse
	   INNER JOIN certificate ON (certificate.certificatekey = certificatecourse.certificatekey)
	   WHERE certificate.certificatekey = 3);
*/

-- create a temp table with WITH called certificate 3 to inner join with course table such that
-- only courses in certificate 3 shows, DISTINCT() is not necessary
WITH certificate_3 AS
(
	SELECT DISTINCT(certificatecourse.certificatekey), certificate.certificatename, certificatecourse.coursekey
	FROM certificatecourse
	INNER JOIN certificate ON (certificate.certificatekey = certificatecourse.certificatekey)
	WHERE certificate.certificatekey = 3
	   	
)   
SELECT course.coursename, course.coursekey, certificate_3.certificatename, certificate_3.certificatekey
FROM course
INNER JOIN certificate_3 ON (course.coursekey = certificate_3.coursekey)
;


/*

2. Who were the people added first to the person table? (could sort, but use a subquery.
   The MIN() function will return the earliest date)
   
*/

-- subquery contained in condition of WHERE clause such that data rows are matched with
-- outcome of subquery using feature dateadded
-- tables: person

SELECT person.personkey, person.lastname, person.firstname, person.dateadded
FROM person
WHERE person.dateadded IN (SELECT MIN(person.dateadded) FROM person);

/*
3.       Return all the students (just their key for now) who are not in any roster.
*/

-- tables:student, roster
-- regular method without subquery
SELECT student.studentkey, roster.rosterkey
FROM student
LEFT JOIN roster ON (student.studentkey = roster.studentkey)
WHERE roster.studentkey ISNULL;



-- method using subquery
SELECT student.studentkey
FROM student
WHERE 
	NOT EXISTS(
		SELECT
				1
		FROM 
				roster
		WHERE
				roster.studentkey = student.studentkey);

/*
4-5. Create a query using the roster table that returns these results. 
	(I am only showing the top 6 results-there are actually 67 rows returned. The field averaged is finalgrade. 
	 I rounded the results to two decimal points. I also removed all nulls with HAVING AVG(finalgrade) IS NOT NULL. 
	 The difference is the grouped average subtracted form the total table average. 
	 A negative result means that the section grades were higher than average, 
	 a positive result that they were below the school average.)
*/
-- look at roster table again
-- find tables that connect to roster that contains values to be averaged
-- 
/*
WITH section_avg AS 
(
	SELECT sectionkey, AVG(finalgrade) AS "section_avg"
	FROM roster
	GROUP BY sectionkey
	HAVING AVG(finalgrade) IS NOT NULL
	ORDER BY sectionkey DESC
),
overall_avg AS
(
	SELECT AVG(finalgrade) AS "total_avg"
	FROM roster
)

SELECT section_avg.sectionkey, ROUND(section_avg.sectionaverage,2) AS sectionaverage,
ROUND(AVG(finalgrade),2) AS "overallaverage",
ROUND(section_avg.sectionaverage,2) - ROUND(AVG(finalgrade),2) AS "diff"
FROM roster AS r1
INNER JOIN 
( SELECT sectionkey, AVG(finalgrade) AS "sectionaverage"
	FROM roster
	GROUP BY sectionkey
	HAVING AVG(finalgrade) IS NOT NULL ) AS section_avg
ON r1.sectionkey = section_avg.sectionkey
GROUP BY section_avg.sectionkey, section_avg.sectionaverage
ORDER BY sectionkey DESC;

SELECT
AVG(r1.finalgrade) AS "overallaverage", 
( SELECT AVG(finalgrade) 
    FROM roster
    GROUP BY sectionkey
    HAVING AVG(finalgrade) IS NOT NULL ) AS "section_avg"
FROM roster AS r1
GROUP BY sectionkey;
*/
-- select subquery can only return 1 const value 
SELECT sectionkey,ROUND(AVG(finalgrade),2) AS "sectionaverage",
(SELECT ROUND(AVG(finalgrade),2)
 FROM roster) AS "overallaverage",
ROUND((SELECT AVG(finalgrade)
 FROM roster) - AVG(finalgrade),2) AS "diff"
FROM roster
GROUP BY sectionkey
HAVING AVG(finalgrade) IS NOT NULL;

/*6.  Use a table expression to get the student key, last name, first name and email from all the   students in section 30.*/

--tables: roster(studentkey,sectionkey), student(studentkey, personkey),person(personkey, lastname, firstname,email)
-- error w ambiguity because I had student.studentkey in select query

	SELECT
	roster.studentkey, person.lastname, person.firstname, person.email
	FROM 
	roster
	INNER JOIN student
	ON roster.studentkey = student.studentkey
	INNER JOIN person
	ON student.personkey = person.personkey
	where roster.sectionkey = 30;



/*
7. Redo number 6 as a Common table expression.
*/
WITH students_in_sect30 AS (
	SELECT
	roster.studentkey, roster.sectionkey, person.personkey, person.lastname, person.firstname, person.email
	FROM 
	roster
	INNER JOIN student
	ON roster.studentkey = student.studentkey
	INNER JOIN person
	ON student.personkey = person.personkey
	where roster.sectionkey = 30
)
SELECT studentkey, lastname, firstname, email
FROM students_in_sect30;

/*
8. Create a Common table expression that shows each instructors name and specialty area.
*/
-- features: person.lastname, person.firstname, instructionalarea.areaname, instructionalarea.description
-- tables: person(personkey),instructor(instructorkey, personkey),instructorarea(instructorkey,instructionalareakey),
-- 		   instructionalarea(instructionalareakey)

-- CTE with all of instructors' details
-- why CTE? neater/cleaner than regular table expression, especially if using FROM subquery, allows us to define
-- and name subqueries first, more logical/readable.
WITH instructor_details AS (
	SELECT *
	FROM person
	INNER JOIN instructor
	ON person.personkey = instructor.personkey
	INNER JOIN instructorarea
	ON instructor.instructorkey = instructorarea.instructorkey
	INNER JOIN instructionalarea
	ON instructorarea.instructionalareakey = instructionalarea.instructionalareakey
)
SELECT lastname, firstname, areaname, description
FROM instructor_details;

/*
9-10.   Create a correlated subquery that shows which students had grades less than the average grades for each section.
*/
SELECT r1.finalgrade, student.studentkey, person.lastname, person.firstname, r1.sectionkey
FROM roster r1
INNER JOIN student
ON r1.studentkey = student.studentkey
INNER JOIN person
ON student.personkey = person.personkey
WHERE finalgrade <
		( SELECT AVG(finalgrade)
		 FROM roster r2
		  WHERE r1.sectionkey = r2.sectionkey )
ORDER BY finalgrade DESC;

/*
SELECT AVG(finalgrade), sectionkey
FROM roster
GROUP BY sectionkey
ORDER BY sectionkey;
*/