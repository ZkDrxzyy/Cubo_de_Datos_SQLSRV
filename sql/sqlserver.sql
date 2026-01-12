-- 1. Crear la base de datos
CREATE DATABASE OLAP_Ventas_DB;
GO

USE OLAP_Ventas_DB;
GO

-- 2. Crear las tablas de Dimensiones
CREATE TABLE dim_producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    categoria VARCHAR(50),
    nombre VARCHAR(50)
);

CREATE TABLE dim_pais (
    id INT IDENTITY(1,1) PRIMARY KEY,
    region VARCHAR(50),
    pais VARCHAR(50)
);

-- 3. Crear la tabla de Hechos (Ventas)
CREATE TABLE fact_ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    producto_id INT,
    pais_id INT,
    cantidad INT,
    total_dinero DECIMAL(10,2),
    fecha DATE DEFAULT GETDATE(),
    -- Relaciones (Llaves foráneas)
    FOREIGN KEY (producto_id) REFERENCES dim_producto(id),
    FOREIGN KEY (pais_id) REFERENCES dim_pais(id)
);
GO

-- 4. Insertar datos en las Dimensiones
INSERT INTO dim_producto (categoria, nombre) VALUES 
('Electronica', 'Laptop'), 
('Electronica', 'Mouse'), 
('Hogar', 'Lampara'), 
('Ropa', 'Jeans');

INSERT INTO dim_pais (region, pais) VALUES 
('America', 'Mexico'), 
('America', 'USA'), 
('Europa', 'España');
GO

-- 5. Generar 1000 ventas aleatorias automáticamente
DECLARE @i INT = 0;
WHILE @i < 1000
BEGIN
    INSERT INTO fact_ventas (producto_id, pais_id, cantidad, total_dinero) 
    VALUES (
        FLOOR(RAND()*4+1),
        FLOOR(RAND()*3+1),
        FLOOR(RAND()*10+1),
        CAST((RAND()*500+10) AS DECIMAL(10,2))
    );
    SET @i = @i + 1;
END
GO

SELECT 'Base de datos creada y llena exitosamente' as Estado;