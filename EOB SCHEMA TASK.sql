-- CREATE DATABASE carRentals;

USE carRentals;

-- .....................................................
-- 1. Independent parent tables (no FKs needed)
-- ........................................................

CREATE TABLE staffs(
    staffID INT PRIMARY KEY,
    staffFullName VARCHAR(40),
    phoneNumber VARCHAR(15),
    email VARCHAR(40),
    permanentStaff ENUM('BranchManager', 'RentalAgent', 'Mechanic', 'Temporary staff') NOT NULL DEFAULT 'Temporary staff'
);

CREATE TABLE branches (
    branchName VARCHAR(20) PRIMARY KEY,
    branchAddress VARCHAR(40),
    branchPhoneNumber VARCHAR(15)
);

CREATE TABLE vehicleCategory (
    categoryName VARCHAR(20) PRIMARY KEY,   -- ECONOMY, SUV, LUXURY, VAN
    dailyRate DECIMAL(5,2),
    seatingCapacity INT
);

-- ......................................................
-- 2. Tables that depend on the above
-- ........................................................

CREATE TABLE customers(
    customerID INT PRIMARY KEY AUTO_INCREMENT,
    fullName VARCHAR(40),
    driverLicenseNumber VARCHAR(15),
    phoneNumber VARCHAR(15),
    email VARCHAR(40),
    preferredBranch VARCHAR(20),
    FOREIGN KEY (preferredBranch) REFERENCES branches(branchName)
);

CREATE TABLE vehicles (
    licencePlate VARCHAR(15) PRIMARY KEY,
    categoryName VARCHAR(20) NOT NULL,
    baseBranch VARCHAR(20) NOT NULL,
    FOREIGN KEY (categoryName) REFERENCES vehicleCategory(categoryName),
    FOREIGN KEY (baseBranch) REFERENCES branches(branchName)
);


-- .....................................................
-- 3. Rental records (depends on customers, vehicles, branches)
-- ........................................................

CREATE TABLE rentalRecords (
    rentalID INT PRIMARY KEY AUTO_INCREMENT,
    customerID INT NOT NULL,
    licencePlate VARCHAR(15) NOT NULL,
    pickupDate DATE NOT NULL,
    pickupBranch VARCHAR(20) NOT NULL,
    plannedReturnDate DATE NOT NULL,
    actualReturnDate DATE,
    returnBranch VARCHAR(20),
    status ENUM('reserved', 'active', 'completed', 'cancelled') NOT NULL DEFAULT 'reserved',
    FOREIGN KEY (customerID) REFERENCES customers(customerID),
    FOREIGN KEY (licencePlate) REFERENCES vehicles(licencePlate),
    FOREIGN KEY (pickupBranch) REFERENCES branches(branchName),
    FOREIGN KEY (returnBranch) REFERENCES branches(branchName)
);

-- .......................................................
-- 4. Maintenance records (depends on vehicles, staffs)
-- ..........................................................

CREATE TABLE maintenanceRecord(
    maintenanceID INT PRIMARY KEY AUTO_INCREMENT,
    licencePlate VARCHAR(15) NOT NULL,
    serviceDate DATE,
    maintenanceDiscription VARCHAR(100),
    staff_mechanic INT NOT NULL,
    cost DECIMAL(6,2),
    FOREIGN KEY (licencePlate) REFERENCES vehicles(licencePlate),
    FOREIGN KEY (staff_mechanic) REFERENCES staffs(staffID)
);

-- .........................................................
-- 5. Damage / condition check (depends on rentalRecords)
-- .............................................................

CREATE TABLE damageFound(
    damageID INT PRIMARY KEY AUTO_INCREMENT,
    rentalID INT NOT NULL,
    damageFound VARCHAR(50),
    damageDescription VARCHAR(100),
    additionalCharges DECIMAL(6,2) DEFAULT 0,
    FOREIGN KEY (rentalID) REFERENCES rentalRecords(rentalID)
);