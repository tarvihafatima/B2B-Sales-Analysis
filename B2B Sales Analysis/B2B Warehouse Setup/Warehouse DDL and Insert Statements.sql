-- ------------------------------------------------------- B2B Warehouse Dimensions and Fact
--

create schema b2btargetdb;

SET search_path = b2btargetdb;

-- d_time definition

-- Drop table

-- DROP TABLE d_time;

CREATE TABLE d_time
(
id integer NOT NULL,
time time NOT NULL,
hours_24 character(2) NOT NULL,
hours_12 character(2) NOT NULL,
hour_minutes character (2)  NOT NULL,
day_minutes integer NOT NULL,
day_time_name character varying (20) NOT NULL,
day_night character varying (20) NOT NULL,
CONSTRAINT d_time_pk PRIMARY KEY (id)
)
WITH (
OIDS=FALSE
);

COMMENT ON TABLE d_time IS 'Time Dimension';
COMMENT ON COLUMN d_time.id IS 'Time Dimension PK';

insert into  d_time

SELECT  cast(to_char(minute, 'hh24miss') as numeric) id,
to_char(minute, 'hh24:mi:ss')::time AS time,
-- Hour of the day (0 - 23)
to_char(minute, 'hh24') AS hour_24,
-- Hour of the day (0 - 11)
to_char(minute, 'hh12') hour_12,
-- Hour minute (0 - 59)
to_char(minute, 'mi') hour_minutes,
-- Minute of the day (0 - 1439)
extract(hour FROM minute)*60 + extract(minute FROM minute) day_minutes,
-- Names of day periods
case when to_char(minute, 'hh24:mi') BETWEEN '00:00' AND '11:59'
then 'AM'
when to_char(minute, 'hh24:mi') BETWEEN '12:00' AND '23:59'
then 'PM'
end AS day_time_name,
-- Indicator of day or night
case when to_char(minute, 'hh24:mi') BETWEEN '07:00' AND '19:59' then 'Day'
else 'Night'
end AS day_night
FROM (SELECT '0:00'::time + (sequence.minute || ' minutes')::interval AS minute
FROM generate_series(0,1439) AS sequence(minute)
GROUP BY sequence.minute
) DQ
ORDER BY 1;

CREATE INDEX ix_d_time_actual
  ON d_time(time);

-- d_date definition

-- Drop table

-- DROP TABLE d_date;

DROP TABLE if exists d_date;

CREATE TABLE d_date
(
  date_dim_id              INT NOT NULL,
  date_actual              DATE NOT NULL,
  epoch                    BIGINT NOT NULL,
  day_suffix               VARCHAR(4) NOT NULL,
  day_name                 VARCHAR(9) NOT NULL,
  day_of_week              INT NOT NULL,
  day_of_month             INT NOT NULL,
  day_of_quarter           INT NOT NULL,
  day_of_year              INT NOT NULL,
  week_of_month            INT NOT NULL,
  week_of_year             INT NOT NULL,
  week_of_year_iso         CHAR(10) NOT NULL,
  month_actual             INT NOT NULL,
  month_name               VARCHAR(9) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  quarter_actual           INT NOT NULL,
  quarter_name             VARCHAR(9) NOT NULL,
  year_actual              INT NOT NULL,
  first_day_of_week        DATE NOT NULL,
  last_day_of_week         DATE NOT NULL,
  first_day_of_month       DATE NOT NULL,
  last_day_of_month        DATE NOT NULL,
  first_day_of_quarter     DATE NOT NULL,
  last_day_of_quarter      DATE NOT NULL,
  first_day_of_year        DATE NOT NULL,
  last_day_of_year         DATE NOT NULL,
  mmyyyy                   CHAR(6) NOT NULL,
  mmddyyyy                 CHAR(10) NOT NULL,
  weekend_indr             BOOLEAN NOT NULL
);

ALTER TABLE d_date ADD CONSTRAINT d_date_date_dim_id_pk PRIMARY KEY (date_dim_id);

CREATE INDEX d_date_actual_idx
  ON d_date(date_actual);

COMMIT;

INSERT INTO d_date
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
       datum AS date_actual,
       EXTRACT(EPOCH FROM datum) AS epoch,
       TO_CHAR(datum, 'fmDDth') AS day_suffix,
       TO_CHAR(datum, 'TMDay') AS day_name,
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       EXTRACT(DAY FROM datum) AS day_of_month,
       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW-') || EXTRACT(ISODOW FROM datum) AS week_of_year_iso,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_actual,
       CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
           END AS quarter_name,
       EXTRACT(YEAR FROM datum) AS year_actual,
       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
       TO_CHAR(datum, 'mmyyyy') AS mmyyyy,
       TO_CHAR(datum, 'mmddyyyy') AS mmddyyyy,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS weekend_indr
FROM (SELECT '1970-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

COMMIT;

-- d_location definition

-- Drop table

-- DROP TABLE d_location;

CREATE TABLE d_location (
	location_key serial NOT NULL,
	longitude float8 NULL,
	latitude float8 NULL,
	housenumber varchar(50) NULL,
	street varchar(100) NULL,
	city varchar(100) NULL,
	region varchar(100) NULL,
	postalcode varchar(50) NULL,
	country varchar(100) NULL,
	CONSTRAINT d_location_pkey PRIMARY KEY (location_key)
);

CREATE INDEX ix_location_longitude ON d_location (longitude);
CREATE INDEX ix_location_latitude ON d_location (latitude);

-- d_company definition

-- Drop table

-- DROP TABLE d_company;

CREATE TABLE d_company (
	cuitnumber bpchar(13) NOT NULL,
	"name" varchar(50) NOT NULL,
	username varchar(100) NOT NULL,
	CONSTRAINT company_pkey PRIMARY KEY (cuitnumber)
);

CREATE INDEX ix_company_username ON d_company (username);

-- d_customer definition

-- Drop table

-- DROP TABLE d_customer;

CREATE TABLE d_customer (
	documentnumber int4 NOT NULL,
	fullname varchar(50) NOT NULL,
	dateofbirth_date_id int4 NULL,
	CONSTRAINT customer_pkey PRIMARY KEY (documentnumber)
);

-- d_customer foreign keys

ALTER TABLE d_customer ADD CONSTRAINT fk_cust_dim FOREIGN KEY (dateofbirth_date_id) REFERENCES d_date(date_dim_id);


-- d_product definition

-- Drop table

-- DROP TABLE d_product;

CREATE TABLE d_product (
	productid int4 NOT NULL,
	productname varchar(50) NOT NULL,
	expirydate_date_id int4 NULL,
	CONSTRAINT product_pkey PRIMARY KEY (productid)
);

-- d_product foreign keys

ALTER TABLE d_product ADD CONSTRAINT fk_prod_dim FOREIGN KEY (expirydate_date_id) REFERENCES d_date(date_dim_id);


-- d_supplier definition

-- Drop table

-- DROP TABLE d_supplier;

CREATE TABLE d_supplier (
	supplierid int4 NOT NULL,
	cuitnumber bpchar(13) NOT NULL,
	CONSTRAINT supplier_pkey PRIMARY KEY (supplierid)
);

-- d_supplier foreign keys

ALTER TABLE d_supplier ADD CONSTRAINT supplier_cuitnumber_fkey2 FOREIGN KEY (cuitnumber) REFERENCES d_company(cuitnumber);
CREATE INDEX ix_supplier_cuitnumber ON d_supplier (cuitnumber);

-- d_marketinglead definition

-- Drop table

-- DROP TABLE d_marketinglead;

CREATE TABLE d_marketinglead (
	marketingleadid serial NOT NULL,
	first_contact_date_id int4 NULL,
	username varchar(50) NULL,
	contact_name varchar(50) NULL,
	city varchar(50) NULL,
	country varchar(50) NULL,
	lead_source varchar(50) NULL,
	status varchar(50) NULL,
	CONSTRAINT d_marketinglead_first_contact_date_id_username_lead_source_key UNIQUE (first_contact_date_id, username, lead_source),
	CONSTRAINT d_marketinglead_pkey PRIMARY KEY (marketingleadid)
);

ALTER TABLE d_marketinglead ADD CONSTRAINT fk_date_marketinglead FOREIGN KEY (first_contact_date_id) REFERENCES d_date(date_dim_id);

CREATE INDEX ix_marketinglead_username ON d_marketinglead (username);
CREATE INDEX ix_marketinglead_user_date ON d_marketinglead (username, first_contact_date_id);

-- d_weblog definition

-- Drop table

-- DROP TABLE d_weblog;

CREATE TABLE d_weblog (
	weblogid SERIAL,
	clientip varchar(15) NOT NULL,
	username varchar(50) NULL,
	useragent varchar(200) NOT NULL,
	location_key int4 NULL,
	device varchar(10) NULL,
	contacted_time_id int4 NULL,
	contacted_date_id int4 NULL,
	CONSTRAINT weblog_clientip_username_contacted_time_id_contacted_date_i_key UNIQUE (clientip, username, contacted_time_id, contacted_date_id, useragent),
	CONSTRAINT weblog_pkey PRIMARY KEY (weblogid)
);

-- d_weblog foreign keys

ALTER TABLE d_weblog ADD CONSTRAINT fk_date_weblog FOREIGN KEY (contacted_date_id) REFERENCES d_date(date_dim_id);
ALTER TABLE d_weblog ADD CONSTRAINT fk_time_weblog2 FOREIGN KEY (contacted_time_id) REFERENCES d_time(id);
ALTER TABLE d_weblog ADD CONSTRAINT weblog_location_key_fkey FOREIGN KEY (location_key) REFERENCES d_location(location_key);

CREATE INDEX ix_weblog_username ON d_weblog (username);
CREATE INDEX ix_weblog_user_date_time ON d_weblog (username, contacted_date_id, contacted_time_id);

-- f_sales_fact definition

-- Drop table

-- DROP TABLE f_sales_fact;

CREATE TABLE f_sales_fact (
	ordernumber int4 NOT NULL,
	productid int4 NOT NULL,
	customerid int4 NOT NULL,
	companycuitnumber bpchar(13) NOT NULL,
	supplierid int4 NOT NULL,
	orderdatekey int4 NULL,
	ordertimekey int4 NULL,
	weblogid int4 NULL,
	userlocationid int4 NULL,
	userlogintimekey int4 NULL,
	userlogindatekey int4 NULL,
	orderstatus int4 NULL,
	itemquantity int4 NULL,
	itemsaleprice float8 NULL,
	itemcostprice float8 NULL,
	marketingleadid int4 NULL,
	CONSTRAINT f_sales_fact_pkey PRIMARY KEY (ordernumber, companycuitnumber, productid, supplierid, customerid)
);


-- f_sales_fact foreign keys

ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_companycuitnumber_fkey FOREIGN KEY (companycuitnumber) REFERENCES d_company(cuitnumber);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_customerid_fkey FOREIGN KEY (customerid) REFERENCES d_customer(documentnumber);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_marketing_fkey FOREIGN KEY (marketingleadid) REFERENCES d_marketinglead(marketingleadid);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_orderdatekey_fkey FOREIGN KEY (orderdatekey) REFERENCES d_date(date_dim_id);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_ordertimekey_fkey FOREIGN KEY (ordertimekey) REFERENCES d_time(id);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_productid_fkey FOREIGN KEY (productid) REFERENCES d_product(productid);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_supplierid_fkey FOREIGN KEY (supplierid) REFERENCES d_supplier(supplierid);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_userlocationid_fkey FOREIGN KEY (userlocationid) REFERENCES d_location(location_key);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_userlogindatekey_fkey FOREIGN KEY (userlogindatekey) REFERENCES d_date(date_dim_id);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_userlogintimekey_fkey FOREIGN KEY (userlogintimekey) REFERENCES d_time(id);
ALTER TABLE f_sales_fact ADD CONSTRAINT f_sales_fact_weblogid_fkey FOREIGN KEY (weblogid) REFERENCES d_weblog(weblogid);


-- Logging
create table Job_Stages_Log
(
	process_date date,
	b2b_sourcing_status int,
	weblog_sourcing_status int,
	marketing_lead_sourcing_status int,
	b2b_transformation_status int,
	weblog_transformation_status int,
	bmarketing_lead_transformation_status int,
	fact_table_population_status int,
	primary key (process_date)
)
