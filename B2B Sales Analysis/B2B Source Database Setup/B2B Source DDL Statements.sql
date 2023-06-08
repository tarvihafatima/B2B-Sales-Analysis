-- -------------------------------------------------- B2B Source Database Entities;

create schema b2bsourcedb;
use b2bsourcedb;

-- company definition

CREATE TABLE `company` (
  `CUITNumber` char(13) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `username` varchar(100) NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`CUITNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- customer definition

CREATE TABLE `customer` (
  `DocumentNumber` int NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `DateOfBirth` date DEFAULT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Address` varchar(100) NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`DocumentNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- product definition

CREATE TABLE `product` (
  `ProductID` int NOT NULL AUTO_INCREMENT,
  `ProductName` varchar(50) NOT NULL,
  `ExpiryDate` date DEFAULT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- supplier definition

CREATE TABLE `supplier` (
  `SupplierID` int NOT NULL AUTO_INCREMENT,
  `CUITNumber` char(13) NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`SupplierID`),
  KEY `CUITNumber` (`CUITNumber`),
  CONSTRAINT `supplier_ibfk_1` FOREIGN KEY (`CUITNumber`) REFERENCES `company` (`CUITNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- companycatalog definition

CREATE TABLE `companycatalog` (
  `CompanyProductID` int NOT NULL AUTO_INCREMENT,
  `CUITNumber` char(13) NOT NULL,
  `ProductID` int NOT NULL,
  `Price` float NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`CompanyProductID`),
  UNIQUE KEY `CUITNumber` (`CUITNumber`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `companycatalog_ibfk_1` FOREIGN KEY (`CUITNumber`) REFERENCES `company` (`CUITNumber`),
  CONSTRAINT `companycatalog_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `product` (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- suppliercatalog definition

CREATE TABLE `suppliercatalog` (
  `SupplierProductID` int NOT NULL AUTO_INCREMENT,
  `SupplierID` int NOT NULL,
  `ProductID` int NOT NULL,
  `Price` float NOT NULL,
  `AvailableQuantity` int NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`SupplierProductID`),
  UNIQUE KEY `SupplierID` (`SupplierID`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `suppliercatalog_ibfk_1` FOREIGN KEY (`SupplierID`) REFERENCES `supplier` (`SupplierID`),
  CONSTRAINT `suppliercatalog_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `product` (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ordertable definition

CREATE TABLE `ordertable` (
  `OrderNumber` int NOT NULL AUTO_INCREMENT,
  `OrderDateTime` timestamp NOT NULL,
  `OrderStatus` int NOT NULL,
  `ExpectedDeliveryDate` date DEFAULT NULL,
  `CustomerID` int NOT NULL,
  `CompanyCUITNumber` char(13) NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`OrderNumber`),
  UNIQUE KEY `OrderDateTime` (`OrderDateTime`,`CustomerID`,`CompanyCUITNumber`),
  KEY `CompanyCUITNumber` (`CompanyCUITNumber`),
  KEY `CustomerID` (`CustomerID`),
  CONSTRAINT `ordertable_ibfk_1` FOREIGN KEY (`CompanyCUITNumber`) REFERENCES `company` (`CUITNumber`),
  CONSTRAINT `ordertable_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`DocumentNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=1251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- orderitems definition

CREATE TABLE `orderitems` (
  `OrderItemNumber` int NOT NULL AUTO_INCREMENT,
  `OrderNumber` int NOT NULL,
  `ProductID` int NOT NULL,
  `SupplierID` int NOT NULL,
  `ItemQuantity` int NOT NULL,
  `Inserted_Date` date DEFAULT NULL,
  `Last_Updated` date DEFAULT NULL,
  PRIMARY KEY (`OrderItemNumber`),
  UNIQUE KEY `OrderNumber` (`OrderNumber`,`ProductID`,`SupplierID`),
  KEY `ProductID` (`ProductID`),
  KEY `SupplierID` (`SupplierID`),
  CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`ProductID`) REFERENCES `product` (`ProductID`),
  CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`SupplierID`) REFERENCES `supplier` (`SupplierID`),
  CONSTRAINT `orderitems_ibfk_3` FOREIGN KEY (`OrderNumber`) REFERENCES `ordertable` (`OrderNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=1584 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
