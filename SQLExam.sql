CREATE TABLE Owners(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes(
	Id INT PRIMARY KEY IDENTITY,
	AnimalType VARCHAR(30) NOT NULL,
)

CREATE TABLE Cages(
	Id INT PRIMARY KEY IDENTITY,
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE Animals(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL,
	OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE AnimalsCages(
	CageId INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Cages(Id),
	AnimalId INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Animals(Id),
	PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments(
	Id INT PRIMARY KEY IDENTITY,
	DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
	DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

--2nd INSERT
SELECT * FROM Volunteers

go
([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
([Name], BirthDate, OwnerId, AnimalTypeId)

INSERT INTO Volunteers VALUES 
	('Anita Kostova',	0896365412,	'Sofia, 5 Rosa str.',	15,	1),
	('Dimitur Stoev',   0877564223, null, 42, 4),
	('Kalina Evtimova',	0896321112,	'Silistra, 21 Breza str.',	9,	7),
	('Stoyan Tomov',	0898564100,	'Montana, 1 Bor str.',	18,	8),
	('Boryana Mileva',	0888112233,	null,	31,	5)


INSERT INTO Animals VALUES 
(	'Giraffe',	'2018-09-21',	21,	1),
('Harpy Eagle',	'2015-04-17',	15,	3),
('Hamadryas Baboon',	'2017-11-02',null,	1),
('Tuatara',	'2021-06-30',	2,	4)


--3rd update
select * from Owners where [Name] = 'Kaloqn Stoqnov'
UPDATE Animals SET OwnerId = 4 WHERE OwnerId IS NULL

--4th delete
SELECT * FROM Volunteers where DepartmentId = 2
SELECT * FROM VolunteersDepartments

DELETE FROM Volunteers WHERE DepartmentId = 2
DELETE FROM VolunteersDepartments WHERE Id = 2

--5th Volunteers
SELECT v.[Name], v.PhoneNumber, v.[Address], v.AnimalId, v.DepartmentId FROM Volunteers AS v ORDER BY v.[Name] ASC, v.AnimalId ASC, v.DepartmentId ASC

--6th Animals Data
SELECT a.[Name], [at].AnimalType,FORMAT(a.BirthDate, 'dd.MM.yyyy') FROM Animals AS a JOIN AnimalTypes AS [at] ON a.AnimalTypeId = [at].Id ORDER BY a.[Name]

--7th owners and their animals
SELECT TOP(5) o.[Name], (SELECT COUNT(*) FROM Animals WHERE OwnerId = o.Id) AS CountOfAnimals FROM Owners AS o ORDER BY CountOfAnimals DESC, o.[Name]

--8th ⦁	Owners, Animals and Cages
SELECT * FROM AnimalTypes
SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals, o.PhoneNumber, (SELECT CageId FROM AnimalsCages WHERE AnimalId = a.Id) AS CageId FROM Owners AS o  JOIN Animals AS a ON o.Id = a.OwnerId WHERE a.AnimalTypeId = 1 ORDER BY o.[Name] ASC, a.[Name] DESC 

SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals, o.PhoneNumber, (SELECT CageId FROM AnimalsCages WHERE AnimalId = a.Id) AS CageId FROM Owners AS o 
INNER JOIN Animals AS a ON o.Id = a.OwnerId WHERE a.AnimalTypeId = (SELECT Id FROM AnimalTypes WHERE AnimalType = 'Mammals') ORDER BY o.[Name] ASC, a.[Name] DESC 


--9th Volunteers in Sofia
SELECT * FROM VolunteersDepartments
SELECT [Address] FROM Volunteers
-- id 2
--substring ( adres, charindex, len(adres))
SELECT * FROM Volunteers WHERE [Name] = 'Dilyana Stoeva'
SELECT [Name], PhoneNumber, SUBSTRING([Address], PATINDEX('%[0-9]%', [Address]), LEN([Address])) AS [Address] FROM Volunteers WHERE [Address] LIKE '%Sofia%' AND DepartmentId = 2 ORDER BY [Name]
SELECT [Address], SUBSTRING([Address], PATINDEX('%[0-9]%', [Address]), LEN([Address])) FROM Volunteers

--10th animals for adoption
SELECT a.[Name], YEAR(a.BirthDate) AS BirthYear, (SELECT AnimalType FROM AnimalTypes WHERE Id = a.AnimalTypeId) AS AnimalType FROM Animals AS a WHERE a.OwnerId IS NULL AND YEAR(a.BirthDate) > '2017' AND a.AnimalTypeId <> 3  ORDER BY [Name]

SELECT * FROM Animals where AnimalTypeId = 3

SELECT a.[Name], YEAR(a.BirthDate) AS BirthYear, (SELECT AnimalType FROM AnimalTypes WHERE AnimalType = a.[Name]) AS AnimalType FROM Animals AS a WHERE 
OwnerId IS NULL AND (YEAR(BirthDate) >= 2018 OR AnimalTypeId = 3) ORDER BY a.[Name]

--11th All Volunteers in a Department

SELECT Count(*) FROM Volunteers where DepartmentId = (SELECT v.Id from VolunteersDepartments as v WHERE v.DepartmentName = 'Education program assistant')
DEClARE @res INT
SET @res = SELECT Id FROM Volunteers WHERE DepartmentId = 2
 SELECT COUNT(SELECT Id FROM Volunteers WHERE DepartmentId = 2)

SELECT * FROM Volunteers
go 

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@name VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @volunteerCount INT;
	set @volunteerCount = (SELECT Count(*) FROM Volunteers where DepartmentId = (SELECT v.Id from VolunteersDepartments as v WHERE v.DepartmentName = @name));

	RETURN @volunteerCount;
END
go

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')


--12th ⦁	Animals with Owner or Not
EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'

SELECT OwnerId FROM Animals WHERE [Name] = 'Pumpkinseed Sunfish'

SELECT [Name] FROM Owners WHERE Id = (SELECT OwnerId FROM Animals WHERE [Name] = 'Pumpkinseed Sunfish')

SELECT a.[Name] AS [Name], 
CASE
	WHEN a.OwnerId IS NULL THEN 'For adoption'
	ELSE (SELECT [Name] FROM Owners WHERE Id = a.OwnerId)
	END
	 AS OwnersName
FROM Animals AS a WHERE a.[Name] = 'Pumpkinseed Sunfish'

SELECT * FROM Animals WHERE [Name] = 'Pumpkinseed Sunfish'


go
CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
SELECT a.[Name] AS [Name], 
CASE
	WHEN a.OwnerId IS NULL THEN 'For adoption'
	ELSE (SELECT [Name] FROM Owners WHERE Id = a.OwnerId)
	END
	 AS OwnersName
FROM Animals AS a WHERE a.[Name] = @AnimalName
go

EXEC usp_AnimalsWithOwnersOrNot 'Hippo'




SELECT * FROM AnimalTypes

--8th ⦁	Owners, Animals and Cages
SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals, o.PhoneNumber, ac.CageId FROM Owners AS o JOIN Animals AS a ON o.Id = a.OwnerId JOIN AnimalsCages AS ac ON ac.AnimalId = a.Id WHERE a.AnimalTypeId = 1 ORDER BY o.[Name] ASC, a.[Name] DESC