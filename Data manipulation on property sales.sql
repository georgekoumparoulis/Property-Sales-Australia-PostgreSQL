/*
Table creation
*/
create table sales(
	datesold date,
	postocode integer,
	price integer,
	propertytype varchar(20),
	bedrooms integer	
	)
;

/*
Date with the highest number of sales.
*/

select 
	datesold as date, 
	count(datesold) as sold
from 
	sales
group by 
	datesold
order by 
	count(datesold) desc
limit 1
;

/*
Postcode with the highest average price per sale.
*/

select 
	distinct(postcode), 
	round(avg(price) over (partition by postcode),2) as avg_price
from 
	sales
group by 
	postcode, price
order by 
	avg_price desc
limit 1
;

/*
Year with the lowest number of sales.
*/

select 
	extract(year from datesold) as year, 
	count((extract(year from datesold))) as num_of_sales
from 
	sales
group by 
	extract(year from datesold)
order by 
	num_of_sales
limit 1
;

/*
Top six postcodes by year's price.
*/

select 
	year, 
	postcode, 
	price
from(
	select 
		*,
		row_number() over (partition by year order by price desc) as row_num
	from(
		select 
			extract(year from datesold) as year, 
			postcode, 
			price,
			dense_rank() over (partition by extract(year from datesold), postcode order by price desc) as rank
		from 
			sales
		)ranked
	where 
		rank < 2) rowed
where 
	row_num <= 6
;

/*
Average bedrooms, price and price per bedroom respectively by year per postcode
*/

select 
	extract(year from datesold) as year,
	postcode, 
	round(avg(bedrooms),1) as avg_bedrooms,
	round(avg(price),2) as avg_price,
	round(round(avg(price),2)/round(avg(bedrooms),1),2) as avg_price_per_bedroom
from 
	sales
group by postcode, year
order by postcode, year
;

/*
Sales progression by years per postcode
*/

select 
	extract(year from datesold) as year,
	postcode,
	count(datesold) as sales_by_year,
	sum(count(datesold)) over(partition by postcode order by extract(year from datesold)) as running_total_sales,
	row_number() over (partition by postcode) as record_years
from 
	sales
group by postcode, year
order by postcode, year
;