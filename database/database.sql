CREATE DATABASE CookingCompanionDb;
GO

USE CookingCompanionDb;
GO

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
