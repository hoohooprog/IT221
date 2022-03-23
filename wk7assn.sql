-- https://www.postgresql.org/docs/9.5/datatype.html
/*
1.       Write the SQL to CREATE the location table. Run it to debug any errors

2.       Write the SQL to CREATE the seminar table. Run it to debug any errors.

3.       Write the SQL to create the seminardetails table, but don’t include the keys in the definition.  Run the code to debug for errors.

4.       ALTER the seminardetails table to add the PRIMARY KEY.

5.       ALTER the seminardetails table to add the FOREIGN KEYS

6.       Write the SQL to create the attendance table. Run the code to debug any errors.

7.       ALTER the person table to add a BOOLEAN column “newsletter” the default is “true.”

8.       Add a CHECK CONSTRAINT to the finalgrade column that sets the range between 0 and 4.

9.       CREATE a TEMP table that contains all the students in roster that have a NULL grade.

10.   DROP the TEMP table.

1-3-4-5-7-8-9-10-2-6
*/

-- ?? how to view sql def of table ??
/*
CREATE TABLE [IF NOT EXISTS] table_name (
   column1 datatype(length) column_contraint,
   column2 datatype(length) column_contraint,
   column3 datatype(length) column_contraint,
   table_constraints
);
*/

-- SERIAL is not really a data type; it is more of a function. 
-- It assigns a data type of INTEGER and auto-numbers the key field, 
-- providing a quick, easy, and unique key for each row.

/*
1.       Write the SQL to CREATE the location table. Run it to debug any errors
*/
ROLLBACK;
BEGIN;

CREATE TABLE IF NOT EXISTS location (
	locationkey INTEGER PRIMARY KEY,
	locationname TEXT NOT NULL,
	locationaddress TEXT NOT NULL,
	locationcity TEXT NOT NULL,
	locationstate CHAR(2) NOT NULL,
	postalcode VARCHAR(12) NOT NULL,
	phone VARCHAR(13) NOT NULL,
	email TEXT UNIQUE
);

COMMIT;

/*
2.       Write the SQL to CREATE the seminar table. Run it to debug any errors.
*/
BEGIN;

CREATE TABLE IF NOT EXISTS seminar (
	seminardetailkey SERIAL PRIMARY KEY,
	locationkey INT NOT NULL REFERENCES location(locationkey),
	theme TEXT NOT NULL,
	seminardate DATE NOT NULL,
	description TEXT
);
COMMIT;

/*
3. Write the SQL to create the seminardetails table, 
	but don’t include the keys in the definition.  
	Run the code to debug for errors.
*/

CREATE TABLE IF NOT EXISTS seminardetails (
	topic TEXT NOT NULL,
	presenttime TIME,
	room CHAR(5),
	description TEXT
);

/*
4.       ALTER the seminardetails table to add the PRIMARY KEY.
*/

ALTER TABLE seminardetails
ADD COLUMN seminardetailkey serial;

ALTER TABLE seminardetails
ADD PRIMARY KEY (seminardetailkey);

/*
5.       ALTER the seminardetails table to add the FOREIGN KEYS
*/
ALTER TABLE seminardetails
ADD COLUMN seminarkey INT NOT NULL;

ALTER TABLE seminardetails
ADD CONSTRAINT fk_seminarkey FOREIGN KEY
(seminarkey) references seminar(seminarkey);

/*
6.       Write the SQL to create the attendance table. Run the code to debug any errors.
*/
-- PK attendencekey (int,serial), FK seminardetailkey(int,notnull)
-- FK personkey int not null
CREATE TABLE IF NOT EXISTS attendance (
	attendencekey SERIAL PRIMARY KEY,
	seminardetailkey INTEGER NOT NULL,
	personkey INTEGER NOT NULL
);

ALTER TABLE attendance
ADD CONSTRAINT fk_seminardetail_attnd FOREIGN KEY 
	(seminardetailkey) REFERENCES seminardetails(seminardetailkey),
ADD CONSTRAINT fk_personkey FOREIGN KEY (personkey) REFERENCES
	person(personkey);
	
/*
7.       ALTER the person table to add a BOOLEAN column “newsletter” the default is “true.”
*/
ALTER TABLE person
ADD COLUMN newsletter BOOLEAN DEFAULT TRUE;

/*
8.       Add a CHECK CONSTRAINT to the finalgrade column that sets the range between 0 and 4.
*/
ALTER TABLE roster
ADD CONSTRAINT ck_finalgrade CHECK( (0<=finalgrade) AND (finalgrade <= 4) );

SELECT *
FROM roster;

/*
9.       CREATE a TEMP table that contains all the students in roster that have a NULL grade.
*/
SELECT *
INTO TEMP nullgrades
FROM roster
WHERE finalgrade ISNULL;

SELECT *
FROM nullgrades;

/*
10.   DROP the TEMP table.
*/
DROP TABLE nullgrades;
