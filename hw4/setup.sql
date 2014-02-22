/*
 Ben Cleveland
 CSEP 544
 Homework 4
 Table setup
*/

/* create the plan table */
CREATE TABLE plans(id int primary key, name varchar(255) NOT NULL UNIQUE, max_rentals int NOT NULL, monthly_fee decimal(18,2) NOT NULL);

INSERT INTO plans VALUES (1, 'Basic', 1, 5);
INSERT INTO plans VALUES (2, 'Basic plus', 3, 10);
INSERT INTO plans VALUES (3, 'Normal', 5, 14.99);
INSERT INTO plans VALUES (4, 'Super Access', 8, 20);

/* create the customer table */
CREATE TABLE customer(id int primary key, login varchar(255) NOT NULL UNIQUE, password text NOT NULL, 
    firstname text, lastname text, plan_id int, foreign key (plan_id ) references plans(id));

INSERT INTO customer VALUES (1, 'ben', 'asdf', 'Ben', 'Cleveland', 1);
INSERT INTO customer VALUES (2, 'phil', 'asdf', 'Phil', 'Nissley', 2);
INSERT INTO customer VALUES (3, 'patti', 'asdf', 'Patti', 'Cleveland', 3);
INSERT INTO customer VALUES (4, 'megan', 'asdf', 'Megan', 'Newton', 4);
INSERT INTO customer VALUES (5, 'carl', 'asdf', 'Carl', 'Newton', 1);
INSERT INTO customer VALUES (6, 'cindy', 'asdf', 'Cindy', 'Cleveland', 2);
INSERT INTO customer VALUES (7, 'sophia', 'asdf', 'Sophia', 'Terada', 3);
INSERT INTO customer VALUES (8, 'derek', 'asdf', 'Derek', 'Terada', 4);

/* create move status 'enumeration' table */
CREATE TABLE movie_status(status varchar(10) primary key);

INSERT INTO movie_status VALUES('open');
INSERT INTO movie_status VALUES('closed');

/* create the rental table */
CREATE TABLE rentals(cust_id int, foreign key(cust_id) references customer(id), movie_id int NOT NULL, 
    status varchar(10) NOT NULL, foreign key(status) references movie_status(status), checkout_time datetime NOT NULL);

CREATE CLUSTERED INDEX rental_cust_idx on rentals (cust_id);

INSERT INTO rentals VALUES (1, 1, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 2, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 3, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 4, 'open',   current_timestamp);
INSERT INTO rentals VALUES (2, 1, 'open',   current_timestamp);
INSERT INTO rentals VALUES (3, 1, 'closed', current_timestamp);
INSERT INTO rentals VALUES (4, 2, 'closed', current_timestamp);
INSERT INTO rentals VALUES (5, 3, 'closed', current_timestamp);
