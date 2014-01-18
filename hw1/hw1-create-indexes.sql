/*
 Ben Cleveland
 CSEP 544
 Homework 1
 Create IMDB table indexes
*/


create unique index actor_idx on actor(id);

create unique index movie_idx on movie(id);

create unique index director_idx on director(id);

create index pid_idx on casts(pid);

create index mid_idx on casts(mid);

create index year_idx on movie(year);

