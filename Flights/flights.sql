--daily flights for some airline
create table flights (
    fno int,
    from_city varchar(20),
    to_city varchar(20),
    departure char(5),  --string in 24h format, from_city timezone
    arrival char(5)     --string in 24h format, to_city timezone
);

insert into flights values(1, 'Victoria', 'Toronto', '06:00', '13:00');
insert into flights values(2, 'Victoria', 'Vancouver', '06:00', '06:30');
insert into flights values(3, 'Victoria', 'Vancouver', '07:00', '07:30');
insert into flights values(4, 'Victoria', 'Vancouver', '08:00', '08:30');
insert into flights values(5, 'Victoria', 'Calgary', '09:00', '11:00');
insert into flights values(6, 'Victoria', 'Calgary', '12:00', '14:00');
insert into flights values(7, 'Vancouver', 'Toronto', '09:00', '14:00');
insert into flights values(8, 'Calgary', 'Toronto', '13:00', '18:00');

-- Q1
-- How many flights are there for each destination city (to_city)?
-- Show only cities with at least 2 flights a day.
-- Output city, number-of-flights pairs.
-- Sort them descending by the number-of-flights.


--Write your solution here
select to_city as city, count(fno) as number_of_flights
from flights
group by to_city
having count(fno) >= 2
order by count(fno) desc;


-- Q2
-- Find all the possible flight routes from Victoria to Toronto with one stop.
-- The result should be fno1, fno2 pairs of flights.
-- Hint: The first flight must arrive earlier (no matter by how much)
-- than the second.


--Write your solution here
select X as fno1,Y as fno2
from flights X, flights Y
where X.from_city='Victoria' and Y.from_city <> 'Victoria' and
      Y.to_city='Toronto' and X.to_city = Y.from_city and X.arrival < Y.arrival ;


-- Q3
-- Find the earliest flight (with respect to departure) for each direct route.
-- The result should be quadruples of the form (from_city, to_city, fno, departure).


--Write your solution here

create view earliestflights as
select from_city, to_city, min(departure) as departure
from flights
group by from_city, to_city;

select flights.from_city, flights.to_city, flights.fno, flights.departure
from flights join earliestflights on flights.from_city = earliestflights.from_city
                                     and flights.to_city = earliestflights.to_city
                                     and flights.departure = earliestflights.departure


