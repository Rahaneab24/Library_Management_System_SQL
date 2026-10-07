create database Library_mang;
use library_mang;

-- Create table "branch"
create table if not exists branch
(
	branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "employee"
create table if not exists employee
(
emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

-- Create table "Members"
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) primary KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employee(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

SELECT * FROM branch;
SELECT * FROM books;
SELECT * FROM employee;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


-- ### 2. CRUD Operations

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

Insert into books
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS104';
SELECT * FROM issued_status ;

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT issued_book_name FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT i.issued_member_id, m.member_name
FROM issued_status i
INNER JOIN members m
ON i.issued_member_id = m.member_id
GROUP BY issued_member_id
HAVING count(issued_book_name)>1;

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE VIEW book_cnt
AS
SELECT issued_book_name, count(issued_id) as book_issued_cnt
FROM issued_status
GROUP BY issued_book_name
ORDER BY book_issued_cnt DESC;

SELECT * FROM book_cnt;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

SELECT Book_title 
FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT category, sum(rental_price) as Total_Rental_income,count(*)
FROM books
GROUP BY category
ORDER BY Total_Rental_Income DESC;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT member_id, member_name, member_address, reg_date
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY
ORDER BY reg_date DESC;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT e1.*, e2.emp_name as manager,b.manager_id,  b.branch_id
FROM employee e1
LEFT JOIN branch b
ON b.branch_id = e1. branch_id
JOIN employee e2
ON b.manager_id = e2. emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Avg rental price

CREATE VIEW Rental_price
AS
SELECT book_title, rental_price
FROM books
WHERE rental_price > (
	select avg(rental_price)  as price
    from books)
ORDER BY rental_price DESC;

SELECT * FROM Rental_price;

-- Task 12. Create a Table of Books with Rental Price Above a Certain Threshold 7USD

CREATE VIEW Rental_price_Above_7
AS
SELECT book_title, rental_price
FROM books
WHERE rental_price > 7;

SELECT * FROM Rental_price_Above_7;

-- Task 13: Retrieve the List of Books Not Yet Returned

WIth book_return AS (
	SELECT i.issued_id, i.issued_book_name, r.return_id
	FROM issued_status i
	LEFT JOIN return_status r
	ON i.issued_id = r.issued_id
)
select issued_book_name
FROM book_return
WHERE return_id IS NULL;



