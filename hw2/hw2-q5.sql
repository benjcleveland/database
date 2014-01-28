/*
 Ben Cleveland
 CSEP 544
 Homework 2 Question 5
*/

/* create table */
/* create table sales(name text, discount char(3), month char(3), price int); */

/* import */
/* \copy sales from '/home/cleveb/frumble/hw2-data.txt' with delimiter E'\t' csv header; */


/* Functional Dependency: month->discount */
/* Query result:
 month | discount 
-------+----------
 apr   | 15%
 aug   | 15%
 dec   | 33%
 feb   | 10%
 jan   | 33%
 jul   | 33%
 jun   | 10%
 mar   | 15%
 may   | 10%
 nov   | 15%
 oct   | 10%
 sep   | 15%
(12 rows)
*/
select month, discount from sales group by month, discount order by month;

/* Functional Dependency: name->price */
/* Query Result:
 price |                             prod                             
-------+--------------------------------------------------------------
    19 | {(bar1),(gizmo3),(gizmo7),(mouse1),(bar8)}
    29 | {(gizmo4),(click7),(gizmo6),(bar4),(mouse3),(bar7),(mouse7)}
    39 | {(click3),(bar9),(click2),(click1),(click8)}
    49 | {(mouse2),(click9),(click4),(gizmo1)}
    59 | {(bar2),(bar3),(mouse8)}
    69 | {(mouse4),(mouse9)}
    79 | {(gizmo5),(gizmo9)}
    89 | {(mouse5),(click6),(gizmo8),(bar5)}
    99 | {(mouse6),(gizmo2),(click5),(bar6)}
(9 rows)
*/
select price, array_agg(row(name)) as prod from (select name, price from sales group by name, price) as row group by price order by price;


/* Other Functional Dependencies that I found that are not used in BCNF */
/* name, discount, month -> price fd */
/* select count(distinct(price)), name, discount, month from sales group by name, discount, month order by name; */

/* Functional dependency: name, month -> price */
/* Query Result: No rows means each name, month goes
to one price.

 name | month | count 
------+-------+-------
(0 rows)
*/
select name, month, count(price) from sales group by name, month having count(price) > 1;


/* Functional dependency: name, month -> discount */
/* Query Result: No rows means each name, month goes
to one discount.

 name | month | count 
------+-------+-------
(0 rows)
*/
/* name, month -> discount */
select name, month, count(discount) from sales group by name, month having count(discount) > 1;

/* Functional dependency: month price -> discount */
/* Query Result: No rows means each month, price goes
to one discount.

 month | price | count 
-------+-------+-------
(0 rows)
*/
select month, price, count(distinct discount) from sales group by month, price having count(distinct discount) > 1;

/* Functional dependency: name discount - > price */
/* Query Result: No rows means each name, discount goes
to one price.

 month | price | count 
-------+-------+-------
(0 rows)
*/
select discount, name, count(distinct (price)) from sales group by discount, name having count(distinct(price)) > 1;


/* Decomposed schema generated using functional dependencies name->price and month->discount: 

    Name, Price
    Month, Discount
    Month, Name
*/
/* create the BCNF tables for the database */
/* month, discount table */
create table monthDiscount(month char(3) primary key, discount char(3));

/* name price table */
create table product(name text primary key, price int);

/* month name table */
create table product_months(month char(3), name text, primary key(name, month),
    foreign key(name) references product(name),
    foreign key(month) references monthDiscount(month));

/* load the tables with the data */
insert into product(name, price) select distinct name, price from sales;

insert into monthDiscount(month, discount) select distinct month, discount from sales;

insert into product_months(name, month) select distinct name, month from sales;

/* print out the data from the tables */
select * from monthDiscount;
/*
 month | discount 
-------+----------
 apr   | 15%
 may   | 10%
 feb   | 10%
 jan   | 33%
 jun   | 10%
 mar   | 15%
 dec   | 33%
 oct   | 10%
 jul   | 33%
 nov   | 15%
 aug   | 15%
 sep   | 15%
(12 rows)
*/

select * from product;
/*
  name  | price 
--------+-------
 mouse1 |    19
 bar9   |    39
 click4 |    49
 bar6   |    99
 gizmo5 |    79
 gizmo8 |    89
 click6 |    89
 mouse6 |    99
 gizmo3 |    19
 gizmo7 |    19
 gizmo1 |    49
 mouse9 |    69
 bar8   |    19
 bar3   |    59
 gizmo9 |    79
 click2 |    39
 bar2   |    59
 mouse5 |    89
 click9 |    49
 bar4   |    29
 gizmo6 |    29
 click5 |    99
 mouse8 |    59
 click1 |    39
 bar5   |    89
 click8 |    39
 mouse2 |    49
 click7 |    29
 gizmo4 |    29
 gizmo2 |    99
 mouse7 |    29
 bar7   |    29
 mouse3 |    29
 bar1   |    19
 mouse4 |    69
 click3 |    39
(36 rows)
*/

select * from product_months;
/*
 month |  name  
-------+--------
 dec   | mouse5
 dec   | gizmo3
 sep   | mouse2
 apr   | gizmo8
 sep   | click5
 feb   | mouse1
 mar   | mouse6
 jan   | gizmo7
 dec   | click3
 oct   | mouse8
 jul   | mouse6
 jun   | click4
 oct   | gizmo9
 jul   | mouse9
 jan   | gizmo8
 aug   | click8
 may   | mouse7
 dec   | bar6
 nov   | mouse7
 feb   | bar8
 sep   | bar4
 mar   | mouse9
 dec   | click6
 apr   | gizmo7
 feb   | gizmo6
 oct   | gizmo4
 oct   | gizmo3
 apr   | mouse7
 oct   | mouse5
 sep   | click2
 sep   | bar3
 oct   | click3
 dec   | mouse8
 may   | gizmo7
 dec   | gizmo9
 nov   | gizmo7
 aug   | bar1
 feb   | mouse4
 oct   | bar6
 jan   | mouse7
 aug   | click9
 may   | gizmo8
 jul   | gizmo1
 nov   | gizmo8
 sep   | mouse3
 sep   | bar7
 oct   | click6
 feb   | bar9
 mar   | gizmo1
 dec   | gizmo4
 jun   | gizmo2
 apr   | bar8
 aug   | gizmo3
 jul   | bar4
 aug   | mouse5
 feb   | gizmo7
 apr   | gizmo6
 mar   | bar4
 aug   | click3
 jun   | bar2
 sep   | mouse9
 feb   | gizmo8
 mar   | mouse2
 mar   | click5
 apr   | mouse1
 oct   | click9
 sep   | mouse6
 oct   | bar1
 may   | mouse4
 jun   | click7
 nov   | mouse4
 aug   | bar6
 jan   | bar8
 dec   | click8
 dec   | click1
 may   | bar9
 nov   | bar9
 jul   | mouse2
 jun   | bar5
 jul   | click5
 jan   | gizmo6
 aug   | click6
 jun   | gizmo5
 may   | mouse1
 nov   | mouse1
 jul   | bar7
 apr   | mouse4
 jul   | mouse3
 apr   | bar9
 sep   | gizmo1
 aug   | gizmo9
 mar   | mouse3
 aug   | mouse8
 mar   | bar7
 may   | bar8
 nov   | bar8
 dec   | click9
 mar   | bar3
 jan   | mouse4
 mar   | click2
 feb   | mouse7
 dec   | bar1
 oct   | click1
 oct   | click8
 aug   | gizmo4
 jul   | bar3
 jul   | click2
 may   | gizmo6
 nov   | gizmo6
 jan   | bar9
 aug   | mouse2
 aug   | click5
 mar   | bar6
 jul   | click6
 oct   | gizmo1
 nov   | click4
 may   | click4
 dec   | mouse9
 mar   | click6
 jul   | bar6
 dec   | mouse6
 sep   | click1
 sep   | click8
 jun   | mouse7
 mar   | mouse5
 mar   | gizmo3
 jul   | mouse5
 jul   | gizmo3
 aug   | bar4
 mar   | click3
 aug   | click2
 feb   | gizmo2
 jul   | gizmo4
 aug   | bar3
 mar   | gizmo4
 jun   | gizmo7
 dec   | gizmo1
 sep   | gizmo2
 nov   | gizmo3
 may   | mouse5
 may   | gizmo3
 jan   | click4
 feb   | bar2
 oct   | mouse9
 nov   | mouse5
 apr   | gizmo9
 sep   | bar5
 aug   | bar9
 sep   | click9
 mar   | click4
 oct   | mouse6
 jul   | gizmo9
 jun   | gizmo8
 apr   | mouse8
 jan   | gizmo4
 sep   | gizmo5
 sep   | bar1
 jul   | mouse8
 may   | click6
 feb   | click7
 nov   | click6
 feb   | click9
 mar   | gizmo9
 jun   | mouse6
 apr   | click4
 feb   | bar5
 jul   | click4
 oct   | gizmo8
 aug   | mouse3
 mar   | mouse8
 feb   | gizmo5
 sep   | click7
 dec   | mouse7
 may   | bar6
 feb   | bar1
 aug   | bar7
 aug   | mouse4
 nov   | bar6
 mar   | click8
 mar   | click1
 sep   | gizmo3
 feb   | click3
 sep   | mouse5
 oct   | click2
 may   | gizmo2
 aug   | gizmo7
 oct   | bar3
 nov   | gizmo2
 dec   | mouse2
 dec   | click5
 apr   | click8
 apr   | click1
 jul   | click8
 nov   | bar2
 feb   | mouse5
 feb   | gizmo3
 jul   | click1
 sep   | click3
 may   | bar2
 aug   | mouse9
 dec   | mouse1
 jun   | bar3
 jun   | click2
 nov   | click7
 jun   | bar7
 jun   | mouse4
 feb   | click6
 may   | click7
 sep   | bar6
 jun   | mouse3
 dec   | gizmo6
 oct   | bar9
 aug   | mouse6
 nov   | bar1
 feb   | bar6
 may   | bar1
 oct   | bar7
 oct   | mouse4
 sep   | click6
 oct   | mouse3
 dec   | bar4
 may   | gizmo5
 nov   | gizmo5
 dec   | bar8
 jan   | click8
 jan   | click1
 aug   | gizmo8
 jun   | bar9
 may   | click9
 nov   | bar5
 nov   | click9
 may   | bar5
 feb   | mouse8
 mar   | gizmo5
 jul   | click7
 jan   | gizmo2
 mar   | bar1
 apr   | click7
 jun   | mouse1
 sep   | click4
 mar   | click9
 dec   | bar3
 feb   | gizmo9
 dec   | click2
 mar   | bar5
 oct   | mouse2
 oct   | click5
 apr   | gizmo5
 jul   | bar1
 sep   | mouse8
 jul   | gizmo5
 apr   | bar1
 mar   | click7
 aug   | gizmo1
 oct   | mouse1
 feb   | click4
 jan   | bar2
 sep   | gizmo9
 apr   | bar5
 jul   | click9
 jun   | mouse2
 jul   | bar5
 jun   | click5
 mar   | bar2
 jun   | bar4
 jun   | bar8
 jul   | gizmo2
 feb   | gizmo4
 dec   | bar9
 apr   | gizmo2
 oct   | gizmo6
 jan   | click7
 dec   | bar7
 jan   | click9
 dec   | mouse4
 aug   | mouse7
 apr   | bar2
 jan   | bar5
 may   | click8
 nov   | click1
 oct   | bar4
 dec   | mouse3
 may   | click1
 nov   | click8
 jul   | bar2
 sep   | gizmo4
 jan   | gizmo5
 oct   | bar8
 jun   | gizmo6
 mar   | gizmo2
 jan   | bar1
 jun   | mouse8
 oct   | click4
 nov   | gizmo1
 jan   | mouse9
 jun   | gizmo9
 jul   | gizmo8
 may   | gizmo1
 mar   | gizmo8
 feb   | mouse2
 feb   | click5
 apr   | mouse6
 sep   | mouse1
 apr   | mouse9
 mar   | gizmo7
 sep   | gizmo6
 jun   | gizmo4
 jan   | mouse6
 jul   | gizmo7
 sep   | bar8
 jun   | click3
 aug   | bar2
 may   | mouse9
 jan   | gizmo1
 nov   | mouse9
 jul   | mouse7
 dec   | click4
 mar   | mouse7
 jun   | mouse5
 jun   | gizmo3
 feb   | bar3
 feb   | click2
 aug   | gizmo2
 feb   | mouse3
 aug   | gizmo5
 feb   | bar7
 jun   | click6
 aug   | bar5
 sep   | bar9
 apr   | gizmo1
 aug   | click7
 jun   | bar6
 sep   | mouse4
 may   | mouse6
 nov   | mouse6
 jul   | bar8
 mar   | gizmo6
 sep   | gizmo7
 apr   | bar4
 oct   | bar2
 feb   | mouse9
 nov   | click2
 may   | bar3
 may   | click2
 nov   | bar3
 oct   | gizmo2
 mar   | bar8
 jul   | gizmo6
 jan   | mouse2
 jan   | click5
 jul   | mouse1
 jan   | bar4
 oct   | bar5
 may   | bar7
 nov   | bar7
 nov   | mouse3
 may   | mouse3
 oct   | gizmo5
 apr   | mouse2
 sep   | gizmo8
 apr   | click5
 mar   | mouse1
 jun   | click9
 feb   | mouse6
 oct   | click7
 jun   | bar1
 mar   | bar9
 aug   | click4
 feb   | gizmo1
 jul   | mouse4
 apr   | mouse3
 apr   | bar7
 dec   | bar2
 dec   | gizmo2
 jul   | bar9
 nov   | mouse2
 nov   | click5
 may   | mouse2
 may   | click5
 jan   | bar3
 mar   | mouse4
 jan   | click2
 jan   | mouse3
 jan   | bar7
 dec   | bar5
 may   | bar4
 nov   | bar4
 apr   | bar3
 apr   | click2
 sep   | mouse7
 dec   | click7
 jun   | click8
 jun   | click1
 dec   | gizmo7
 jan   | click3
 may   | gizmo9
 jun   | gizmo1
 nov   | gizmo9
 apr   | click6
 may   | mouse8
 nov   | mouse8
 jan   | mouse5
 aug   | mouse1
 jan   | gizmo3
 apr   | bar6
 jan   | click6
 aug   | gizmo6
 nov   | gizmo4
 may   | gizmo4
 apr   | click3
 jan   | bar6
 dec   | gizmo8
 aug   | bar8
 feb   | click8
 feb   | click1
 apr   | mouse5
 apr   | gizmo3
 oct   | mouse7
 jan   | mouse8
 apr   | gizmo4
 oct   | gizmo7
 may   | click3
 sep   | bar2
 jun   | mouse9
 jan   | gizmo9
 nov   | click3
 (426 rows)
 */
