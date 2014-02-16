/* create the plan table */
CREATE TABLE plans(id int primary key, name text, max_rentals int, monthly_fee int);

INSERT INTO plans VALUES (1, 'Basic', 1, 5);
INSERT INTO plans VALUES (2, 'Basic plus', 3, 10);
INSERT INTO plans VALUES (3, 'Normal', 5, 15);
INSERT INTO plans VALUES (4, 'Super Access', 8, 20);

/* create the customer table */
CREATE TABLE customer(id int primary key, login text, password text, firstname text, lastname text, plan_id int, foreign key (plan_id ) references plans(id));

INSERT INTO customer VALUES (1, 'ben', 'asdf', 'Ben', 'Cleveland', 1);
INSERT INTO customer VALUES (2, 'phil', 'asdf', 'Phil', 'Nissley', 2);
INSERT INTO customer VALUES (3, 'patti', 'asdf', 'Patti', 'Cleveland', 3);
INSERT INTO customer VALUES (4, 'megan', 'asdf', 'Megan', 'Newton', 4);
INSERT INTO customer VALUES (5, 'carl', 'asdf', 'Carl', 'Newton', 1);
INSERT INTO customer VALUES (6, 'cindy', 'asdf', 'Cindy', 'Cleveland', 2);
INSERT INTO customer VALUES (7, 'sophia', 'asdf', 'Sophia', 'Terada', 3);
INSERT INTO customer VALUES (8, 'derek', 'asdf', 'Derek', 'Terada', 4);

CREATE TABLE status(id int primary key, status text);

/* create the rental table */
/* TODO - should there be another table that has the available statuss? */
/* TODO - set constraints like not null, etc on things like movieid and status */
CREATE TABLE rentals(cust_id int, foreign key(cust_id) references customer(id), movie_id int, status text, checkout_time datetime);

CREATE CLUSTERED INDEX rental_cust_idx on rentals (cust_id);

INSERT INTO rentals VALUES (1, 1, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 2, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 3, 'closed', current_timestamp);
INSERT INTO rentals VALUES (1, 4, 'open',   current_timestamp);
INSERT INTO rentals VALUES (2, 1, 'open',   current_timestamp);
INSERT INTO rentals VALUES (3, 1, 'closed', current_timestamp);
INSERT INTO rentals VALUES (4, 2, 'closed', current_timestamp);
INSERT INTO rentals VALUES (5, 3, 'closed', current_timestamp);
