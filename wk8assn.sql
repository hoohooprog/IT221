/*
1. Create a new instructor SCHEMA named instructorschema.

2. Create a VIEW in the instructorschema that provides a roster for section 71. It should include the students first and last names and their email.

3. Create an UPDATABLE VIEW in the instructorschema based on the table person that only includes those that live in the state of Washington.

4. Insert this person information through the VIEW: Melanie Jackson, meljack@gmail.com, 111 South Anderson Street, Seattle, WA, 98002,2065552323. The date added can be the current date and time.

5. UPDATE through the VIEW to change personkey 330. Set the firstname from “Kane” to “Kenneth”

6. Revise the VIEW to add the CHECK OPTION.

7. INSERT the following person through the VIEW: Rachel Norman, rachelnorman@msn.com, 212 Mercer Avenue, New York, NY, 00234, 1035552310. The date can be current date and time. Turn in both the SQL for changed VIEW and the resulting message.

8. Create a MATERIALIZED VIEW in the instructorschema that includes the first name, last name, student start date and status of every student.

9. Add Melanie Jackson from number 4 above to the student table. Make her start date whatever the start date for the current session is.

10. REFRESH THE MATERIALIZED VIEW
*/


CREATE SCHEMA instructorschema;

/*
2. Create a VIEW in the instructorschema that provides a roster for section 71. 
It should include the students first and last names and their email.
*/

CREATE VIEW roster_sect_71
AS
SELECT
person.lastname AS "student last name", 
person.firstname AS "student first name", 
person.email AS "student email"
FROM roster
JOIN student USING (studentkey)
JOIN person USING (personkey)
WHERE roster.sectionkey = 71;

SELECT * FROM roster_sect_71;

/*
3. Create an UPDATABLE VIEW in the instructorschema based on the table person that only includes those 
that live in the state of Washington.
*/

-- more convenient to use table.state instead of "state", better practice too?
CREATE VIEW instructorschema.people
AS
SELECT 
personkey AS "ID",
lastname AS "last name",
firstname AS "first name",
email,
address,
city,
person.state,
postalcode,
phone,
dateadded,
newsletter
FROM
person
WHERE "state" = 'WA';


/*  4. Insert this person information through the VIEW: 
	Melanie Jackson, meljack@gmail.com, 111 South Anderson Street, Seattle, WA, 98002,2065552323. 
	The date added can be the current date and time.
	*/

INSERT INTO instructorschema.people("last name","first name", email, address, city, "state", postalcode,phone,dateadded)
VALUES('Jackson','Melanie','meljack@gmail.com','111 South Anderson Street','Seattle','WA',98002,2065552323, current_timestamp);

SELECT *
FROM person
WHERE lastname = 'Jackson';

/*
5. UPDATE through the VIEW to change personkey 330. Set the firstname from “Kane” to “Kenneth”
*/
UPDATE instructorschema.people
SET "first name" = 'Kane'
WHERE "ID" = 330;

/*
6. Revise the VIEW to add the CHECK OPTION.
*/

-- ADD CHECK OPTION TO MAKE SURE UPDATES CAN ONLY HAPPEN ONLY IF VIEW CAN RETURN IT
-- IE THE CONDITIONS OF THE QUERY COULD PULL UP THE UPDATE

CREATE OR REPLACE VIEW instructorschema.people
AS
SELECT 
personkey AS "ID",
lastname AS "last name",
firstname AS "first name",
email,
address,
city,
person.state,
postalcode,
phone,
dateadded,
newsletter
FROM
person
WHERE "state" = 'WA'
WITH CHECK OPTION;

/*
7. INSERT the following person through the VIEW: Rachel Norman, rachelnorman@msn.com, 
212 Mercer Avenue, New York, NY, 00234, 1035552310. The date can be current date and time. 
Turn in both the SQL for changed VIEW and the resulting message.
*/

INSERT INTO instructorschema.people("last name","first name", email, address, city, "state", postalcode,phone,dateadded)
VALUES('Norman','Rachel','rachelnorman@msn.com','212 Mercer Avenue','New York','NY',00234,1035552310, current_timestamp);

-- ERROR:  new row violates check option for view "people"
-- DETAIL:  Failing row contains (438, Norman, Rachel, rachelnorman@msn.com, 212 Mercer Avenue, New York, NY, 234, 1035552310    , 2022-03-21, t).
-- SQL state: 44000

/*
8. Create a MATERIALIZED VIEW in the instructorschema that includes 
the first name, last name, student start date and status of every student.
*/

-- views that contain actual data; queries are prejoined instead of repeatedly
-- pulled from original tables and checked for referential integrity
-- drawback is data is not live (does not reflect current state of data in database)

CREATE MATERIALIZED VIEW instructorschema.studentprofile
AS
SELECT person.lastname AS "student last name", 
person.firstname AS "student first name", 
student.studentstartdate AS "student start date",
status.statusname
FROM roster
JOIN student USING (studentkey)
JOIN person USING (personkey)
JOIN status USING (statuskey)
WITH DATA;

SELECT *
FROM instructorschema.studentprofile;


/*
9. Add Melanie Jackson from number 4 above to the student table. 
Make her start date whatever the start date for the current session is.
*/
-- ?? what's the point of this exercise ??
SELECT *
FROM PERSON
WHERE lastname = 'Jackson';

SELECT *
FROM status;

-- redo this using select for personkey and startdate
INSERT INTO student(personkey,studentstartdate,statuskey)
VALUES(434 ,'2022-03-21', 1);

SELECT *
FROM student
WHERE personkey = 434;
/*
10. REFRESH THE MATERIALIZED VIEW
*/
REFRESH MATERIALIZED VIEW instructorschema.studentprofile;

