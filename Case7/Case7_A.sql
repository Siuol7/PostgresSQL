--High Level Sales Analysis
	--What was the total quantity sold for all products?
	SELECT SUM(qty) AS Total_quantity
	FROM balanced_tree.sales

    --What is the total generated revenue for all products before discounts?
	SELECT SUM(qty*price) AS Total_Revenue
	FROM balanced_tree.sales

    --What was the total discount amount for all products?
	SELECT SUM(qty*price)*17/100 AS Total_Discount
	FROM balanced_tree.sales


