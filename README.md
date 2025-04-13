# Mobile Manufacturer Data Analysis - SQL Case Study
The database “Cellphones Information” contains details on cell phone sales or transactions.

## Detailes stored are:

- Dim_manufacturer
- Dim_model
- Dim_customer
- Dim_Location 
- Fact_Transactions

The first four store entries for the respective elements and Fact_Transactions stores all the information about sales of specific cellphones.

## Data Availability

Assume that you do not have access to the data. Hence, pls create a schema based on the representation below to work on the case study

![image](https://github.com/user-attachments/assets/410501f9-578e-4457-b07c-595b2d2533e8)

## Questions:

Write queries to find out the following:

1. List all the states in which we have customers who have bought cellphones from 2005 till today.
2. What state in the US is buying the most 'Samsung' cell phones?
3. Show the number of transactions for each model per zip code per state.
4. Show the cheapest cellphone (Output should contain the price also).
5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500
7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.


## Answers

--SQL Advance Case Study
--Q1--BEGIN

SELECT distinct State from (
SELECT t1.State, SUM(quantity) as cnt, Year(t2.date) as Year from DIM_LOCATION as t1
JOIN FACT_TRANSACTIONS as t2
on t1.IDLocation = t2.IDLocation
where Year(t2.date) >=2005
group by t1.State, Year(t2.date)
) as A

--Q1--END

--Q2--BEGIN

SELECT Top 1 State, Count (*) as cnt from DIM_MANUFACTURER as t1
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3
on t2.IDModel= t3.IDModel
JOIN DIM_LOCATION as t4
on t3.IDLocation=t4.IDLocation
Where Country ='US' AND Manufacturer_Name = 'Samsung'
Group by State
Order by cnt desc

--Q2--END

--Q3--BEGIN

SELECT idmodel,State, ZipCode,  COUNT (*) as tot_trans From FACT_TRANSACTIONS as t1
JOIN DIM_LOCATION as t2
on t1.IDLocation=t2.IDLocation 
group by idmodel,State, ZipCode
order by tot_trans desc

--Q3--END

--Q4--BEGIN

SELECT TOP 1 IDModel, Model_Name, Unit_price as Min_Price from DIM_MODEL
group by IDModel, Model_Name, Unit_price
order by Min_Price ASC 

--Q4--END

--Q5--BEGIN

SELECT t2.idmodel, avg(TotalPrice) as AVG_Price, SUM(quantity) as tot_qty from DIM_MANUFACTURER as t1 
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3 
on t2.IDModel = t3.IDModel
where Manufacturer_Name in (SELECT top 5 Manufacturer_Name from DIM_MANUFACTURER as t1 
                            JOIN DIM_MODEL as t2
	                        on t1.IDManufacturer = t2.IDManufacturer
                            JOIN FACT_TRANSACTIONS as t3 
							on t2.IDModel = t3.IDModel
							group by Manufacturer_Name
							order by SUM(TotalPrice) desc)
group by t2.idmodel
Order by AVG_Price desc
 
--Q5--END

--Q6--BEGIN

SELECT Customer_Name, AVG(TotalPrice) as AVG_Price from DIM_CUSTOMER as t1
JOIN FACT_TRANSACTIONS as t2
on t1.IDCustomer = t2.IDCustomer
Where year(date)=2009
Group by Customer_Name
Having AVG(TotalPrice) >500

--Q6--END

--Q7--BEGIN

SELECT * from (
SELECT top 5 IDModel from FACT_TRANSACTIONS
Where year(date) = 2008
Group By IDModel, year(date)
order by SUM (quantity) desc) as A
INTERSECT 
SELECT * from (
SELECT top 5 IDModel from FACT_TRANSACTIONS
Where year(date) = 2009
Group By IDModel, year(date)
order by SUM (quantity) desc) as B
INTERSECT 
SELECT * from (
SELECT top 5 IDModel from FACT_TRANSACTIONS
Where year(date) = 2010
Group By IDModel, year(date)
order by SUM (quantity) desc) as C

--Q7--END

--Q8--BEGIN

SELECT * from (
Select top 1 * from (
SELECT top 2 Manufacturer_Name, year(date) as year, SUM(TotalPrice) as sales from DIM_MANUFACTURER as t1
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3
on t2.IDModel = t3.IDModel
Where year(date)=2009
Group by  Manufacturer_Name, year(date)
order by sales desc
) as A
Order by sales asc
) as C
union
Select * from (
Select top 1 * from (
SELECT top 2 Manufacturer_Name, year(date) as year, SUM(TotalPrice) as sales from DIM_MANUFACTURER as t1
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3
on t2.IDModel = t3.IDModel
Where year(date)=2010
Group by  Manufacturer_Name, year(date)
order by sales desc
) as B
Order by sales asc
) as D
order by sales desc

--Q8--END

--Q9--BEGIN

SELECT Manufacturer_Name  from DIM_MANUFACTURER as t1
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3
on t2.IDModel = t3.IDModel
Where year(date)=2010
group by Manufacturer_Name
EXCEPT
SELECT Manufacturer_Name from DIM_MANUFACTURER as t1
JOIN DIM_MODEL as t2
on t1.IDManufacturer = t2.IDManufacturer
JOIN FACT_TRANSACTIONS as t3
on t2.IDModel = t3.IDModel
Where year(date)=2009
group by Manufacturer_Name

--Q9--END

--Q10--BEGIN

SELECT *, ((avg_price-lag_price)/lag_price) as percentage_change from (
Select *, lag(avg_price,1) over(partition by idcustomer order by year) as lag_price from (
Select idcustomer, year(date) as year, avg(totalprice) as avg_price, sum(quantity) as qty from FACT_TRANSACTIONS
where idcustomer in (Select top 100 idcustomer from FACT_TRANSACTIONS 
                     group by IDCustomer 
                     order by sum(totalprice) desc)
group by idcustomer, year(date)
) as A
) as B

--Q10--END


## Note: Please Find all relevant files in attached folder

## 🔍 Repository File Types

| Repository                          | SQL | Python | Excel | Power BI |
|-------------------------------------|:---:|:------:|:-----:|:--------:|
| [Cellphones-Information](#)         | ✅  |        |       |          |
| [Cleaning-Data-in-Python](#)        |     | ✅     |       |          |
| [Customer-Churn-with-Power-BI](#)   |     |        | ✅    | ✅       |
| [Read-a-File-into-Python](#)        |     | ✅     | ✅    |          |
| [Handling-Missing-Data-by-Python](#)|     | ✅     |       |          |

