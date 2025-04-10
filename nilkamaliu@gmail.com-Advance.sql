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

