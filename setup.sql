USE my-database-e-commerce;

DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name NVARCHAR(255) NOT NULL,
  address NVARCHAR(255) NOT NULL
);

INSERT INTO Employees (name, address)
VALUES ('Vincent Llauderes', 'Caloocan City'), ('Apple Pangantihon', 'Pasig City');