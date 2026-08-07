select* from dbo.Calendar
select* from dbo.Container
select* from dbo.Customer
select* from dbo.Location
select* from dbo.Shipping_Line
select* from dbo.Logistics_Dashboard_Clean_Data
select * from Commodity

---#Create Dimension Tables
select distinct customer,Export_Country
into Customer_data
from dbo.Logistics_Dashboard_Clean_Data

select distinct origin into Origin
from dbo.Logistics_Dashboard_Clean_Data


select distinct Destination into Destination
from dbo.Logistics_Dashboard_Clean_Data

--verify
select * from Customer_data
select * from Origin
select * from Destination

 --Display Shipment ID, Customer, Freight from logistis Dashoboard table
 select Shipment_ID,Customer,Freight_Cost
 from dbo.Logistics_Dashboard_Clean_Data

 --Shipments with Freight > 70000
 select * from dbo.Logistics_Dashboard_Clean_Data
 where Freight_Cost>70000

 ---- Shipments to UAE
 select * from dbo.Logistics_Dashboard_Clean_Data
 where Export_Country='UAE'

 ---- Sort by Profit
SELECT * from dbo.Logistics_Dashboard_Clean_Data
order by Profit desc

--Aggregate Functions
--Count shipments
select distinct count(shipment_ID) as Total_Shippment from dbo.Logistics_Dashboard_Clean_Data

--Total Freight cost
select sum(Freight_Cost)as Total_Freight_cost from dbo.Logistics_Dashboard_Clean_Data

--Average Profit
select avg(Profit)as Average_Profit from dbo.Logistics_Dashboard_Clean_Data

--Highest Freight
select max(Freight_Cost) as Highest_Profit from dbo.Logistics_Dashboard_Clean_Data

--Lowest_Freight
select min(Freight_Cost)as Lowest_Freight from dbo.Logistics_Dashboard_Clean_Data


--GROUP BY
--Commodity wise Freight cost
select Commodity,sum(Freight_Cost)as Total_Freight_Cost from dbo.Logistics_Dashboard_Clean_Data
group by Commodity

--Shipping Line wise Freight_Cost
select Shipping_Line,sum(Freight_Cost) as Total_Freight_Cost from dbo.Logistics_Dashboard_Clean_Data
group by Shipping_Line

--Avg Freight Paid to shipping lines
select Shipping_Line,avg(Freight_Cost) as Avg_Freight from dbo.Logistics_Dashboard_Clean_Data
group by Shipping_Line

--Countrywise shipments
select Export_Country, Count(distinct Shipment_ID)as Total_Shipments from dbo.Logistics_Dashboard_Clean_Data
group by Export_Country

--select commoditywise Freight cost which we paid Freight more than 4000000
select Commodity,sum( Freight_Cost) as Total_Freight_Cost from dbo.Logistics_Dashboard_Clean_Data
group by Commodity
having sum(Freight_Cost)>4000000


--Show commodities exported to UAE where the total freight is greater than ₹90,000.
select Commodity,sum(Freight_Cost)as Total_Freight
from dbo.Logistics_Dashboard_Clean_Data
where Export_Country='UAE'
group by Commodity
having sum(Freight_Cost)>90000

--Show shipping lines where Profit > 5000 and Average Freight > 60000.
select Shipping_Line,avg(Freight_Cost) as avg_Freight_cost
from dbo.Logistics_Dashboard_Clean_Data
where Profit>5000
group by Shipping_Line
having avg(Freight_Cost)>60000


---CASE
select Shipment_ID,Freight_Cost,
case
when Freight_Cost>80000 then 'High'
when Freight_Cost>50000 then 'Medium'
else 'low'
end as Freight_Category
from dbo.Logistics_Dashboard_Clean_Data

--joins
--Inner Join
--Show Shipment ID, Customer Name, Country and Freight Cost.
select s.Shipment_ID,s.Freight_Cost,c.Customer,c.Export_Country
from dbo.Logistics_Dashboard_Clean_Data s inner join Customer_data c
on s.Customer=c.Customer
--Show every customer even if there are no shipments.
select c.customer,s.Shipment_ID
from dbo.Logistics_Dashboard_Clean_Data s right join Customer_Data c
on s.Customer=c.Customer

--FULL OUTER JOIN
select s.Shipment_ID,c.Customer from Logistics_Dashboard_Clean_Data s
full outer join Customer_data c
on S.Customer=c.Customer


---Window Functions
---Number shipments within each shipping line.
Select Shipment_ID,Shipping_Line,Freight_Cost,
row_number()over (Partition by Shipping_Line Order by Freight_Cost Desc) as Row_No from Logistics_Dashboard_Clean_Data 
select * from Customer_data
select * from Origin

--DENSE_RANK()
select Shipment_ID,Profit,
DENSE_RANK()over(Order by Profit Desc)as DenseRank
from  Logistics_Dashboard_Clean_Data

--Divide shipments into 4 profit groups.
select Shipment_ID,Profit,
NTILE(4)over(Order by Profit Desc) as Quartile
from Logistics_Dashboard_Clean_Data


--Average freight by shipping line.
select Shipment_ID,Shipping_Line,Freight_Cost,
avg(Freight_Cost)over(partition by Shipping_Line) as Avg_Freight
from Logistics_Dashboard_Clean_Data;

--Running Total
Select Booking_Date,Freight_Cost,
sum(Freight_Cost)over(Order By Booking_Date) as Running_Total
from Logistics_Dashboard_Clean_Data;

---Top 3 Shipments by Profit in each Shipping Line
with CTE as
(Select Shipment_ID,Shipping_Line,Profit,
row_Number()over (Partition by Shipping_Line order by Profit Desc) as rnk from Logistics_Dashboard_Clean_Data)
select * from CTE
where RNK>=3


--Shipments with Profit > ₹10,000
with High_Profit as 
(select * from Logistics_Dashboard_Clean_Data
where profit > 10000)
select* from High_Profit

--High Freight Shipments
with High_Freight as
(select Shipment_ID,Customer,Profit
from Logistics_Dashboard_Clean_Data
where Freight_Cost>70000)
select * From High_Freight

--Subqueries
---Find shipments having Freight Cost greater than Average Freight Cost
select Shipment_ID,Freight_Cost
from Logistics_Dashboard_Clean_Data
where Freight_Cost>
(select avg(Freight_Cost) from Logistics_Dashboard_Clean_Data)

--Find Highest Profit Shipment
select * From Logistics_Dashboard_Clean_Data
where Profit=
(Select max( Profit) from Logistics_Dashboard_Clean_Data)

--Find all shipments of the Customer having highest Profit
select * from Logistics_Dashboard_Clean_Data
where Customer=
(select top 1 Customer from Logistics_Dashboard_Clean_Data
order by Profit Desc)

---Find Commodities having Average Freight greater than overall Average Freight
select Commodity,Avg(Freight_Cost)  as AvgFreight from Logistics_Dashboard_Clean_Data
group by Commodity 
having Avg(Freight_Cost)>
(select Avg(Freight_Cost) from Logistics_Dashboard_Clean_Data)

--Find shipments exported to countries where profit is more than ₹10,000.
select * from Logistics_Dashboard_Clean_Data
where Export_Country in
(Select Export_Country From Logistics_Dashboard_Clean_Data
where Profit>10000)

--Freight Summary View
Create view Freight_Summary 
as
Select 
Shipping_Line,sum(Freight_Cost) as Freight_Cost
from Logistics_Dashboard_Clean_Data
group by Shipping_Line;
 
Select * From Freight_Summary
order by Freight_Cost Desc

---stored procedure
--Display All Shipments
create Procedure GETALLSHIPMENTS
as Begin
select * from Logistics_Dashboard_Clean_Data
end

execute GETALLSHIPMENTS

--High Profit Shipments

create procedure HighPROFITSHIPMENTS
as begin
select Shipment_ID,Customer,Profit
from Logistics_Dashboard_Clean_Data
where Profit>10000
end

execute HighPROFITSHIPMENTS


---Find shipments for a specific country.
create procedure shipmentbycountry
@country varchar(50)
as begin
select * from Logistics_Dashboard_Clean_Data
where Export_Country = @country
end

execute shipmentbycountry 'UAE'


--Freight Greater Than
Create procedure Freightabove
@amount decimal(18,2)
as begin
select * from Logistics_Dashboard_Clean_Data
where Freight_Cost>@amount
end

exec Freightabove 70000

--Shipment by Commodity
create procedure ShipmentbyCommodity
@Commodity varchar (50)
as begin
select * from Logistics_Dashboard_Clean_Data
where Commodity= @commodity
end

exec ShipmentbyCommodity 'Cumin'



--Case
create procedure FreightRemarks
as begin
select Shipping_Line,Freight_Cost,
case
when Freight_Cost> 70000 then 'High'
else 'low'
end as Freightcategory
from Logistics_Dashboard_Clean_Data
end

exec FreightRemarks
from 
if @amount>70000
select'High Freight'
else select 'Low Freight'
end
from Logistics_Dashboard_Clean_Data
end
 
exec FreightRemarks 

--COUNT Shipments
create procedure count_Shipment
@country varchar(50)
as begin
select count(*) as Total_shipments
from Logistics_Dashboard_Clean_Data
where Export_C
ountry=@country
end

exec count_Shipment 'UAE'