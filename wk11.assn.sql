/*
1. List all the tables in techcertificates. 
2. List all the columns in Certificate along with their data types. 
3. Create an index on lastname in person. 
4. Create an index on studentkeyin roster. 
5. Create a multiple column index on coursesection which includes coursekey, quarterkey, and sectionyear. 


7. Create a role called “instructorrole” that has permission to SELECT from all the tables in the schema public 
   and in the instructorschema. (We only do select for now.) 
8. Grant the instructorrole to mbrown. Test the login and permissions. 
*/

/*
1. List all the tables in techcertificates.
*/
SELECT * FROM information_schema.Tables;

/*
2. List all the columns in Certificate along with their data types.
*/

SELECT Column_name, data_type FROM information_schema.columns
WHERE table_name='certificate';

/*
3. Create an index on lastname in person.
*/
CREATE INDEX ON person(lastname);

/*
4. Create an index on studentkey in roster. 
*/
CREATE INDEX ON roster(studentkey);

/*
5. Create a multiple column index on coursesection which includes coursekey, quarterkey, and sectionyear.
*/
CREATE INDEX ON coursesection(coursekey,quarterkey,sectionyear);

/*
6. Create a role called mbrown (for Miriana Brown, one of the instructors) with a LOGIN and a password of ‘P@ssw0rd1’.
*/
CREATE ROLE mbrown WITH password 'P@ssw0rd1' LOGIN;

/*
7. Create a role called “instructorrole” that has permission to SELECT from all the tables in the schema public 
   and in the instructorschema. (We only do select for now.) 
   GRANT SELECT ON ALL TABLES IN SCHEMA public TO employeerole;
*/

CREATE ROLE instructorrole;
GRANT SELECT ON ALL TABLES IN SCHEMA public to instructorrole;
GRANT SELECT ON ALL TABLES IN SCHEMA instructorschema to instructorrole;

/*
8. Grant the instructorrole to mbrown. Test the login and permissions.
*/
grant instructorrole to mbrown;