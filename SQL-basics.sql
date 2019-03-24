/* 1a: Display the first and last names of all actors from the table actor*/
use sakila;
Select first_name, last_name from actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name*/
Select concat(upper(first_name), ' ', upper(Last_name)) as `Actor Name` from actor;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/
Select actor_id, first_name, last_name from actor where actor.first_name = "Joe";

/*2b. Find all actors whose last name contain the letters GEN*/
Select first_name, last_name from actor ac where (ac.last_name like "gen%"
 or ac.last_name like "%gen%" or ac.last_name like "%gen");

/*2c. Find all actors whose last names contain the letters LI. This time,
 order the rows by last name and first name, in that order*/
 Select last_name, first_name from actor ac where (ac.last_name like "li%"
 or ac.last_name like "%li%" or ac.last_name like "%li");
 
 /*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China*/
 Select country_id, country from country where country in
	('Afghanistan', 'Bangladesh', 'China');
 
 /*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
 so create a column in the table actor named description and use the data type BLOB*/
Alter table actor add column description BLOB after last_update;

/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
Alter table actor drop column description;

/*4a. List the last names of actors, as well as how many actors have that last name.*/
Select last_name, count(last_name) as 'Actor Count' from actor group by last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
Select last_name, count(last_name) as Actor_Count from actor group by last_name having Actor_Count > 1;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
Update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query,
 if the first name of the actor is currently HARPO, change it to GROUCHO.*/
Update actor set first_name = 'GROUCHO' where first_name = 'HARPO' and last_name = 'WILLIAMS';

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
Show create table sakila.address;

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address*/
Select first_name, last_name, address from staff join address on staff.address_id = address.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment*/
Select first_name, last_name, sum(amount) from staff join payment on staff.staff_id = payment.staff_id
group by payment.staff_id;

/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
Select title, count(actor_id) from film inner join film_actor on film.film_id = film_actor.film_id group by title;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
Select title, count(inventory_id) from film join inventory  on film.film_id = inventory.film_id where title = "Hunchback Impossible";

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name*/
Select last_name, first_name, sum(amount) as 'Total Amount Paid' from payment join customer on payment.customer_id = customer.customer_id
group by payment.customer_id order by last_name asc;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films
 starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting
 with the letters K and Q whose language is English.*/
Select title from film where language_id in
	(Select language_id from `language` where `name` = "English" ) and (title like "K%") or (title like "Q%");

/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
Select last_name, first_name from actor where actor_id in
	(Select actor_id from film_actor where film_id in 
		(Select film_id from film where title = "Alone Trip"));
        
/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses
 of all Canadian customers. Use joins to retrieve this information.*/
Select country.country, customer.last_name, customer.first_name, customer.email from country join city on country.country_id = city.country_id
join address on city.city_id = address.city_id
join customer on address.address_id = customer.address_id where country = 'Canada';

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/
Select title, category from film_list where category = 'Family';

/*7e. Display the most frequently rented movies in descending order.*/
Select inventory.film_id, film_text.title, count(rental.inventory_id) from inventory join rental on inventory.inventory_id = rental.inventory_id
join film_text on inventory.film_id = film_text.film_id group by rental.inventory_id order by count(rental.inventory_id) desc;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/
Select store.store_id, sum(amount) from store join staff on store.store_id = staff.store_id
join payment  on payment.staff_id = staff.staff_id group by store.store_id order by sum(amount);

/*7g. Write a query to display for each store its store ID, city, and country.*/
Select store.store_id, city, country from store join customer on store.store_id = customer.store_id
join staff on store.store_id = staff.store_id
join address on customer.address_id = address.address_id
join city on address.city_id = city.city_id
join country on city.country_id = country.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following
 tables: category, film_category, inventory, payment, and rental.)*/
Select name, sum(payment.amount) from category join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id group by name limit 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross
 revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute
 another query to create a view.*/
create view `Top Five Genres` as
Select name, sum(payment.amount) from category join film_category on category.category_id = film_category.category_id
join inventory on film_category.film_id = inventory.film_id
join rental on inventory.inventory_id = rental.inventory_id
join payment on rental.rental_id = payment.rental_id group by name limit 5;

/*8b. How would you display the view that you created in 8a?*/
SELECT * FROM `Top Five Genres`;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW `Top Five Genres`;