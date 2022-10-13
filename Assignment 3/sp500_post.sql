-- Create the tables for the S&P 500 database.
-- They contain information about the companies 
-- in the S&P 500 stock market index
-- during some interval of time in 2014-2015.
-- https://en.wikipedia.org/wiki/S%26P_500 

create table history
(
	symbol text,
	day date,
	open numeric,
	high numeric,
	low numeric,
	close numeric,
	volume integer,
	adjclose numeric
);

create table sp500
(
	symbol text,
	security text,
	sector text,
	subindustry text,
	address text,
	state text
);

-- Populate the tables
insert into history select * from bob.history;
insert into sp500 select * from bob.sp500;
drop table history
drop table sp500
-- Familiarize yourself with the tables.
select * from history;
select * from sp500;

create view A as
    select symbol, state, day, close, volume
    from sp500 join history using(symbol)
    order by day desc;

select * from A;

select state, round(sum(volume),-9) as totaldollarvol
from A
where extract(year from day) = 2015
group by state
having sum(volume) >= 1000000000000
order by sum(volume) desc;

drop view a;

create view b as
select min(day) as first, max(day) as last
from history
where extract(year from day) = 2015 and extract(month from day) >= 1 and extract(month from day) <= 3;

select * from b;

drop view b;

create view c as
    select symbol, X.close as closefirst, Y.close as closelast, 100*(Y.close-X.close)/X.close as pctchange from
    (select symbol, close
    from history, b
    group by symbol, close, b.first
    having min(day) = b.first) X
    join
    (select symbol, close
    from history, b
    group by symbol, close, b.last
    having min(day) = b.last) Y using(symbol);


select * from c;

select symbol, pctchange, rank
from (select symbol, rank() over(order by pctchange desc) as rank, pctchange from c group by symbol, pctchange) X
where rank <= 5
order by rank;

select symbol, pctchange, sector, rank
from (select c.symbol, pctchange, sector, rank() over (order by pctchange desc) as rank from c, sp500 where c.symbol = sp500.symbol
    group by sector, c.symbol, pctchange) X
where rank <=2
order by rank;


-- Exercise 1 (3 pts)

-- 1. (1 pts) Find the number of companies for each state, sort descending by the number.

-- Write your query here. 
select state, count(distinct(security)) as num_companies
from sp500
group by state
order by count(distinct(security)) desc;

-- 2. (1 pts) Find the number of companies for each sector, sort descending by the number.

-- Write your query here. 
select sector, count(distinct(security)) as num_companies
from sp500
group by sector
order by count(distinct(security)) desc;

-- 3. (1 pts) Order the days of the week by their average volatility.
-- Sort descending by the average volatility. 
-- Use 100*abs(high-low)/low to measure daily volatility.

-- Write your query here. 
select extract(dow from day) as day_of_week, avg(100*abs(high-low)/low) as average_volatility
from history
group by extract(dow from day)
order by avg(100*abs(high-low)/low) desc;




-- Exercise 2 (4 pts)

-- 1. (2 pts) Find for each symbol and day the pct change from the previous business day.
-- Order descending by pct change. Use adjclose.

-- Write your query here.
select symbol, day, (100*(adjclose-adjclose_prev)/adjclose_prev) as pct_change
from (select symbol, day, adjclose, LAG(adjclose,1) OVER (partition by symbol order by symbol, day) AS adjclose_prev
      from history) X
where adjclose_prev is not null
order by (100*(adjclose-adjclose_prev)/adjclose_prev) desc;


-- 2. (2 pts)
-- Many traders believe in buying stocks in uptrend
-- in order to maximize their chance of profit. 
-- Let us check this strategy.
-- Find for each symbol on Oct 1, 2015 
-- the pct change 20 trading days earlier and 20 trading days later.
-- Order descending by pct change with respect to 20 trading days earlier.
-- Use adjclose.

-- Expected result
--symbol,pct_change,pct_change2
--TE,26.0661102331371252,3.0406725557250169
--TAP,24.6107784431137725,5.1057184046131667
--CVC,24.4688922610015175,-0.67052727826882048156
--...

-- Write your query here. 
select symbol,
       100*(adjclose-adjclose_prev)/adjclose_prev AS pct_change,
       100*(adjclose_post-adjclose)/adjclose AS pct_change2
from (select symbol, day, adjclose,
             LAG(adjclose,20) OVER (partition by symbol order by symbol, day) AS adjclose_prev,
             LEAD(adjclose,20) OVER (partition by symbol order by symbol, day) AS adjclose_post
      from history) X
where adjclose_prev is not null and adjclose_post is not null and
      extract(year from day) = 2015 and extract(month from day) = 10 and extract(day from day) = 1
order by (100*(adjclose-adjclose_prev)/adjclose_prev) desc;



-- Exercise 3 (3 pts)
-- Find the top 10 symbols with respect to their average money volume AVG(volume*adjclose).
-- Use round(..., -8) on the average money volume.
-- Give three versions of your query, using ROW_NUMBER(), RANK(), and DENSE_RANK().

-- Write your query here.
select symbol, rank
from (select symbol, ROW_NUMBER() over (order by round(AVG(volume*adjclose),-8)) AS rank
      from history
      group by symbol) X
where rank<=10
order by rank;

select symbol, rank
from (select symbol, RANK() over (order by round(AVG(volume*adjclose),-8)) AS rank
      from history
      group by symbol) X
where rank<=10
order by rank;

select symbol, rank
from (select symbol, DENSE_RANK() over (order by round(AVG(volume*adjclose),-8)) AS rank
      from history
      group by symbol) X
where rank<=10
order by rank;

