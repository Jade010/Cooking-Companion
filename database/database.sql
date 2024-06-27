-- Users table
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY, -- auto-increment
    Username NVARCHAR(50) NOT NULL UNIQUE, -- usernames cannot be the same
    Email NVARCHAR(50) NOT NULL UNIQUE, -- one email per account
    PasswordHash NVARCHAR(255) NOT NULL, -- passwords required
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('admin', 'regular'))
);

-- Categories table
CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY, 
    Name NVARCHAR(50) NOT NULL, -- Category name
    Subcategories NVARCHAR(MAX) -- JSON array of subcategories
);

-- Recipes table
CREATE TABLE Recipes (
    RecipeId INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Author NVARCHAR(50) NOT NULL,
    Date DATETIME NOT NULL DEFAULT GETDATE(),
    Ingredients NVARCHAR(MAX) NOT NULL, -- JSON string
    Instructions NVARCHAR(MAX) NOT NULL, -- JSON array
    PrepTime INT,
    CookTime INT,
    Servings INT,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- RecipeCategories Table for Many-to-Many Relationship
CREATE TABLE RecipeCategories (
    RecipeId INT NOT NULL,
    CategoryId INT NOT NULL,
    PRIMARY KEY (RecipeId, CategoryId),
    FOREIGN KEY (RecipeId) REFERENCES Recipes(RecipeId),
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);


-- Predetermined Categories insert
INSERT INTO Categories (Name, Subcategories) VALUES
('Course', '["Appetizers", "Main Courses", "Desserts", "Snacks", "Soups", "Salads", "Beverages", "Side Dishes"]'),
('Cuisine', '["Italian", "Mexican", "Chinese", "Indian", "French", "Japanese", "Mediterranean", "American"]'),
('Dietary Restrictions', '["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free", "Keto", "Paleo", "Low-Carb"]'),
('Meal Type', '["Breakfast", "Brunch", "Lunch", "Dinner", "Snacks"]'),
('Preparation Method', '["Baking", "Grilling", "Roasting", "Stir-Frying", "Slow Cooking", "Pressure Cooking", "No-Cook"]'),
('Occasions', '["Holiday", "Party", "Family Gatherings", "Quick & Easy", "Comfort Food", "Healthy"]'),
('Health & Lifestyle', '["Low-Fat", "Low-Sodium", "High-Protein", "Sugar-Free", "Heart-Healthy"]');



-- Triggers

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
