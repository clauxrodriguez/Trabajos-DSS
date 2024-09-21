--20 DE SEPTIEMBRE - CARGA DE DATOS

Use master
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'soporteF')
BEGIN
    ALTER DATABASE [soporteF] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [soporteF];
END
--Drop database soporteF;
CREATE DATABASE soporteF;
GO

USE soporteF;
GO

-- GENERALIZACION 
IF OBJECT_ID('PaymentMethod','U')IS NOT NULL
DROP TABLE PaymentMethod
GO

CREATE TABLE PaymentMethod (
    MethodID INT PRIMARY KEY IDENTITY ,
	Name NVarchar(30) NOT NULL 
);
GO

IF OBJECT_ID('Cash','U')IS NOT NULL
DROP TABLE Cash
GO

CREATE TABLE Cash (
    CashID INT PRIMARY KEY  ,
	FOREIGN KEY (CashID) REFERENCES PaymentMethod(MethodID)
	ON DELETE CASCADE 
	ON UPDATE CASCADE , 
	Currency NVARCHAR(3) NOT NULL, 
);
GO

IF OBJECT_ID('CreditCard','U')IS NOT NULL
DROP TABLE CreditCard
GO

CREATE TABLE CreditCard (
    CreditCardID INT PRIMARY KEY , 
	FOREIGN KEY (CreditCardID)REFERENCES PaymentMethod(MethodID)
	ON DELETE CASCADE 
	ON UPDATE CASCADE ,
	CardNumber INT NOT NULL, 
	ExpirationDate Date NOT NULL
);
GO

IF OBJECT_ID('QRcode','U')IS NOT NULL
DROP TABLE QRcode
GO

CREATE TABLE QRcode (
    QRcodeID INT PRIMARY KEY , 
	FOREIGN KEY (QRcodeID)REFERENCES PaymentMethod(MethodID)
	ON DELETE CASCADE 
	ON UPDATE CASCADE ,
	QRCodeData NVARCHAR(100) NOT NULL, 
	PlataformName NVARCHAR(50) NOT NULL
	
);
GO

IF OBJECT_ID('Payment','U')IS NOT NULL
DROP TABLE Payment
GO

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY , 
	DDate Date NOT NULL, 
	Amount Float Not NULL,
	MethodID INT NOT NULL, 
	FOREIGN KEY (MethodID)REFERENCES PaymentMethod(MethodID)
);
GO

IF OBJECT_ID('Country','U')IS NOT NULL
DROP TABLE Country
GO

CREATE TABLE Country (
    CountryID INT PRIMARY KEY IDENTITY, 
    Name VARCHAR(100) NOT NULL CHECK (Name != '') -- El nombre del país no debe estar vacío
);
GO


IF OBJECT_ID('DocumentType','U')IS NOT NULL
DROP TABLE DocumentType
GO

CREATE TABLE DocumentType (
    DocumentTypeID INT PRIMARY KEY IDENTITY, 
    TypeName VARCHAR(50) NOT NULL CHECK (TypeName != '') -- El nombre del tipo de documento no debe estar vacío
);
GO
--
IF OBJECT_ID('CustomerType','U')IS NOT NULL
DROP TABLE CustomerType
GO

CREATE TABLE CustomerType (
    CustomerTypeID INT PRIMARY KEY IDENTITY,
    TypeName VARCHAR(50) NOT NULL CHECK (TypeName != ''), -- El nombre del tipo de documento no debe estar vacío
	Description NVARCHAR(100) NOT NULL CHECK (Description != '')
);
GO
---
IF OBJECT_ID('FlightCategory', 'U') IS NOT NULL
    DROP TABLE FlightCategory;
GO

CREATE TABLE FlightCategory (
    FlightCategoryID INT PRIMARY KEY IDENTITY, 
    CategoryName NVARCHAR(50) NOT NULL CHECK (CategoryName != '') -- El nombre de la categoría de vuelo no debe estar vacío
);
GO

IF OBJECT_ID('PlaneModel', 'U') IS NOT NULL
    DROP TABLE PlaneModel;
GO

CREATE TABLE PlaneModel (
    PlaneModelID INT PRIMARY KEY IDENTITY, 
    Description VARCHAR(100) NOT NULL CHECK (Description != ''), -- La descripción no debe estar vacía
    Graphic VARBINARY(MAX),
	SeatingCapacity INT NOT NULL,
);
GO


IF OBJECT_ID('Clase', 'U') IS NOT NULL
    DROP TABLE Clase;
GO

CREATE TABLE Clase (
    ClaseID INT PRIMARY KEY IDENTITY, 
    NombreClase VARCHAR(50) NOT NULL CHECK (NombreClase != ''), -- El nombre de la clase no debe estar vacío
    Price FLOAT NOT NULL
);
GO


IF OBJECT_ID('City', 'U') IS NOT NULL
    DROP TABLE City;
GO
CREATE TABLE City (
    CityID INT PRIMARY KEY IDENTITY, 
    Name NVARCHAR(100) NOT NULL CHECK (Name != ''), -- El nombre de la ciudad no debe estar vacío
    CountryID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)--No action 
);
GO


IF OBJECT_ID('Airport', 'U') IS NOT NULL
    DROP TABLE Airport;
GO

CREATE TABLE Airport (
    IATA_Code VARCHAR(10) PRIMARY KEY, 
    Name NVARCHAR(100) NOT NULL CHECK (Name != ''), -- El nombre del aeropuerto no debe estar vacío
    CityID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (CityID) REFERENCES City(CityID)
	ON DELETE CASCADE 
);
GO

IF OBJECT_ID('Person', 'U') IS NOT NULL
    DROP TABLE Person;
GO
CREATE TABLE Person (
    PersonID INT PRIMARY KEY IDENTITY , 
	Name VARCHAR(60) NOT NULL, 
	phoneNumber INT NOT NULL 
);
GO



IF OBJECT_ID('Customer', 'U') IS NOT NULL
    DROP TABLE Customer;
GO
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY , 
	FOREIGN KEY (CustomerID) REFERENCES Person(PersonID),
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE()), -- La fecha de nacimiento no puede ser en el futuro
    Email NVARCHAR(60) NOT NULL 
);
GO

IF OBJECT_ID('Assignment', 'U') IS NOT NULL
    DROP TABLE Assignment;
GO
CREATE TABLE Assignment (
    AssignmentID INT PRIMARY KEY IDENTITY ,
	AssignmentDate Date NOT NULL,
	CustomerID INT NOT NULL, 
	FOREIGN KEY (CustomerID)REFERENCES Customer(CustomerID), 
	CustomerTypeID INT NOT NULL, 
	FOREIGN KEY (CustomerTypeID)REFERENCES CustomerType(CustomerTypeID)
);
GO

IF OBJECT_ID('Reservation','U') IS NOT NULL
	DROP TABLE Reservation; 
GO

CREATE TABLE Reservation(
    ReservationID INT PRIMARY KEY IDENTITY ,
	Date DATETIME NOT NULL ,
	Status VARCHAR(25) NOT NULL,
	CustomerID int not null, 
	PaymentID INT NOT NULL,
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),--NO ACTION
	FOREIGN KEY (PaymentID)REFERENCES Payment(PaymentID)
)
Go

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Customer_Name' AND object_id = OBJECT_ID('Customer'))
BEGIN
    DROP INDEX idx_Customer_Name ON Customer;
END
GO
-- CREATE INDEX idx_Customer_Name ON Customer(Name); -- Índice para buscar clientes por nombre
-- GO

IF OBJECT_ID('passenger', 'U') IS NOT NULL
    DROP TABLE passenger;
GO

CREATE TABLE passenger (
    PassengerID INT PRIMARY KEY ,
	FOREIGN KEY (passengerID) REFERENCES person(personID)
	ON DELETE CASCADE 
	ON UPDATE CASCADE, 
	SpecialAsistance BIT NOT NULL
);
GO

IF OBJECT_ID('Document', 'U') IS NOT NULL
    DROP TABLE Document;
GO

CREATE TABLE Document (
    DocumentID INT PRIMARY KEY IDENTITY, 
    DocumentTypeID INT, -- Clave foránea
    DocumentNumber VARCHAR(50) NOT NULL CHECK (DocumentNumber != ''), -- El número de documento no debe estar vacío
    IssueDate DATE CHECK (IssueDate <= GETDATE()), -- La fecha de emisión no puede ser en el futuro
    ExpiryDate DATE, -- La fecha de expiración
    IssuingCityID INT NOT NULL, -- Ciudad emisora no debe estar vacía
    passengerID INT, -- Clave foránea
    FOREIGN KEY (DocumentTypeID) REFERENCES DocumentType(DocumentTypeID),
	FOREIGN KEY (IssuingCityID) REFERENCES City(CityID),
    FOREIGN KEY (passengerID) REFERENCES passenger(passengerID)
    ON DELETE SET NULL,
    CONSTRAINT CHK_Document_Dates CHECK (ExpiryDate >= IssueDate OR ExpiryDate IS NULL) -- La fecha de expiración no puede ser anterior a la fecha de emisión, o puede ser NULL
);
GO
-- Verifica y elimina el índice en Document.CustomerID si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Document_CustomerID' AND object_id = OBJECT_ID('Document'))
BEGIN
    DROP INDEX idx_Document_CustomerID ON Document;
END
GO
-- CREATE INDEX idx_Document_CustomerID ON Document(CustomerID); -- Índice en Document.CustomerID
-- GO          

IF OBJECT_ID('Airline', 'U') IS NOT NULL
    DROP TABLE Airline;
GO

CREATE TABLE Airline (
    AirlineID INT PRIMARY KEY IDENTITY, 
	Name VARCHAR(100) NOT NULL,
	FoundedYear DATE NOT NULL,
	Fleet_Size INT NOT NULL,
	CityID INT NOT NULL,
	FOREIGN KEY (CityID) REFERENCES City(CityID),
    );
GO

IF OBJECT_ID('Airplane', 'U') IS NOT NULL
    DROP TABLE Airplane;
GO
CREATE TABLE Airplane (
    AirplaneID INT PRIMARY KEY IDENTITY, 
    RegistrationNumber VARCHAR(50) NOT NULL CHECK (RegistrationNumber != ''), -- El número de registro no debe estar vacío
    BeginOfOperation DATE NOT NULL CHECK (BeginOfOperation <= GETDATE()), -- La fecha de inicio de operación no puede ser en el futuro
    Status VARCHAR(50) NOT NULL CHECK (Status != ''), -- El estado no debe estar vacío
    PlaneModelID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
);
GO


IF OBJECT_ID('FlightNumber', 'U') IS NOT NULL
    DROP TABLE FlightNumber;
GO

CREATE TABLE FlightNumber (
    FlightNumberID INT PRIMARY KEY IDENTITY, 
    DepartureTime DATETIME NOT NULL CHECK (DepartureTime > GETDATE()), -- La hora de salida debe ser en el futuro
    Description VARCHAR(50) NOT NULL CHECK (Description != ''), -- La descripción no debe estar vacía
    StartAirportID VARCHAR(10) NOT NULL, 
    GoalAirportID VARCHAR(10) NOT NULL,
	AirlineID INT NOT NULL, -- La aerolínea no debe estar vacía
    AirplaneID INT NOT NULL,
    FlightCategoryID INT NOT NULL, 
	FOREIGN KEY (AirlineID) REFERENCES Airline(AirlineID),
    FOREIGN KEY (StartAirportID) REFERENCES Airport(IATA_Code),
    FOREIGN KEY (GoalAirportID) REFERENCES Airport(IATA_Code),
    FOREIGN KEY (AirplaneID) REFERENCES Airplane(AirplaneID),
    FOREIGN KEY (FlightCategoryID) REFERENCES FlightCategory(FlightCategoryID),
    FOREIGN KEY (StartAirportID) REFERENCES Airport(IATA_Code),
    FOREIGN KEY (GoalAirportID) REFERENCES Airport(IATA_Code)
);
GO

-- Verifica y elimina el índice en FlightNumber.Airline si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_FlightNumber_Airline' AND object_id = OBJECT_ID('FlightNumber'))
BEGIN
    DROP INDEX idx_FlightNumber_Airline ON FlightNumber;
END
GO

-- Verifica y elimina el índice en FlightNumber.DepartureTime si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_FlightNumber_DepartureTime' AND object_id = OBJECT_ID('FlightNumber'))
BEGIN
    DROP INDEX idx_FlightNumber_DepartureTime ON FlightNumber;
END
GO
CREATE INDEX idx_FlightNumber_DepartureTime ON FlightNumber(DepartureTime); -- Índice en FlightNumber.DepartureTime
GO


IF OBJECT_ID('FrequentFlyerCard', 'U') IS NOT NULL
BEGIN
    DROP TABLE FrequentFlyerCard;
END
GO

CREATE TABLE FrequentFlyerCard (
    FFCNumber INT PRIMARY KEY, 
    Miles INT NOT NULL CHECK (Miles >= 0), -- Los millas no pueden ser negativas
    MealCode VARCHAR(10) NOT NULL CHECK (MealCode != ''), -- El código de la comida no debe estar vacío
    IssueDate DATE CHECK (IssueDate <= GETDATE()), -- La fecha de emisión no puede ser en el futuro
    ExpiryDate DATE NOT NULL,
	CustomerID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);
GO


IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY IDENTITY, 
    TicketingCode VARCHAR(50) NOT NULL CHECK (TicketingCode != ''), -- El código del ticket no debe estar vacío
	Number INT NOT NULL, 
	PurchaseDate Date NOT NULL, 
	TotalImport Float NOT NULL,
	DocumentID INT NOT NULL, 
	ReservationID INT NOT NULL,
	PassengerID INT NOT NULL,
	FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
	FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID),
	FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID)
);
GO

IF OBJECT_ID('CancellationPolicy', 'U') IS NOT NULL
    DROP TABLE CancellationPolicy;
GO

CREATE TABLE CancellationPolicy (
    CPolicyID INT PRIMARY KEY IDENTITY , 
	Descripcion Varchar (100) NOT NULL,
	DaysBeforeFlight INT NOT NULL,
	CancellationFee Float NOT  NULL, 
	TicketID INT NOT NULL, 
	FOREIGN KEY (TicketID)REFERENCES Ticket(TicketID)
);
GO



-- Verifica y elimina el índice en Ticket.CustomerID si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Ticket_CustomerID' AND object_id = OBJECT_ID('Ticket'))
BEGIN
    DROP INDEX idx_Ticket_CustomerID ON Ticket;
END
GO


-- Verifica y elimina el índice único en Ticket.TicketingCode si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Ticket_TicketingCode' AND object_id = OBJECT_ID('Ticket'))
BEGIN
    DROP INDEX idx_Ticket_TicketingCode ON Ticket;
END
GO
CREATE UNIQUE INDEX idx_Ticket_TicketingCode ON Ticket(TicketingCode); -- Índice único en Ticket.TicketingCode
GO


IF OBJECT_ID('Flight', 'U') IS NOT NULL
    DROP TABLE Flight;
GO
CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY, 
    BoardingTime DATETIME NOT NULL CHECK (BoardingTime > GETDATE()), -- La hora de embarque debe ser en el futuro
    FlightDate DATE NOT NULL CHECK (FlightDate >= CONVERT(DATE, GETDATE())), -- La fecha del vuelo no puede ser anterior a la fecha actual
    Gate VARCHAR(50) NOT NULL CHECK (Gate != ''), -- La puerta no debe estar vacía
    CheckInCounter VARCHAR(50) NOT NULL CHECK (CheckInCounter != ''), -- El mostrador de check-in no debe estar vacío
    Status VARCHAR(50) NOT NULL CHECK (Status != ''), 
	FlightNumberID INT NOT NULL, -- Clave foránea
	AirplaneID INT NOT NULL, 
    FOREIGN KEY (FlightNumberID) REFERENCES FlightNumber(FlightNumberID),
	FOREIGN KEY (AirplaneID) REFERENCES Airplane(AirplaneID)
);
GO

IF OBJECT_ID('CrewMember', 'U') IS NOT NULL
    DROP TABLE CrewMember;
GO
CREATE TABLE CrewMember (
    CrewMemberID INT PRIMARY KEY , 
	FOREIGN KEY (CrewMemberID) REFERENCES person(personID)
	ON DELETE CASCADE 
	ON UPDATE CASCADE, 
    Position VARCHAR(40) NOT NULL, 
	EmploymentDate DATE NOT NULL, 
	FlightHours INT NOT NULL
);
GO

IF OBJECT_ID('Crew', 'U') IS NOT NULL
    DROP TABLE Crew;
GO
CREATE TABLE Crew (
    CrewID INT PRIMARY KEY, 
	AssigmentDate DATE NOT NULL,
    ShiftStart DATETIME NOT NULL,
	ShiftEnd DATETIME NOT NULL,
	Status VARCHAR(50) NOT NULL CHECK (Status != ''),
	CrewMemberID INT, 
	FOREIGN KEY (CrewMemberID) REFERENCES CrewMember(CrewMemberID)
);
GO


IF OBJECT_ID('FlightCancelation','U')IS NOT NULL
DROP TABLE FlightCancelation
GO

CREATE TABLE FlightCancelation (
    FCancelationID INT PRIMARY KEY IDENTITY ,
	CancelationDate Date NOT NULL, 
	Reason VARCHAR(100) NOT NULL, 
	FlightID INT NOT NULL, 
	FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
);
GO



IF OBJECT_ID('CompesationType','U')IS NOT NULL
DROP TABLE CompesationType
GO

CREATE TABLE CompesationType (
    CompesationTypeID INT PRIMARY KEY IDENTITY, 
	Name VARCHAR(100) NOT NULL,
	Description Varchar(100) NOT NULL,
	ValueType VARCHAR(50) NOT NULL,
	IsActive BIT NOT NULL,
	ExpirationPolicy DATE NOT NULL,
);
GO

IF OBJECT_ID('Compesation','U')IS NOT NULL
DROP TABLE Compesation
GO

CREATE TABLE Compesation (
    CompesationID INT PRIMARY KEY IDENTITY, 
	Amount Float NOT NULL, 
	Descripcion Varchar(100) NOT NULL, 
	CompensationDate DATE NOT NULL,
	FCancelationID INT NOT NULL, 
	CompesationTypeID INT NOT NULL,
	FOREIGN KEY (FCancelationID) REFERENCES FlightCancelation(FCancelationID),
	FOREIGN KEY (CompesationTypeID) REFERENCES CompesationType(CompesationTypeID)
);
GO


IF OBJECT_ID('CheckIn', 'U') IS NOT NULL
    DROP TABLE CheckIn;
GO

CREATE TABLE CheckIn (
   CheckInID INT PRIMARY KEY IDENTITY, 
   CheckInDateTime DateTime Not null, 
   BoardingGate VARCHAR(25) NOT NULL,
   CheckInStatus VARCHAR(50) NOT NULL CHECK (CheckInStatus != ''),
   TicketID Int Not null, 
   BoardingTime DateTime Not null CHECK (BoardingTime > GETDATE()),
   FOREIGN KEY (TicketID)REFERENCES Ticket(TicketID), 
);
GO

IF OBJECT_ID('Seat', 'U') IS NOT NULL
    DROP TABLE Seat;
GO
CREATE TABLE Seat (
    SeatID INT PRIMARY KEY IDENTITY, 
    Size VARCHAR(50) NOT NULL CHECK (Size != ''), -- El tamaño no debe estar vacío
    Number INT NOT NULL CHECK (Number > 0), -- El número del asiento debe ser positivo
    Location VARCHAR(50) NOT NULL CHECK (Location != ''), -- La ubicación no debe estar vacía
	PlaneModelID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (PlaneModelID) REFERENCES PlaneModel(PlaneModelID)
);
GO

IF OBJECT_ID('AvailableSeat', 'U') IS NOT NULL
    DROP TABLE AvailableSeat;
GO

CREATE TABLE AvailableSeat (
    AvailableSeatID INT PRIMARY KEY IDENTITY, -- 10 dígitos
    FlightID INT NOT NULL, -- Clave foránea
    SeatID INT NOT NULL, -- Clave foránea
	CheckInID INT NOT NULL,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    FOREIGN KEY (SeatID) REFERENCES Seat(SeatID),
	FOREIGN KEY (CheckInID) REFERENCES CheckIn(CheckInID),
);
GO


IF OBJECT_ID('Coupon', 'U') IS NOT NULL
    DROP TABLE Coupon;
GO
CREATE TABLE Coupon (
    CouponID INT PRIMARY KEY IDENTITY, 
    DateOfRedemption DATE NOT NULL CHECK (DateOfRedemption <= GETDATE()), -- La fecha de canje no puede ser en el futuro
    Standby VARCHAR(50) NOT NULL CHECK (Standby != ''), -- El standby no debe estar vacío
    MealCode VARCHAR(50) NOT NULL CHECK (MealCode != ''), -- El código de comida no debe estar vacío
    TicketID INT NOT NULL, -- Clave foránea
    FlightID INT NOT NULL, -- Clave foránea
    ClaseID INT,
    FOREIGN KEY (ClaseID) REFERENCES Clase(ClaseID)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);
GO


-- Verifica y elimina el índice en Coupon.TicketID si ya existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Coupon_TicketID' AND object_id = OBJECT_ID('Coupon'))
BEGIN
    DROP INDEX idx_Coupon_TicketID ON Coupon;
END
GO
CREATE INDEX idx_Coupon_TicketID ON Coupon(TicketID); -- Índice en Coupon.TicketID
GO


CREATE TABLE PiecesOfLuggage (
    LuggageID INT PRIMARY KEY IDENTITY, 
    Number INT NOT NULL CHECK (Number > 0), -- El número del equipaje debe ser positivo
    Weight DECIMAL(5, 2) NOT NULL CHECK (Weight > 0 AND Weight <= 999.99), -- El peso debe ser positivo y no exceder 999.99 kg
    CouponID INT NOT NULL, -- Clave foránea
    FOREIGN KEY (CouponID) REFERENCES Coupon(CouponID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);
GO



---- PRUEBAS 
IF OBJECT_ID('NamePerson','U')IS NOT NULL
DROP TABLE NamePerson
GO

CREATE TABLE NamePerson (
    Name VARCHAR(150), 
);
GO


IF OBJECT_ID('NameCountry','U')IS NOT NULL
DROP TABLE NameCountry
GO

CREATE TABLE NameCountry (
    Name VARCHAR(100), 
);
GO

IF OBJECT_ID('NameCity','U')IS NOT NULL
DROP TABLE NameCity
GO
CREATE TABLE NameCity (
    Name NVARCHAR(100), 
);
GO

IF OBJECT_ID('NameAirport','U')IS NOT NULL
DROP TABLE NameAirport
GO

CREATE TABLE NameAirport (
    Name NVARCHAR(100), 
);
GO


IF OBJECT_ID('NameAirline','U')IS NOT NULL
DROP TABLE NameAirline
GO

CREATE TABLE NameAirline (
    Name VARCHAR(50), 
);
GO


-- DATOS CATEGORIA DE VUELO
INSERT INTO FlightCategory (CategoryName) 
VALUES 
('Domestic'),        -- Vuelos nacionales
('International'),   -- Vuelos internacionales
('Charter'),         -- Vuelos privados o arrendados
('Cargo'),           -- Vuelos de carga
('Military'),        -- Vuelos militares
('VIP');             -- Vuelos VIP o de lujo

GO

-- DATOS MODELO DE AVION
INSERT INTO PlaneModel (Description, Graphic, SeatingCapacity) VALUES
('Airbus A320', CAST('' AS VARBINARY(MAX)), 150),
('Boeing 737', CAST('' AS VARBINARY(MAX)), 180),
('Embraer E195', CAST('' AS VARBINARY(MAX)), 120),
('Airbus A321', CAST('' AS VARBINARY(MAX)), 200),
('Boeing 747', CAST('' AS VARBINARY(MAX)), 400),
('Boeing 777', CAST('' AS VARBINARY(MAX)), 300),
('Airbus A330', CAST('' AS VARBINARY(MAX)), 250),
('Bombardier CRJ900', CAST('' AS VARBINARY(MAX)), 90),
('Boeing 787', CAST('' AS VARBINARY(MAX)), 250),
('Airbus A350', CAST('' AS VARBINARY(MAX)), 300),
('McDonnell Douglas MD-80', CAST('' AS VARBINARY(MAX)), 150),
('Airbus A380', CAST('' AS VARBINARY(MAX)), 500),
('Boeing 717', CAST('' AS VARBINARY(MAX)), 110),
('Airbus A220', CAST('' AS VARBINARY(MAX)), 140),
('Boeing 767', CAST('' AS VARBINARY(MAX)), 200),
('Airbus A310', CAST('' AS VARBINARY(MAX)), 280),
('Fokker 100', CAST('' AS VARBINARY(MAX)), 100),
('Airbus A321neo', CAST('' AS VARBINARY(MAX)), 240),
('Boeing 737 MAX', CAST('' AS VARBINARY(MAX)), 210),
('Airbus A300', CAST('' AS VARBINARY(MAX)), 260),
('Boeing 787 Dreamliner', CAST('' AS VARBINARY(MAX)), 250),
('Airbus A319', CAST('' AS VARBINARY(MAX)), 140),
('Embraer E175', CAST('' AS VARBINARY(MAX)), 88),
('Boeing 737-800', CAST('' AS VARBINARY(MAX)), 162),
('Airbus A330neo', CAST('' AS VARBINARY(MAX)), 260),
('Boeing 757', CAST('' AS VARBINARY(MAX)), 200),
('Airbus A350-1000', CAST('' AS VARBINARY(MAX)), 410),
('Boeing 767-300', CAST('' AS VARBINARY(MAX)), 240),
('Airbus A321XLR', CAST('' AS VARBINARY(MAX)), 220),
('Boeing 737-900', CAST('' AS VARBINARY(MAX)), 180),
('Airbus A220-300', CAST('' AS VARBINARY(MAX)), 160),
('Boeing 737 MAX 10', CAST('' AS VARBINARY(MAX)), 230),
('Airbus A310-300', CAST('' AS VARBINARY(MAX)), 280),
('Boeing 737 MAX 8', CAST('' AS VARBINARY(MAX)), 210),
('Airbus A321LR', CAST('' AS VARBINARY(MAX)), 220),
('Embraer E190', CAST('' AS VARBINARY(MAX)), 100),
('Airbus A300-600', CAST('' AS VARBINARY(MAX)), 250),
('Boeing 737-500', CAST('' AS VARBINARY(MAX)), 132),
('Airbus A310-200', CAST('' AS VARBINARY(MAX)), 280),
('Boeing 757-200', CAST('' AS VARBINARY(MAX)), 200),
('Airbus A380-800', CAST('' AS VARBINARY(MAX)), 550),
('McDonnell Douglas MD-11', CAST('' AS VARBINARY(MAX)), 285),
('Boeing 787-9', CAST('' AS VARBINARY(MAX)), 296),
('Airbus A321-200', CAST('' AS VARBINARY(MAX)), 220),
('Boeing 747-8', CAST('' AS VARBINARY(MAX)), 410),
('Airbus A350-900', CAST('' AS VARBINARY(MAX)), 325),
('Boeing 737-700', CAST('' AS VARBINARY(MAX)), 143),
('Airbus A220-100', CAST('' AS VARBINARY(MAX)), 120),
('Embraer E175-E2', CAST('' AS VARBINARY(MAX)), 80),
('Airbus A319neo', CAST('' AS VARBINARY(MAX)), 160),
('Boeing 737-300', CAST('' AS VARBINARY(MAX)), 148),
('Airbus A321neoLR', CAST('' AS VARBINARY(MAX)), 240),
('Boeing 767-200', CAST('' AS VARBINARY(MAX)), 216),
('Airbus A350-800', CAST('' AS VARBINARY(MAX)), 300),
('Boeing 757-300', CAST('' AS VARBINARY(MAX)), 243),
('Airbus A330-200', CAST('' AS VARBINARY(MAX)), 250);


-- DATOS DE CLASE
INSERT INTO Clase (NombreClase, Price) VALUES 
('Económica', 100.00),
('Ejecutiva', 300.00),
('Primera Clase', 600.00),
('Premium Economy', 200.00),
('Business Class', 400.00);


-- DATOS DE TIPO DE DOCUMENTO
INSERT INTO DocumentType (TypeName) VALUES 
('Pasaporte'),
('Cédula de Identidad'),
('Tarjeta de Residencia'),
('Licencia de Conducir'),
('Documento Nacional de Identidad');

-- DATOS DE TIPO DE CLIENTE
INSERT INTO CustomerType (TypeName, Description) VALUES 
('Regular', 'Clientes que viajan con frecuencia y tienen acceso a tarifas estándar.'),
('VIP', 'Clientes de alto nivel que reciben atención y beneficios especiales.'),
('Estudiante', 'Clientes que viajan como estudiantes, con descuentos especiales.'),
('Niño', 'Clientes que son menores de edad y tienen tarifas reducidas.'),
('Militar', 'Clientes con afiliación militar que reciben tarifas y beneficios especiales.');

--DATOS DE METODO DE PAGO
INSERT INTO PaymentMethod (Name) VALUES 
('Efectivo'),
('Tarjeta de Crédito'),
('Código QR');

-- DATOS DE TIPO DE COMPESACION
INSERT INTO CompesationType (Name, Description, ValueType, IsActive, ExpirationPolicy) VALUES 
('Reembolso', 'Compensación por cancelación de vuelo.', 'Monetaria', 1, '2025-12-31'),
('Bono de Viaje', 'Crédito para futuros vuelos.', 'No Monetaria', 1, '2026-06-30'),
('Compensación por Retraso', 'Compensación por retrasos mayores a 2 horas.', 'Monetaria', 1, '2025-12-31'),
('Asiento Mejorado', 'Mejora de clase en el próximo vuelo.', 'No Monetaria', 1, '2026-12-31'),
('Descuento', 'Descuento en la próxima compra de billete.', 'Monetaria', 1, '2026-11-30');


--Procedimiento que carga datos en Country
CREATE PROCEDURE InsertRandomCountry
    @num_countries INT -- Número de países a insertar
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @name VARCHAR(100);

    WHILE @i <= @num_countries
    BEGIN
        -- Seleccionar un nombre aleatorio de la tabla PaisNombre
        SELECT TOP 1 @name = Name 
        FROM NameCountry 
        ORDER BY NEWID(); -- NEWID() genera un valor único para ordenar aleatoriamente

        -- Insertar el nombre en la tabla Country
        INSERT INTO Country (Name)
        VALUES (@name);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;
GO
EXEC InsertRandomCountry @num_countries = 100; 
--SELECT * FROM Country;

--Procedimiento que carga datos en City
CREATE PROCEDURE InsertRandomCiudad
    @num_city INT -- Número de países a insertar
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @name NVARCHAR(100);

    WHILE @i <= @num_city
    BEGIN
        -- Seleccionar un nombre aleatorio de la tabla NombreCiudad
        SELECT TOP 1 @name = Name 
        FROM NameCity 
        ORDER BY NEWID(); -- NEWID() genera un valor único para ordenar aleatoriamente

        -- Insertar el nombre en la tabla City

		INSERT INTO City(Name,CountryID)
		VALUES (
		 (@name),
        (SELECT TOP 1 CountryID FROM Country ORDER BY NEWID()) -- PaisID aleatorio
    );

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;
GO

EXEC InsertRandomCiudad @num_city = 1000; 

--SELECT * FROM City;

--Procedimiento que carga datos en Airport

CREATE PROCEDURE InsertMultipleAirports
    @NumberOfAirports INT
AS
BEGIN
    DECLARE @random_iata CHAR(3);
    DECLARE @random_name NVARCHAR(100);
    DECLARE @iata_exists INT;
    DECLARE @counter INT = 0;
    

    -- Bucle para insertar múltiples aeropuertos
    WHILE @counter < @NumberOfAirports
    BEGIN
        SET @iata_exists = 1;

        -- Bucle para generar un IATA_Code único
        WHILE @iata_exists = 1
        BEGIN
            -- Generar IATA_Code de 3 letras mayúsculas
            SET @random_iata = CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) + 
                               CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) + 
                               CHAR(65 + ABS(CHECKSUM(NEWID())) % 26);

            -- Verificar si el IATA_Code ya existe en la tabla
            SELECT @iata_exists = COUNT(*)
            FROM Airport
            WHERE IATA_Code = @random_iata;
        END

        -- Generar nombre de aeropuerto aleatorio basado en el IATA_Code
        SELECT TOP 1 @random_name = Name 
        FROM NameAirport
        ORDER BY NEWID();

        -- Insertar el nuevo aeropuerto en la tabla
        INSERT INTO Airport (IATA_Code, Name, CityID)
        VALUES (@random_iata, @random_name, (SELECT TOP 1 CityID FROM City ORDER BY NEWID()));

        -- Incrementar el contador
        SET @counter = @counter + 1;
    END
END


EXEC InsertMultipleAirports @NumberOfAirports = 1000; 
--select * from Airport;

--Procedimiento para cargar datos de Aerolinea
CREATE PROCEDURE InsertRandomAirlines
    @NumberOfAirlines INT
AS
BEGIN
    DECLARE @Name VARCHAR(100);
    DECLARE @FoundedYear DATE;
    DECLARE @Fleet_Size INT;
    DECLARE @CityID INT;
    DECLARE @counter INT = 1;
    WHILE @counter <= @NumberOfAirlines
    BEGIN
        -- Generar nombre aleatorio para la aerolínea
        SELECT TOP 1 @Name = Name 
        FROM NameAirport
        ORDER BY NEWID();

        -- Generar año de fundación aleatorio entre 1900 y el año actual
        SET @FoundedYear = DATEADD(YEAR, -(ABS(CHECKSUM(NEWID())) % 123), GETDATE()); -- 123 años atrás desde el año actual

        -- Generar tamaño de flota aleatorio entre 1 y 500
        SET @Fleet_Size = ABS(CHECKSUM(NEWID())) % 500 + 1;

        -- Elegir CityID aleatorio
        SELECT TOP 1 @CityID = CityID 
        FROM City 
        ORDER BY NEWID(); -- Elegir un CityID al azar

        -- Insertar la nueva aerolínea en la tabla
        INSERT INTO Airline (Name, FoundedYear, Fleet_Size, CityID)
        VALUES (@Name, @FoundedYear, @Fleet_Size, @CityID);

        -- Incrementar el contador
        SET @counter = @counter + 1;
    END
END


EXEC InsertRandomAirlines @NumberOfAirlines = 800;

select * from Airline
-- Procedimeinto para cargar datos en Avion
CREATE PROCEDURE InsertRandomAirplanes
    @NumberOfAirplanes INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @RegistrationNumber VARCHAR(50);
    DECLARE @BeginOfOperation DATE;
    DECLARE @Status VARCHAR(50);
    DECLARE @PlaneModelID INT;

    WHILE @i < @NumberOfAirplanes
    BEGIN
        SET @RegistrationNumber = CONCAT('REG-', NEWID()); -- Generar un número de registro aleatorio
        SET @BeginOfOperation = DATEADD(DAY, -FLOOR(RAND() * 3650), GETDATE()); -- Fecha aleatoria dentro de los últimos 10 años
        SET @Status = CASE WHEN RAND() < 0.5 THEN 'Active' ELSE 'Inactive' END; -- Estado aleatorio
        select top 1 @PlaneModelID= PlaneModelID from PlaneModel ORDER BY NEWID();

        INSERT INTO Airplane (RegistrationNumber, BeginOfOperation, Status, PlaneModelID)
        VALUES (@RegistrationNumber, @BeginOfOperation, @Status, @PlaneModelID);

        SET @i = @i + 1;
    END
END;

EXEC InsertRandomAirplanes @NumberOfAirplanes = 800;
select * from PlaneModel;
select * from Airplane
--Procedimiento para cargar datos en FlightNumber
CREATE PROCEDURE InsertRandomFlights
    @NumberOfFlights INT
AS
BEGIN
    DECLARE @DepartureTime DATETIME;
    DECLARE @Description VARCHAR(50);
    DECLARE @StartAirportID VARCHAR(10);
    DECLARE @GoalAirportID VARCHAR(10);
    DECLARE @AirlineID INT;
    DECLARE @AirplaneID INT;
    DECLARE @FlightCategoryID INT;
    DECLARE @counter INT = 0;

    WHILE @counter < @NumberOfFlights
    BEGIN
        -- Generar hora de salida futura
        SET @DepartureTime = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % (30 * 24 * 60), GETDATE());

        -- Generar descripción aleatoria
        SET @Description = 'Vuelo ' + CAST(@counter + 1 AS VARCHAR(3));

        -- Elegir aeropuertos aleatorios
        SELECT TOP 1 @StartAirportID = IATA_Code 
        FROM Airport 
        ORDER BY NEWID(); -- Elegir un aeropuerto al azar

        SELECT TOP 1 @GoalAirportID = IATA_Code 
        FROM Airport 
        WHERE IATA_Code <> @StartAirportID 
        ORDER BY NEWID(); -- Elegir otro aeropuerto al azar diferente

        -- Elegir aerolínea, avión y categoría de vuelo aleatorios
        SELECT TOP 1 @AirlineID = AirlineID 
        FROM Airline 
        ORDER BY NEWID();

        SELECT TOP 1 @AirplaneID = AirplaneID 
        FROM Airplane 
        ORDER BY NEWID();

        SELECT TOP 1 @FlightCategoryID = FlightCategoryID 
        FROM FlightCategory 
        ORDER BY NEWID();

        -- Insertar el nuevo vuelo en la tabla
        INSERT INTO FlightNumber (DepartureTime, Description, StartAirportID, GoalAirportID, AirlineID, AirplaneID, FlightCategoryID)
        VALUES (@DepartureTime, @Description, @StartAirportID, @GoalAirportID, @AirlineID, @AirplaneID, @FlightCategoryID);

        -- Incrementar el contador
        SET @counter = @counter + 1;
    END
END

EXEC InsertRandomFlights @NumberOfFlights = 600;


-- select * from FlightNumber;


--Procedimiento para cargar datos en Flight
CREATE PROCEDURE InsertRandomFlight1
    @Number_Flights INT
AS
BEGIN
    DECLARE @i INT = 0;
    DECLARE @BoardingTime DATETIME;
    DECLARE @FlightDate DATE;
    DECLARE @Gate VARCHAR(50);
    DECLARE @CheckInCounter VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @FlightNumberID INT;
    DECLARE @AirplaneID INT;

    WHILE @i < @Number_Flights
    BEGIN
        -- Generar una fecha de vuelo aleatoria en los próximos 2 años
        SET @FlightDate = DATEADD(DAY, FLOOR(RAND() * 730), GETDATE()); -- Fecha en el futuro (0 a 730 días desde hoy)

        -- Generar una hora de embarque aleatoria en el mismo día de vuelo (30 a 210 minutos antes del vuelo)
        SET @BoardingTime = DATEADD(MINUTE, FLOOR(RAND() * 180) + 30, CAST(@FlightDate AS DATETIME));

        -- Generar una puerta de embarque aleatoria (A-Z)
        SET @Gate = CONCAT('Gate ', CHAR(65 + FLOOR(RAND() * 26)));

        -- Generar un mostrador de check-in aleatorio (1-10)
        SET @CheckInCounter = CONCAT('Check-in ', FLOOR(RAND() * 10) + 1);

        -- Generar un estado aleatorio (On Time o Delayed)
        SET @Status = CASE WHEN RAND() < 0.5 THEN 'On Time' ELSE 'Delayed' END;

        -- Seleccionar FlightNumberID y AirplaneID aleatoriamente
        SET @FlightNumberID = (SELECT TOP 1 FlightNumberID FROM FlightNumber ORDER BY NEWID());
        SET @AirplaneID = (SELECT TOP 1 AirplaneID FROM Airplane ORDER BY NEWID());

        -- Insertar el vuelo en la tabla Flight
        INSERT INTO Flight (BoardingTime, FlightDate, Gate, CheckInCounter, Status, FlightNumberID, AirplaneID)
        VALUES (@BoardingTime, @FlightDate, @Gate, @CheckInCounter, @Status, @FlightNumberID, @AirplaneID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;




EXEC InsertRandomFlight1 @Number_Flights =2000;

-- Select * from Flight;

--Procedimineto para cargar datos de Asientos
CREATE PROCEDURE InsertRandomSeats
    @NumberOfSeats INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @Size VARCHAR(50);
    DECLARE @Number INT;
    DECLARE @Location VARCHAR(50);
    DECLARE @PlaneModelID INT;
	DECLARE @SeatingCapacity INT; 

    WHILE @i < @NumberOfSeats
    BEGIN


		SELECT TOP 1 @PlaneModelID = PlaneModelID, @SeatingCapacity = SeatingCapacity
        FROM PlaneModel
        ORDER BY NEWID();

        -- Generar tamaño aleatorio
		SELECT TOP 1 @Size = NombreClase
        FROM Clase
        ORDER BY NEWID();

        -- Número de asiento aleatorio (suponiendo un rango de 1 a la capacidad)
        SET @Number = FLOOR(RAND() * @SeatingCapacity) + 1;

        -- Generar ubicación aleatoria (Ej. "Row 5, Column A")
        SET @Location = CONCAT('Row ', FLOOR(RAND() * 20) + 1, ', Column ', CHAR(65 + FLOOR(RAND() * 6))); -- A-F

         

        INSERT INTO Seat (Size, Number, Location, PlaneModelID)
        VALUES (@Size, @Number, @Location, @PlaneModelID);

        SET @i = @i + 1;
    END
END;

EXEC InsertRandomSeats @NumberOfSeats = 500;

select * from Seat

-- Procedimiento para cargar datos en Cancelacion de Vuelos
CREATE PROCEDURE InsertRandomFlightCancelations
    @NumberOfCancelations INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @CancelationDate DATE;
    DECLARE @Reason VARCHAR(100);
    DECLARE @FlightID INT;

    WHILE @i < @NumberOfCancelations
    BEGIN
        -- Generar una fecha de cancelación aleatoria (en los próximos 2 años)
        SET @CancelationDate = DATEADD(DAY, FLOOR(RAND() * 730), GETDATE());

        -- Seleccionar una razón de cancelación aleatoria
        SET @Reason = CASE 
            WHEN RAND() < 0.2 THEN 'Weather'
            WHEN RAND() < 0.4 THEN 'Technical Issue'
            WHEN RAND() < 0.6 THEN 'Crew Shortage'
            WHEN RAND() < 0.8 THEN 'Air Traffic Control'
            ELSE 'Other'
        END;
        -- Seleccionar un FlightID válido aleatoriamente desde la tabla Flight
        SELECT TOP 1 @FlightID = FlightID
        FROM Flight
        ORDER BY NEWID(); -- Selecciona un vuelo aleatorio
        -- Insertar la cancelación en la tabla FlightCancelation
        INSERT INTO FlightCancelation (CancelationDate, Reason, FlightID)
        VALUES (@CancelationDate, @Reason, @FlightID);
        SET @i = @i + 1;
    END
END;


EXEC InsertRandomFlightCancelations @NumberOfCancelations= 500;


select * from FlightCancelation
--Procedimiento para cargar datos de Compensacion

CREATE PROCEDURE InsertRandomCompensations
    @NumberOfCompensations INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @Amount FLOAT;
    DECLARE @Descripcion VARCHAR(100);
    DECLARE @CompensationDate DATE;
    DECLARE @FCancelationID INT;
    DECLARE @CompesationTypeID INT;

    WHILE @i < @NumberOfCompensations
    BEGIN
        -- Generar un monto de compensación aleatorio entre 100 y 1000
        SET @Amount = ROUND(RAND() * (1000 - 100) + 100, 2);

        -- Generar una descripción aleatoria
        SET @Descripcion = CASE 
            WHEN RAND() < 0.3 THEN 'Flight delay compensation'
            WHEN RAND() < 0.6 THEN 'Cancellation compensation'
            ELSE 'Overbooking compensation'
        END;

        -- Generar una fecha de compensación aleatoria en los próximos 2 años
        SET @CompensationDate = DATEADD(DAY, FLOOR(RAND() * 730), GETDATE());

        -- Seleccionar un FlightCancelationID válido aleatoriamente desde la tabla FlightCancelation
        SELECT TOP 1 @FCancelationID = FCancelationID
        FROM FlightCancelation
        ORDER BY NEWID(); -- Selecciona una cancelación aleatoria

        -- Seleccionar un CompesationTypeID válido aleatoriamente desde la tabla CompesationType
        SELECT TOP 1 @CompesationTypeID = CompesationTypeID
        FROM CompesationType
        ORDER BY NEWID(); -- Selecciona un tipo de compensación aleatorio

        -- Insertar la compensación en la tabla Compesation
        INSERT INTO Compesation (Amount, Descripcion, CompensationDate, FCancelationID, CompesationTypeID)
        VALUES (@Amount, @Descripcion, @CompensationDate, @FCancelationID, @CompesationTypeID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomCompensations @NumberOfCompensations=50000;

--Procedimiento para insertar datos en Persona
CREATE PROCEDURE InsertRandomPerson
    @num_person INT -- Número de países a insertar
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @name VARCHAR(100);
	DECLARE @PhoneNumber INT;

    WHILE @i <= @num_person
    BEGIN
        -- Seleccionar un nombre aleatorio de la tabla PaisNombre
        SELECT TOP 1 @name = Name 
        FROM NamePerson
        ORDER BY NEWID(); -- NEWID() genera un valor único para ordenar aleatoriamente

		SET @PhoneNumber = 70000000 + FLOOR(RAND() * 10000000);

        -- Insertar el nombre en la tabla Country
        INSERT INTO Person(Name,PhoneNumber)
        VALUES (@name,@PhoneNumber);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;
GO

EXEC InsertRandomPerson @num_person=50000;

--Procedimiento para almacenar datos en Pasajero
CREATE PROCEDURE InsertRandomPassengers
    @NumberOfPassengers INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @PassengerID INT;
    DECLARE @SpecialAssistance BIT;

    WHILE @i < @NumberOfPassengers
    BEGIN
        -- Seleccionar un PassengerID aleatorio desde la tabla Person
        SELECT TOP 1 @PassengerID = PersonID
        FROM Person
        WHERE PersonID NOT IN (SELECT PassengerID FROM Passenger) -- Evitar duplicados
        ORDER BY NEWID(); -- Selecciona un ID de persona aleatorio

        -- Verificar que se encontró un PassengerID válido
        IF @PassengerID IS NOT NULL
        BEGIN
            -- Generar asistencia especial aleatoria (0 o 1)
            SET @SpecialAssistance = CASE WHEN RAND() < 0.5 THEN 0 ELSE 1 END;

            -- Insertar los datos en la tabla Passenger
            INSERT INTO Passenger (PassengerID, SpecialAsistance)
            VALUES (@PassengerID, @SpecialAssistance);

            -- Incrementar el contador
            SET @i = @i + 1;
        END
        ELSE
        BEGIN
            -- No hay más pasajeros disponibles para insertar, salir del bucle
            BREAK;
        END
    END
END;
--drop procedure InsertRandomCustomers;
--delete from Customer 
EXEC InsertRandomPassengers @NumberOfPassengers=10000;

-- Procedimiento para cargar datos de Cliente
CREATE PROCEDURE InsertRandomCustomers
    @NumCustomers INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerID INT;
    DECLARE @DateOfBirth DATE;
    DECLARE @Email NVARCHAR(60);
    DECLARE @RandomIndex INT;

    -- Insertar datos aleatorios
    WHILE @NumCustomers > 0
    BEGIN
        -- Seleccionar un CustomerID aleatorio de la tabla Person
        SELECT TOP 1 @CustomerID = PersonID
        FROM Person
        WHERE PersonID NOT IN (SELECT CustomerID FROM Customer) -- Evitar duplicados
        ORDER BY NEWID(); -- Selecciona un ID de persona aleatorio

        -- Generar una fecha de nacimiento aleatoria
        SET @DateOfBirth = DATEADD(YEAR, -FLOOR(RAND() * 40) - 18, GETDATE()); -- Edad entre 18 y 57 años

        -- Generar un email aleatorio
        SET @Email = CONCAT( @CustomerID, '@gmail.com');

        -- Insertar el nuevo cliente
        INSERT INTO Customer (CustomerID, DateOfBirth, Email)
        VALUES (@CustomerID, @DateOfBirth, @Email);

        SET @NumCustomers = @NumCustomers - 1;
    END
END;

EXEC InsertRandomCustomers @NumCustomers=2000;


--Procedimiento p ara cargar datos en Documento
CREATE PROCEDURE InsertRandomDocuments
    @NumberOfDocuments INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @DocumentTypeID INT;
    DECLARE @DocumentNumber VARCHAR(50);
    DECLARE @IssueDate DATE;
    DECLARE @ExpiryDate DATE;
    DECLARE @IssuingCityID INT;
    DECLARE @PassengerID INT;

    WHILE @i < @NumberOfDocuments
    BEGIN
        -- Seleccionar un DocumentTypeID aleatorio
        SELECT TOP 1 @DocumentTypeID = DocumentTypeID
        FROM DocumentType
        ORDER BY NEWID();

        -- Generar un número de documento aleatorio
        SET @DocumentNumber = CONCAT('DOC-', CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR(10)));

        -- Generar una fecha de emisión aleatoria (últimos 5 años)
        SET @IssueDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 1825), GETDATE());

        -- Generar una fecha de expiración aleatoria (entre 1 y 5 años después de la fecha de emisión)
        SET @ExpiryDate = DATEADD(YEAR, ABS(CHECKSUM(NEWID()) % 5) + 1, @IssueDate);

        -- Seleccionar un IssuingCityID aleatorio
        SELECT TOP 1 @IssuingCityID = CityID
        FROM City
        ORDER BY NEWID();

        -- Seleccionar un PassengerID aleatorio
        SELECT TOP 1 @PassengerID = PassengerID
        FROM Passenger
        ORDER BY NEWID();

        -- Insertar los datos en la tabla Document
        INSERT INTO Document (DocumentTypeID, DocumentNumber, IssueDate, ExpiryDate, IssuingCityID, PassengerID)
        VALUES (@DocumentTypeID, @DocumentNumber, @IssueDate, @ExpiryDate, @IssuingCityID, @PassengerID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomDocuments @NumberOfDocuments=5000;

-- Procedimiento para cargar datos en Pago
CREATE PROCEDURE InsertRandomPayments
    @NumberOfPayments INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @DDate DATE;
    DECLARE @Amount FLOAT;
    DECLARE @MethodID INT;

    WHILE @i < @NumberOfPayments
    BEGIN
        -- Generar una fecha aleatoria dentro de los próximos 2 años
        SET @DDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), GETDATE()); -- 730 días = 2 años

        -- Generar un importe aleatorio entre 10 y 1000
        SET @Amount = ROUND((RAND() * 9990) + 10, 2); -- Monto entre 10 y 1000

        -- Seleccionar un MethodID aleatorio
        SELECT TOP 1 @MethodID = MethodID
        FROM PaymentMethod
        ORDER BY NEWID();

        -- Insertar los datos en la tabla Payment
        INSERT INTO Payment (DDate, Amount, MethodID)
        VALUES (@DDate, @Amount, @MethodID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;
EXEC InsertRandomPayments @NumberOfPayments=3000;

--Procedimiento para cargar datos en Reservacion
CREATE PROCEDURE InsertRandomReservations
    @NumberOfReservations INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @Date DATETIME;
    DECLARE @Status VARCHAR(25);
    DECLARE @CustomerID INT;
    DECLARE @PaymentID INT;

    DECLARE @StatusList TABLE (Status VARCHAR(25));
    INSERT INTO @StatusList VALUES ('Pending'), ('Confirmed'), ('Cancelled'), ('Completed');

    WHILE @i < @NumberOfReservations
    BEGIN
        -- Generar una fecha aleatoria dentro de los próximos 2 años
        SET @Date = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), GETDATE()); -- 730 días = 2 años

        -- Seleccionar un CustomerID aleatorio
        SELECT TOP 1 @CustomerID = CustomerID
        FROM Customer
        ORDER BY NEWID();

        -- Seleccionar un PaymentID aleatorio
        SELECT TOP 1 @PaymentID = PaymentID
        FROM Payment
        ORDER BY NEWID();

        -- Seleccionar un estado aleatorio de la lista
        SELECT TOP 1 @Status = Status
        FROM @StatusList
        ORDER BY NEWID();

        -- Insertar los datos en la tabla Reservation
        INSERT INTO Reservation (Date, Status, CustomerID, PaymentID)
        VALUES (@Date, @Status, @CustomerID, @PaymentID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomReservations @NumberOfReservations=2000;

--Procedimiento para cargar datos en Ticket
--Procedimiento para cargar datos en Ticket
CREATE PROCEDURE InsertRandomTickets
    @NumberOfTickets INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @TicketingCode VARCHAR(50);
    DECLARE @Number INT;
    DECLARE @PurchaseDate DATE;
    DECLARE @TotalImport FLOAT;
    DECLARE @DocumentID INT;
    DECLARE @ReservationID INT;
	DECLARE @passengerID  INT ; 

    WHILE @i < @NumberOfTickets
    BEGIN
        -- Generar un código de ticket aleatorio
        SET @TicketingCode = CONCAT('TICKET-', CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR(10)));

        -- Verificar que no exista el código generado y regenerar si es necesario
        WHILE EXISTS (SELECT 1 FROM Ticket WHERE TicketingCode = @TicketingCode)
        BEGIN
            -- Regenerar el código si ya existe
            SET @TicketingCode = CONCAT('TICKET-', CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR(10)));
        END

        -- Generar un número aleatorio para el ticket
        SET @Number = ABS(CHECKSUM(NEWID()) % 1000) + 1; -- Número entre 1 y 1000

        -- Generar una fecha de compra aleatoria dentro de los próximos 2 años
        SET @PurchaseDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), GETDATE()); -- 730 días = 2 años

        -- Generar un importe total aleatorio
        SET @TotalImport = ROUND(RAND() * 500, 2); -- Importe entre 0 y 500

        -- Seleccionar un DocumentID aleatorio
        SELECT TOP 1 @DocumentID = DocumentID
        FROM Document
        ORDER BY NEWID();

        -- Seleccionar un ReservationID aleatorio
        SELECT TOP 1 @ReservationID = ReservationID
        FROM Reservation
        ORDER BY NEWID();

		SELECT TOP 1 @passengerID = PassengerID
		FROM passenger
		ORDER BY NEWID(); 
        -- Insertar los datos en la tabla Ticket
        INSERT INTO Ticket (TicketingCode, Number, PurchaseDate, TotalImport, DocumentID, ReservationID,PassengerID)
        VALUES (@TicketingCode, @Number, @PurchaseDate, @TotalImport, @DocumentID, @ReservationID,@passengerID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomTickets @NumberOfTickets=10000;

DROP PROCEDURE InsertRandomTickets
--Procedimiento para cargar datos en Check In
CREATE PROCEDURE InsertRandomCheckIns
    @NumberOfCheckIns INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @CheckInDateTime DATETIME;
    DECLARE @BoardingGate VARCHAR(25);
    DECLARE @CheckInStatus VARCHAR(50);
    DECLARE @TicketID INT;
    DECLARE @BoardingTime DATETIME;

    -- Lista de estados de check-in
    DECLARE @StatusList TABLE (Status VARCHAR(50));
    INSERT INTO @StatusList VALUES ('Checked In'), ('Boarded'), ('Missed'), ('Cancelled');

    WHILE @i < @NumberOfCheckIns
    BEGIN
        -- Generar una fecha de check-in aleatoria dentro de los próximos 2 años
        SET @CheckInDateTime = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 730), GETDATE()); -- 730 días = 2 años

        -- Generar una puerta de embarque aleatoria
        SET @BoardingGate = CONCAT('Gate ', CHAR(65 + ABS(CHECKSUM(NEWID()) % 26)), CAST(ABS(CHECKSUM(NEWID()) % 10) AS VARCHAR(1)));

        -- Seleccionar un estado de check-in aleatorio
        SELECT TOP 1 @CheckInStatus = Status
        FROM @StatusList
        ORDER BY NEWID();

        -- Seleccionar un TicketID aleatorio
        SELECT TOP 1 @TicketID = TicketID
        FROM Ticket
        ORDER BY NEWID();

        -- Generar una hora de embarque aleatoria (debería ser después de la fecha de check-in)
        SET @BoardingTime = DATEADD(MINUTE, ABS(CHECKSUM(NEWID()) % 120) + 1, @CheckInDateTime); -- Entre 1 y 120 minutos después del check-in

        -- Insertar los datos en la tabla CheckIn
        INSERT INTO CheckIn (CheckInDateTime, BoardingGate, CheckInStatus, TicketID, BoardingTime)
        VALUES (@CheckInDateTime, @BoardingGate, @CheckInStatus, @TicketID, @BoardingTime);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomCheckIns @NumberOfCheckIns =10000

--Procedimiento para cargar datos en Cupon
CREATE PROCEDURE InsertRandomCoupons
    @NumberOfCoupons INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @DateOfRedemption DATE;
    DECLARE @Standby VARCHAR(50);
    DECLARE @MealCode VARCHAR(50);
    DECLARE @TicketID INT;
    DECLARE @FlightID INT;
    DECLARE @ClaseID INT;

    WHILE @i < @NumberOfCoupons
    BEGIN
        -- Generar una fecha de canje aleatoria dentro de los próximos 2 años
        SET @DateOfRedemption = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 730), GETDATE()); -- 730 días = 2 años

        -- Generar un standby aleatorio
        SET @Standby = CONCAT('Standby-', CAST(ABS(CHECKSUM(NEWID()) % 1000) AS VARCHAR(10)));

        -- Generar un código de comida aleatorio
        SET @MealCode = CONCAT('MEAL-', CAST(ABS(CHECKSUM(NEWID()) % 100) AS VARCHAR(2)));

        -- Seleccionar un TicketID aleatorio
        SELECT TOP 1 @TicketID = TicketID
        FROM Ticket
        ORDER BY NEWID();

        -- Seleccionar un FlightID aleatorio
        SELECT TOP 1 @FlightID = FlightID
        FROM Flight
        ORDER BY NEWID();

        -- Seleccionar un ClaseID aleatorio (opcional)
        SET @ClaseID = (SELECT TOP 1 ClaseID FROM Clase ORDER BY NEWID());

        -- Insertar los datos en la tabla Coupon
        INSERT INTO Coupon (DateOfRedemption, Standby, MealCode, TicketID, FlightID, ClaseID)
        VALUES (@DateOfRedemption, @Standby, @MealCode, @TicketID, @FlightID, @ClaseID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomCoupons @NumberOfCoupons=10000;


--Priocedimiento para cargar datos en Poltica de cancelacion
CREATE PROCEDURE InsertRandomCancellationPolicies
    @NumberOfPolicies INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @Descripcion VARCHAR(100);
    DECLARE @DaysBeforeFlight INT;
    DECLARE @CancellationFee FLOAT;
    DECLARE @TicketID INT;

    WHILE @i < @NumberOfPolicies
    BEGIN
        -- Generar una descripción aleatoria
        SET @Descripcion = CONCAT('Política de cancelación ', CAST(ABS(CHECKSUM(NEWID()) % 1000) AS VARCHAR(10)));

        -- Generar un número de días aleatorio entre 1 y 30
        SET @DaysBeforeFlight = ABS(CHECKSUM(NEWID()) % 30) + 1; -- Entre 1 y 30 días

        -- Generar una tarifa de cancelación aleatoria entre 0 y 500
        SET @CancellationFee = ROUND(RAND() * 500, 2); -- Tarifa entre 0 y 500

        -- Seleccionar un TicketID aleatorio
        SELECT TOP 1 @TicketID = TicketID
        FROM Ticket
        ORDER BY NEWID();

        -- Insertar los datos en la tabla CancellationPolicy
        INSERT INTO CancellationPolicy (Descripcion, DaysBeforeFlight, CancellationFee, TicketID)
        VALUES (@Descripcion, @DaysBeforeFlight, @CancellationFee, @TicketID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomCancellationPolicies @NumberOfPolicies = 500;
----
CREATE PROCEDURE InsertRandomLuggagePieces
    @NumberOfPieces INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @Number INT;
    DECLARE @Weight DECIMAL(5, 2);
    DECLARE @CouponID INT;

    WHILE @i < @NumberOfPieces
    BEGIN
        -- Generar un número de equipaje aleatorio entre 1 y 5
        SET @Number = ABS(CHECKSUM(NEWID()) % 5) + 1; -- Número entre 1 y 5

        -- Generar un peso aleatorio entre 1.00 y 999.99 kg
        SET @Weight = ROUND((RAND() * (999.99 - 1.00)) + 1.00, 2); -- Peso entre 1.00 y 999.99

        -- Seleccionar un CouponID aleatorio
        SELECT TOP 1 @CouponID = CouponID
        FROM Coupon
        ORDER BY NEWID();

        -- Insertar los datos en la tabla PiecesOfLuggage
        INSERT INTO PiecesOfLuggage (Number, Weight, CouponID)
        VALUES (@Number, @Weight, @CouponID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomLuggagePieces @NumberOfPieces = 8000;

-----
CREATE PROCEDURE InsertRandomAssignments
    @NumberOfAssignments INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 0;
    DECLARE @AssignmentDate DATE;
    DECLARE @CustomerID INT;
    DECLARE @CustomerTypeID INT;
    WHILE @i < @NumberOfAssignments
    BEGIN
        -- Generar una fecha aleatoria en los últimos 365 días
        SET @AssignmentDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE());
        -- Seleccionar un CustomerID aleatorio
        SELECT TOP 1 @CustomerID = CustomerID
        FROM Customer
        ORDER BY NEWID();
        -- Seleccionar un CustomerTypeID aleatorio
        SELECT TOP 1 @CustomerTypeID = CustomerTypeID
        FROM CustomerType
        ORDER BY NEWID();
        -- Insertar los datos en la tabla Assignment
        INSERT INTO Assignment (AssignmentDate, CustomerID, CustomerTypeID)
        VALUES (@AssignmentDate, @CustomerID, @CustomerTypeID);
        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomAssignments @NumberOfAssignments = 2000;

select * from Assignment
----------------
CREATE PROCEDURE InsertRandomFrequentFlyerCards
    @NumberOfCards INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @FFCNumber INT;
    DECLARE @Miles INT;
    DECLARE @MealCode VARCHAR(10);
    DECLARE @IssueDate DATE;
    DECLARE @ExpiryDate DATE;
    DECLARE @CustomerID INT;

    WHILE @i < @NumberOfCards
    BEGIN
        -- Generar un número de millas aleatorio entre 0 y 100000
        SET @Miles = ABS(CHECKSUM(NEWID()) % 100001); -- Entre 0 y 100,000 millas

        -- Generar un código de comida aleatorio (por ejemplo: "Meal123")
        SET @MealCode = CONCAT('Meal', CAST(ABS(CHECKSUM(NEWID()) % 9999) AS VARCHAR(4)));

        -- Generar una fecha de emisión aleatoria en los últimos 5 años
        SET @IssueDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 1825), GETDATE()); -- Últimos 5 años

        -- Generar una fecha de expiración aleatoria dentro de los próximos 5 años
        SET @ExpiryDate = DATEADD(YEAR, 1 + ABS(CHECKSUM(NEWID()) % 5), @IssueDate); -- Entre 1 y 5 años

        -- Seleccionar un CustomerID aleatorio
        SELECT TOP 1 @CustomerID = CustomerID
        FROM Customer
        ORDER BY NEWID();

        -- Insertar los datos en la tabla FrequentFlyerCard
        INSERT INTO FrequentFlyerCard (FFCNumber, Miles, MealCode, IssueDate, ExpiryDate, CustomerID)
        VALUES (@i + 1, @Miles, @MealCode, @IssueDate, @ExpiryDate, @CustomerID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

-- Ejecutar el procedimiento para insertar 1400 tarjetas
EXEC InsertRandomFrequentFlyerCards @NumberOfCards = 1400;

select * from FrequentFlyerCard



CREATE PROCEDURE InsertRandomCrewMembers
    @NumberOfCrewMembers INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @CrewMemberID INT;
    DECLARE @Position VARCHAR(40);
    DECLARE @EmploymentDate DATE;
    DECLARE @FlightHours INT;

    WHILE @i < @NumberOfCrewMembers
    BEGIN
        -- Seleccionar un CrewMemberID aleatorio de la tabla person
        SELECT TOP 1 @CrewMemberID = personID
        FROM person
        ORDER BY NEWID();

        -- Generar una posición aleatoria
        SET @Position = CASE ABS(CHECKSUM(NEWID()) % 5)
            WHEN 0 THEN 'Pilot'
            WHEN 1 THEN 'Co-Pilot'
            WHEN 2 THEN 'Flight Attendant'
            WHEN 3 THEN 'Cabin Crew'
            ELSE 'Ground Staff'
        END;

        -- Generar una fecha de empleo aleatoria dentro de los últimos 10 años
        SET @EmploymentDate = DATEADD(YEAR, -ABS(CHECKSUM(NEWID()) % 10), GETDATE());

        -- Generar un número aleatorio de horas de vuelo entre 100 y 5000
        SET @FlightHours = ABS(CHECKSUM(NEWID()) % 4900) + 100; -- Entre 100 y 5000

        -- Insertar los datos en la tabla CrewMember
        INSERT INTO CrewMember (CrewMemberID, Position, EmploymentDate, FlightHours)
        VALUES (@CrewMemberID, @Position, @EmploymentDate, @FlightHours);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

EXEC InsertRandomCrewMembers @NumberOfCrewMembers = 800;

select * from CrewMember


CREATE PROCEDURE InsertRandomCrewData
    @NumberOfCrews INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 0;
    DECLARE @AssignmentDate DATE;
    DECLARE @ShiftStart DATETIME;
    DECLARE @ShiftEnd DATETIME;
    DECLARE @Status VARCHAR(50);
    DECLARE @CrewMemberID INT;

    WHILE @i < @NumberOfCrews
    BEGIN
        -- Generar una fecha de asignación aleatoria
        SET @AssignmentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 30), GETDATE()); -- Hasta 30 días a partir de hoy

        -- Generar una hora de inicio aleatoria
        SET @ShiftStart = DATEADD(HOUR, ABS(CHECKSUM(NEWID()) % 24), CAST(GETDATE() AS DATETIME)); -- Hora de inicio en el día actual

        -- Generar una hora de fin aleatoria (asegurarse de que sea después de ShiftStart)
        SET @ShiftEnd = DATEADD(HOUR, ABS(CHECKSUM(NEWID()) % 8) + 1, @ShiftStart); -- Entre 1 y 8 horas después

        -- Generar un estado aleatorio
        SET @Status = CASE 
                        WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 'Active' 
                        ELSE 'Inactive' 
                      END;

        -- Seleccionar un CrewMemberID aleatorio
        SELECT TOP 1 @CrewMemberID = CrewMemberID
        FROM CrewMember
        ORDER BY NEWID();

        -- Insertar los datos en la tabla Crew
        INSERT INTO Crew (CrewID, AssigmentDate, ShiftStart, ShiftEnd, Status, CrewMemberID)
        VALUES (@i + 1, @AssignmentDate, @ShiftStart, @ShiftEnd, @Status, @CrewMemberID);

        -- Incrementar el contador
        SET @i = @i + 1;
    END
END;

-- Ejecutar el procedimiento para insertar datos
EXEC InsertRandomCrewData @NumberOfCrews = 500;
