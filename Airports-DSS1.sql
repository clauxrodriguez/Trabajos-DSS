CREATE DATABASE airports1; 
use airports1; 

--DROP DATABASE airports1;


CREATE TABLE Customer (
    customerID INT NOT NULL PRIMARY KEY,
    nname VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL
);

CREATE TABLE Document (
    documentID INT NOT NULL PRIMARY KEY,
	nacionality VARCHAR(30) NOT NULL,
    expiration_date DATE NOT NULL,
	id_customer INT NOT NULL,
	FOREIGN KEY (id_customer) REFERENCES Customer(customerID)
);

CREATE TABLE FrequentFlyerCard (
    fcc_number VARCHAR(20) PRIMARY KEY NOT NULL,
    miles INT NOT NULL,
    meal_code VARCHAR(10) NOT NULL,
	id_customer int not null,
    foreign key(id_customer) references Customer(customerID)
);

CREATE TABLE FlightClass (
	classID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);

CREATE TABLE Ticket (
	ticketing_code VARCHAR(20) PRIMARY KEY NOT NULL,
    ticket_number VARCHAR(20) NOT NULL,
	id_class INT NOT NULL,
	FOREIGN KEY (id_class) REFERENCES FlightClass(classID),
    id_customer INT NOT NULL,
    FOREIGN KEY (id_customer) REFERENCES Customer(customerID)
);

CREATE TABLE PlaneModel (
    modelID INT PRIMARY KEY NOT NULL,
    ddescription VARCHAR(255),
    graphic VARBINARY(MAX) ,
);

CREATE TABLE Seat (
    seatID INT PRIMARY KEY NOT NULL,
    size VARCHAR(10) NOT NULL,
    number VARCHAR(10) NOT NULL,
    llocation VARCHAR(50) NOT NULL,
    id_model INT NOT NULL,
    FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
);

CREATE TABLE Airplane (
    registration_number VARCHAR(20) PRIMARY KEY NOT NULL,
    begin_of_operation DATE NOT NULL,
    sstatus VARCHAR(20) NOT NULL,
	id_model INT NOT NULL , 
	FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
);

CREATE TABLE Country (
	countryID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);

CREATE TABLE City (
	cityID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);


CREATE TABLE Airport (
    airportID INT PRIMARY KEY NOT NULL,
    nname VARCHAR(100) NOT NULL,
	id_city INT NOT NULL,
	FOREIGN KEY (id_city) REFERENCES City(cityID),
	id_country INT NOT NULL,
	FOREIGN KEY (id_country) REFERENCES Country(countryID)
);


CREATE TABLE FlightNumber(
	flightNumberID VARCHAR(20)PRIMARY KEY NOT NULL, 
	departure_time DATETIME NOT NULL,
	ddescription VARCHAR(255),
	ttype VARCHAR(50) NOT NULL,
	airline VARCHAR(100) NOT NULL,
	start_airportID INT NOT NULL,
    goal_airportID INT NOT NULL,
    FOREIGN KEY (start_airportID) REFERENCES Airport(airportID),
    FOREIGN KEY (goal_airportID) REFERENCES Airport(airportID),
	id_model INT NOT NULL, 
	FOREIGN KEY (id_model) REFERENCES PlaneModel(modelID)
); 


/*CREATE TABLE FlightCategory (
	categoryID INT PRIMARY KEY NOT NULL,
	nname VARCHAR(30) NOT NULL
);*/

CREATE TABLE Flight (
    flightID VARCHAR(20) PRIMARY KEY NOT NULL,
    boarding_time TIME NOT NULL,          -- Hora de embarque, tipo TIME
    flight_date DATE NOT NULL,            -- Fecha del vuelo, tipo DATE
    gate VARCHAR(10) NOT NULL,            -- Puerta de embarque, tipo VARCHAR (hasta 10 caracteres)
	/*id_categoria INT,
	FOREIGN KEY (id_categoria) REFERENCES FlightCategory(categoryID),*/
    check_in_counter VARCHAR(10) NOT NULL,-- Mostrador de check-in, tipo VARCHAR (hasta 10 caracteres)
	id_flightNumber VARCHAR(20) NOT NULL,
	FOREIGN KEY (id_flightNumber) REFERENCES FlightNumber(flightNumberID)
);


CREATE TABLE Coupon (
    couponID INT PRIMARY KEY NOT NULL ,
    date_of_redemption DATE NOT NULL,
    class VARCHAR(20) NOT NULL,
    stand_by BIT NOT NULL,
    meal_code VARCHAR(10) NOT NULL,
    ticket_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (ticket_number) REFERENCES Ticket(ticketing_code),
	 id_flight VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_flight) REFERENCES Flight(flightID),
);

CREATE TABLE PiecesOfLuggage (
    luggageID INT PRIMARY KEY NOT NULL,
    number INT NOT NULL,
    wweight DECIMAL(5,2) NOT NULL,
    id_coupon INT NOT NULL,
    FOREIGN KEY (id_coupon) REFERENCES Coupon(couponID)
);


CREATE TABLE AvailableSeat (
    availableSeatID INT PRIMARY KEY NOT NULL,
    id_flight VARCHAR(20) NOT NULL,
    id_seat INT NOT NULL,
    FOREIGN KEY (id_flight) REFERENCES Flight(flightID),
    FOREIGN KEY (id_seat) REFERENCES Seat(seatID),
	id_coupon INT NOT NULL,
    FOREIGN KEY (id_coupon) REFERENCES Coupon(couponID)
);



--INSERTAR DATOS---------------------------------------------------------------------

INSERT INTO Customer (customerID, nname, date_of_birth) VALUES
	(1, 'John Rojas', '1985-07-14'),
	(2, 'Jane Smith', '1990-03-22'),
	(3, 'Carlos Santana', '1995-10-22'),
	(4, 'Mario Perez', '2001-11-20'),
	(5, 'Patricia Cortez', '1960-09-05'),
	(6, 'Pedro Lanza', '1980-12-13');

INSERT INTO Document (documentID, nacionality, expiration_date, id_customer) VALUES
	(1, 'American', '2026-08-01', 1),
	(2, 'British', '2025-05-15', 2),
	(3, 'Mexican', '2024-11-30', 3),
	(4, 'Bolivian', '2028-05-20', 5),
	(5, 'Mexican', '2026-08-15', 6);

INSERT INTO FrequentFlyerCard (fcc_number, miles, meal_code, id_customer) VALUES
	('FF10001', 15000, 'VGML', 1),
	('FF10002', 25000, 'HNML', 3),
	('FF10003', 30000, 'KSML', 4);

INSERT INTO FlightClass (classID, nname) VALUES
	(1, 'Economy'),
	(2, 'Business'),
	(3, 'First');

INSERT INTO Ticket (ticketing_code, ticket_number, id_class, id_customer) VALUES
	('T123001', 'TK123456', 1, 1),
	('T123002', 'TK987654', 2, 2),
	('T123003', 'TK112233', 3, 3),
	('T123004', 'TK987654', 1, 4),
	('T123005', 'TK987654', 3, 5),
	('T123006', 'TK987654', 2, 6);

INSERT INTO PlaneModel (modelID, ddescription) VALUES
	(1, 'Boeing 737'),
	(2, 'Airbus A320'),
	(3, 'Boeing 777');

INSERT INTO Seat (seatID, size, number, llocation, id_model) VALUES
	(1, 'Standard', '12A', 'Window', 1),
	(2, 'Standard', '12B', 'Middle', 1),
	(3, 'Standard', '12C', 'Aisle', 1),
	(4, 'Premium', '1A', 'Window', 2),
	(5, 'Premium', '1B', 'Aisle', 2),
	(6, 'Luxury', '1F', 'Window', 3);

INSERT INTO Airplane (registration_number, begin_of_operation, sstatus, id_model) VALUES
	('B737-123', '2018-05-01', 'Active', 1),
	('A320-456', '2020-06-15', 'Active', 2),
	('B777-789', '2019-11-20', 'Under Maintenance', 3);

INSERT INTO Country (countryID, nname) VALUES
	(1, 'USA'),
	(2, 'UK'),
	(3, 'Mexico'),
	(4, 'Bolivia');

INSERT INTO City (cityID, nname) VALUES
	(1, 'New York'),
	(2, 'Los Angeles'),
	(3, 'London'),
	(4, 'Santa Cruz'),
	(5, 'Cochabamba');

INSERT INTO Airport (airportID, nname, id_city, id_country) VALUES
	(1, 'John F. Kennedy International Airport', 1, 1),
	(2, 'Los Angeles International Airport', 2, 1),
	(3, 'Heathrow Airport', 3, 2),
	(4, 'Viru Viru', 4, 4),
	(5, 'Internacional Jorge Wilstermann', 5, 4);


INSERT INTO FlightNumber (flightNumberID, departure_time, ddescription, ttype, airline, start_airportID, goal_airportID, id_model) VALUES
	('AA100', '2024-09-01 08:00:00', 'Morning flight from JFK to LAX', 'Domestic', 'American Airlines', 1, 2, 1),
	('BA200', '2024-09-05 10:00:00', 'Transatlantic flight from LAX to LHR', 'International', 'British Airways', 2, 3, 3),
	('CA300', '2024-09-02 07:00:00', 'Morning flight from SC to CBBA', 'Domestic', 'BOA', 4, 5, 3);

INSERT INTO Flight (flightID, boarding_time, flight_date, gate, check_in_counter, id_flightNumber) VALUES
	('F1234', '07:30:00', '2024-09-01', 'G12', 'C5', 'AA100'),
	('F5678', '09:30:00', '2024-09-05', 'G14', 'C7', 'BA200'),
	('F1231', '06:30:00', '2024-09-02', 'A10', 'A1', 'CA300');

INSERT INTO Coupon (couponID, date_of_redemption, class, stand_by, meal_code, ticket_number, id_flight) VALUES
	(1, '2024-09-01', 'Economy', 0, 'VGML', 'T123001', 'F1234'),
	(2, '2024-09-05', 'Business', 0, 'HNML', 'T123002', 'F5678'),
	(3, '2024-09-02', 'Economy', 0, 'SCCL', 'T123004', 'F1231');

INSERT INTO PiecesOfLuggage (luggageID, number, wweight, id_coupon) VALUES
	(1, 2, 23.50, 1),
	(2, 1, 18.00, 2),
	(3, 1, 15.00, 3);

INSERT INTO AvailableSeat (availableSeatID, id_flight, id_seat, id_coupon) VALUES
	(1, 'F1234', 1, 1),
	(2, 'F5678', 4, 2),
	(3, 'F1231', 2, 3);



