CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    DateCreated DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

CREATE UNIQUE INDEX IX_Users_Email ON dbo.Users(Email);

CREATE TABLE dbo.Complaints (
    ComplaintID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Subject NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    DateSubmitted DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'Open',
    CONSTRAINT FK_Complaints_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);

CREATE TABLE dbo.Subscribers (
    SubscriberID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    SubscribedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

CREATE UNIQUE INDEX IX_Subscribers_Email ON dbo.Subscribers(Email);

INSERT INTO dbo.Users (FullName, Email, Password) VALUES ('Test User', 'test@example.com', '123456');

SELECT 'Users' as TableName, COUNT(*) as RecordCount FROM dbo.Users
UNION ALL
SELECT 'Complaints', COUNT(*) FROM dbo.Complaints
UNION ALL  
SELECT 'Subscribers', COUNT(*) FROM dbo.Subscribers;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME IN ('Users', 'Complaints', 'Subscribers')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

PRINT 'Database tables created successfully!';

SELECT * FROM dbo.Complaints;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Subscribers;



USE pia;
GO


IF OBJECT_ID('dbo.Complaints', 'U') IS NOT NULL
BEGIN
    -- Check if ResponseMessage column exists, if not add it
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Complaints' AND COLUMN_NAME = 'ResponseMessage')
    BEGIN
        ALTER TABLE dbo.Complaints ADD ResponseMessage NVARCHAR(MAX) NULL;
        PRINT 'Added ResponseMessage column to Complaints table';
    END
    
    -- Check if LastUpdated column exists, if not add it
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Complaints' AND COLUMN_NAME = 'LastUpdated')
    BEGIN
        ALTER TABLE dbo.Complaints ADD LastUpdated DATETIME NULL;
        PRINT 'Added LastUpdated column to Complaints table';
    END
END
ELSE
BEGIN
    -- Create new Complaints table with all columns
    CREATE TABLE dbo.Complaints (
        ComplaintID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        Subject NVARCHAR(200) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        DateSubmitted DATETIME DEFAULT GETDATE(),
        Status NVARCHAR(50) DEFAULT 'Open',
        ResponseMessage NVARCHAR(MAX) NULL,
        LastUpdated DATETIME NULL,
        CONSTRAINT FK_Complaints_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
    );
    PRINT 'Created new Complaints table with enhanced structure';
END
GO

-- Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Complaints_UserID')
BEGIN
    CREATE INDEX IX_Complaints_UserID ON dbo.Complaints(UserID);
    PRINT 'Created index on UserID';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Complaints_DateSubmitted')
BEGIN
    CREATE INDEX IX_Complaints_DateSubmitted ON dbo.Complaints(DateSubmitted);
    PRINT 'Created index on DateSubmitted';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Complaints_Status')
BEGIN
    CREATE INDEX IX_Complaints_Status ON dbo.Complaints(Status);
    PRINT 'Created index on Status';
END

-- Insert sample complaints for testing (OPTIONAL)
-- Only insert if no data exists
IF NOT EXISTS (SELECT * FROM dbo.Complaints)
BEGIN
    -- Get a test user ID
    DECLARE @TestUserID INT;
    SELECT TOP 1 @TestUserID = UserID FROM dbo.Users;
    
    IF @TestUserID IS NOT NULL
    BEGIN
        -- Insert sample complaints with different timestamps for testing
        INSERT INTO dbo.Complaints (UserID, Subject, Message, DateSubmitted, Status) VALUES
        (@TestUserID, 'Login Issues', 'I am having trouble logging into my account. The password seems correct but it keeps saying invalid.', DATEADD(HOUR, -30, GETDATE()), 'Open'),
        (@TestUserID, 'Application Process Unclear', 'The internship application process is not clear. Can you provide more details?', DATEADD(HOUR, -12, GETDATE()), 'Open'),
        (@TestUserID, 'Website Loading Slow', 'The website is loading very slowly on my computer. Is there a technical issue?', DATEADD(HOUR, -6, GETDATE()), 'Open'),
        (@TestUserID, 'Email Not Received', 'I have not received confirmation email after signup.', DATEADD(MINUTE, -30, GETDATE()), 'Open');
        
        PRINT 'Inserted sample complaint data';
    END
    ELSE
    BEGIN
        PRINT 'No users found - cannot insert sample complaints';
    END
END
ELSE
BEGIN
    PRINT 'Complaints table already contains data';
END

-- Create a stored procedure to automatically update complaint statuses
IF OBJECT_ID('dbo.UpdateComplaintStatuses', 'P') IS NOT NULL
    DROP PROCEDURE dbo.UpdateComplaintStatuses;
GO

CREATE PROCEDURE dbo.UpdateComplaintStatuses
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update complaints older than 24 hours to "Completed"
    UPDATE dbo.Complaints 
    SET Status = 'Completed',
        ResponseMessage = CASE 
            WHEN ResponseMessage IS NULL 
            THEN 'Thank you for your complaint. This matter has been reviewed and resolved by our team.'
            ELSE ResponseMessage
        END,
        LastUpdated = GETDATE()
    WHERE DateSubmitted <= DATEADD(HOUR, -24, GETDATE()) 
    AND Status IN ('Open', 'Pending');
    
    DECLARE @CompletedCount INT = @@ROWCOUNT;
    
    -- Update complaints between 1-24 hours to "Pending"
    UPDATE dbo.Complaints 
    SET Status = 'Pending',
        LastUpdated = GETDATE()
    WHERE DateSubmitted > DATEADD(HOUR, -24, GETDATE()) 
    AND DateSubmitted <= DATEADD(HOUR, -1, GETDATE())
    AND Status = 'Open';
    
    DECLARE @PendingCount INT = @@ROWCOUNT;
    
    PRINT CONCAT('Updated ', @CompletedCount, ' complaints to Completed and ', @PendingCount, ' to Pending');
END
GO

-- Test the stored procedure
EXEC dbo.UpdateComplaintStatuses;

-- Show final table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Complaints'
ORDER BY ORDINAL_POSITION;

-- Show sample data
SELECT TOP 5 
    ComplaintID,
    Subject,
    Status,
    DateSubmitted,
    ResponseMessage
FROM dbo.Complaints
ORDER BY DateSubmitted DESC;

PRINT 'Enhanced complaints system setup completed successfully!';

SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Complaints'

SELECT COUNT(*) FROM dbo.Complaints WHERE UserID = [your_user_id]
