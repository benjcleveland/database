/*
 Ben Cleveland
 CSEP 544
 Homework 2
 Question 2a.
*/


/* create the vehicle table */
create table vehicle(licencePlate text primary key, maxLiability int, maxLossDamage int,
    year int, ssn int, name text, foreign key(ssn) references person(ssn), 
    foreign key(name) references insuranceco(name));

/* create the truck table */
create table truck(licencePlate text primary key, capacity int);

/* create the car table */
create table car(licencePlate text primary key, make text);

/* create the InsuranceCo table */
create table insuranceco(name text primary key, phone int);

/* create the person table */
create table person(ssn int primary key, name text);

