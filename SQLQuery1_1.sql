CREATE DATABASE Aqil
USE Aqil


CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL,
    Surname VARCHAR(255) NOT NULL,
    Username VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Gender VARCHAR(10) NOT NULL
);



CREATE TABLE Artists (
    ArtistID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL,
    Surname VARCHAR(255) NOT NULL,
    Birthday DATE,
    Gender VARCHAR(10)
);



CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL
);


CREATE TABLE Musics (
    MusicID INT  PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL,
    DurationInSeconds INT NOT NULL,
    CategoryID INT,
    ArtistID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

CREATE TABLE Playlists (
    PlaylistID INT  PRIMARY KEY IDENTITY,
    Name VARCHAR(255) NOT NULL,
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Playlist_Music (
    PlaylistID INT,
    MusicID INT,
    PRIMARY KEY (PlaylistID, MusicID),
    FOREIGN KEY (PlaylistID) REFERENCES Playlists(PlaylistID),
    FOREIGN KEY (MusicID) REFERENCES Musics(MusicID)
);


INSERT INTO Categories (Name) VALUES 
('Nostaji'),('Şən');



INSERT INTO Artists (Name, Surname, Birthday, Gender) VALUES 
('aqil', 'baxsiyev', '2004-05-31', 'Male'),
('pervin', 'abiyev', '2004-01-1', 'female');


INSERT INTO Musics (Name, DurationInSeconds, CategoryID, ArtistID) VALUES 
('unutma', 200, 1, 1),
('salam yetir', 146, 2, 2);


INSERT INTO Users (Name, Surname, Username, Password, Gender) VALUES 
('tural', 'qaratev', 'turaldi', 'tural123', 'Male'),
('nezrin', 'verdiyeva', 'nezrindi', 'nezrin123', 'Female');



INSERT INTO Playlists (Name, UserID) VALUES 
('Favorites', 1),
(' Mix', 2);



CREATE VIEW MusicDetails AS
SELECT
    M.Name AS 'MusicName',
    M.DurationInSeconds AS 'MusicDuration',
    C.Name AS 'CategoryName',
    A.Name AS 'ArtistName'
FROM Musics M
LEFT JOIN Categories C ON M.CategoryID = C.CategoryID
LEFT JOIN Artists A ON M.ArtistID = A.ArtistID;


CREATE PROCEDURE usp_CreateMusic
    @Name VARCHAR(255),
    @DurationInSeconds INT,
    @CategoryID INT,
    @ArtistID INT
AS
BEGIN
    INSERT INTO Musics (Name, DurationInSeconds, CategoryID, ArtistID)
    VALUES (@Name, @DurationInSeconds, @CategoryID, @ArtistID);
END

CREATE PROCEDURE usp_CreateUser
    @Name VARCHAR(255),
    @Surname VARCHAR(255),
    @Username VARCHAR(255),
    @Password VARCHAR(255),
    @Gender VARCHAR(10)
AS
BEGIN
    INSERT INTO Users (Name, Surname, Username, Password, Gender)
    VALUES (@Name, @Surname, @Username, @Password, @Gender);
END

CREATE PROCEDURE usp_CreateCategory
    @Name VARCHAR(255)
AS
BEGIN
    INSERT INTO Categories (Name)
    VALUES (@Name);
END



EXEC usp_CreateMusic ' mahni', 100, 1, 2;


EXEC usp_CreateUser 'aqil', 'baxsiyev', 'aqilbaxsiyev', 'aqil12345', 'Male';

EXEC usp_CreateCategory 'nostaji';


ALTER TABLE Musics
ADD IsDeleted BIT NOT NULL DEFAULT 0;



CREATE TRIGGER tr_Musics_SoftDelete
ON Musics
INSTEAD OF DELETE
AS
BEGIN
    UPDATE m
    SET IsDeleted = 1
    FROM Musics m
    JOIN deleted d ON m.MusicID = d.MusicID;

   
    DELETE FROM Musics
    WHERE IsDeleted = 1;
END;



CREATE FUNCTION dbo.GetUniqueArtistsListenedByUser (@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @UniqueArtistsCount INT;
    
    SELECT @UniqueArtistsCount = COUNT(DISTINCT A.ArtistID)
    FROM Playlist_Music PM
    JOIN Musics M ON PM.MusicID = M.MusicID
    JOIN Artists A ON M.ArtistID = A.ArtistID
    WHERE PM.PlaylistID IN (SELECT PlaylistID FROM Playlists WHERE UserID = @UserID);

    RETURN @UniqueArtistsCount;
END;

DECLARE @UserID INT = 1;
SELECT dbo.GetUniqueArtistsListenedByUser(@UserID) AS UniqueArtistsCount;













