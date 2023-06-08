-- company definition

-- Drop table

-- DROP TABLE company;
create schema b2bstagingdb;
set search_path = 'b2bstagingdb';

CREATE TABLE company (
	cuitnumber bpchar(13) NOT NULL,
	"name" varchar(50) NOT NULL,
	username varchar(100) NOT NULL
);


-- customer definition

-- Drop table

-- DROP TABLE customer;

CREATE TABLE customer (
	documentnumber int4 NOT NULL,
	fullname varchar(50) NOT NULL,
	dateofbirth date NULL
);

-- product definition

-- Drop table

-- DROP TABLE product;

CREATE TABLE product (
	productid int4 NOT NULL,
	productname varchar(50) NOT NULL,
	expirydate date NULL
);

-- supplier definition

-- Drop table

-- DROP TABLE supplier;

CREATE TABLE supplier (
	supplierid int4 NOT NULL,
	cuitnumber bpchar(13) NOT NULL
);


-- companycatalog definition

-- Drop table

-- DROP TABLE companycatalog;

CREATE TABLE companycatalog (
	companyproductid int4 NOT NULL,
	cuitnumber bpchar(13) NOT NULL,
	productid int4 NOT NULL,
	price float8 NOT NULL
);

-- suppliercatalog definition

-- Drop table

-- DROP TABLE suppliercatalog;

CREATE TABLE suppliercatalog (
	supplierproductid int4 NOT NULL,
	supplierid int4 NOT NULL,
	productid int4 NOT NULL,
	price float8 NOT NULL,
	availablequantity int4 NOT NULL
);


-- ordertable definition

-- Drop table

-- DROP TABLE ordertable;

CREATE TABLE ordertable (
	ordernumber int4 NOT NULL,
	orderdatetime timestamp NOT NULL,
	orderstatus int4 NOT NULL,
	expecteddeliverydate date NULL,
	customerid int4 NOT NULL,
	companycuitnumber bpchar(13) NOT NULL
);


-- orderitems definition

-- Drop table

-- DROP TABLE orderitems;

CREATE TABLE orderitems (
	orderitemnumber int4 NOT NULL,
	ordernumber int4 NOT NULL,
	productid int4 NOT NULL,
	supplierid int4 NOT NULL,
	itemquantity int4 NOT NULL
);
