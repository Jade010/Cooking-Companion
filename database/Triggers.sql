-- Password complexity
CREATE TRIGGER trg_CheckPasswordComplexity
ON Users
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @Password NVARCHAR(255)
    SELECT @Password = inserted.PasswordHash
    FROM inserted

    IF NOT (
        @Password LIKE '%[A-Z]%' AND
        @Password LIKE '%[a-z]%' AND
        @Password LIKE '%[0-9]%' AND
        @Password LIKE '%[!@#$%^&*()]%'
    )
    BEGIN
        ROLLBACK;
        RAISERROR ('Password does not meet requirements.', 16, 1);
    END
END;
GO

-- Updating recipe timestamp 
CREATE TRIGGER trg_UpdateRecipeTimestamp
ON Recipes
FOR UPDATE
AS
BEGIN
    UPDATE Recipes
    SET Date = GETDATE()
    FROM inserted
    WHERE Recipes.RecipeId = inserted.RecipeId;
END;
GO

-- No repeated categories 
CREATE TRIGGER trg_UniqueCategoryName
ON Categories
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @CategoryName NVARCHAR(50)
    SELECT @CategoryName = inserted.Name
    FROM inserted

    IF EXISTS (SELECT 1 FROM Categories WHERE Name = @CategoryName)
    BEGIN
        ROLLBACK;
        RAISERROR ('Category name must be unique.', 16, 1);
    END
END;
GO

-- User roles
CREATE TRIGGER trg_EnforceUserRole
ON Users
FOR INSERT, UPDATE
AS
BEGIN
    -- Declaring variables to hold inserted values
    DECLARE @Email NVARCHAR(50);
    DECLARE @Role NVARCHAR(20);

    -- Selecting the inserted values
    SELECT @Email = inserted.Email, @Role = inserted.Role
    FROM inserted;

    -- Check if the inserted/updated user is the admin account
    IF @Email = 'admin@example.com'
    BEGIN
        -- Allow the admin account to retain the "admin" role
        IF @Role != 'admin'
        BEGIN
            -- Revert to "admin" role if any other role is set
            UPDATE Users
            SET Role = 'admin'
            WHERE Email = @Email;
        END
    END
    ELSE
    BEGIN
        -- For all other users, enforce "regular" role
        UPDATE Users
        SET Role = 'regular'
        WHERE Email = @Email;
    END
END;
GO
