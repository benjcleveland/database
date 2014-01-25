/*
 Ben Cleveland
 CSEP 544
 Homework 2
 Question 2a.
*/


/* create the vehicle table */
create table vehicle(licencePlate text primary key, maxLiability int, maxLossDamage int,
    year int, ssn int, name text, foreign key(ssn) references person(ssn), 
    foreign key(name) references insuranceCo(name));

/* create the truck table */
create table truck(licencePlate text primary key, capacity int, ssn int, licenceNo text,
    foreign key(ssn, licenceNo) references professionalDriver(ssn, licenceNo));

/* create the car table */
create table car(licencePlate text primary key, make text);

/* create the InsuranceCo table */
create table insuranceCo(name text primary key, phone int);

/* create the person table */
create table person(ssn int primary key, name text);

/* create the driver table */
create table driver(ssn int, licenceNo text, primary key(ssn, licenceNo));

/* create the non-Pro driver table */
create table nonProfessionalDriver(ssn int, licenceNo text, primary key(ssn, licenceNo));

/* create the driver table */
create table drives(ssn int. licenceNo text, licencePlate text, 
    foreign key(ssn, licenceNo) references nonProfestionalDriver(ssn, licenceNo),
    foreign key(licencePlate) references car(licencePlate));

/* create the professional driver table */
create table professionalDriver(ssn int, licenceNo text, medialHistory text, 
    primary key(ssn, licenceNo));
