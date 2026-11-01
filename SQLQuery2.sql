CREATE DATABASE UniversityDB;
GO

USE UniversityDB;
GO

CREATE TABLE Researcher (
    ResearcherID INT PRIMARY KEY,
    Email VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) NULL,
    LastName VARCHAR(50) NOT NULL,
    Building VARCHAR(50) NULL,
    Room VARCHAR(20) NULL,
    SupervisorID INT NULL,
    SupervisionStartDate DATE NULL,
    SupervisionType VARCHAR(50) NULL,
    FOREIGN KEY (SupervisorID) REFERENCES Researcher(ResearcherID)
);

CREATE TABLE ResearcherPhone (
    ResearcherID INT NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (ResearcherID, Phone),
    FOREIGN KEY (ResearcherID) REFERENCES Researcher(ResearcherID)
);

CREATE TABLE ResearcherSpecialization (
    ResearcherID INT NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    PRIMARY KEY (ResearcherID, Specialization),
    FOREIGN KEY (ResearcherID) REFERENCES Researcher(ResearcherID)
);

CREATE TABLE ResearchProject (
    ProjectID VARCHAR(10) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    TotalBudget DECIMAL(18,2) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    LeaderID INT NOT NULL,
    FOREIGN KEY (LeaderID) REFERENCES Researcher(ResearcherID)
);

CREATE TABLE ProjectKeyword (
    ProjectID VARCHAR(10) NOT NULL,
    Keyword VARCHAR(100) NOT NULL,
    PRIMARY KEY (ProjectID, Keyword),
    FOREIGN KEY (ProjectID) REFERENCES ResearchProject(ProjectID)
);

CREATE TABLE WorksOn (
    ResearcherID INT NOT NULL,
    ProjectID VARCHAR(10) NOT NULL,
    JoinDate DATE NOT NULL,
    Role VARCHAR(50) NULL,
    HoursPerWeek DECIMAL(5,2) NULL,
    CreditPercent DECIMAL(5,2) NULL,
    PRIMARY KEY (ResearcherID, ProjectID),
    FOREIGN KEY (ResearcherID) REFERENCES Researcher(ResearcherID),
    FOREIGN KEY (ProjectID) REFERENCES ResearchProject(ProjectID)
);

CREATE TABLE Publication (
    PublicationID INT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    PublicationDate DATE NULL,
    DOI VARCHAR(100) NULL,
    PublicationType VARCHAR(20) NOT NULL,
    CitationCount INT NOT NULL DEFAULT 0
);

CREATE TABLE PublicationKeyword (
    PublicationID INT NOT NULL,
    Keyword VARCHAR(100) NOT NULL,
    PRIMARY KEY (PublicationID, Keyword),
    FOREIGN KEY (PublicationID) REFERENCES Publication(PublicationID)
);

CREATE TABLE Authors (
    ResearcherID INT NOT NULL,
    PublicationID INT NOT NULL,
    AuthorPosition INT NULL,
    ContributionType VARCHAR(50) NULL,
    PRIMARY KEY (ResearcherID, PublicationID),
    FOREIGN KEY (ResearcherID) REFERENCES Researcher(ResearcherID),
    FOREIGN KEY (PublicationID) REFERENCES Publication(PublicationID)
);

CREATE TABLE Grants (
    GrantID INT PRIMARY KEY,
    GrantName VARCHAR(200) NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    StartDate DATE NULL,
    EndDate DATE NULL,
    FundingAgency VARCHAR(100) NULL
);

CREATE TABLE Funds (
    GrantID INT NOT NULL,
    ProjectID VARCHAR(10) NOT NULL,
    AllocatedAmount DECIMAL(18,2) NULL,
    AllocationDate DATE NULL,
    PRIMARY KEY (GrantID, ProjectID),
    FOREIGN KEY (GrantID) REFERENCES Grants(GrantID),
    FOREIGN KEY (ProjectID) REFERENCES ResearchProject(ProjectID)
);