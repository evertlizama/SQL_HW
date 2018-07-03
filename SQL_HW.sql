-- Activate sakila database
Use sakila;

-- 1a. Select first and last name from actor table

select first_name, last_name 
from actor;

-- 1b. combine first and last name from actor table

SELECT concat(upper(first_name),' ',upper(last_name)) as Actor_Name 
FROM actor;

-- 2a. ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."

select actor_id, first_name, last_name 
from actor 
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

select * 
from actor 
where last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI

select last_name, first_name 
from actor 
where last_name LIKE '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) NOT NULL AFTER first_name;

-- 3b. change datatype to blob for middle name

ALTER TABLE actor 
CHANGE COLUMN middle_name middle_name BLOB NOT NULL ;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor 
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS Last_name_count
FROM actor
GROUP by last_name;

-- 4b. List last names of actors and the number of 
-- actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS Last_name_count
FROM actor
GROUP by last_name
having Last_name_count >=2;

-- 4c Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the 
-- `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE ACTOR
SET first_name = "HARPO"
where first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4D -- Review

UPDATE actor
SET first_name =
case when first_name = "HARPO"
THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO'
END
where actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table.
-- Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, 
-- as well as the address, of each staff member. Use the tables `staff` and `address`:

select staff.first_name, staff.last_name, address.address
from staff
join address on 
staff.address_id = address.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff
-- member in August of 2005. Use tables `staff` and `payment`.

select staff.staff_id, sum(payment.amount) as 'August_2005_amount'
from staff join payment on staff.staff_id = payment.staff_id
where payment.payment_date like '2005-08%'
group by staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

select f.title, count(a.actor_id) as filmActorCount
from film_actor a
inner join film f on a.film_id = f.film_id
group by a.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select f.title, count(f.film_id)
from film f
join inventory i on f.film_id = i.film_id
where f.title = "HUNCHBACK IMPOSSIBLE";

 
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name:

select c.last_name, sum(p.amount) as totalCustomerPayment
from customer c
join payment p on p.customer_id = c.customer_id
group by c.last_name
order by c.last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` 
-- have also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters `K` and `Q` whose language is English.


select title 
from film_text
where film_id in
(
select film_id
from film
where (title LIKE 'Q%' OR title like 'K%') 
AND language_id = (SELECT language_id FROM sakila.language where name='English')
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT actor_id, first_name, last_name 
FROM actor
where actor_id in
( 
 select actor_id
 from film_actor
 where film_id in
 ( 
  select film_id
  from film 
  where title = "Alone Trip"
  )
  );
  
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select concat(customer.first_name, ' ', customer.last_name) AS Name, customer.email
from customer 
inner join address on 
customer.address_id = address.address_id
inner join city on
address.city_id = city.city_id
inner join country on 
country.country_id = city.country_id
where country = "Canada";

-- * 7d. Sales have been lagging among young families, and you wish target 
-- all family movies for a promotion.
--  Identify all movies categorized as family films.

select title
from film 
inner join film_category on
film.film_id = film_category.film_id
inner join category on
film_category.category_id = category.category_id
where category.name = "Family";

-- * 7e. Display the most frequently rented movies in descending order.
-- Come back to this

SELECT i.film_id, film.title, COUNT(*) AS 'rental_count'
    FROM rental r
    inner JOIN inventory i ON 
    r.inventory_id=i.inventory_id
    inner join film on 
    i.film_id = film.film_id
    GROUP BY film_id
    order by COUNT(*) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- Follow up

select store.store_id, sum(payment.amount) as totalPayment 
from payment 
inner join customer on payment.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
group by store.store_id;


-- * 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store 
inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id;

-- * 7h. List the top five genres in gross revenue in descending order.
--  (**Hint**: you may need to use the following tables:
-- category, film_category, inventory, payment, and rental.)


select category.name, sum(payment.amount) AS totalCategoryRevenue
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on category.category_id = film_category.category_id
group by category.name 
order by sum(payment.amount) DESC limit 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE 
VIEW `sakila`.`Top_5_Grossing_Genres` as
select category.name, sum(payment.amount) AS totalCategoryRevenue
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on category.category_id = film_category.category_id
group by category.name 
order by sum(payment.amount) DESC limit 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Grossing_Genres;

-- 8c. Drop created view

DROP VIEW Top_5_Grossing_Genres;

