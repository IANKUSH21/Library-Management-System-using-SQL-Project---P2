CREATE DATABASE Library_project_02;
USE Library_project_02;

-- CREATING BRANCH 
CREATE TABLE Branch_table(
branch_id VARCHAR (8) PRIMARY KEY,
manager_id VARCHAR (8),
branch_address VARCHAR (25),
contact_no  VARCHAR (25) );



 -- EMPLOYEES TABLE CREATION 
 DROP TABLE IF EXISTS Employees;
 CREATE TABLE Employees(
 emp_id VARCHAR (10) PRIMARY KEY,
 emp_name VARCHAR (20),
 position VARCHAR (15),
 salary INT,
 branch_id VARCHAR (20));
 
 -- CREATION OF BOOK TABLE 
 CREATE TABLE Books(
 isbn VARCHAR (20) PRIMARY KEY,
 book_title VARCHAR (80),
 category VARCHAR (15),
 rental_price FLOAT,
 status	VARCHAR (20),
 author VARCHAR (35),
 publisher VARCHAR (50));
 
 -- CREATION OF MEMBER TABLE
 CREATE TABLE Members(
 member_id VARCHAR (15) PRIMARY KEY,
 member_name VARCHAR (25),
 member_address VARCHAR (30),
 reg_date DATE);
 
 -- CREATION OF ISSUED STATUS TABLE 
 CREATE TABLE Issued_status(
 issued_id VARCHAR(15) PRIMARY KEY,
 issued_member_id VARCHAR (10),
 issued_book_name VARCHAR (100),
 issued_date DATE ,
 issued_book_isbn VARCHAR (50),
 issued_emp_id VARCHAR (10));


-- CREATION OF RETURN STATUS TABLE 
CREATE TABLE Return_status(
return_id VARCHAR (15) PRIMARY KEY,
issued_id  VARCHAR (15),
return_book_name VARCHAR (50),
return_date	DATE,
return_book_isbn VARCHAR (20));

-- FOREIGN KEY 
ALTER TABLE Issued_status 
ADD CONSTRAINT FOREIGN KEY (issued_member_id)	REFERENCES Members(member_id);

-- CORRECTION DUE TO INSUFFICIENT DATA UPLOAD

SELECT DISTINCT issued_book_isbn
FROM issued_status
WHERE issued_book_isbn NOT IN (
    SELECT isbn FROM books
);

INSERT INTO books (isbn)
SELECT DISTINCT issued_book_isbn
FROM issued_status
WHERE issued_book_isbn NOT IN (
    SELECT isbn FROM books
);
-- FOREIGN KEY ALTERATION AFTER CORRECTION 
ALTER TABLE Issued_status 
ADD CONSTRAINT FOREIGN KEY (issued_book_isbn)	REFERENCES Books(isbn);
 
ALTER TABLE Issued_status 
ADD CONSTRAINT FOREIGN KEY(issued_emp_id)	REFERENCES Employees(emp_id);

ALTER TABLE Employees
ADD CONSTRAINT FOREIGN KEY(branch_id)	REFERENCES 	Branch_table(branch_id);

-- CORRECTION DUE TO INSUFFICIENT DATA UPLOAD 

SELECT DISTINCT issued_id
FROM return_status
WHERE issued_id NOT IN (
    SELECT issued_id FROM issued_status
);

INSERT INTO issued_status (issued_id)
SELECT DISTINCT issued_id
FROM return_status
WHERE issued_id NOT IN (
    SELECT issued_id FROM issued_status
);
-- FOREIGN KEY ALTERATION AFTER CORRECTION 
ALTER TABLE  return_status
ADD CONSTRAINT FOREIGN KEY(issued_id)	REFERENCES 	Issued_status(issued_id);

SELECT * FROM BOOKS;
SELECT * FROM BRANCH_TABLES;
SELECT * FROM EMPLOYEES;
SELECT * FROM ISSUED_STATUS;
SELECT * FROM MEMBERS;
SELECT * FROM RETURN_STATUS;

-- PROJECT TASK
-- ### 2. CRUD Operations
-- Create: Inserted sample records into the books table.
-- Read: Retrieved and displayed data from various tables.
-- Update: Updated records in the employees table.
-- Delete: Removed records from the members table as needed.
---------------------------------------------------------------

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books
(isbn,book_title,category,rental_price,status,author,publisher)
values 
("978-1-60129-456-2","To Kill a Mockingbird","Classic","6.00","yes","Harper Lee","J.B. Lippincott & Co.");

-- Task 2: Update an Existing Member's Address

UPDATE MEMBERS
SET member_address = "123 OAK ST"
WHERE member_id = "C103";

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

DELETE FROM issued_status
 WHERE issued_id = "IS104";
 
 -- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status WHERE issued_emp_id = "E101";

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
count(*) FROM issued_status
GROUP BY 1
HAVING COUNT(*)> 1;

- ### 3. CTAS (Create Table As Select

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT * FROM BOOKS 
WHERE CATEGORY= "CLASSIC";

-- Task 8: Find Total Rental Income by Category:

SELECT category,
SUM(rental_price),COUNT(*)
 FROM books
GROUP BY category;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT * FROM members
WHERE reg_date >= current_date-interval 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT manager_id,emp_name,branch_address,contact_no,emp_id,position,salary
 FROM employees,branch_table
group by manager_id,emp_name,branch_address,contact_no,emp_id,position,salary;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE Expensive_books
AS SELECT * FROM BOOKS
WHERE rental_price >= 7;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
