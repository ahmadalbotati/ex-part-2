USE UniversityDB;
GO
SELECT r.ResearcherID, r.FirstName, r.LastName, p.Title AS ProjectTitle
FROM Researcher r
LEFT JOIN WorksOn w ON r.ResearcherID = w.ResearcherID
LEFT JOIN ResearchProject p ON w.ProjectID = p.ProjectID;

SELECT p.ProjectID, p.Title,
       CONCAT_WS(' ', l.FirstName, l.MiddleName, l.LastName) AS LeaderFullName,
       l.Email
FROM ResearchProject p
JOIN Researcher l ON p.LeaderID = l.ResearcherID
WHERE EXISTS (SELECT 1 FROM Funds f WHERE f.ProjectID = p.ProjectID);

SELECT r.ResearcherID, r.FirstName, r.LastName, p.PublicationID, p.Title
FROM Researcher r
CROSS JOIN Publication p;

SELECT CONCAT_WS(' ', s.FirstName, s.MiddleName, s.LastName) AS SupervisorName,
       CONCAT_WS(' ', e.FirstName, e.MiddleName, e.LastName) AS SupervisedName,
       e.SupervisionStartDate, e.SupervisionType AS Role
FROM Researcher e
JOIN Researcher s ON e.SupervisorID = s.ResearcherID;

SELECT r.*
FROM Researcher r
WHERE EXISTS (SELECT 1 FROM Authors a WHERE a.ResearcherID = r.ResearcherID)
  AND NOT EXISTS (SELECT 1
                  FROM WorksOn w
                  JOIN ResearchProject p ON w.ProjectID = p.ProjectID
                  WHERE w.ResearcherID = r.ResearcherID AND p.Status = 'Active');

SELECT TOP (5) WITH TIES *
FROM Publication
ORDER BY CitationCount DESC;

SELECT *
FROM Researcher
ORDER BY LastName
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT ResearcherID, FirstName, LastName, Building, DateOfBirth,
       ROW_NUMBER() OVER (PARTITION BY Building ORDER BY DateOfBirth ASC) AS SeqIndex
FROM Researcher;

SELECT Title, PublicationType, CitationCount,
       RANK() OVER (PARTITION BY PublicationType ORDER BY CitationCount DESC) AS PubRank
FROM Publication;

SELECT Title, Status, TotalBudget,
       RANK()       OVER (PARTITION BY Status ORDER BY TotalBudget DESC) AS RankWithGaps,
       DENSE_RANK() OVER (PARTITION BY Status ORDER BY TotalBudget DESC) AS RankWithoutGaps
FROM ResearchProject;

SELECT r.ResearcherID,
       CONCAT_WS(' ', r.FirstName, r.MiddleName, r.LastName) AS FullName,
       COUNT(a.PublicationID) AS PublicationCount,
       NTILE(4) OVER (ORDER BY COUNT(a.PublicationID) DESC) AS GroupNumber
FROM Researcher r
LEFT JOIN Authors a ON r.ResearcherID = a.ResearcherID
GROUP BY r.ResearcherID, r.FirstName, r.MiddleName, r.LastName;

SELECT ResearcherID, COUNT(*) AS ProjectCount
FROM WorksOn
GROUP BY ResearcherID
HAVING COUNT(*) > 2;

SELECT CONCAT_WS(' ', FirstName, MiddleName, LastName) AS FullName,
       LOWER(Email) AS Email,
       DATEDIFF(YEAR, DateOfBirth, GETDATE())
         - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateOfBirth, GETDATE()), DateOfBirth) > GETDATE()
                THEN 1 ELSE 0 END AS AgeInYears
FROM Researcher;

SELECT ProjectID, Title,
       DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE())) AS DurationDays,
       DATENAME(MONTH, StartDate) AS StartMonth,
       YEAR(StartDate) AS StartYear
FROM ResearchProject;

SELECT *
FROM Researcher
WHERE Email LIKE '%@university.edu';

SELECT ResearcherID, FirstName,
       ISNULL(MiddleName, 'N/A') AS MiddleName,
       LastName, Email, Building,
       ISNULL(CAST(Room AS VARCHAR(20)), 'N/A') AS Room
FROM Researcher;

SELECT ProjectID, Title, TotalBudget,
       CASE WHEN TotalBudget < 50000 THEN 'Small'
            WHEN TotalBudget BETWEEN 50000 AND 150000 THEN 'Medium'
            ELSE 'Large'
       END AS BudgetCategory
FROM ResearchProject;

SELECT CONCAT_WS(' ', r.FirstName, r.MiddleName, r.LastName) AS FullName,
       SUM(p.TotalBudget) AS TotalBudgetManaged
FROM Researcher r
JOIN ResearchProject p ON p.LeaderID = r.ResearcherID
GROUP BY r.ResearcherID, r.FirstName, r.MiddleName, r.LastName;

SELECT Building, COUNT(*) AS ResearcherCount
FROM Researcher
GROUP BY Building
HAVING COUNT(*) > 3;

SELECT PublicationType,
       AVG(CitationCount * 1.0) AS AvgCitations,
       SUM(CitationCount) AS TotalCitations,
       COUNT(*) AS PublicationCount
FROM Publication
GROUP BY PublicationType
HAVING AVG(CitationCount * 1.0) > 50;

SELECT ResearcherID, COUNT(ProjectID) AS ProjectCount, SUM(HoursPerWeek) AS TotalHours
FROM WorksOn
GROUP BY ResearcherID
HAVING COUNT(ProjectID) > 2 AND SUM(HoursPerWeek) > 60;

SELECT *
FROM ResearchProject
WHERE TotalBudget > (SELECT AVG(TotalBudget) FROM ResearchProject);

SELECT r.*
FROM Researcher r
WHERE (SELECT COUNT(*) FROM Authors a WHERE a.ResearcherID = r.ResearcherID)
    > (SELECT AVG(x.PubCount * 1.0)
       FROM (SELECT r2.ResearcherID, COUNT(a2.PublicationID) AS PubCount
             FROM Researcher r2
             LEFT JOIN Authors a2 ON a2.ResearcherID = r2.ResearcherID
             WHERE r2.Building = r.Building
             GROUP BY r2.ResearcherID) x);

SELECT s.*
FROM Researcher s
WHERE EXISTS (SELECT 1 FROM Researcher e WHERE e.SupervisorID = s.ResearcherID);

SELECT p.ProjectID, p.Title,
       (SELECT COUNT(*) FROM WorksOn w WHERE w.ProjectID = p.ProjectID) AS ResearcherCount
FROM ResearchProject p;

SELECT MAX(TotalBudget) AS SecondHighestBudget
FROM ResearchProject
WHERE TotalBudget < (SELECT MAX(TotalBudget) FROM ResearchProject);

SELECT r.*
FROM Researcher r
WHERE EXISTS (SELECT 1 FROM WorksOn w WHERE w.ResearcherID = r.ResearcherID)
  AND NOT EXISTS (SELECT 1 FROM Authors a WHERE a.ResearcherID = r.ResearcherID);

SELECT Email AS [Contact Information] FROM Researcher
UNION
SELECT FundingAgency FROM Grants;

SELECT r.*
FROM Researcher r
WHERE EXISTS (SELECT 1 FROM Researcher e WHERE e.SupervisorID = r.ResearcherID)
  AND EXISTS (SELECT 1 FROM ResearchProject p WHERE p.LeaderID = r.ResearcherID);

WITH ResearcherHours AS (
    SELECT ResearcherID, SUM(HoursPerWeek) AS TotalHours
    FROM WorksOn
    GROUP BY ResearcherID
)
SELECT r.ResearcherID,
       CONCAT_WS(' ', r.FirstName, r.MiddleName, r.LastName) AS FullName,
       h.TotalHours
FROM ResearcherHours h
JOIN Researcher r ON r.ResearcherID = h.ResearcherID
WHERE h.TotalHours > 40;

WITH LeaderBudget AS (
    SELECT LeaderID AS ResearcherID, SUM(TotalBudget) AS TotalBudget
    FROM ResearchProject
    GROUP BY LeaderID
),
PubCount AS (
    SELECT ResearcherID, COUNT(*) AS PublicationCount
    FROM Authors
    GROUP BY ResearcherID
)
SELECT r.ResearcherID,
       CONCAT_WS(' ', r.FirstName, r.MiddleName, r.LastName) AS FullName,
       b.TotalBudget, p.PublicationCount
FROM Researcher r
JOIN LeaderBudget b ON b.ResearcherID = r.ResearcherID
JOIN PubCount p ON p.ResearcherID = r.ResearcherID
WHERE b.TotalBudget > 100000 AND p.PublicationCount >= 3;
GO

CREATE FUNCTION dbo.fn_ProjectActiveDays (@ProjectID VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @Days INT;
    SELECT @Days = DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE()))
    FROM ResearchProject
    WHERE ProjectID = @ProjectID;
    RETURN @Days;
END;
GO

CREATE FUNCTION dbo.fn_ResearcherProjects (@ResearcherID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.Title, w.Role, w.HoursPerWeek
    FROM WorksOn w
    JOIN ResearchProject p ON p.ProjectID = w.ProjectID
    WHERE w.ResearcherID = @ResearcherID
);
GO

CREATE FUNCTION dbo.fn_ResearcherSummary (@ResearcherID INT)
RETURNS @Result TABLE
(
    TotalProjects INT,
    TotalPublications INT,
    TotalHoursPerWeek DECIMAL(10,2),
    AvgCitationsPerPublication DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT
        (SELECT COUNT(*) FROM WorksOn WHERE ResearcherID = @ResearcherID),
        (SELECT COUNT(*) FROM Authors WHERE ResearcherID = @ResearcherID),
        (SELECT ISNULL(SUM(HoursPerWeek), 0) FROM WorksOn WHERE ResearcherID = @ResearcherID),
        (SELECT ISNULL(AVG(p.CitationCount * 1.0), 0)
         FROM Authors a
         JOIN Publication p ON p.PublicationID = a.PublicationID
         WHERE a.ResearcherID = @ResearcherID);
    RETURN;
END;
GO

CREATE NONCLUSTERED INDEX IX_ResearchProject_Status_StartDate
ON ResearchProject (Status, StartDate);
GO

CREATE NONCLUSTERED INDEX IX_Researcher_Email_Covering
ON Researcher (Email)
INCLUDE (FirstName, LastName);
GO

CREATE VIEW dbo.ActiveProjectSummary
AS
SELECT p.Title,
       CONCAT_WS(' ', l.FirstName, l.MiddleName, l.LastName) AS LeaderName,
       COUNT(w.ResearcherID) AS TeamMembers,
       ISNULL(SUM(w.HoursPerWeek), 0) AS TotalHoursPerWeek,
       p.TotalBudget
FROM ResearchProject p
JOIN Researcher l ON l.ResearcherID = p.LeaderID
LEFT JOIN WorksOn w ON w.ProjectID = p.ProjectID
WHERE p.Status = 'Active'
GROUP BY p.ProjectID, p.Title, l.FirstName, l.MiddleName, l.LastName, p.TotalBudget;
GO

CREATE VIEW dbo.ResearcherPublicationStats
WITH SCHEMABINDING
AS
SELECT r.ResearcherID,
       r.FirstName + ' ' + ISNULL(r.MiddleName + ' ', '') + r.LastName AS FullName,
       COUNT_BIG(*) AS TotalPublications
FROM dbo.Researcher r
JOIN dbo.Authors a ON a.ResearcherID = r.ResearcherID
GROUP BY r.ResearcherID, r.FirstName, r.MiddleName, r.LastName;
GO

CREATE UNIQUE CLUSTERED INDEX IX_ResearcherPublicationStats
ON dbo.ResearcherPublicationStats (ResearcherID);
GO

CREATE PROCEDURE dbo.AddResearcherToProject
    @ResearcherID INT,
    @ProjectID VARCHAR(10),
    @JoinDate DATE,
    @Role VARCHAR(50),
    @HoursPerWeek DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Researcher WHERE ResearcherID = @ResearcherID)
        RETURN -1;

    IF NOT EXISTS (SELECT 1 FROM ResearchProject WHERE ProjectID = @ProjectID)
        RETURN -1;

    IF EXISTS (SELECT 1 FROM WorksOn WHERE ResearcherID = @ResearcherID AND ProjectID = @ProjectID)
        RETURN -1;

    BEGIN TRY
        INSERT INTO WorksOn (ResearcherID, ProjectID, JoinDate, Role, HoursPerWeek)
        VALUES (@ResearcherID, @ProjectID, @JoinDate, @Role, @HoursPerWeek);
        RETURN 0;
    END TRY
    BEGIN CATCH
        RETURN -1;
    END CATCH
END;
GO

CREATE PROCEDURE dbo.UpdateProjectStatus
    @ProjectID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ResearchProject WHERE ProjectID = @ProjectID AND Status = 'Pending')
            THROW 50001, 'Project does not exist or its status is not Pending.', 1;

        IF NOT EXISTS (SELECT 1 FROM WorksOn WHERE ProjectID = @ProjectID)
            THROW 50002, 'Project has no researchers assigned.', 1;

        IF NOT EXISTS (SELECT 1 FROM Funds WHERE ProjectID = @ProjectID)
            THROW 50003, 'Project has no funding source.', 1;

        UPDATE ResearchProject
        SET Status = 'Active'
        WHERE ProjectID = @ProjectID AND Status = 'Pending';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE dbo.GetResearcherStats
    @ResearcherID INT,
    @TotalProjects INT OUTPUT,
    @TotalPublications INT OUTPUT,
    @TotalWeeklyHours DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalProjects = COUNT(*),
           @TotalWeeklyHours = ISNULL(SUM(HoursPerWeek), 0)
    FROM WorksOn
    WHERE ResearcherID = @ResearcherID;

    SELECT @TotalPublications = COUNT(*)
    FROM Authors
    WHERE ResearcherID = @ResearcherID;
END;
GO

CREATE TRIGGER trg_WorksOn_MaxFiveProjects
ON WorksOn
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1
               FROM WorksOn w
               WHERE w.ResearcherID IN (SELECT ResearcherID FROM inserted)
               GROUP BY w.ResearcherID
               HAVING COUNT(*) > 5)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50010, 'A researcher cannot be assigned to more than 5 projects.', 1;
    END
END;
GO

CREATE TRIGGER trg_ResearchProject_AutoComplete
ON ResearchProject
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(EndDate)
        UPDATE p
        SET p.Status = 'Completed'
        FROM ResearchProject p
        JOIN inserted i ON i.ProjectID = p.ProjectID
        WHERE i.EndDate < CAST(GETDATE() AS DATE)
          AND p.Status <> 'Completed';
END;
GO

CREATE TABLE GrantsAudit
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    GrantID INT,
    OldAmount DECIMAL(18,2),
    NewAmount DECIMAL(18,2),
    ModifiedBy NVARCHAR(128),
    ModifiedDate DATETIME
);
GO

CREATE TRIGGER trg_Grants_Audit
ON Grants
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO GrantsAudit (GrantID, OldAmount, NewAmount, ModifiedBy, ModifiedDate)
    SELECT d.GrantID, d.TotalAmount, i.TotalAmount, SYSTEM_USER, GETDATE()
    FROM deleted d
    JOIN inserted i ON i.GrantID = d.GrantID;
END;
GO

DECLARE @ProjectID VARCHAR(10) = 'P100',
        @Title VARCHAR(200) = 'New Project',
        @StartDate DATE = GETDATE(),
        @Budget DECIMAL(18,2) = 100000,
        @LeaderID INT = 1,
        @HoursPerWeek DECIMAL(5,2) = 10,
        @GrantID INT = 1,
        @AllocatedAmount DECIMAL(18,2) = 50000;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO ResearchProject (ProjectID, Title, StartDate, TotalBudget, Status, LeaderID)
    VALUES (@ProjectID, @Title, @StartDate, @Budget, 'Pending', @LeaderID);

    INSERT INTO WorksOn (ResearcherID, ProjectID, JoinDate, Role, HoursPerWeek)
    VALUES (@LeaderID, @ProjectID, @StartDate, 'Leader', @HoursPerWeek);

    INSERT INTO Funds (GrantID, ProjectID, AllocatedAmount, AllocationDate)
    VALUES (@GrantID, @ProjectID, @AllocatedAmount, GETDATE());

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

CREATE NONCLUSTERED INDEX IX_ResearchProject_Status_StartDate_Desc
ON ResearchProject (Status, StartDate DESC)
INCLUDE (ProjectID, Title);
GO

CREATE NONCLUSTERED INDEX IX_WorksOn_ProjectID
ON WorksOn (ProjectID)
INCLUDE (ResearcherID);
GO

SELECT p.Title, r.FirstName, r.LastName
FROM ResearchProject p
JOIN WorksOn w ON p.ProjectID = w.ProjectID
JOIN Researcher r ON w.ResearcherID = r.ResearcherID
WHERE p.Status = 'Active'
ORDER BY p.StartDate DESC;

GRANT CONTROL ON SCHEMA::dbo TO ResearchManager;

GRANT SELECT, INSERT ON dbo.Researcher TO ResearchAssistant;
GRANT SELECT, INSERT ON dbo.Publication TO ResearchAssistant;

GRANT SELECT ON dbo.ActiveProjectSummary TO DataAnalyst;
GRANT SELECT ON dbo.ResearcherPublicationStats TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Researcher TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.ResearchProject TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.WorksOn TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Publication TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Authors TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Grants TO DataAnalyst;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Funds TO DataAnalyst;
GO

REVOKE INSERT, UPDATE ON dbo.Researcher FROM ResearchAssistant;