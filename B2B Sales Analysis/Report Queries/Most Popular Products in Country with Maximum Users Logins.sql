with sub as 
	(
		select dw.location_key, username , country
		from d_weblog dw
		left join d_location dl 
		on dw.location_key = dl.location_key 
		where country is not null and username is not null and dw.location_key is not null
	),

CountrywithUserLogins as 
	(
		select country, count(distinct username) NumberOfLogins
		from sub
		group by 1
	),

CountrywithUserLoginsRn as
	(
		select country, row_number() over(order by NumberOfLogins desc) rn
		from CountrywithUserLogins
	),

CountryWithMostUserLogins as
	(
		select country
		from CountrywithUserLoginsRn 
		where rn =1
	),

PopularCountryProducts as
	(
		select productid, count(distinct ordernumber) as NumberofOrders
		from f_sales_fact f 
		join d_location dl 
		on dl.location_key = f.userlocationid 
		join CountryWithMostUserLogins c
		on c.country = dl.country 
		group by 1
	),

PopularCountryProductsRn as
	(
		select productid, row_number() over(order by NumberofOrders desc) rn, NumberofOrders
		from PopularCountryProducts
	)

select productname, NumberofOrders
from PopularCountryProductsRn rn
join d_product dp 
on dp.productid = rn.productid
where rn <=5
order by rn;
