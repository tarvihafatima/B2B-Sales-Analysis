CREATE OR REPLACE FUNCTION b2btargetdb.s_update_fact_table()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
        begin

	        drop table if exists  b2bstagingdb.sales_temp;
	        create table  b2bstagingdb.sales_temp as
	        with weblog_temp as 
			(
				select username, to_timestamp(replace(replace(b.Time, '[', '') , ']', '') , 'dd/Mon/YYYY:HH24:MI:SS') web_time,
				longitude, latitude, ClientIP, UserAgent 
				from b2bstagingdb.weblog_staging b
			),
			sub as
			(
				SELECT web_time, b.username, longitude, latitude, ClientIP, UserAgent, 
				lag (b.web_time) over (partition by p.username order by b.web_time) as prev_time
				from weblog_temp b
				left join b2bstagingdb.company p
				on b.username = p.username
				left join b2bstagingdb.ordertable o 
				on o.companycuitnumber = p.cuitnumber 
				and o.orderdatetime >= web_time
			),
			sub2 as
			(
				SELECT b.first_contact_date, b.username, b.contact_name, b.city,b.country, b.lead_source, b.status,
				lag (b.first_contact_date) over (partition by p.username order by b.first_contact_date) as prev_time
				from b2bstagingdb.marketinglead b
				left join b2bstagingdb.company p
				on b.username = p.username
				left join b2bstagingdb.ordertable o 
				on o.companycuitnumber = p.cuitnumber 
				and o.orderdatetime >= b.first_contact_date::date
			),
			distinct_web_time as 
			(
				select b.username, web_time, l.location_key, w.weblogid, w.contacted_time_id UserLoginTimeKey, w.contacted_date_id UserLoginDateKey 
				from b2bstagingdb.company b 
				left join sub
				on b.username= sub.username
				and prev_time is null 
				left join b2btargetdb.d_location l
				on sub.longitude::float = l.longitude
				and sub.latitude::float = l.latitude
				left join b2btargetdb.d_date d 
				on d.date_actual = web_time::date
			    left join b2btargetdb.d_time t
			    on t."time"::time = web_time::time
				left join b2btargetdb.d_weblog w
				on w.clientip = sub.clientip
				and w.username = sub.username
				and w.useragent = sub.useragent
				and w.contacted_time_id = t.id 
				and w.contacted_date_id = d.date_dim_id 
            ),
			distinct_marketing_user as 
			(
				select b.username, first_contact_date, w.marketingleadid,  w.first_contact_date_id
				from b2bstagingdb.company b 
				left join sub2
				on b.username= sub2.username
				and prev_time is null 
				left join b2btargetdb.d_date d 
				on d.date_actual = first_contact_date::date
				left join b2btargetdb.d_marketinglead w
				on  w.first_contact_date_id= d.date_dim_id
				and w.username = sub2.username
				and w.lead_source = sub2.lead_source
            )
	        
	        SELECT ord.ordernumber, d.date_dim_id OrderDateKey, t.id OrderTimeKey, ord.customerid, oit.productid, ord.companycuitnumber, 
	               oit.supplierid, ord.orderstatus, oit.itemquantity, ccat.price as ItemCostPrice, scat.price as ItemSalePrice,
	               web.weblogid, web.location_key as UserLocationID, UserLoginDateKey, UserLoginTimeKey, ml.marketingleadid 
	        from b2bstagingdb.orderitems oit
	        left join b2bstagingdb.ordertable ord
	        on oit.ordernumber = ord.ordernumber 
	        left join b2btargetdb.d_date d 
	        on ord.orderdatetime::date = d.date_actual 
	        left join b2btargetdb.d_time t 
	        on t."time" = ord.orderdatetime::time
	        left join b2bstagingdb.companycatalog ccat 
	        on ccat.cuitnumber = ord.companycuitnumber 
	        and ccat.productid = oit.productid 
	        left join b2bstagingdb.suppliercatalog scat 
	        on scat.supplierid = oit.supplierid 
	        and scat.productid = oit.productid
	        left join b2bstagingdb.company comp
	        on comp.cuitnumber = ord.companycuitnumber
	        left join distinct_web_time web
	        on web.username = comp.username
	        left join distinct_marketing_user ml
	        on ml.username = comp.username ;



            INSERT INTO b2btargetdb.f_sales_fact (ordernumber, productid, customerid, companycuitnumber, supplierid, orderdatekey, ordertimekey, 
	        weblogid, UserLocationID, orderstatus, itemquantity, itemsaleprice, itemcostprice, UserLoginDateKey, UserLoginTimeKey, marketingleadid)
	        SELECT ordernumber, productid, customerid, companycuitnumber, supplierid, orderdatekey, ordertimekey, weblogid, UserLocationID, orderstatus, itemquantity, itemsaleprice, itemcostprice, UserLoginDateKey, UserLoginTimeKey,marketingleadid
            FROM b2bstagingdb.sales_temp
            ON CONFLICT (ordernumber,productid,customerid, companycuitnumber,supplierid) DO UPDATE 
				  SET orderdatekey = excluded.orderdatekey, 
				      ordertimekey = excluded.ordertimekey,
				      weblogid = excluded.weblogid, 
				      UserLocationID = excluded.UserLocationID,
				      orderstatus = excluded.orderstatus, 
				      itemquantity = excluded.itemquantity, 
				      itemsaleprice = excluded.itemsaleprice,
				      itemcostprice = excluded.itemcostprice, 
				      UserLoginDateKey = excluded.UserLoginDateKey,
				      UserLoginTimeKey = excluded.UserLoginTimeKey, 
				      marketingleadid = excluded.marketingleadid;
				      
				     
        END;
$function$
;
