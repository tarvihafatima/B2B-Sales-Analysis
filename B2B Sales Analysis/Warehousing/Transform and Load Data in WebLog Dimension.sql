CREATE OR REPLACE FUNCTION b2btargetdb.sp_transform_and_load_data_in_weblog_dimensions()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
        begin
	        
	            update  b2bstagingdb.weblog_staging
	            set longitude = case when longitude = 'None' then null else longitude end,
	            latitude = case when latitude = 'None' then null else latitude end,
	            country = case when country = 'None' then null else country end,
	            city = case when city = 'None' then null else city end,
	            region = case when region = 'None' then null else region end,
	            street = case when street = 'None' then null else street end,
	            postalcode = case when postalcode = 'None' then null else postalcode end,
	            housenumber = case when housenumber = 'None' then null else housenumber end;
	            
                drop table if exists b2bstagingdb.weblog_temp;
                create table b2bstagingdb.weblog_temp as
	            with sub as 
				(select ClientIP, 
				case when UserName in ('-', 'None') then null else UserName end as UserName, 
				to_timestamp(replace(replace(Time, '[', '') , ']', '') , 'dd/Mon/YYYY:HH24:MI:SS') as Time, 
				case when UserAgent in ('-', 'None') then null else UserAgent end as UserAgent, 
				l.location_key , 
				case when Device in ('-', 'None') then null else Device end as Device
				from b2bstagingdb.weblog_staging w
				left join b2btargetdb.d_location l
				on w.longitude::float = l.longitude
				and w.latitude::float = l.latitude
				)
				select ClientIP, UserName, d.date_dim_id contacted_date_id, t.id contacted_time_id, 
				UserAgent, location_key, Device  from sub s
			    left join b2btargetdb.d_date d 
				on d.date_actual = Time::date
			    left join b2btargetdb.d_time t
			    on t."time"::time = s.Time::time;
			 

                ALTER TABLE b2btargetdb.f_sales_fact drop CONSTRAINT f_sales_fact_weblogid_fkey;


			    INSERT INTO b2btargetdb.d_weblog (ClientIP, UserName, contacted_date_id, contacted_time_id, UserAgent, location_key, Device) 
				SELECT ClientIP, UserName, contacted_date_id, contacted_time_id, UserAgent, location_key, Device from b2bstagingdb.weblog_temp
				ON CONFLICT (ClientIP,UserName,contacted_time_id, contacted_date_id,UserAgent) DO UPDATE 
				  SET location_key = excluded.location_key, 
				      Device = excluded.Device;
		
			    ALTER TABLE b2btargetdb.f_sales_fact ADD CONSTRAINT f_sales_fact_weblogid_fkey FOREIGN KEY (weblogid) REFERENCES b2btargetdb.d_weblog(weblogid);

        END;
$function$
;
