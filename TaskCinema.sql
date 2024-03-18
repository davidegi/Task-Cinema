CREATE TABLE Cinema (
	CinemaID INT PRIMARY KEY,
	Name VARCHAR (100) NOT NULL,
	Address VARCHAR (255) NOT NULL,
	Phone VARCHAR (20)
);
 
CREATE TABLE Theater (
	TheaterID INT PRIMARY KEY,
	CinemaID INT,
	Name VARCHAR(50) NOT NULL,
	Capacity INT NOT NULL,
	ScreenType VARCHAR(50),
	FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);

CREATE TABLE Movie (
	MovieID INT PRIMARY KEY,
	Title VARCHAR(255) NOT NULL,
	Director VARCHAR(100),
	ReleaseDate DATE,
	DurationMinutes INT,
	Rating VARCHAR(5)
);

CREATE TABLE Showtime (
	ShowtimeID INT PRIMARY KEY,
	MovieID INT,
	TheaterID INT,
	ShowDateTime DATETIME NOT NULL,
	Price DECIMAL(5,2) NOT NULL,
	FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
	FOREIGN KEY (TheaterID) REFERENCES Theater(TheaterID)
);

CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100),
	PhoneNumber VARCHAR(20)
);

CREATE TABLE Ticket (
	TicketID INT PRIMARY KEY,
	ShowtimeID INT,
	SeatNumber VARCHAR(10) NOT NULL,
	PurchasedDateTime DATETIME NOT NULL,
	CustomerID INT,
	FOREIGN KEY (ShowtimeID) REFERENCES Showtime(ShowtimeID),
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Review (
	ReviewID INT PRIMARY KEY,
	MovieID INT,
	CustomerID INT,
	ReviewText TEXT,
	Rating INT CHECK (Rating >= 1 AND Rating <= 5),
	ReviewDate DATETIME NOT NULL,
	FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Employee (
	EmployeeID INT PRIMARY KEY,
	CinemaID INT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Position VARCHAR(50),
	HireDate DATE,
	FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
); 

INSERT INTO Cinema (CinemaID, Name, Address, Phone)
VALUES
(1, 'Cinema Paradiso', 'Via Roma 123', '06 1234567'),
(2, 'Cinema inferno', 'Via Napoli 222', '+ 06 8574635');
 
INSERT INTO Theater (TheaterID, CinemaID, Name, Capacity, ScreenType)
VALUES
(1, 1, 'Sala 1', 100, '2D'),
(2, 1, 'Sala 2', 80, '3D'),
(3, 2, 'Sala 3', 150, 'IMAX'),
(4, 2, 'Sala 4', 120, '2D');
 
INSERT INTO Movie (MovieID, Title, Director, ReleaseDate, DurationMinutes, Rating) VALUES
(1, 'The Shawshank Redemption', 'Frank Darabont', '1994-09-23', 142, '4'),
(2, 'Inception', 'Christopher Nolan', '2010-07-16', 148, '4'),
(3, 'Pulp Fiction', 'Quentin Tarantino', '1994-10-14', 154, '5');
 
INSERT INTO Showtime (ShowtimeID, MovieID, TheaterID, ShowDateTime, Price) VALUES
(1, 1, 1, '2024-03-2 18:00:00', 10.00),
(2, 2, 3, '2024-03-2 20:00:00', 12.50),
(3, 3, 2, '2024-03-2 19:30:00', 11.00);
 
INSERT INTO Customer (CustomerID, FirstName, LastName, Email, PhoneNumber) VALUES
(1, 'Mario', 'Rossi', 'mrossi@example.com', '3334657889'),
(2, 'Valerio', 'Bianchi', 'valbianch@example.com', '336970699');
 
INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID) VALUES
(1, 1, 'A1', '2024-03-01 15:30:00', 1),
(2, 2, 'B5', '2024-03-01 10:45:00', 2);

INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID) VALUES
(3, 1, 'A2', '2024-03-01 15:30:00', 1);
 
INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate) VALUES
(1, 1, 1, 'Bellissimo film,uno dei migliori!', 5, '2024-03-01 09:15:00'),
(2, 2, 2, 'Film dell''anno.', 4, '2024-03-01 22:30:00');

INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate) VALUES
(3, 3, 1, 'Un classico intramontabile', 5, '2024-02-02 23:50:00');
 
INSERT INTO Employee (EmployeeID, CinemaID, FirstName, LastName, Position, HireDate) VALUES
(1, 1, 'Franco', 'Rossi', 'Manager', '2020-01-15'),
(2, 2, 'Luca', 'Gialli', 'Cassiere', '2022-03-01');

-- Creare una vista FilmsInProgrammation che mostri i titoli dei film, la data di inizio
-- programmazione, la durata e la classificazione per età. Questa vista aiuterà il personale e i clienti a
-- vedere rapidamente quali film sono attualmente in programmazione.

CREATE VIEW FilmsInProgrammation AS
	SELECT Movie.Title AS 'Titolo', Showtime.ShowDateTime AS 'data di inizio', Movie.DurationMinutes AS 'durata'
		FROM Movie
		JOIN Showtime ON Movie.MovieID = Showtime.MovieID

SELECT * FROM FilmsInProgrammation;

-- Creare una vista AvailableSeatsForShow che, per ogni spettacolo, mostri il numero totale di
-- posti nella sala e quanti sono ancora disponibili. Questa vista è essenziale per il personale alla
-- biglietteria per gestire le vendite dei biglietti.

DROP VIEW IF EXISTS AvailableSeatsForShow; 
CREATE VIEW AvailableSeatsForShow AS 
	SELECT Theater.Capacity AS 'Posti totali', (Theater.Capacity - COUNT(Ticket.TicketID)) AS 'Posti disponibili'
		FROM Theater
		JOIN Showtime ON Theater.TheaterID = Showtime.TheaterID
		JOIN Movie ON Showtime.ShowtimeID = Movie.MovieID
		JOIN Ticket ON Showtime.ShowtimeID = Ticket.ShowtimeID
		GROUP BY Theater.TheaterID, Theater.Capacity;
	
SELECT * FROM AvailableSeatsForShow;

-- Generare una vista TotalEarningsPerMovie che elenchi ogni film insieme agli incassi totali
-- generati. Questa informazione è cruciale per la direzione per valutare il successo commerciale dei
-- film.

DROP VIEW IF EXISTS TotalEarningsPerMovie;
CREATE VIEW TotalEarningsPerMovie AS 
	SELECT Movie.Title AS 'Titolo', SUM(Showtime.Price) AS 'Incassi totali'
		FROM Movie
		JOIN Showtime ON Movie.MovieID = Showtime.MovieID
		JOIN Ticket ON Showtime.ShowtimeID = Ticket.ShowtimeID
		GROUP BY Title;

SELECT * FROM TotalEarningsPerMovie;

--Creare una vista RecentReviews che mostri le ultime recensioni lasciate dai clienti, includendo il
--titolo del film, la valutazione, il testo della recensione e la data. Questo permetterà al personale e
--alla direzione di monitorare il feedback dei clienti in tempo reale.

DROP VIEW IF EXISTS RecentReviews;
CREATE VIEW RecentReviews AS
	SELECT Movie.Title AS 'Titolo', Review.Rating AS 'Valutazione', Review.ReviewText AS 'Recensione',
	Review.ReviewDate AS 'Data'
		FROM Movie
		JOIN Review ON Movie.MovieID = Review.MovieID;

SELECT * FROM RecentReviews ORDER BY 'Data' DESC;

-- Creare una stored procedure PurchaseTicket che permetta di acquistare un biglietto per uno
-- spettacolo, specificando l'ID dello spettacolo, il numero del posto e l'ID del cliente. La procedura
-- dovrebbe verificare la disponibilità del posto e registrare l'acquisto.

DROP PROCEDURE IF EXISTS PurchaseTicket;
CREATE PROCEDURE PurchaseTicket
	@id_spettacolo INT,
	@num_posto INT,
	@id_cliente INT

	AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF @num_posto <= 0
					THROW 50001, 'Quantità non concessa', 1
				UPDATE Ticket
				SET SeatNumber = SeatNumber - @num_posto
				WHERE TicketID = @id_spettacolo

				IF @@ROWCOUNT = 0
					THROW 50002, 'Errore generico', 1
					INSERT INTO Ticket (TicketID, SeatNumber, CustomerID) VALUES
					(@id_spettacolo, TRY_PARSE(@num_posto AS int), @id_cliente);

				PRINT 'Transazione eseguita correttamente'
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION
			PRINT 'Errore riscontrato: ' + ERROR_MESSAGE()
		END CATCH
	END;

EXEC PurchaseTicket @id_spettacolo = 1, @num_posto = 2, @id_cliente = 1;