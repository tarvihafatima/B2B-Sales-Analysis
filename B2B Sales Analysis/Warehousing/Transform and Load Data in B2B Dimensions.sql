CREATE OR REPLACE FUNCTION b2btargetdb.sp_transform_and_load_data_in_b2b_dimensions()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
        begin
	       
---------------------------- Insertion 
	       
	        -- Insert new records into Company dimension
	        INSERT INTO b2btargetdb.d_company
	        SELECT * FROM b2bstagingdb.company
	        ON CONFLICT (cuitnumber) DO UPDATE 
				  set name =excluded.name,
				  username = excluded.username;

	       	-- Get Date ID from Date for Product Expiry Date
	        drop table if exists  b2bstagingdb.product_temp;
	        create table  b2bstagingdb.product_temp as
	        SELECT c.productid , c.productname, d.date_dim_id expirydate_date_id
	        FROM b2bstagingdb.product c
	        left join b2btargetdb.d_date d
	        on c.expirydate = d.date_actual;
	       	       
	        -- Insert new records into Product dimension
	        INSERT INTO b2btargetdb.d_product 
	        SELECT * FROM b2bstagingdb.product_temp
	        ON CONFLICT (productid) DO UPDATE 
		  	set productname =excluded.productname,
		  	expirydate_date_id = excluded.expirydate_date_id;

	       	-- Get Date ID from Date for Customer Date of Birth
	        drop table if exists  b2bstagingdb.customer_temp;
	        create table  b2bstagingdb.customer_temp as
	        SELECT c.documentnumber , c.fullname, d.date_dim_id dateofbirth_date_id
	        FROM b2bstagingdb.customer c
	        left join b2btargetdb.d_date d
	        on c.dateofbirth = d.date_actual;
	        
	        -- Insert new records into Customer dimension
	        INSERT INTO b2btargetdb.d_customer
	        SELECT * FROM b2bstagingdb.customer_temp
	        ON CONFLICT (documentnumber) DO UPDATE 
		  	set fullname =excluded.fullname,
		  	dateofbirth_date_id= excluded.dateofbirth_date_id;

	        -- Insert new records into Supplier dimension
	        INSERT INTO b2btargetdb.d_supplier 
	        SELECT * FROM b2bstagingdb.supplier
	        ON CONFLICT (supplierid) DO UPDATE 
		  	set cuitnumber =excluded.cuitnumber;
	       

        END;
$function$
;
