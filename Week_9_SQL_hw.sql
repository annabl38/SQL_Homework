/*getting started */
use sakila;
/*Displaying actors names */
select first_name, last_name from actor;
select concat(upper(first_name), ' ',upper(last_name)) as 'Actor Name' from actor;

/*Actors named Joe */
select actor_id, first_name, last_name from actor where first_name='Joe';

-- Actors with last names that contain GEN
select actor_id, first_name, last_name from actor where last_name like '%gen%';

-- Actors with last names that contain LI, order by last, first name
select actor_id, first_name, last_name from actor where last_name like '%li%' order by last_name, first_name;

-- Country IDs
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- alter table to add description
alter table actor add description blob;

-- delete description comment
alter table actor drop column description;

-- Find Count of actors by last name
select last_name, count(actor_id) as 'Actor Count' from actor group by last_name;

-- find last names shared by at least two actors
select last_name, count(actor_id) as 'Actor Count' from actor group by last_name having count(actor_id) >=2;

-- Updating Groucho Williams to Harpo WIlliams
select * from actor where first_name='Groucho';
update actor 
set first_name='HARPO' where first_name='GROUCHO' and last_name='Williams';

-- Undoing that change
select * from actor where first_name='HARPO';
update actor 
set first_name='GROUCHO' where first_name='HARPO' and last_name='Williams';

-- display schema of address table
show create table address;

-- Show names and addresses of staff
select * from address 
join staff on staff.address_id=address.address_id;

-- Show amount rung up by each staff memebr in August 2005
select staff.staff_id as 'Staff ID',
staff.first_name as 'First Name', 
staff.last_name as 'Last Name', 
sum(payment.amount) from payment
join staff on staff.staff_id=payment.staff_id
and date(payment_date)<'2005-08-31' and date(payment_date)>'2005-08-01'
group by staff.staff_id;

-- display number of actors in each film
select film.film_id as 'Film ID', film.title as 'Title', count(film_actor.actor_id) as '# Actors in Film' from film 
inner join film_actor on film.film_id=film_actor.film_id
group by film.film_id;

-- Count number of Hunchback impossible in inventory
select film.title as 'Title', count(inventory.inventory_id) as '# in Inventory' from film
join inventory on film.film_id=inventory.film_id
and film.title='HUNCHBACK IMPOSSIBLE';

-- total amount paid by each customer
select customer.first_name as 'First Name', customer.last_name as 'Last Name', sum(payment.amount) as 'Total Amount Paid' from customer
join payment on payment.customer_id=customer.customer_id
group by customer.customer_id
order by customer.last_name;

-- English language films starting Q or K
select * from film
where language_id=
(select language_id from language where name='English')
and title like 'Q%' or 
title like 'K%';

-- Actors in Alone Trip
select * from actor
where actor_id in 
(select actor_id from film_actor where 
film_id in
(select film_id from film where 
title='ALONE TRIP')
);
 
 -- Names and Emails of Canadian employees
select customer.first_name, customer.last_name, customer.email from customer
where address_id in
	(select address_id from address
	 where city_id in
		(select city_id from city
		join country where country.country_id=city.country_id
		and country='CANADA')
        );
     
-- identify family movies     
select film.title from film
where film_id in
	(select film_id from film_category
	where category_id in
	(select category_id from category
    where name='Family')
    );


-- most frequently rented movies in descending order    
select film.title,count(inventory.inventory_id) as '# Times Rented' from film 
join inventory
on inventory.film_id=film.film_id
join rental 
on rental.inventory_id=inventory.inventory_id
group by film.title
order by count(inventory.inventory_id) desc;   

-- displays how much business each store brought in based on gross revenue
select store.store_id, sum(payment.amount) as 'Gross Revenue' from store
join staff on staff.store_id=store.store_id
join payment on staff.staff_id=payment.staff_id
group by store_id;

-- displays each stores id city and country
select store.store_id, city.city, country.country from store
join address on store.address_id=address.address_id
join city on city.city_id=address.city_id
join country on country.country_id=city.country_id;

-- top five genres in gross revenue in descending order
select category.name as 'Category', sum(payment.amount) as 'Gross Revenue' from payment
join rental on payment.rental_id=rental.rental_id
join inventory on rental.inventory_id=inventory.inventory_id
join film_category on inventory.film_id=film_category.film_id
join category on film_category.category_id=category.category_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- create view just for Top Five Genres
create view top_five_genres as
select category.name as 'Category', sum(payment.amount) as 'Gross Revenue' from payment
join rental on payment.rental_id=rental.rental_id
join inventory on rental.inventory_id=inventory.inventory_id
join film_category on inventory.film_id=film_category.film_id
join category on film_category.category_id=category.category_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- display top five genres view
SELECT * FROM top_five_genres;

-- delete top five genres view
drop view top_five_genres;