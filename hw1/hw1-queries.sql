1 select y.fname, y.lname from movie x, actor y, casts z where x.name = 'Officer 444' and z.mid = x.id and z.pid = y.id;

2 select d.fname, d.lname, g.genre, m.year from genre g, movie m, movie_directors md, directors d where g.genre = 'Film-Noir' and g.mid = m.id and m.id = md.mid and md.did = d.id and m.year % 4 = 0;

3 -----
select x.fname, x.lname
from (select a.fname, a.lname, a.id, m.year from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year < 1900) x,
 (select a.fname, a.lname, a.id, m.year from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year > 2000) y where
x.id = y.id;

select distinct z.fname, z.lname from actor z where z.id not in(select a.id from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year <= 2000 and m.year >= 1900)
----

4 select z.fname, z.lname, z.totalmovies from (select d.fname, d.lname, count(*) as totalmovies from directors d, movie_directors md where d.id = md.did group by d.fname, d.lname) z 
where z.totalmovies > 500 order by z.totalmovies desc

5 ---- 
select z.fname, z.lname, z.name, z.roles from (select a.fname, a.lname, m.name, count(c.role) as roles from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2000 group by a.fname, a.lname, m.name) z
where z.roles >= 5

select z.fname, z.lname, z.name, z.totalroles
from (select t.fname, t.lname, t.name, count(t.role) as totalroles from (select distinct a.fname, a.lname, m.name, c.role from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2000) t group by t.fname, t.lname, t.name) z
where z.totalroles >= 5


*****select z.fname, z.lname, z.name, z.totalroles
from (select a.id, a.fname, a.lname, m.name, count(c.role) as totalroles from actor a, (select distinct * from casts) c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2000 group by a.id, a.fname, a.lname, m.name ) z
where z.totalroles >= 5

select z.fname, z.lname, z.name, z.totalroles
from (select t.fname, t.lname, t.id, t.mid, t.name, count(t.role) as totalroles 
from (select distinct a.id, m.id as mid, a.fname, a.lname, m.name, c.role from actor a, casts c, movie m where a.id = c.pid and c.mid = m.id and m.year = 2000) t
group by t.fname, t.lname, t.id, t.mid, t.name) z
where z.totalroles >= 5

----
