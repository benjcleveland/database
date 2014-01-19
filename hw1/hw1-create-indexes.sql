/*
 Ben Cleveland
 CSEP 544
 Homework 1
 Create IMDB table indexes
*/


/* Help speed up join in query 11 */
create unique index actor_idx on actor(id);

/* Help speed up join in query 6 */
create unique index movie_idx on movie(id);

/* Help speed up join in query 2*/
create unique index directors_idx on directors(id);

/* Help speed up join in query 4 */
create index md_idx on movie_directors(did);

/* Help speed up join in query 11 */
create index pid_idx on casts(pid);

/* Help speed up join in query 9 */
create index mid_idx on casts(mid);

/* Help speed up where clause in query 10 */
create index year_idx on movie(year);

/* Help speed up where clause in queries 7 and 8. */ 
create index gender_idx on actor(gender);

/* Help speed up join in query 2 */
create index gmid_idx on genre(mid);

/* Help speed up join in query 11 */
create index fl_name_idx on actor(fname, lname);
