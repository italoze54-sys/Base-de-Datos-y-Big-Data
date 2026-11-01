CREATE DATABASE TOTTUSMERMA
use TOTTUSMERMA
go
create table Sede_Tottus (
	id_sede INT IDENTITY(1,1) PRIMARY KEY,
	nombre_sede VARCHAR(50) NOT NULL,
	direccion VARCHAR(50) NOT NULL,
	distrito VARCHAR(50) NOT NULL,
	telefono_contacto VARCHAR(15) NULL
);
create table Categoria(
	id_categoria INT IDENTITY (1,1) PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
	dias_alerta_merma INT NOT NULL CHECK (dias_alerta_merma > 0)
);

create table Beneficiario (
	id_beneficiario INT IDENTITY(1,1) PRIMARY KEY,
	tipo_beneficiario VARCHAR(30) NOT NULL,
	nombre_institucion VARCHAR(50) NOT NULL,
	ruc_o_codigo_midis VARCHAR(30) NOT NULL UNIQUE,
	representante VARCHAR(50) NOT NULL,
	telefono VARCHAR(15) NULL,
	distrito VARCHAR(50) NOT NULL
);

create table Producto (
	id_producto INT IDENTITY(1,1) PRIMARY KEY,
	codigo_barras VARCHAR(15) NOT NULL UNIQUE,
	nombre_producto VARCHAR(50) NOT NULL,
	unidad_medida VARCHAR(10) NOT NULL,
	precio_original DECIMAL(5,2) NOT NULL CHECK (precio_original>=0),
	id_categoria INT NOT NULL,
	CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

create table Lote_merma (
	id_lote INT IDENTITy(1,1) PRIMARY KEY,
	id_producto INT NOT NULL,
	id_sede INT NOT NULL,
	fecha_ingreso_merma DATE NOT NULL,
	fecha_vencimiento DATE NOT NULL,
	cantidad_disponible DECIMAL(5,2) NOT NULL CHECK(cantidad_disponible>=0),
	tipo_destino VARCHAR(50) NOT NULL,
	precio_rescate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
	estado_lote VARCHAR(15) NOT NULL DEFAULT 'Disponible',
	CONSTRAINT FK_Lote_Producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    CONSTRAINT FK_Lote_Sede FOREIGN KEY (id_sede) REFERENCES Sede_Tottus(id_sede)
);



create table Pedido_rescate (
	id_pedido INT IDENTITY(1,1) PRIMARY KEY,
	id_beneficiario INT NOT NULL,
	id_sede INT NOT NULL,
	fecha_solicitud DATE NOT NULL DEFAULT GETDATE(),
	costo_total DECIMAL(5,2) NOT NULL DEFAULT 0.00,
	estado_pedido VARCHAR(15) NOT NULL DEFAULT 'Pendiente',
	CONSTRAINT FK_Pedido_Beneficiario FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario),
    CONSTRAINT FK_Pedido_Sede FOREIGN KEY (id_sede) REFERENCES Sede_Tottus(id_sede)
);

create table detalle_pedido_rescate (
	id_detalle INT IDENTITY(1,1) PRIMARY KEY,
	id_pedido INT NOT NULL,
	id_lote INT NOT NULL,
	cantidad_solicitada DECIMAL(5,2) NOT NULL CHECK (cantidad_solicitada > 0),
	subtotal DECIMAL(6,2) NOT NULL DEFAULT 0.00,
	CONSTRAINT FK_Detalle_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido_rescate(id_pedido),
    CONSTRAINT FK_Detalle_Lote FOREIGN KEY (id_lote) REFERENCES Lote_merma(id_lote)
);

create table Entrega_despacho (
	id_entrega INT IDENTITY (1,1) PRIMARY KEY,
	id_pedido INT NOT NULL UNIQUE,
	responsable_transporte VARCHAR(50) NOT NULL,
	fecha_hora_salida DATETIME NOT NULL,
	fecha_hora_recepcion DATETIME NOT NULL,
	conformidad_recibida VARCHAR(15) NOT NULL DEFAULT 'Pendiente',
	firma_o_constancia VARCHAR(30) NULL	,
	CONSTRAINT FK_Entrega_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedido_rescate(id_pedido)
);



USE TOTTUSMERMA;
GO