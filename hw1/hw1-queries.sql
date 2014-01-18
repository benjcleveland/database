/*
 Ben Cleveland
 CSEP 544
 Homework 1
 IMDB SQL Queries
*/

/* Q.1 */
select a.fname, a.lname from movie m, actor a, casts c where m.name = 'Officer 444' and c.mid = m.id and c.pid = a.id;

/* Q.2 */
select d.fname, d.lname, m.name, m.year from genre g, movie m, movie_directors md, directors d where g.genre = 'Film-Noir' and g.mid = m.id and m.id = md.mid and md.did = d.id and m.year % 4 = 0;

/* Q.3 */
select distinct a.fname, a.lname from actor a, movie m1, movie m2, casts c1, casts c2 where a.id = c1.pid and c1.mid = m1.id and m1.year < 1900 and a.id = c2.pid and c2.mid = m2.id and m2.year > 2000;

/* How can actors be in movies that are more than 100 years apart? One reason is archival footage of the actor could have been used 
in a film that was produced after the year 2000. An example of this is Queen Alexandra. */
select * from actor a, movie m1, movie m2, casts c1, casts c2 where a.id = c1.pid and c1.mid = m1.id and m1.year < 1900 and a.id = c2.pid and c2.mid = m2.id and m2.year > 2000 and a.id = 1679737;

/* Additionally it looks like some of the movie records were imported into the database incorrectly. For example Walter Cronkite was in 
"The Conquest of Mexico" and the database says that movie was created in 1519, when it was actually created in 1953 
(from http://www.imdb.com/title/tt0812976/?ref_=fn_al_tt_1). It appears like all movies with a year in the name in parenthesis were 
imported incorrectly.
*/
select from movie m where m.id = 1559520;

4 select z.fname, z.lname, z.totalmovies from (select d.fname, d.lname, count(*) as totalmovies from directors d, movie_directors md where d.id = md.did group by d.fname, d.lname) z 
where z.totalmovies > 500 order by z.totalmovies desc

5 ---- select z.fname, z.lname, z.name, z.roles from (select a.fname, a.lname, m.name, count(c.role) as roles from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2010 group by a.fname, a.lname, m.name) z where z.roles >= 5

6 (only 137 returned) select aa.fname, aa.lname, cc.role from (select z.id, z.mid from (select a.id, a.fname, a.lname, m.id as mid, count(c.role) as roles from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2010 group by a.id, a.fname, a.lname, m.id) z
where z.roles >= 5) w, actor aa, casts cc where w.id = aa.id and aa.id = cc.pid and cc.mid = w.mid;

7 select mm.year, count(mm.id) from movie mm where mm.id not in (select distinct m.id from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and a.gender = 'M') group by mm.year;
use this one -- select mm.year, count(mm.id) from movie mm where not exists (select * from actor a, casts c where a.id = c.pid and c.mid = mm.id and a.gender = 'M') group by mm.year


8 -select z.year, (((cast (z.c as float))/ x.c) * 100) 
from (select mm.year, count(mm.id) as c from movie mm where mm.id not in (select distinct m.id from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and a.gender = 'M') group by mm.year) z,
(select m.year, count(m.id) as c from movie m group by m.year) x
where z.year = x.year

use this one ----
select z.year, (((cast (z.c as float))/ x.c) * 100), x.c 
from (select mm.year, count(mm.id) as c from movie mm where not exists (select * from actor a, casts c where a.id = c.pid and c.mid = mm.id and a.gender = 'M') group by mm.year) z,
(select m.year, count(m.id) as c from movie m group by m.year) x
where z.year = x.year


9 - select w.name, w.c from (select max(z.c) as max_actors from (select m.id, m.name, count(distinct c.pid) as c from movie m, casts c where m.id = c.mid group by m.name, m.id) z) y, 
(select m.id, m.name, count(distinct c.pid) as c from movie m, casts c where m.id = c.mid group by m.name, m.id) w
where w.c = y.max_actors

or 

select w.name, w.c from (select max(z.c) as max_actors from (select m.id, count(distinct c.pid) as c from movie m, casts c where m.id = c.mid group by  m.id) z) y, 
(select m.id, m.name, count(distinct c.pid) as c from movie m, casts c where m.id = c.mid group by m.name, m.id) w
where w.c = y.max_actors
;

 

10 - select z.year as start, (z.year + 10) as end, z.c from (select max(w.c) as max_movies from (select y.year, count(m.name) as c from (select distinct m.year from movie m) y, movie m where m.year < y.year + 10 and m.year >= y.year group by y.year) w) y, (select y.year, count(m.name) as c from (select distinct m.year from movie m) y, movie m where m.year < y.year + 10 and m.year >= y.year group by y.year) z where z.c = y.max_movies;

11
select count(distinct a1.id) from actor a1, casts c1, casts c2, (select distinct a.id from actor a, casts c1, casts c2, actor kb where kb.fname = 'Kevin' and kb.lname = 'Bacon' and kb.id = c2.pid and c2.mid = c1.mid and c1.pid = a.id and kb.id != a.id) kb1 where kb1.id = c2.pid and c2.mid = c1.mid and c1.pid = a1.id and  not exists (select distinct a.id from actor a, casts c1, casts c2, actor kb where kb.fname = 'Kevin' and kb.lname = 'Bacon' and kb.id = c2.pid and c2.mid = c1.mid and c1.pid = a.id and a1.id = a.id);

