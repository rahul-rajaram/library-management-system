CREATE DATABASE LibraryDB;

USE LibraryDB;

//************CREATE TABLE*************//
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    membership_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INT,
    category_id INT,
    ISBN VARCHAR(20) UNIQUE,
    publisher VARCHAR(100),
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,

    FOREIGN KEY (author_id)
        REFERENCES Authors(author_id),

    FOREIGN KEY (category_id)
        REFERENCES Categories(category_id),

    CHECK (total_copies >= 0),
    CHECK (available_copies >= 0),
    CHECK (available_copies <= total_copies)
);

CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status VARCHAR(20) DEFAULT 'Issued',

    FOREIGN KEY (user_id)
        REFERENCES Users(user_id),

    FOREIGN KEY (book_id)
        REFERENCES Books(book_id),

    CHECK (due_date >= issue_date),
    CHECK (status IN ('Issued', 'Returned'))
);


CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'Unpaid',

    FOREIGN KEY (transaction_id)
        REFERENCES Transactions(transaction_id),

    CHECK (fine_amount >= 0)
);

//****************INSERT QUERIES***************//
INSERT INTO Authors (author_name)
VALUES
('Paulo Coelho'),
('J.K. Rowling'),
('F. Scott Fitzgerald');

INSERT INTO Categories (category_name)
VALUES
('Fiction'),
('Fantasy'),
('Classic Literature');

INSERT INTO Users
(name, email, phone, address, membership_date)
VALUES
('Arun Kumar', 'arun@gmail.com',
 '9876543210', 'Chennai', CURDATE()),

('Priya', 'priya@gmail.com',
 '9876543211', 'Madurai', CURDATE()),

('Rahul', 'rahul@gmail.com',
 '9876543212', 'Coimbatore', CURDATE());

INSERT INTO Books
(title, author_id, category_id, ISBN,
 publisher, total_copies, available_copies)
VALUES
('The Alchemist', 1, 1, '9780062315007',
 'HarperOne', 5, 5),

('Harry Potter and the Philosopher''s Stone', 2, 2, '9780747532699',
 'Bloomsbury', 3, 3),

('The Great Gatsby', 3, 3, '9780743273565',
 'Scribner', 4, 4);
 
//***********ISSUE BOOK**************// 
SELECT * FROM Books
WHERE book_id = 1
AND available_copies > 0;

UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 1
AND available_copies > 0;

INSERT INTO Transactions
(user_id, book_id, issue_date, due_date, status)
SELECT 1, 1, CURDATE(),
       DATE_ADD(CURDATE(), INTERVAL 14 DAY),
       'Issued'
WHERE ROW_COUNT() > 0;

//*********RETURN BOOK****************//
UPDATE Transactions
SET return_date = CURDATE(),
    status = 'Returned'
WHERE transaction_id = 1
AND status = 'Issued';

UPDATE Books
SET available_copies = available_copies + 1
WHERE book_id = (
    SELECT book_id
    FROM Transactions
    WHERE transaction_id = 1
);

//*********TRACKING BOOKS****************//

-- DISPLAY ALL BOOKS
SELECT
    B.book_id,
    B.title,
    A.author_name,
    C.category_name,
    B.total_copies,
    B.available_copies
FROM Books B
JOIN Authors A
    ON B.author_id = A.author_id
JOIN Categories C
    ON B.category_id = C.category_id;

-- DISPLAY AVAILABLE BOOKS
SELECT book_id, title, available_copies
FROM Books
WHERE available_copies > 0;

-- DISPLAY ISSUED BOOKS
SELECT
    T.transaction_id,
    U.name AS user_name,
    B.title AS book_title,
    T.issue_date,
    T.due_date,
    T.status
FROM Transactions T
JOIN Users U
    ON T.user_id = U.user_id
JOIN Books B
    ON T.book_id = B.book_id
WHERE T.status = 'Issued';

-- DISPLAY RETURNED BOOKS
SELECT
    T.transaction_id,
    U.name,
    B.title,
    T.issue_date,
    T.return_date
FROM Transactions T
JOIN Users U
    ON T.user_id = U.user_id
JOIN Books B
    ON T.book_id = B.book_id
WHERE T.status = 'Returned';	

--FIND OVERDUE BOOKS
SELECT
    U.name,
    B.title,
    T.due_date,
    DATEDIFF(CURDATE(), T.due_date)
        AS overdue_days
FROM Transactions T
JOIN Users U
    ON T.user_id = U.user_id
JOIN Books B
    ON T.book_id = B.book_id
WHERE T.status = 'Issued'
AND T.due_date < CURDATE();

--DISPLAY USER TRANSACTION HISTORY
SELECT
    U.name,
    B.title,
    T.issue_date,
    T.due_date,
    T.return_date,
    T.status
FROM Transactions T
JOIN Users U
    ON T.user_id = U.user_id
JOIN Books B
    ON T.book_id = B.book_id
WHERE U.user_id = 1;