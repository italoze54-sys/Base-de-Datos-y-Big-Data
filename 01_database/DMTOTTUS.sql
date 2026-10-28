-- 1. Creación de la base de datos analítica (Data Mart)
CREATE DATABASE DM_Tottus_Merma;
GO

USE DM_Tottus_Merma;
GO

-- 2. Dimensión Tiempo
CREATE TABLE dim_Tiempo (
    id_tiempo INT PRIMARY KEY, -- Formato entero YYYYMMDD
    fecha DATE NOT NULL,
    numero_semana INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    año INT NOT NULL
);
GO

-- 3. Dimensión Producto
CREATE TABLE dim_Producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    codigo_barras VARCHAR(13) NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    precio_original DECIMAL(8,2) NOT NULL
);
GO

-- 4. Dimensión Sede
CREATE TABLE dim_Sede (
    id_sede INT IDENTITY(1,1) PRIMARY KEY,
    codigo_tienda VARCHAR(10) NOT NULL,
    nombre_sede VARCHAR(80) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    distrito VARCHAR(50) NOT NULL
);
GO

-- 5. Dimensión Beneficiario
CREATE TABLE dim_Beneficiario (
    id_beneficiario INT IDENTITY(1,1) PRIMARY KEY,
    tipo_beneficiario VARCHAR(30) NOT NULL,
    nombre_institucion VARCHAR(100) NOT NULL,
    ruc_o_codigo_midis VARCHAR(30) NOT NULL,
    distrito VARCHAR(50) NOT NULL
);
GO

-- 6. Dimensión Lote
CREATE TABLE dim_Lote (
    id_lote INT IDENTITY(1,1) PRIMARY KEY,
    fecha_ingreso_merma DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    tipo_destino VARCHAR(50) NOT NULL,
    estado_lote VARCHAR(20) NOT NULL
);
GO

-- 7. Dimensión Canal de Rescate
CREATE TABLE dim_Canal_Rescate (
    id_canal INT IDENTITY(1,1) PRIMARY KEY,
    nombre_canal VARCHAR(50) NOT NULL,
    tipo_operacion VARCHAR(20) NOT NULL
);
GO

-- 8. Tabla de Hechos Central
CREATE TABLE fact_Gestion_Merma_Rescate (
    id_hecho BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT NOT NULL,
    id_producto INT NOT NULL,
    id_lote INT NOT NULL,
    id_sede INT NOT NULL,
    id_beneficiario INT NOT NULL,
    id_canal INT NOT NULL,
    cantidad_rescatada DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    cantidad_merma_perdida DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    monto_perdida_merma DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    monto_recuperado_rescate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ahorro_social_donado DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Fact_Tiempo FOREIGN KEY (id_tiempo) REFERENCES dim_Tiempo(id_tiempo),
    CONSTRAINT FK_Fact_Producto FOREIGN KEY (id_producto) REFERENCES dim_Producto(id_producto),
    CONSTRAINT FK_Fact_Lote FOREIGN KEY (id_lote) REFERENCES dim_Lote(id_lote),
    CONSTRAINT FK_Fact_Sede FOREIGN KEY (id_sede) REFERENCES dim_Sede(id_sede),
    CONSTRAINT FK_Fact_Beneficiario FOREIGN KEY (id_beneficiario) REFERENCES dim_Beneficiario(id_beneficiario),
    CONSTRAINT FK_Fact_Canal FOREIGN KEY (id_canal) REFERENCES dim_Canal_Rescate(id_canal)
);
GO

-- Índices para optimizar las consultas del Dashboard en Power BI
CREATE INDEX IX_Fact_Tiempo ON fact_Gestion_Merma_Rescate(id_tiempo);
CREATE INDEX IX_Fact_Producto ON fact_Gestion_Merma_Rescate(id_producto);
CREATE INDEX IX_Fact_Sede ON fact_Gestion_Merma_Rescate(id_sede);
CREATE INDEX IX_Fact_Beneficiario ON fact_Gestion_Merma_Rescate(id_beneficiario);
GO


