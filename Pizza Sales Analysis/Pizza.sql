Create database pizza;
Use Pizza;
Create table orders
(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);
Create table orders_details
(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

Select * from orders_details;
Select * from pizzas;
Select * from orders;
Select * from pizza_types;

## Total number of orders placed
Select count(order_id) from orders;

## Total revenue generated from pizza sales
Select sum(orders_details.quantity*pizzas.price) as total_revenue 
from orders_details 
join pizzas
on pizzas.pizza_id=orders_details.pizza_id;

## Highest_priced pizza
Select pizza_types.name,pizzas.price from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id 
order by pizzas.price desc limit 1;

## Most common pizza size ordered
Select pizzas.size,count(orders_details.order_details_id) as order_count
from pizzas join orders_details
on pizzas.pizza_id= orders_details.pizza_id
group by pizzas.size order by order_count desc;

## Top 5 most ordered pizza types along with their quantites
Select pizza_types.name,sum(orders_details.quantity) as quantity
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity desc limit 5;

## To find the total quantity of each pizza category ordered
Select pizza_types.category,sum(orders_details.quantity)as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;

## To determine the distribution of orders by hour of the day
Select hour(order_time),count(order_id) from orders
group by hour(order_time);

## To find the category wise distribution of pizzas
Select category, count(name) from pizza_types
group by category;

## To calculate the average number of pizzas ordered per day
Select avg(quantity) from 
(
select orders.order_date,sum(orders_details.quantity) as quantity
from orders join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date)as order_quantity;

## The top 3 most ordered pizza types based on revenue
Select pizza_types.name,sum(orders_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

