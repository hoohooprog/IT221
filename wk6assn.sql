/*

Be especially careful with the UPDATE and DELETE commands. Use the BEGIN TRANSACTION and ROLLBACK or COMMIT command 
if you need for safety.

1. Insert a new course called testcourse. 
   It will be worth 0 credits and the description will simple say “this is a test.”

2-4. Add a new student:

		Roberta Hernadez
		apt 101, 234 Nelson Street
		Seattle, WA 98122
		2065552019
		rhernadez@outlook.com

	The date added should be today. You will also need to add her to the logintable. 
	The username should be the first letter of her first name and her whole last name. 
	To get the password, use the CRYPT function like this:

	crypt(‘HernadezPass’, gen_salt('bf', 8))

5-7.  Add a new instructor.

                Marylin Brenen

				1983 South Madison

 				Seattle. WA, 98122

				2065557798

	Her work email will be Maylin.Brenen@getcerts.com

	Her instructional areas are web design, javascript and mobile apps development.

	You will need to add her to the login table just like the student in the exercise above.

 

8. Geraldine Clark (personkey 211) notified the school that her last name was wrong, It should be “Clarkston.” 
   Also, her email should be geraldineclark@msn.com. Make those changes.
9. Luke Smith, studentkey 19, was mistakenly give the grade 2.23 for the course with the roster key 1179. 
   It should be 3.22. UPDATE Roster to the correct grade.
10. Delete testcourse from the course table

*/

/*
	1. Insert a new course called testcourse. 
    It will be worth 0 credits and the description will simple say “this is a test.”
*/
ROLLBACK;

BEGIN;
INSERT INTO course(coursename,credits, coursedescription)
VALUES('testcourse',0, 'this is a test');

SELECT *
FROM course;

COMMIT;

/*
2-4. Add a new student:

		Roberta Hernadez
		apt 101, 234 Nelson Street
		Seattle, WA 98122
		2065552019
		rhernadez@outlook.com

	The date added should be today. You will also need to add her to the logintable. 
	The username should be the first letter of her first name and her whole last name. 
	To get the password, use the CRYPT function like this:

	crypt(‘HernadezPass’, gen_salt('bf', 8))
	
	https://www.postgresql.org/docs/8.3/pgcrypto.html
*/
-- ??why crypt fn takes so long to be added to db??
SELECT *
FROM person;



ROLLBACK;

BEGIN TRANSACTION;

-- insert values that aren't auto gen. ie PK
INSERT INTO person(firstname, lastname, address, city, "state",postalcode, phone, dateadded, email)
VALUES('Roberta','Hernadez','apt 101, 234 Nelson Street', 'Seattle','WA', '98122', '2065552019',current_timestamp,
	  'rhernadez@outlook.com');

-- would there be better way to maintain date between tables?
-- CURRVAL returns the latest serial from a sequence(table) CURRVAL('table_keyname_seq')
-- to this table student
INSERT INTO student(studentstartdate, statuskey,personkey)
VALUES(current_timestamp, 4, CURRVAL('person_personkey_seq') );

-- also performs the same with CURRVAL to link to related table row
INSERT INTO logintable(username, personkey, userpassword, datelastchanged)
VALUES('RHernadez',CURRVAL('person_personkey_seq'), 'HernadezPass', current_timestamp);

SELECT *
FROM logintable
INNER JOIN PERSON on logintable.personkey = person.personkey
INNER JOIN student ON person.personkey = student.personkey
WHERE person.personkey = CURRVAL('person_personkey_seq');

COMMIT;

/*
5-7.  Add a new instructor.

                Marylin Brenen

				1983 South Madison

 				Seattle. WA, 98122

				2065557798

	Her work email will be Maylin.Brenen@getcerts.com

	Her instructional areas are web design, javascript and mobile apps development.

	You will need to add her to the login table just like the student in the exercise above.
*/

-- person -> logintable -> instructor -> instructorarea
--?? is there a more elegant way of inserting multiple values in another table with the same value key of current table??
SELECT *
FROM instructionalarea
WHERE areaname = 'JavaScript Development';

ROLLBACK; 

BEGIN;

INSERT INTO person(firstname, lastname, address, city, "state", postalcode, phone, email, dateadded)
VALUES('Marylin','Brenen','1983 South Madison','Seattle','WA','98122','2065557798','Maylin.Brenen@getcerts.com'
	   ,current_timestamp);
	   
INSERT INTO logintable(username, personkey, userpassword, datelastchanged)
VALUES('MBrenen', CURRVAL('person_personkey_seq'), 'BrenenPass', current_timestamp);

INSERT INTO instructor(personkey, hiredate, statuskey)
VALUES(CURRVAL('person_personkey_seq'), current_timestamp, 4);

INSERT INTO instructorarea(instructionalareakey, instructorkey)
VALUES
((SELECT instructionalareakey FROM instructionalarea WHERE areaname='Web Design'),CURRVAL('instructor_instructorkey_seq')), 
((SELECT instructionalareakey FROM instructionalarea WHERE areaname='JavaScript Development'), CURRVAL('instructor_instructorkey_seq')),
((SELECT instructionalareakey FROM instructionalarea WHERE areaname='Mobile Apps'), CURRVAL('instructor_instructorkey_seq'))
;

SELECT *
FROM person
JOIN logintable USING (personkey)
JOIN instructor USING (personkey)
JOIN instructorarea USING (instructorkey)
WHERE person.lastname = 'Brenen';

COMMIT;
	   
/*
8. Geraldine Clark (personkey 211) notified the school that her last name was wrong, It should be “Clarkston.” 
   Also, her email should be geraldineclark@msn.com. Make those changes.
*/
BEGIN;
UPDATE person
SET lastname='Clarkston',
email='geraldineclark@msn.com'
WHERE personkey=211;

SELECT *
FROM person
WHERE personkey=211;

COMMIT;

/*
9. Luke Smith, studentkey 19, was mistakenly give the grade 2.23 for the course with the roster key 1179. 
   It should be 3.22. UPDATE Roster to the correct grade.
*/

SELECT *
FROM roster
WHERE rosterkey=1179;

BEGIN;
UPDATE roster
SET finalgrade = 2.23
WHERE rosterkey=1179;
COMMIT;

/*
10. Delete testcourse from the course table
*/
SELECT *
FROM course
where coursename='testcourse';

BEGIN;
DELETE FROM course WHERE coursename='testcourse';

COMMIT;


