Use master
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'airports1')
BEGIN
    ALTER DATABASE [airports1] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [airports1];
END


CREATE DATABASE airports1; 
go
use airports1; 
go
--DROP DATABASE airports1;



CREATE TABLE Customer (
    customerID INT NOT NULL PRIMARY KEY,
    nname VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL
);
go

CREATE INDEX idx_customer_nname ON Customer(nname);--clientes por nombre
GO

CREATE TABLE DocumentType (
    DocumentTypeID INT PRIMARY KEY , -- 10 dígitos
    TypeName VARCHAR(50) NOT NULL -- Hasta 50 caracteres
);
go

CREATE TABLE Document (
    documentID INT NOT NULL PRIMARY KEY,
	id_documentType INT NOT NULL,
	nacionality VARCHAR(30) NOT NULL,
    expiration_date DATE NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES Customer(customerID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	FOREIGN KEY (id_documentType) REFERENCES DocumentType(DocumentTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE INDEX idx_Document_CustomerID ON Document(id_customer);--uniones de busqueda por cliente 
GO

CREATE TABLE FrequentFlyerCard (
    fcc_number VARCHAR(20) PRIMARY KEY NOT NULL,
    miles INT NOT NULL,
    meal_code VARCHAR(10) NOT NULL,
	issue_date DATE NOT NULL,
	expiration_date DATE NOT NULL,
	sstatus CHAR(1) NOT NULL,
	id_customer int not null,
    foreign key(id_customer) references Customer(customerID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go


CREATE TABLE Ticket (
	ticketing_code VARCHAR(20) PRIMARY KEY NOT NULL,
    ticket_number VARCHAR(20) NOT NULL,
    id_customer INT NOT NULL,
    FOREIGN KEY (id_customer) REFERENCES Customer(customerID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go
CREATE INDEX idx_Ticket_CustomerID ON Ticket(id_customer);--tickets por cliente 
GO
CREATE UNIQUE INDEX idx_Ticket_TicketingCode ON Ticket(ticketing_code);--por codigo de ticket
GO

CREATE TABLE PlaneModel (
    modelID INT PRIMARY KEY NOT NULL,
    ddescription VARCHAR(255),
    graphic VARBINARY(MAX) ,
);
go


CREATE TABLE Seat (
    seatID INT PRIMARY KEY NOT NULL,
    size VARCHAR(30) NOT NULL,
    number VARCHAR(10) NOT NULL,
    llocation VARCHAR(50) NOT NULL,
    id_model INT NOT NULL,
    FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE TABLE Airplane (
    registration_number VARCHAR(20) PRIMARY KEY NOT NULL,
    begin_of_operation DATE NOT NULL,
    sstatus VARCHAR(20) NOT NULL,
	id_model INT NOT NULL , 
	FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE TABLE Country (
	countryID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL,

);
go

CREATE TABLE City (
	cityID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL,
	id_country int not null,
	FOREIGN KEY (id_country) REFERENCES Country(countryID)
);
go


CREATE TABLE Airport (
    airportID INT PRIMARY KEY NOT NULL,
    nname VARCHAR(100) NOT NULL,
	id_city INT NOT NULL,
	FOREIGN KEY (id_city) REFERENCES City(cityID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE TABLE FlightCategory (
	categoryID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);
go

CREATE TABLE FlightNumber(
	flightNumberID VARCHAR(20)PRIMARY KEY NOT NULL, 
	departure_time DATETIME NOT NULL,
	ddescription VARCHAR(255),
	id_categoria INT NOT NULL,
	airline VARCHAR(100) NOT NULL,
	start_airportID INT NOT NULL,
    goal_airportID INT NOT NULL,
    FOREIGN KEY (start_airportID) REFERENCES Airport(airportID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
    FOREIGN KEY (goal_airportID) REFERENCES Airport(airportID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION,
	id_model INT NOT NULL, 
	FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION,
	FOREIGN KEY (id_categoria) REFERENCES FlightCategory(categoryID)
); 
go

CREATE INDEX idx_FlightNumber_Airline ON FlightNumber(Airline);--vuelos de aerolinea 
GO
CREATE INDEX idx_FlightNumber_DepartureTime ON FlightNumber(departure_time);--vuelos por hora de salida 
GO

CREATE TABLE Flight (
    flightID VARCHAR(20) PRIMARY KEY NOT NULL,
    boarding_time TIME NOT NULL,          -- Hora de embarque, tipo TIME
    flight_date DATE NOT NULL,            -- Fecha del vuelo, tipo DATE
    gate VARCHAR(10) NOT NULL,            -- Puerta de embarque, tipo VARCHAR (hasta 10 caracteres)
    check_in_counter VARCHAR(10) NOT NULL,-- Mostrador de check-in, tipo VARCHAR (hasta 10 caracteres)
	id_flightNumber VARCHAR(20) NOT NULL,
	FOREIGN KEY (id_flightNumber) REFERENCES FlightNumber(flightNumberID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE TABLE FlightClass (
	classID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);
go


CREATE TABLE Coupon (
    couponID INT PRIMARY KEY NOT NULL ,
    date_of_redemption DATE NOT NULL,
    stand_by BIT NOT NULL,
    meal_code VARCHAR(10) NOT NULL,
    id_ticket VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_ticket) REFERENCES Ticket(ticketing_code)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	 id_flight VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_flight) REFERENCES Flight(flightID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	id_class INT NOT NULL,
	FOREIGN KEY (id_class) REFERENCES FlightClass(classID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

CREATE INDEX idx_Coupon_TicketID ON Coupon(id_ticket);
GO


CREATE TABLE PiecesOfLuggage (
    luggageID INT PRIMARY KEY NOT NULL,
    number INT NOT NULL,
    wweight DECIMAL(5,2) NOT NULL,
    id_coupon INT NOT NULL,
    FOREIGN KEY (id_coupon) REFERENCES Coupon(couponID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);
go

--drop table AvailableSeat;

CREATE TABLE AvailableSeat (
    availableSeatID INT PRIMARY KEY NOT NULL,
    id_flight VARCHAR(20) NOT NULL,
    id_seat INT NOT NULL,
	id_coupon INT NOT NULL,
    FOREIGN KEY (id_coupon) REFERENCES Coupon(couponID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
    FOREIGN KEY (id_flight) REFERENCES Flight(flightID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION,
    FOREIGN KEY (id_seat) REFERENCES Seat(seatID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION
);
go


--INSERCION DE DATOS---------------------------------------------------------------------

-- Población de la tabla Customer
INSERT INTO Customer (customerID, nname, date_of_birth) VALUES
(1, 'John Cortez', '1985-06-15'),
(2, 'Jane Smith', '1990-12-01'),
(3, 'Michael Robles', '1978-03-23'),
(4, 'Emily Sanchez', '1995-09-05'),
(5, 'Sara Perez', '1982-11-19');
GO

-- Población de la tabla DocumentType
INSERT INTO DocumentType (DocumentTypeID, TypeName) VALUES
(1, 'Passport'),
(2, 'Visa'),
(3, 'DNI');
GO

-- Población de la tabla Document
INSERT INTO Document (documentID, id_documentType, nacionality, expiration_date, id_customer) VALUES
(1, 1, 'USA', '2025-06-15', 1),
(2, 2, 'USA', '2023-12-01', 2),
(3, 3, 'USA', '2024-03-23', 3),
(4, 1, 'USA', '2025-09-05', 4),
(5, 3, 'Canada', '2026-11-19', 5);
GO

-- Población de la tabla FrequentFlyerCard
INSERT INTO FrequentFlyerCard (fcc_number, miles, meal_code, issue_date, expiration_date, sstatus, id_customer) VALUES
('FF001', 15000, 'VGML', '2022-01-15', '2025-01-15', 'A', 1),
('FF002', 12000, 'NVML', '2021-11-10', '2024-11-10', 'A', 2),
('FF003', 18000, 'VOML', '2020-08-25', '2023-08-25', 'A', 3),
('FF004', 20000, 'LCML', '2023-04-18', '2026-04-18', 'A', 4),
('FF005', 25000, 'BLML', '2021-06-12', '2024-06-12', 'A', 5);
GO

-- Población de la tabla PlaneModel
INSERT INTO PlaneModel (modelID, ddescription, graphic) VALUES
(1, 'Boeing 737', NULL),
(2, 'Airbus A320', NULL),
(3, 'Boeing 777', NULL),
(4, 'Airbus A350', NULL),
(5, 'Boeing 787', NULL);
GO

-- Población de la tabla Seat
INSERT INTO Seat (seatID, size, number, llocation, id_model) VALUES
(1, 'Standard', '12A', 'Window', 1),
(2, 'Standard', '14B', 'Aisle', 1),
(3, 'Extra Legroom', '10C', 'Window', 2),
(4, 'Standard', '15D', 'Aisle', 3),
(5, 'Business', '2A', 'Window', 4);
GO

-- Población de la tabla Airplane
INSERT INTO Airplane (registration_number, begin_of_operation, sstatus, id_model) VALUES
('N12345', '2015-01-20', 'Active', 1),
('N67890', '2017-03-15', 'Active', 2),
('C98765', '2018-05-10', 'Under Maintenance', 3),
('D54321', '2019-07-25', 'Active', 4),
('E13579', '2020-09-30', 'Retired', 5);
GO

-- Población de la tabla Country
INSERT INTO Country (countryID, nname) VALUES
(1, 'USA'),
(2, 'Canada'),
(3, 'Mexico'),
(4, 'UK'),
(5, 'Germany');
GO

-- Población de la tabla City
INSERT INTO City (cityID, nname, id_country) VALUES
(1, 'New York', 1),
(2, 'Toronto', 2),
(3, 'Mexico City', 3),
(4, 'London', 4),
(5, 'Berlin', 5);
GO

-- Población de la tabla Airport
INSERT INTO Airport (airportID, nname, id_city) VALUES
(1, 'JFK International Airport', 1),
(2, 'Toronto Pearson Airport', 2),
(3, 'Benito Juarez International Airport', 3),
(4, 'Heathrow Airport', 4),
(5, 'Berlin Brandenburg Airport', 5);
GO

-- Población de la tabla FlightCategory
INSERT INTO FlightCategory (categoryID, nname) VALUES
(1, 'Domestic'),
(2, 'International'),
(3, 'Charter'),
(4, 'Cargo'),
(5, 'Private');
GO

-- Población de la tabla FlightNumber
INSERT INTO FlightNumber (flightNumberID, departure_time, ddescription, id_categoria, airline, start_airportID, goal_airportID, id_model) VALUES
('FN001', '2023-09-10 07:30:00', 'Morning Flight', 1, 'Delta', 1, 2, 1),
('FN002', '2023-09-11 09:45:00', 'Noon Flight', 2, 'Air Canada', 2, 3, 2),
('FN003', '2023-09-12 13:20:00', 'Afternoon Flight', 1, 'American Airlines', 3, 4, 3),
('FN004', '2023-09-13 18:15:00', 'Evening Flight', 2, 'British Airways', 4, 5, 4),
('FN005', '2023-09-14 22:00:00', 'Night Flight', 1, 'Lufthansa', 5, 1, 5);
GO

-- Población de la tabla Flight
INSERT INTO Flight (flightID, boarding_time, flight_date, gate, check_in_counter, id_flightNumber) VALUES
('FL001', '06:30:00', '2023-09-10', 'A1', 'C1', 'FN001'),
('FL002', '08:45:00', '2023-09-11', 'B2', 'C2', 'FN002'),
('FL003', '12:20:00', '2023-09-12', 'C3', 'C3', 'FN003'),
('FL004', '17:15:00', '2023-09-13', 'D4', 'C4', 'FN004'),
('FL005', '21:00:00', '2023-09-14', 'E5', 'C5', 'FN005');
GO

-- Población de la tabla FlightClass
INSERT INTO FlightClass (classID, nname) VALUES
(1, 'Economy'),
(2, 'Business'),
(3, 'First Class'),
(4, 'Premium Economy'),
(5, 'Economy Plus');
GO

-- Población de la tabla Ticket
INSERT INTO Ticket (ticketing_code, ticket_number, id_customer) VALUES
('TK001', '1234567890', 1),
('TK002', '0987654321', 2),
('TK003', '1122334455', 3),
('TK004', '5566778899', 4),
('TK005', '6677889900', 5);
GO

-- Población de la tabla Coupon
INSERT INTO Coupon (couponID, date_of_redemption, stand_by, meal_code, id_ticket, id_flight, id_class) VALUES
(1, '2023-09-10', 0, 'VGML', 'TK001', 'FL001', 1),
(2, '2023-09-11', 1, 'NVML', 'TK002', 'FL002', 2),
(3, '2023-09-12', 0, 'VOML', 'TK003', 'FL003', 3),
(4, '2023-09-13', 1, 'LCML', 'TK004', 'FL004', 4),
(5, '2023-09-14', 0, 'BLML', 'TK005', 'FL005', 5);
GO

-- Población de la tabla PiecesOfLuggage
INSERT INTO PiecesOfLuggage (luggageID, number, wweight, id_coupon) VALUES
(1, 2, 15.75, 1),
(2, 1, 10.50, 2),
(3, 3, 23.00, 3),
(4, 2, 18.20, 4),
(5, 1, 12.00, 5);
GO

-- Población de la tabla AvailableSeat
INSERT INTO AvailableSeat (availableSeatID, id_flight, id_seat, id_coupon) VALUES
(1, 'FL001', 1, 1),
(2, 'FL002', 2, 2),
(3, 'FL003', 3, 3),
(4, 'FL004', 4, 4),
(5, 'FL005', 5, 5);
GO





