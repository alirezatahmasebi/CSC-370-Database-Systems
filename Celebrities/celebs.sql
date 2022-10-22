CREATE TABLE Albums (
  title VARCHAR(100)
);
CREATE TABLE Celebs(
  name VARCHAR(30)
);
CREATE TABLE Enemies (
  celeb1 VARCHAR(30),
  celeb2 VARCHAR(30)
);
CREATE TABLE MovieTitles(
  title VARCHAR(100)
);
CREATE TABLE Relationships (
  celeb1 VARCHAR(30),
  celeb2 VARCHAR(30),
  started VARCHAR(15),
  ended VARCHAR(15)
);
CREATE TABLE Releases (
  celeb VARCHAR(30),
  album VARCHAR(100)
);
CREATE TABLE StarredIn (
  celeb VARCHAR(30),
  movie VARCHAR(100)
);

INSERT INTO Albums SELECT * FROM bob.Albums;
INSERT INTO Celebs SELECT * FROM bob.Celebs;
INSERT INTO Enemies SELECT * FROM bob.Enemies;
INSERT INTO MovieTitles SELECT * FROM bob.MovieTitles;
INSERT INTO Relationships SELECT * FROM bob.Relationships;
INSERT INTO Releases SELECT * FROM bob.Releases;
INSERT INTO StarredIn SELECT * FROM bob.StarredIn;

/*Familiarize yourself with the tables*/
select * from starredin;
select * from relationships;
select * from enemies;
select * from releases;

-- 1. Find the movies where both Tom Cruise and Pen… C…
-- have starred together.

-- ...
-- INTERSECT
-- ...
-- ... LIKE 'Pen% C%';

select X.movie
from starredin X, starredin Y
where X.celeb = 'Tom Cruise' and Y.celeb like 'Pen% C%' and X.movie = Y.movie;


-- 2. Find all co-stars of Nicolas Cage.

select distinct Y.celeb
from StarredIn X, StarredIn Y
where X.celeb='Nicolas Cage' AND Y.celeb <> 'Nicolas Cage' AND X.movie=Y.movie;

--Join StarredIn with itself using the movie attribute. Use aliases.


-- 3. Find the movies where Tom Cruise co-starred with a celeb
-- he is (or has been) in relationship with.
-- The result should be (costar, movie) pairs.
select distinct Y.celeb, X.movie
from StarredIn X, StarredIn Y, Relationships R
where X.celeb='Tom Cruise' AND X.movie=Y.movie AND R.celeb1=X.celeb AND R.celeb2=Y.celeb;


-- Join StarredIn with itself using the movie attribute,
-- then join with the Relationship table.


-- 4. Find the movies where a celeb co-starred with another celeb
-- he/she is (or has been) in relationship with.
-- The result should be (celeb1 celeb2 movie) triples.
select distinct X.celeb as celeb1, Y.celeb as celeb2, X.movie
from StarredIn X, StarredIn Y, Relationships R
where X.movie=Y.movie AND R.celeb1=X.celeb AND R.celeb2=Y.celeb;


-- 5. Find how many movies each celeb has starred in.
-- Order the results by the number of movies (in descending order).
-- Show only the celebs who have starred in at least 10 movies.

select celeb, count(movie) as moviecnt
from StarredIn
group by celeb
having count(movie)>=10
order by moviecnt desc;


-- 6. Find the celebs that have been in relationship with the same celeb.
-- The result should be (celeb1, celeb2, celeb3) triples,
-- meaning that celeb1 and celeb2 have been in relationship with celeb3.
select celeb1, celeb2, celeb3
from
(select distinct X.name as celeb1, Y.name as celeb2
from Celebs X, Celebs Y, Relationships R
where R.celeb1=X.name AND R.celeb2=Y.name) couple1
join
(select distinct X.name as celeb1, Z.name as celeb3
from Celebs X, Celebs Z, Relationships R
where R.celeb1=X.name AND R.celeb2=Z.name) couple2 using(celeb1) where celeb2 <> celeb3;

-- 7. For each pair of enemies give the number of movies each has starred in.
-- The result should be a set of (celeb1 celeb2 n1 n2) quadruples,
-- where n1 and n2 are the number of movies that celeb1 and celeb2 have starred in, respectively.
-- Observe that there might be celebs with zero movies they have starred in.
-- Hint. Create first a virtual view: “celebMovieCounts”,
-- which gives for each celeb the number of movies he/she has starred in.
-- Then, join this view with itself and the Enemies table.

create view celebMovieCount AS
SELECT X.name, COUNT(Y.movie) AS moviecount
FROM Celebs X LEFT JOIN StarredIn Y ON X.name=Y.celeb
GROUP BY X.name;

select E.celeb1, E.celeb2, X.moviecount, Y.moviecount
from Enemies E, celebMovieCount X, celebMovieCount Y
where E.celeb1=X.name AND E.celeb2=Y.name;



-- 8. Find how many albums each celeb has released.
-- Order the results by the number of albums (in descending order).
-- Show only the celebs who have released at least two albums.
select celeb, count(album) as albumcount
from releases
group by celeb
having count(album)>=2
order by albumcount desc;

-- 9. Find those celebs that have starred in some movie and have released some album.
select celeb
from
    (select celeb
    from starredin
    group by celeb) X
    JOIN
    (select celeb
    from releases
    group by celeb) Y USING (celeb)

-- 10. For each celeb that has both starred in some movie and released some album
-- give the numbers of movies and albums he/she has starred in and released, respectively.
-- The result should be a set of (celeb, number_of_movies, number_of_albums) triples.

select *
from
    (select celeb, count(movie) as number_of_movies
    from starredin
    group by celeb) X
    JOIN
    (select celeb, count(album) as number_of_albums
    from releases
    group by celeb) Y USING (celeb)
