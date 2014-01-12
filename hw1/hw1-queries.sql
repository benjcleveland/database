1 select y.fname, y.lname from movie x, actor y, casts z where x.name = 'Officer 444' and z.mid = x.id and z.pid = y.id;

2 select d.fname, d.lname, g.genre, m.year from genre g, movie m, movie_directors md, directors d where g.genre = 'Film-Noir' and g.mid = m.id and m.id = md.mid and md.did = d.id and m.year % 4 = 0;

3 ----- (only 48 returned...)
select x.fname, x.lname
from (select a.fname, a.lname, a.id, m.year from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year < 1900) x,
 (select a.fname, a.lname, a.id, m.year from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year > 2000) y where
x.id = y.id;

select distinct z.fname, z.lname from actor z where z.id not in(select a.id from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year <= 2000 and m.year >= 1900)
----

4 select z.fname, z.lname, z.totalmovies from (select d.fname, d.lname, count(*) as totalmovies from directors d, movie_directors md where d.id = md.did group by d.fname, d.lname) z 
where z.totalmovies > 500 order by z.totalmovies desc

5 ---- select z.fname, z.lname, z.name, z.roles from (select a.fname, a.lname, m.name, count(c.role) as roles from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2010 group by a.fname, a.lname, m.name) z where z.roles >= 5

6 (only 137 returned) select aa.fname, aa.lname, cc.role from (select z.id, z.mid from (select a.id, a.fname, a.lname, m.id as mid, count(c.role) as roles from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2010 group by a.id, a.fname, a.lname, m.id) z
where z.roles >= 5) w, actor aa, casts cc where w.id = aa.id and aa.id = cc.pid and cc.mid = w.mid;

7 select mm.year, count(mm.id) from movie mm where mm.id not in (select m.id from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and a.gender = 'M' group by m.id) group by mm.year;
 
