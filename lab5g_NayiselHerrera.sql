/* ==========================================================================
   lab5g_starter.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5g, Procedures That Make Decisions

   WHAT THIS FILE IS
   Lab 5f finished, plus a numbered heading for every step of Lab 5g waiting
   to be filled in.

   WHAT IT ALREADY BUILDS
     1. Everything Lab 5f started from: the tables, the view, the function,
        attendance and the two triggers
     2. The three procedures from Lab 5f: list_students (highest gpa
        first), student_report and scores_for_test

   HOW TO RUN IT
   One statement at a time. Put the cursor on it and press Ctrl + E twice.
   Anything that runs from CREATE down to END (a function, a trigger or a
   procedure) is ONE statement, however many semicolons are inside it.
   Select the whole block and run the selection. No DELIMITER lines.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these three first, one at a time, while you are still
-- connected to information_schema.
-- =================================================================

-- every schema on this server. cis_students_db may or may not be listed.
show databases;

-- make yours. IF NOT EXISTS means it is safe to run twice.
create database if not exists cis_students_db;

-- switch into it, so everything below lands in the right place.
use cis_students_db;


-- ==================================================================
-- FROM LAB 5D. students. student_id is a surrogate key the server fills in.
-- ==================================================================
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name  VARCHAR(40) NOT NULL,
    gpa        FLOAT(4,2)
);
INSERT INTO students VALUES (NULL,'Jenna','Wilson',NULL);
INSERT INTO students VALUES (NULL,'Robert','Reese',NULL);
INSERT INTO students VALUES (NULL,'Maria Elena','Jimenez',NULL);
INSERT INTO students VALUES (NULL,'Inder','Singh',NULL);
INSERT INTO students (first_name,last_name) VALUES ('Rita','Nunez');
INSERT INTO students (first_name,last_name) VALUES ('James','Toor');

-- ==================================================================
-- James was student 6. Deleting him is why the counter says 7.
-- ==================================================================
DELETE FROM students WHERE first_name = 'James' AND last_name = 'Toor';

-- ==================================================================
-- FROM LAB 5D. test_scores, linked to students by a foreign key.
-- ==================================================================
CREATE TABLE test_scores (
    test_score_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name     VARCHAR(20) NOT NULL,
    student_id    INT NOT NULL,
    score         FLOAT,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
INSERT INTO test_scores VALUES (NULL,'quiz1',1,90),(NULL,'quiz1',2,85),(NULL,'quiz1',3,95),
 (NULL,'quiz2',1,80),(NULL,'quiz2',2,72),(NULL,'quiz2',3,88),(NULL,'quiz2',4,91),
 (NULL,'quiz3',2,95),(NULL,'quiz3',3,94),(NULL,'quiz3',4,74);

-- ==================================================================
-- FROM LAB 5D. The student_scores view.
-- ==================================================================
CREATE VIEW student_scores AS
SELECT s.student_id,
       CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       t.test_name,
       t.score
FROM students s
LEFT OUTER JOIN test_scores t ON s.student_id = t.student_id;

-- ==================================================================
-- FROM LAB 5D. The calculate_gpa function. Select the whole block from
-- CREATE FUNCTION down to END and run the selection.
-- ==================================================================
CREATE FUNCTION calculate_gpa(p_student_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_gpa DECIMAL(4,2);

    SELECT ROUND(AVG(score), 2)
    INTO v_gpa
    FROM test_scores
    WHERE student_id = p_student_id
      AND score IS NOT NULL;

    RETURN IFNULL(v_gpa, 0.00);
END;

-- ==================================================================
-- Fill in every gpa using the function.
-- ==================================================================
UPDATE students SET gpa = calculate_gpa(student_id);

-- ==================================================================
-- FROM LAB 5E. attendance, with its surrogate key starting at 500.
-- ==================================================================
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    attended_on   DATE,
    status        VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
) AUTO_INCREMENT = 500;
INSERT INTO attendance (student_id, attended_on, status) VALUES (1,'2026-10-05','present');
INSERT INTO attendance (student_id, attended_on, status) VALUES (2,'2026-10-05','absent');
INSERT INTO attendance (student_id, attended_on, status) VALUES (3,'2026-10-06','present');

-- ==================================================================
-- FROM LAB 5E. The BEFORE INSERT trigger. Select the whole block and run the selection.
-- ==================================================================
CREATE TRIGGER trg_attendance_before_insert
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NEW.attended_on IS NULL THEN
        SET NEW.attended_on = CURDATE();
    END IF;
    SET NEW.status = UPPER(NEW.status);
END;

-- ==================================================================
-- FROM LAB 5E. The AFTER DELETE trigger. Select the whole block and run the selection.
-- ==================================================================
CREATE TRIGGER trg_scores_after_delete
AFTER DELETE ON test_scores
FOR EACH ROW
BEGIN
    UPDATE students
    SET gpa = calculate_gpa(OLD.student_id)
    WHERE student_id = OLD.student_id;
END;

-- ==================================================================
-- FROM LAB 5E Step 9. The row the BEFORE trigger filled in. It becomes 503.
-- ==================================================================
INSERT INTO attendance (student_id, status) VALUES (4,'present');


-- ======================================================================
-- FROM LAB 5F. The three procedures.
-- Each procedure is one statement. Select the whole block and run it.
-- ======================================================================

-- ==================================================================
-- FROM LAB 5F Step 6. list_students, highest gpa first.
-- ==================================================================
CREATE PROCEDURE list_students()
BEGIN
    SELECT student_id, first_name, last_name, gpa
    FROM students
    ORDER BY gpa DESC;
END;

-- ==================================================================
-- FROM LAB 5F Step 4. student_report.
-- ==================================================================
CREATE PROCEDURE student_report(IN p_student_id INT)
BEGIN
    SELECT student_name, test_name, score
    FROM student_scores
    WHERE student_id = p_student_id;
END;

-- ==================================================================
-- FROM LAB 5F Step 7. scores_for_test.
-- ==================================================================
CREATE PROCEDURE scores_for_test(IN p_test_name VARCHAR(20))
BEGIN
    SELECT student_name, score
    FROM student_scores
    WHERE test_name = p_test_name
    ORDER BY score DESC;
END;


-- ======================================================================
-- CHECKS. Highest gpa first: 92.33, 85.00, 84.00, 82.50, 0.00.
-- ======================================================================

CALL list_students();


-- ######################################################################
-- YOUR LAB 5G WORK STARTS BELOW THIS LINE
--
-- LABELING AND COMMENTING IS REQUIRED. It is worth a full point.
--
-- You write Steps 4, 6, 8, 9 and 10 yourself. Steps 3 and 7 are
-- skeletons with one statement for you to write. Step 5 is mostly yours.
-- ######################################################################


-- =================================================================
-- STEP 3. Create add_score
--
-- Copy the skeleton from the handout and write the INSERT.
-- =================================================================

--create a procedure that 
-- adds one test score and keeps that student's gpa correct
CREATE PROCEDURE add_score(IN p_test_name VARCHAR(20),
IN p_student_id INT,
IN p_score FLOAT)
BEGIN
-- job one: store the new score
insert into test_score (test_name, student_id, score)
    values (p_test_name, p_student_id, p_score);
-- job two: recalculate that one student's gpa
UPDATE students
SET gpa = calculate_gpa(p_student_id)
WHERE student_id = p_student_id;
END

-- =================================================================
-- STEP 4. Use add_score, and watch the gpa change
-- =================================================================

--call the stored procedure add_score twice
CALL add_score('quiz4', 5, 88);
CALL add_score('quiz4', 1, 100);
CALL list_students();

-- =================================================================
-- STEP 5. Write record_attendance
--
-- Most of this one is yours. The handout walks you through it.
-- =================================================================

--write stored procedure record_attendance
CREATE PROCEDURE record_attendance(IN p_student_id INT,
IN p_status VARCHAR(10))
BEGIN
-- job one: store the new attendance record
INSERT INTO attendance (student_id, status)
    VALUES (p_student_id, p_status);
END

-- =================================================================
-- STEP 6. Test record_attendance
-- =================================================================

--call stored procedure record_attendance.
--record student 2 as "absent"
CALL record_attendance(2, 'absent');
SELECT * FROM attendance;


-- =================================================================
-- STEP 7. Create remove_score
--
-- Copy the skeleton and write the DELETE.
-- =================================================================

-- removes one named test score for one student
CREATE PROCEDURE remove_score(IN p_student_id INT,
IN p_test_name VARCHAR(20))
BEGIN
-- delete only the row that matches BOTH values
DELETE FROM test_scores
WHERE student_id = p_student_id
AND test_name = p_test_name;
SELECT CONCAT("The test name ", p_test_name, " for student_id",
 CAST(p_student_id AS CHAR),
 " has been deleted.") AS message;
END


-- =================================================================
-- STEP 8. Test remove_score
-- =================================================================

-- remove quiz4 for sytudent 1 by calling the remove_score
--the after delete trigger is already created and runs automatically
CALL remove_score(1, 'quiz4');
SELECT * FROM student
WHERE student_id =1;


-- =================================================================
-- STEP 9. Two problems, left open on purpose
--
-- Under each call, a comment on what happened and what should have.
-- =================================================================

--call procedures and documents results
CALL add_score("quiz5", 4, -20);
--inders scores is 48.33 and a score of less than zero should not be accepted

CALL remove_score(4, "quiz5");
CALL list_students;

CALL record_attendance(9, "present");
--this call failed because of foreign key constraint.
--student_id 9 does not exist. 
-- =================================================================
-- STEP 10. List every routine in your schema
-- =================================================================

--list every routine in schema
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'cis_students_db'
ORDER BY routine_name;

-- =================================================================
-- STEP 11 and 12. Push to GitHub and submit the URL
--
-- Nothing to write here. Follow the handout.
-- =================================================================
SELECT *
FROM test_scores;

/*insert into test_scores(student_id, test_name, score)
values (3, "quiz4", 89);*/

--drop procedure student_count;
create procedure student_count(in p_student_id int, out p_count int)
READS SQL DATA
BEGIN
    SELECT COUNT(*)
    INTO p_count
    FROM test_scores
    WHERE student_id = p_student_id;

    IF p_count = 0 THEN
        SELECT CONCAT('NO student with id ', p_student_id) AS Message;
     ELSEIF p_count > 3 THEN
         SELECT CONCAT('This student with id', p_student_id, ' has taken ' , p_count, 'tests !') AS Message;
     ELSE
         SELECT CONCAT('studnet ' , p_student_id, 'exists') AS Message;
    END IF;
END;

CALL student_count (2,@n);
SELECT @n AS student_count;

CALL student_count(3,@n);
SELECT @n AS student_count;