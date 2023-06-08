-- ------------------------------------------------ B2B Source Data Population


INSERT INTO company
(CUITNumber, Name, username)
VALUES
('12-1234567890', 'Ezz Peezy', 'ezz_peezy2'),
('23-1234567890', 'Truckee', 'trukee23'),
('34-1234567890', 'Foodzon' , 'foodzon123'),
('45-1234567890', 'Facefood' , 'facefood_123'),
('56-1234567890', 'Ace Hero', 'ace_hero'),
('98-3535367890', 'Metarukk', 'metarukk'),
('61-1236666460', 'Turinglo', 'turinglo99'),
('07-1264666466', 'Foodies', 'foodiez987'),
('12-1235367890', 'Edd Pepzy', 'edd_pepzy2'),
('23-1235367890', 'Truckep', 'tducep23'),
('34-1235367890', 'Eatzon' , 'Eatzon123'),
('45-1235367890', 'FDeEat' , 'fDeEat_123'),
('56-1235367890', 'De Hero', 'De_hero'),
('98-1235367890', 'Metaduck', 'metaduck'),
('61-1235367890', 'Crosslo', 'Crosslo99'),
('07-1235367890', 'Eaties', 'Eatiez987'),
('12-1236546460', 'Food Panda', 'fzz_pffzy2'),
('23-1236546460', 'Alibaba', 'orukff23'),
('34-1236546460', 'Amazon' , 'faadzan123'),
('45-1236546460', 'Facebook' , 'fdccffaad_123'),
('56-1236546460', 'Instagram', 'dccf_hfra'),
('98-1236546460', 'Bagallery', 'afodcrukk'),
('61-1236546460', 'Trendyol', 'ouringla99'),
('07-1236546460', 'Getir', 'faadifz987'),
('12-1234567822', 'Snapchat', 'Snapchat2'),
('23-1234567822', 'Sada Pay', 'sadpay23'),
('34-1234567822', 'Naya Pay' , 'npay123'),
('45-1234567822', 'Retailo' , 'retailo_123'),
('56-1234567822', 'Bazaar', 'bzrr'),
('98-1234567822', 'Taajir', 'tajirrrr'),
('61-1234567822', 'Turing', 'turing99'),
('07-1234567822', 'Eatoyee', 'eoye987'),
('12-1234876823', 'HapsiBurada', 'hepsi_bur2'),
('23-1234876823', 'Eddzon', 'edzee23'),
('34-1234876823', 'Plum' , 'plum123'),
('45-1234876823', 'Postgres' , 'postgres_123'),
('56-1234876823', 'Delivery Hero', 'delivery_hero'),
('98-1234876823', 'Uber', 'uberrr22'),
('61-1234876823', 'Careem', 'careem_876'),
('07-1234876823', 'InDrive', 'indrive234'),
('12-0934276123', 'InDriver', 'InDrivery12'),
('23-0934276123', 'Flow', 'floww23'),
('34-0934276123', 'WayToGo' , 'waytogo123'),
('45-0934276123', 'Alfateh' , 'Alfateh_2234'),
('56-0934276123', 'Centaurus', 'Centaurus23'),
('98-0934276123', 'Bikeaa', 'Bikeaaaa'),
('61-0934276123', 'Upwork', 'upwork99');


INSERT INTO customer
(DocumentNumber, FullName, DateOfBirth, Address, PhoneNumber, Email)
VALUES
(67829993, 'Ahmed Faraz', '1996-08-01', '78-B Gulberg 3, Lahore', '+92-333-481-5734', 'ahmedfaraz@gmail.com'),
(90030023, 'Adil Ahmed', '1992-02-01', '202-R MM Alam, Lahore', '+92-300-786-0001', 'adilahmed764@gmail.com'),
(80034054, 'Furqan Saqib', '1997-04-01', '122-F FRC Road , Karachi', '+92-321-854-2444', 'furqansqib34@gmail.com'),
(24547721, 'Waleed Faraz', '1991-06-01', '9-B Naheed Akhtar Road, Multan', '+92-312-099-6456', 'waleed_faraz@gmail.com'),
(74765433, 'Rizwan Adil', '1985-05-01', '67-B Rehbar Chawk, Faisalabad', '+92-331-345-3454', 'rizwan.adil43@gmail.com'),
(65748393, 'Ahmed Waleed', '1983-05-01', '88-A Ahmadabad Street, Gujranwala', '+92-343-745-9588', 'shwaleed@gmail.com'),
(74763355, 'Faiq Sohail', '1986-03-01', '54-C Tehzeeb Colony, Aimenabad', '+92-302-977-0987', 'sohail3434@gmail.com'),
(09876235, 'Kiran Haider', '1999-02-01', '39-C DHA PHASE 8, Islamabad', '+92-333-567-2454', 'kiranh24@gmail.com');


INSERT INTO customer
(DocumentNumber, FullName, DateOfBirth, Address, PhoneNumber, Email)
SELECT LPAD(FLOOR(RAND() * 999999.99), 8, '0') doc, concat(SUBSTRING_INDEX(FullName, ' ', 1), ' ' ,SUBSTRING_INDEX(TRIM(FullName), ' ', -1)) name, 
concat(concat(FLOOR(RAND()*(2000-1970+1))+1970 , '-', LPAD(FLOOR(RAND()*(12-1+1))+1,2,0)), '-',LPAD(FLOOR(RAND()*(28-1+1))+1,2,0)) dob,
concat(concat(SUBSTRING_INDEX(Address , ' ', 1), ' ' ,SUBSTRING_INDEX(SUBSTRING_INDEX(Address, ' ', 3), ' ', -1)), ' ', SUBSTRING_INDEX(TRIM(Address), ' ', -1)) address,
concat(concat(concat(concat('+9', FLOOR(RAND()*(9-1+1))+1, '-' ), FLOOR(RAND()*(999-1+1))+1, '-'), FLOOR(RAND()*(9999-1+1))+1, '-'), LPAD(FLOOR(RAND()*(999-1+1))+1,3,0)) phoneno,
concat(concat(SUBSTRING_INDEX(FullName, ' ', 1),SUBSTRING_INDEX(TRIM(FullName), ' ', -1), FLOOR(RAND()*(999-1+1))+1), '@gmail.com') email
FROM customer
ORDER BY RAND( ) LIMIT 20;


INSERT INTO supplier (CUITNumber)
SELECT CUITNumber
FROM company ORDER BY RAND( ) LIMIT 20;


INSERT INTO product
(ProductName,  ExpiryDate)
VALUES('3D Spoon', '2023-04-01' ),
('Atf H2 Glass', '2022-02-03'),
('Sonic Wheel Chair', '2024-08-15'),
('Conatural Face Mask','2022-12-01'),
('Remington Straigtener', '2023-01-04'),
('Dell Laptop HD Pro','2025-06-19'),
('Iphone 14 Pro', '2024-04-28'),
('Steel Data Cable', '2022-08-22'),
('Oxygen Exercise Bike', '2023-04-01' ),
('Stello Cup 14', '2022-02-03'),
('Stello Cup 12', '2024-08-15'),
('Stello Cup 11','2022-12-01'),
('Phillips Straigtener', '2023-01-04'),
('HP Laptop HD Pro','2025-06-19'),
('Redmi 11 Pro', '2024-04-28'),
('Samsung 12 HD Pro', '2022-08-22'),
('Stello Cup 11','2022-12-01'),
('Phillips Hair Dryer', '2023-01-04'),
('Auto Hair Brush','2025-06-19'),
('Nestle Milk Pack Large', '2024-04-28'),
('Nestle Milk Pack Sall', '2022-08-22'),
('Adell Cup 9', '2022-02-03'),
('Mayfair Glass 12', '2024-08-15'),
('Mayfair Cup 2','2022-12-01'),
('Cadbury Dairy Milk Pure', '2023-01-04'),
('Nestle Kitkat','2025-06-19'),
('M&Ms', '2024-04-28'),
('Cadbury Dairy Milk Silk', '2022-08-22'),
('Toblerone Dark Chocolate','2022-12-01'),
('Nivea Honey Lotion', '2023-01-04'),
('Nivea Extra Brightness','2025-06-19'),
('Cotton Buds', '2024-04-28'),
('Arteco Wipes', '2022-08-22');


INSERT INTO companycatalog
(CUITNumber, ProductID, Price)
SELECT CUITNumber, ProductID, concat(FLOOR(RAND()*(2000-1+1))+1, '.', LPAD(FLOOR(RAND()*(99-1+1))+1,2,0))
FROM company , product
ORDER BY RAND( ) LIMIT 50;


INSERT INTO suppliercatalog
(SupplierID, ProductID, Price, AvailableQuantity)
SELECT SupplierID, ProductID, concat(FLOOR(RAND()*(2000-1+1))+1, '.', LPAD(FLOOR(RAND()*(99-1+1))+1,2,0)), FLOOR(RAND()*(150-1+1))+1
FROM supplier , product
ORDER BY RAND( ) LIMIT 60;


INSERT INTO ordertable
(OrderDateTime, ExpectedDeliveryDate, CustomerID, OrderStatus, CompanyCUITNumber)
SELECT
concat(concat('2022', '-', LPAD(FLOOR(RAND()*(12-1+1))+1,2,0)), '-',LPAD(FLOOR(RAND()*(28-1+1))+1,2,0)),
concat(concat('2022', '-', LPAD(FLOOR(RAND()*(12-1+1))+1,2,0)), '-',LPAD(FLOOR(RAND()*(28-1+1))+1,2,0)),
DocumentNumber, FLOOR(RAND()*(1-0+1))+0, CUITNumber
FROM customer , company
ORDER BY RAND( ) LIMIT 50;


update ordertable
set ExpectedDeliveryDate = date(OrderDateTime)
where ExpectedDeliveryDate < date(OrderDateTime);


INSERT INTO orderitems
(OrderNumber, ProductID, SupplierID, ItemQuantity)
SELECT OrderNumber, ProductID, SupplierID , FLOOR(RAND()*(150-1+1))+1 
FROM ordertable , product, supplier
ORDER BY RAND( ) LIMIT 50;


UPDATE Customer SET Inserted_Date = date_sub(curdate(), interval 1 day) , Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE Company SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE Supplier SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE CompanyCatalog SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE SupplierCatalog SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE Product SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE OrderTable SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;
UPDATE OrderItems SET Inserted_Date = date_sub(curdate(), interval 1 day), Last_Updated= date_sub(curdate(), interval 1 day) ;