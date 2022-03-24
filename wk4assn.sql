/*
Using the techcertificate database, write the SQL to fulfill these statements or
answer the questions.
1. What is every possible combination of quarter and course?

2. What are the names, emails, and start dates of all the students who
started sometime in 2020?

3. What are the studentkey, student names, the course name, and the
instructorkey for sectionkey 17?

4. What is the total enrollment of students in each course by quarter?
Include the course names and quarter.

5. What is the average grade for each course? Include the course names.

6. What is the average grade for the student with the studentkey 21?

Include the last name and the average. (We won’t worry about GPA for
now. Just use a straight average.)
7. Which instructors listed have never taught a class? Return their names.

8. What are the names of the courses that have never been offered yet?

9. Use a FULL JOIN to return the same values as in question 8.

10. Use a NATURAL JOIN to show the name of each certificate and the
names of the courses each contains.
*/

/**********************************************
************************************************
************************************************
*/

/*
1. What is every possible combination of quarter and course?
*/

-- check out coursesection table
SELECT * 
FROM coursesection;

-- filter using distinct? (similar ex from past module) then inner join with course table and quarter table to 
-- show what's the names for each variables.

SELECT quarter.quarterkey, quarter.quartername, course.coursekey, course.coursename
FROM quarter
INNER JOIN coursesection ON (quarter.quarterkey = coursesection.quarterkey)
INNER JOIN course ON (coursesection.coursekey = course.coursekey);

-- looking at schema, I know to find combination of quarter and courses, I need to combine tables quarter, coursesection and course

/*
2. What are the names, emails, and start dates of all the students who
started sometime in 2020?
*/
SELECT *
FROM student;

-- find date corresponding to 2020 for students and select name, email, start date
-- inner join (year)=2020 in personkey key between student table and person table
SELECT person.lastname, person.firstname, person.email, student.studentstartdate
FROM person
INNER JOIN student ON (student.personkey = person.personkey)
WHERE EXTRACT(year FROM student.studentstartdate) = '2020'
ORDER BY studentstartdate DESC
;


/*
3. What are the studentkey, student names, the course name, and the
instructorkey for sectionkey 17?
*/

-- tables involved: student(studentkey,personkey), coursesection(linkin; sectionkey, coursekey, instructorkey), 
--                  person(student names, personkey), course(coursename, coursekey),
--					roster(studentkey, sectionkey)

-- joins order: (roster,student,person) -> coursesection -> course

SELECT student.studentkey, person.lastname, person.firstname, course.coursename, coursesection.instructorkey,
	   coursesection.sectionkey
FROM student
INNER JOIN person ON (student.personkey = person.personkey)
INNER JOIN roster ON (student.studentkey = roster.studentkey)
INNER JOIN coursesection ON (roster.sectionkey = coursesection.sectionkey)
INNER JOIN course ON (course.coursekey = coursesection.coursekey)
WHERE coursesection.sectionkey = '17';

/*
4. What is the total enrollment of students in each course by quarter?
Include the course names and quarter.
*/
SELECT *
FROM certificatecourse;
-- tables needed: coursesection(quarterkey,coursekey,sectionkey), roster(sectionkey, studentkey)  -> enables count of stud
--				  quarter(quarterkey, quartername) -> to id quarters
--				  course(coursekey, coursename) -> to id course

-- functions: COUNT, GROUP BY

SELECT COUNT(studentkey), quarter.quartername, course.coursename
FROM coursesection
INNER JOIN course ON (coursesection.coursekey = course.coursekey)
INNER JOIN quarter ON (coursesection.quarterkey = quarter.quarterkey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
GROUP BY quarter.quarterkey, course.coursename
ORDER BY quarter.quartername, course.coursename;

-- how to compare courses of different quarters?

/*
5. What is the average grade for each course? Include the course names.
*/
-- tables needed: course(coursekey, coursename), coursesection(coursekey,sectionkey), roster(sectionkey, finalgrade)
-- fns: GROUP BY to make distinct courses, AVERAGE SUM of finalgrade 

SELECT course.coursename, ROUND(SUM(roster.finalgrade)/count(roster.studentkey),2) AS "average grades of class"
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
GROUP BY course.coursename
HAVING SUM(roster.finalgrade)/count(roster.studentkey) IS NOT NULL;

SELECT course.coursename, SUM(roster.finalgrade)/count(roster.studentkey)
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
GROUP BY course.coursename;

-- check on data values, whether python data analytics really is null
SELECT course.coursename, roster.finalgrade
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
WHERE course.coursename LIKE 'Python Data%';

-- check avg grade for ETL
SELECT count(roster.finalgrade ISNULL) AS null_grades, count(roster.finalgrade) AS graded
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
WHERE course.coursename LIKE 'ETL%';

-- join tables course, coursesectionn, roster, filter for courses that start with ETL and display count of 
-- rows across course and roster with final grade above 2.0
-- ?? HOW TO SHOW COURSE NAME COLUMN IN RETURN, ALONG WITH COUNT, RATHER THAN JUST NAMING COLUMN AS SUCH  ??
SELECT count(roster.finalgrade > 2.0) AS "# PEOPLE ACROSS ROSTER THAT HAS GRADE ABOVE 2.0 FOR COURSE ETL"
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
WHERE course.coursename LIKE 'ETL%';

SELECT ROUND(SUM(roster.finalgrade)/count(roster.studentkey),2) AS etl_and_reporting_tools
FROM course
INNER JOIN coursesection ON (course.coursekey = coursesection.coursekey)
INNER JOIN roster ON (roster.sectionkey = coursesection.sectionkey)
WHERE course.coursename LIKE 'ETL%';

/*
6. What is the average grade for the student with the studentkey 21?
*/

-- tables used: roster(studentkey, finalgrade), coursesection(sectionkey)

-- check coursesection
-- sum the grades that studentkey 21 received across all classes and divide by the # of times
-- it appears to get average
SELECT SUM(roster.finalgrade)/COUNT(roster.studentkey) AS stdkey_21_gpa
FROM roster
WHERE studentkey = 21;

/*
7. Which instructors listed have never taught a class? Return their names.
*/
SELECT person.personkey, person.lastname, person.firstname, instructor.instructorkey
FROM instructor
LEFT JOIN coursesection ON (instructor.instructorkey = coursesection.instructorkey)
INNER JOIN person ON (person.personkey = instructor.personkey)
WHERE coursesection.coursekey ISNULL;

/*
8. What are the names of the courses that have never been offered yet?
*/

-- courses that haven been offered yet do not have coursesection.coursekey/course.coursekey
-- LEFT JOIN == values in the left set + ISNULL == exclude items with connecting key
-- tables used: course(coursekey, coursename); coursesection(coursekey)
SELECT course.coursekey, course.coursename, coursesection.coursekey
FROM course
LEFT JOIN coursesection ON (coursesection.coursekey = course.coursekey)
WHERE coursesection.coursekey ISNULL;

/*
9. Use a FULL JOIN to return the same values as in question 8.
*/
-- combbine whole set then show only NULL coursekey
SELECT course.coursekey, course.coursename, coursesection.coursekey, coursesection.quarterkey
FROM course
FULL JOIN coursesection ON (coursesection.coursekey = course.coursekey)
WHERE coursesection.coursekey ISNULL;

/*
10. Use a NATURAL JOIN to show the name of each certificate and the
names of the courses each contains.
*/
-- NATURAL JOIN PRODUCES EQUIVALENT RESULTS AS INNER JOIN (IN THIS CASE OR IN GENERAL?)
SELECT certificate.certificatekey, certificate.certificatename, course.coursename
FROM certificate
JOIN certificatecourse ON (certificate.certificatekey = certificatecourse.certificatekey)
JOIN course ON (course.coursekey = course.coursekey)
GROUP BY certificate.certificatekey, certificate.certificatename, course.coursename;

SELECT certificate.certificatekey, certificate.certificatename, course.coursename
FROM certificate
INNER JOIN certificatecourse ON (certificate.certificatekey = certificatecourse.certificatekey)
INNER JOIN course ON (course.coursekey = course.coursekey)
GROUP BY certificate.certificatekey, certificate.certificatename, course.coursename;