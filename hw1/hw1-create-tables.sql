/*
  Ben Cleveland
  CSEP 544
  Homework 1
  Create IMDB tables
*/


/* create and import the actor table */
create table actor(id int primary key, fname text, lname text, gender char(1));
\copy actor from '/home/cleveb/imdb2010/actor-ascii.txt' with delimiter '|' csv quote E'\n';

/* create and import the movie table */
create table movie(id int primary key, name text, year int);
\copy movie from '/home/cleveb/imdb2010/movie-ascii.txt' with delimiter '|' csv quote E'\n';

/* create and import the directors table */
create table directors (id int primary key, fname text, lname text);
\copy directors from '/home/cleveb/imdb2010/directors-ascii.txt' with delimiter '|' csv quote E'\n';

/* create and import the casts table */
create table casts (pid int, mid int, foreign key(pid) references actor(id), foreign key(mid) references movie(id), role text);
\copy casts from '/home/cleveb/imdb2010/casts-ascii.txt' with delimiter '|' csv quote E'\n';

/* create and import the movie directors table */
create table movie_directors (did int, mid int, foreign key(did) references directors(id), foreign key(mid) references movie(id));
\copy movie_directors from '/home/cleveb/imdb2010/movie_directors-ascii.txt' with delimiter '|' csv quote E'\n';

/* create and import the genre table */
create table genre (mid int, genre text);
\copy genre from '/home/cleveb/imdb2010/genre-ascii.txt' with delimiter '|' csv quote E'\n';
