---------------------------------------------
/*

1.       The user name in the login table is like the user name in Community Assist except it does not put it all in lower case. For instance, Vivian Justice becomes VJustice. Make a FUNCTION that takes in the first name and lastname as parameters and returns a username.

2.       CREATE a FUNCTION that returns the number of credits in a certificate. It takes a certificatekey as a parameter and returns INTEGER. You will need to join course and certificate course to do this. You can return the query to do this. Just write RETURN (SELECT etc.).

3.       CREATE a FUNCTION that returns the cost of a section. You will need to join course, coursesection and pricehistory to do this. The query should take the sectionkey as a parameter and return NUMERIC.

4.       CREATE a FUNCTION that returns the total number of credits a student has taken.

5.       CREATE a FUNCTION that returns a table containing the coursename, credits and grade for each course they have taken

6.       CREATE a procedure type Function that inserts a new student. You will need to INSERTinto person, student and logintable.

7.       CREATE a procedure that lets a student UPDATE their own information (name, email, phone and addresses only.)

8.       ALTER the roster table to ADD a Boolean column called lowgradeflag. The DEFAULT is false.

9.       CREATE a trigger FUNCTION that flags a grade if it is less than 2.0.

10.   CREATE a trigger on the table roster that fires after UPDATE and EXECUTES the TRIGGER FUNCTION created in exercise 9.
*/

-------------------------------------------------------






/*
1. The user name in the login table is like the user 
name in Community Assist except it does not put it all in lower case. 

For instance, Vivian Justice becomes VJustice. 

Make a FUNCTION that takes in the 
first name and lastname as parameters and returns a username.
*/
CREATE OR REPLACE FUNCTION username_creation
(lastname TEXT, firstname TEXT)
RETURNS TEXT
AS $$
BEGIN
-- take first letter of firstname and concatenate with lastname
-- return text object
RETURN SUBSTRING(firstname,1,1) || lastname;
END;
$$ LANGUAGE plpgsql;

SELECT person.firstname, person.lastname,
username_creation(lastname, firstname) AS username
FROM
person;

/*
2. CREATE a FUNCTION that returns the number of credits in a certificate.

It takes a certificatekey as a parameter and returns INTEGER. 

You will need to join course and certificate course to do this. 

You can return the query to do this. Just write RETURN (SELECT etc.).
*/
DROP FUNCTION total_credits_in_cert(integer);

CREATE OR REPLACE FUNCTION total_credits_in_cert
(certkey INTEGER)
RETURNS TABLE
(
	certificatekey INT,
	total_credits BIGINT
)
AS $$
BEGIN
-- join certificatecourse and course, GROUP BY credits based on certificatekey
RETURN QUERY
SELECT certificatecourse.certificatekey, SUM(credits) AS "total credits per certificate"
FROM certificatecourse
INNER JOIN course
ON certificatecourse.coursekey = course.coursekey
GROUP BY certificatecourse.certificatekey
HAVING certkey = certificatecourse.certificatekey;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM total_credits_in_cert(1);

/*
3. CREATE a FUNCTION that returns the cost of a section. 
You will need to join course, coursesection and pricehistory to do this. 
The query should take the sectionkey as a parameter and return NUMERIC.
*/
-- GROUP BY coursesection.sectionkey, course.credits, pricehistory.pricepercredit, pricehistory.pricediscount
-- GROUPBY NOT NEEDED SINCE THERE'S SECTION KEYS ARE UNIQUE

CREATE OR REPLACE FUNCTION cost_of_section
(sectkey INT)
RETURNS NUMERIC
AS $$
BEGIN
RETURN
-- returns pricepercreditafterdiscount * total credits of courses in section
(SELECT (pricehistory.pricepercredit-pricehistory.pricediscount) * course.credits AS "cost of section after discount"
FROM coursesection
INNER JOIN course
ON coursesection.coursekey = course.coursekey
INNER JOIN pricehistory
ON coursesection.pricehistorykey = pricehistory.pricehistorykey
WHERE coursesection.sectionkey = sectkey);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cost_of_section(9);

/*
SELECT *, (pricepercredit-pricediscount) AS "pricepercredit after discount"
FROM pricehistory;

SELECT *
FROM coursesection
INNER JOIN course
ON coursesection.coursekey = course.coursekey
INNER JOIN pricehistory
ON coursesection.pricehistorykey = pricehistory.pricehistorykey
*/

/*
4.       CREATE a FUNCTION that returns the total number of credits a student has taken.
*/
CREATE OR REPLACE FUNCTION total_credits_student_taken
(studkey INT)
RETURNS INT 
AS $$
BEGIN
RETURN SUM(course.credits)
FROM roster
INNER JOIN coursesection
ON roster.sectionkey = coursesection.sectionkey
INNER JOIN course
ON course.coursekey = coursesection.coursekey
WHERE roster.studentkey = 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM total_credits_student_taken(1)

/*
5. CREATE a FUNCTION that returns a table containing the coursename, 
   credits and grade for each course they have taken
*/
CREATE OR REPLACE FUNCTION taken_course_details_n_grades()
RETURNS TABLE 
(
	coursename text,
	credits int,
	finalgrade numeric,
	studentkey int
)
AS $$
BEGIN
RETURN QUERY
(SELECT course.coursename, course.credits, roster.finalgrade , roster.studentkey
FROM roster
INNER JOIN coursesection
ON roster.sectionkey = coursesection.sectionkey
INNER JOIN course
ON coursesection.coursekey = course.coursekey
ORDER BY studentkey ASC);
END;
$$
LANGUAGE plpgsql;

select * from taken_course_details_n_grades();

/*
6. CREATE a procedure type Function that inserts a new student. 
   You will need to INSERTinto person, student and logintable.
*/

CREATE OR REPLACE FUNCTION addstudent
(
	new_firstname TEXT,
	new_lastname TEXT,
	new_email TEXT,
	new_address TEXT,
	new_city TEXT,
	new_state CHAR(2),
	new_postalcode CHAR(11),
	new_phone CHAR,
	new_passwd VARCHAR(50)
) RETURNS void
AS $$
INSERT INTO person
(lastname, firstname, email, address, city, "state", postalcode, phone, dateadded)
VALUES(new_lastname, new_firstname, new_email, new_address, new_city, new_state, new_postalcode, new_phone, current_timestamp);
INSERT INTO student
(personkey, studentstartdate)
VALUES(CURRVAL('person_personkey_seq'),current_timestamp);
INSERT INTO logintable
(username, personkey, userpassword, datelastchanged)
VALUES(username_creation(new_lastname,new_firstname), CURRVAL('person_personkey_seq'),new_passwd, current_timestamp);
$$ LANGUAGE sql;


SELECT addstudent(
'Joseph', 'Rodgers', 'joseph.rodgers@hotmail.com',
'222 7th Avenue','Seattle',
'WA', '98001','2065552010','RodgersPass'
);



SELECT * FROM PERSON WHERE Lastname='Rodgers';
SELECT * FROM STUDENT WHERE PERSONKEY = 405;
SELECT * FROM LOGINTABLE WHERE PERSONKEY = 405;

/*
7.  CREATE a procedure that lets a student UPDATE their own information 
(name, email, phone and addresses only.)
*/

CREATE OR REPLACE function editStudent
(
	pkey INTEGER,
	new_firstname TEXT,
	new_lastname TEXT,
	new_email TEXT,
	new_phone CHAR,
	new_address TEXT,
	new_city TEXT,
	new_state CHAR(2),
	new_postalcode CHAR(11)
) RETURNS VOID
AS $$
UPDATE person
SET lastname=new_lastname,
firstname=new_firstname,
email=new_email,
address=new_address,
city=new_city,
"state"=new_state,
postalcode=new_postalcode,
phone=new_phone,
dateadded=current_timestamp
WHERE personkey=pKey;
$$ LANGUAGE sql;

SELECT editStudent(
405,'Joseph', 'Rodgers', 'joseph.rodgers@hotmail.com',
'2065552010','1200 150th Street','Seattle',
'WA', '98001'
);

/*
8.       ALTER the roster table to ADD a Boolean column called lowgradeflag. The DEFAULT is false.
*/
ALTER TABLE roster
ADD lowgradeflag BOOLEAN DEFAULT FALSE;

/*
9.       CREATE a trigger FUNCTION that flags a grade if it is less than 2.0.
*/
CREATE OR REPLACE FUNCTION flaggrade()
RETURNS TRIGGER AS
$BODY$
BEGIN
IF NEW.finalgrade < 2.0
THEN
UPDATE roster
SET lowgrade=TRUE
WHERE studentkey=NEW.studentkey;
END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


/* 10.   CREATE a trigger on the table roster that fires after UPDATE and EXECUTES the TRIGGER FUNCTION created in exercise 9. */

CREATE TRIGGER roster_flaggrade_afterUpdate
AFTER UPDATE
ON roster
FOR EACH ROW
EXECUTE PROCEDURE flaggrade();