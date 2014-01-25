
/* create table */
create table sales(name text, discount char(3), month char(3), price int);

/* import */
\copy sales from '/home/cleveb/frumble/hw2-data.txt' with delimiter E'\t' csv header;


/* month->discount fd */
select distinct(month, discount) from sales;


/* name->discount - no fd */

/* name->price fd */
/* todo make the return smaller... */
select distinct(name, price) from sales;


/* name, discount, month -> price fd */
select  count(distinct(price)), name, discount, month from sales group by name, discount, month order by name;

/* name, month -> price fd */
select name, month, count(distinct (price)) from sales group by name, month order by name;

/* name, month -> discount */
select name, month, count(distinct (discount)) from sales group by name, month order by name;

/* month price -> discount */
select month, price, count(distinct (discount)) from sales group by month, price order by month;

/* name discount - > price */
select discount, name, count(distinct (price)) from sales group by discount, name order by name;



/* create the BCNF tables for the database */
create table monthDiscount(month char(3) primary key, discount char(3));

create table product(name text primary key, price int);

create table product_months(month char(3), name text, primary key(name, month),
    foreign key(name) references product(name),
    foreign key(month) references monthDiscount(month));


insert into product(name, price) select distinct name, price from sales;

insert into monthDiscount(month, discount) select distinct month, discount from sales;

insert into product_months(name, month) select distinct name, month from sales;

select * from product;
select * from monthDiscount;
select * from product_months;
