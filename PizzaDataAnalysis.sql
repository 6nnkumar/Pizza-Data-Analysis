             --                                       	PIZZA DATA ANALYSIS
             
 select * from order_details;
 select * from orders;
 select * from pizza_types;
 select * from pizzas;

-- 1. Retrieve the total number of orders placed.
		select count(order_id) as Total_Orders from orders;
        
-- 2. Calculate the total revenue generated from pizza sales.
		SELECT pizzas.pizza_type_id,
               (order_details.quantity * pizzas.price) AS total_Sales
                  FROM
                    order_details
				     JOIN
                       pizzas ON pizzas.pizza_id = order_details.pizza_id;  -- this is for total sales by pizza
                       
		SELECT 
               round(sum(order_details.quantity * pizzas.price),2) AS total_Sales
                  FROM
                    order_details
				     JOIN
                       pizzas ON pizzas.pizza_id = order_details.pizza_id; -- This is the total sales of all orders
                       
	-- 3. Identify the highest-priced pizza.
          select pizza_types.name, pizzas.price 
               from pizza_types join pizzas 
                 on pizza_types.pizza_type_id = pizzas.pizza_type_id;   -- the price of all pizas
                 
		 select pizza_types.name, pizzas.price
               from pizza_types join pizzas 
                 on pizza_types.pizza_type_id = pizzas.pizza_type_id 
                    order by pizzas.price desc limit 1;   -- the price of highest price pizzas
                    
	-- 4. Identify the most common pizza size ordered.
         select  pizzas.size, count(order_details. order_details_id) as Total_Orders
             from order_details join pizzas
             on pizzas.pizza_id= order_details.pizza_id
              group by  pizzas.size
                 order by Total_Orders desc;
             
	-- 5. List the top 5 most ordered pizza types along with their quantities.
            select pizza_types.name, sum(order_details.quantity) as Total_Quantity
             from pizza_types 
               join pizzas
                 on pizza_types.pizza_type_id = pizzas.pizza_type_id
                  join order_details 
                    on order_details.pizza_id = pizzas.pizza_id
					group by pizza_types.name
                      order by Total_Quantity desc limit 5;
                      
-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
                  
		  select pizza_types.category, sum(order_details.quantity) as Quantity
             from pizza_types 
               join pizzas
                 on pizza_types.pizza_type_id = pizzas.pizza_type_id
                  join order_details 
                    on order_details.pizza_id = pizzas.pizza_id
					group by pizza_types.category
                     order by Quantity desc;
                     
-- 7. Determine the distribution of orders by hour of the day.
              select hour(time), count(order_id) as Order_Count
                 from orders
                   group by hour(time);
                   
-- 8. Join relevant tables to find the category-wise distribution of pizzas.
    
          select category, count(name) 
             from pizza_types
                group by category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
   
     SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.date, COUNT(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS Order_Quantity;
             
-- 10. Determine the top 3 most ordered pizza types based on revenue.

            SELECT 
    pizza_types.name,
    Sum(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by Revenue desc limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
              SELECT 
    pizza_types.category,
     round(sum(order_details.quantity * pizzas.price ) / (SELECT pizzas.pizza_type_id,
              round(sum(order_details.quantity * pizzas.price),2) AS total_Sales
                  FROM
                    order_details
				     JOIN
                       pizzas ON pizzas.pizza_id = order_details.pizza_id) *100, 2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by Revenue desc ;


-- 12. Analyze the cumulative revenue generated over time.

 select date, sum(Revenue) over(order by date) as Sales from
     ( select orders.date, sum(order_details.quantity * pizzas.price) as Revenue
          from order_details join pizzas
            on order_details.pizza_id = pizzas.pizza_id 
            join orders on orders.order_id = order_details.order_id
            group by orders.date) as sales;
            
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

 select category, name, Revenue from
(select name, category, Revenue, rank() over (partition by category order by Revenue desc) as rn from
   ( SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM((order_details.quantity) * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as A)as B where rn <= 3;


