CREATE OR REPLACE FUNCTION b2btargetdb.sp_transform_and_load_data_in_marketing_lead_dimension()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
        begin

                drop table if exists b2bstagingdb.marketing_temp;
                create table b2bstagingdb.marketing_temp as
	            select d.date_dim_id first_contact_date_id, w.username, w.contact_name, w.city, w.country, w.lead_source, w.status 
				from b2bstagingdb.marketinglead w
				left join b2btargetdb.d_date d
				on d.date_actual = w.first_contact_date::date ;


                ALTER TABLE b2btargetdb.f_sales_fact drop CONSTRAINT  f_sales_fact_marketing_fkey;

			   
			    INSERT INTO b2btargetdb.d_marketinglead (first_contact_date_id, username, contact_name, city, country, lead_source, status) 
				SELECT first_contact_date_id, username, contact_name, city, country, lead_source, status 
				from b2bstagingdb.marketing_temp
				ON CONFLICT (first_contact_date_id, username, lead_source) DO UPDATE 
				  SET contact_name = excluded.contact_name, 
				      city = excluded.city,
				      country = excluded.country, 
				      status = excluded.status;
		
				
			    ALTER TABLE b2btargetdb.f_sales_fact ADD CONSTRAINT f_sales_fact_marketing_fkey FOREIGN KEY (marketingleadid) REFERENCES b2btargetdb.d_marketinglead(marketingleadid);

        END;
$function$
;
