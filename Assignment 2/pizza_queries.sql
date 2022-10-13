/* Create the schema for our tables */
create table Person(name VARCHAR(30), age int, gender VARCHAR(10));
create table Frequents(name VARCHAR(30), pizzeria VARCHAR(30));
create table Eats(name VARCHAR(30), pizza VARCHAR(30));
create table Serves(pizzeria VARCHAR(30), pizza VARCHAR(30), price float);

/* Populate the tables with our data */
insert into Person values('Amy', 16, 'female');
insert into Person values('Ben', 21, 'male');
insert into Person values('Cal', 33, 'male');
insert into Person values('Dan', 13, 'male');
insert into Person values('Eli', 45, 'male');
insert into Person values('Fay', 21, 'female');
insert into Person values('Gus', 24, 'male');
insert into Person values('Hil', 30, 'female');
insert into Person values('Ian', 18, 'male');

insert into Frequents values('Amy', 'Pizza Hut');
insert into Frequents values('Ben', 'Pizza Hut');
insert into Frequents values('Ben', 'Chicago Pizza');
insert into Frequents values('Cal', 'Straw Hat');
insert into Frequents values('Cal', 'New York Pizza');
insert into Frequents values('Dan', 'Straw Hat');
insert into Frequents values('Dan', 'New York Pizza');
insert into Frequents values('Eli', 'Straw Hat');
insert into Frequents values('Eli', 'Chicago Pizza');
insert into Frequents values('Fay', 'Dominos');
insert into Frequents values('Fay', 'Little Caesars');
insert into Frequents values('Gus', 'Chicago Pizza');
insert into Frequents values('Gus', 'Pizza Hut');
insert into Frequents values('Hil', 'Dominos');
insert into Frequents values('Hil', 'Straw Hat');
insert into Frequents values('Hil', 'Pizza Hut');
insert into Frequents values('Ian', 'New York Pizza');
insert into Frequents values('Ian', 'Straw Hat');
insert into Frequents values('Ian', 'Dominos');

insert into Eats values('Amy', 'pepperoni');
insert into Eats values('Amy', 'mushroom');
insert into Eats values('Ben', 'pepperoni');
insert into Eats values('Ben', 'cheese');
insert into Eats values('Cal', 'supreme');
insert into Eats values('Dan', 'pepperoni');
insert into Eats values('Dan', 'cheese');
insert into Eats values('Dan', 'sausage');
insert into Eats values('Dan', 'supreme');
insert into Eats values('Dan', 'mushroom');
insert into Eats values('Eli', 'supreme');
insert into Eats values('Eli', 'cheese');
insert into Eats values('Fay', 'mushroom');
insert into Eats values('Gus', 'mushroom');
insert into Eats values('Gus', 'supreme');
insert into Eats values('Gus', 'cheese');
insert into Eats values('Hil', 'supreme');
insert into Eats values('Hil', 'cheese');
insert into Eats values('Ian', 'supreme');
insert into Eats values('Ian', 'pepperoni');

insert into Serves values('Pizza Hut', 'pepperoni', 12);
insert into Serves values('Pizza Hut', 'sausage', 12);
insert into Serves values('Pizza Hut', 'cheese', 9);
insert into Serves values('Pizza Hut', 'supreme', 12);
insert into Serves values('Little Caesars', 'pepperoni', 9.75);
insert into Serves values('Little Caesars', 'sausage', 9.5);
insert into Serves values('Little Caesars', 'cheese', 7);
insert into Serves values('Little Caesars', 'mushroom', 9.25);
insert into Serves values('Dominos', 'cheese', 9.75);
insert into Serves values('Dominos', 'mushroom', 11);
insert into Serves values('Straw Hat', 'pepperoni', 8);
insert into Serves values('Straw Hat', 'cheese', 9.25);
insert into Serves values('Straw Hat', 'sausage', 9.75);
insert into Serves values('New York Pizza', 'pepperoni', 8);
insert into Serves values('New York Pizza', 'cheese', 7);
insert into Serves values('New York Pizza', 'supreme', 8.5);
insert into Serves values('Chicago Pizza', 'cheese', 7.75);
insert into Serves values('Chicago Pizza', 'supreme', 8.5);


/*
Q1. (1 point). Find all the persons under the age of 18.
*/
select name
from Person
where age < 18;

/*
Q2. (2 points) Find all the pizzerias that serve at least one pizza that Amy eats for less than $10.00.
Print out the pizzeria name, pizza, and price.
*/
select pizzeria, pizza, price
from Eats Join Serves using(pizza)
where (name = 'Amy') and (price < 10);

/*
Q3. (2 points) Find all the pizzerias frequented by at least one person under the age of 18.
Print out the pizzeria name, person's name, and person's age.
*/
select pizzeria, name, age
from Person join Frequents using(name)
where age < 18;

/*
Q4. (2 points) Find all the pizzerias frequented by at least one person under the age of 18
and at least one person over the age of 30.
Print out only the pizzeria name.
*/
select distinct X.pizzeria
from (Person join Frequents using(name)) X, (Person join Frequents using(name)) Y
where (X.age < 18 and Y.age > 30) and (X.pizzeria = Y.pizzeria);

/*
Q5. (2 points) Find all pizzerias frequented by at least one person under the age of 18
and at least one person over the age of 30.
Print out all the quintuples (pizzeria, person1, age1, person2, age2),
where person1 and person2 are persons who frequent the pizzeria,
and person1 is under the age of 18 and person2 is over the age of 30.
*/
select X.pizzeria as pizzeria, X.name as person1, X.age as age1, Y.name as person2, Y.age as age2
from (Person join Frequents using(name)) X, (Person join Frequents using(name)) Y
where (X.age < 18 and Y.age > 30) and (X.pizzeria = Y.pizzeria);

/*
Q6. (2 points) For each person, find how many types of pizzas he/she eats.
Show only those people who eat at least two types of pizzas.
Sort in descending order of the number of types of pizzas they eat.
*/
select Person.name, count(pizza)
from Person join Eats on Person.name = Eats.name
group by Person.name
having count(pizza) >= 2
order by count(pizza) desc;

/*
Q7. (2 points) For each type of pizza, find its average price. Sort descending by average price.
*/
select pizza, avg(price)
from Serves
group by pizza
order by avg(price) desc;
