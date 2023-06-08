with sub as
	(
		select ordernumber, orderdatekey, orderstatus, itemquantity, itemsaleprice
		from b2btargetdb.f_sales_fact fsf 
		where itemquantity is not null and itemsaleprice  is not null and orderdatekey is not null
	),

lastyeardata as
	(	
		select dd.month_name, dd.mmyyyy, sub.* 
		from  b2btargetdb.d_date dd 
		join sub
		on dd.date_dim_id = sub.orderdatekey
		where dd.year_actual = extract (year from date_trunc('year', current_date) ) --- interval '1 year'
	)

select month_name, round(sum(itemquantity * itemsaleprice)::numeric,3) totalsales
from lastyeardata
where orderstatus=1
group by month_name, mmyyyy
order by mmyyyy;

