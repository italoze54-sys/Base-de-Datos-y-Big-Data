USE TOTTUSMERMA;
GO

-- 1. Limpieza en orden inverso de claves foráneas
DELETE FROM Entrega_despacho;
DELETE FROM detalle_pedido_rescate;
DELETE FROM Pedido_rescate;
DELETE FROM Lote_merma;
DELETE FROM Producto;
DELETE FROM Beneficiario;
DELETE FROM Categoria;
DELETE FROM Sede_Tottus;
GO

-- 2. Reiniciar contadores de IDENTITY a 0
DBCC CHECKIDENT ('Entrega_despacho', RESEED, 0);
DBCC CHECKIDENT ('detalle_pedido_rescate', RESEED, 0);
DBCC CHECKIDENT ('Pedido_rescate', RESEED, 0);
DBCC CHECKIDENT ('Lote_merma', RESEED, 0);
DBCC CHECKIDENT ('Producto', RESEED, 0);
DBCC CHECKIDENT ('Beneficiario', RESEED, 0);
DBCC CHECKIDENT ('Categoria', RESEED, 0);
DBCC CHECKIDENT ('Sede_Tottus', RESEED, 0);
GO

-- ============================================================================
-- 1. SEDE_TOTTUS (10 Sedes - nombre_sede <= 20, distrito <= 20)
-- ============================================================================
SET IDENTITY_INSERT Sede_Tottus ON;
GO

INSERT INTO Sede_Tottus (id_sede, nombre_sede, direccion, distrito, telefono_contacto) VALUES
(1, 'Tottus Pte Piedra', 'Av. Puente Piedra 450', 'Puente Piedra', '01-5110001'),
(2, 'Tottus MegaPlaza', 'Av. Alfredo Mendiola 3698', 'Independencia', '01-5110002'),
(3, 'Tottus Los Olivos', 'Av. Carlos Izaguirre 275', 'Los Olivos', '01-5110003'),
(4, 'Tottus Comas', 'Av. Universitaria 6540', 'Comas', '01-5110004'),
(5, 'Tottus Carabayllo', 'Av. Tupac Amaru Km 21', 'Carabayllo', '01-5110005'),
(6, 'Tottus SJL Proceres', 'Av. Proceres 1632', 'SJL', '01-5110006'),
(7, 'Tottus San Miguel', 'Av. La Marina 2355', 'San Miguel', '01-5110007'),
(8, 'Tottus Canta Callao', 'Av. Canta Callao 3005', 'SMP', '01-5110008'),
(9, 'Tottus Atocongo', 'Av. Circunvalacion 1801', 'SJM', '01-5110009'),
(10, 'Tottus Las Begonias', 'Calle Las Begonias 785', 'San Isidro', '01-5110010');
GO

SET IDENTITY_INSERT Sede_Tottus OFF;
GO

-- ============================================================================
-- 2. CATEGORIA (7 Categorías - nombre_categoria <= 30)
-- ============================================================================
SET IDENTITY_INSERT Categoria ON;
GO

INSERT INTO Categoria (id_categoria, nombre_categoria, dias_alerta_merma) VALUES
(1, 'Lacteos y Derivados', 4),
(2, 'Panaderia y Pasteleria', 3),
(3, 'Carnes y Aves', 3),
(4, 'Pescados y Mariscos', 2),
(5, 'Embutidos y Fiambreria', 5),
(6, 'Frutas y Verduras', 2),
(7, 'Abarrotes y Granos', 15);
GO

SET IDENTITY_INSERT Categoria OFF;
GO

-- ============================================================================
-- 3. BENEFICIARIO (70 Beneficiarios - nombre_institucion <= 50, ruc <= 30)
-- ============================================================================
SET IDENTITY_INSERT Beneficiario ON;
GO

INSERT INTO Beneficiario (id_beneficiario, tipo_beneficiario, nombre_institucion, ruc_o_codigo_midis, representante, telefono, distrito) VALUES
(1, 'Olla Comun', 'Olla Comun San Cayetano 1', 'MIDIS-OC-1001', 'Maria Huaman', '991000001', 'Puente Piedra'),
(2, 'Olla Comun', 'Olla Comun San Cayetano 2', 'MIDIS-OC-1002', 'Rosa Quispe', '991000002', 'Comas'),
(3, 'Olla Comun', 'Olla Comun San Cayetano 3', 'MIDIS-OC-1003', 'Juana Flores', '991000003', 'San Juan de Lurigancho'),
(4, 'Olla Comun', 'Olla Comun San Cayetano 4', 'MIDIS-OC-1004', 'Carmen Rojas', '991000004', 'Independencia'),
(5, 'Olla Comun', 'Olla Comun San Cayetano 5', 'MIDIS-OC-1005', 'Elena Chavez', '991000005', 'Carabayllo'),
(6, 'Olla Comun', 'Olla Comun San Cayetano 6', 'MIDIS-OC-1006', 'Teresa Diaz', '991000006', 'Puente Piedra'),
(7, 'Olla Comun', 'Olla Comun San Cayetano 7', 'MIDIS-OC-1007', 'Ana Morales', '991000007', 'Comas'),
(8, 'Olla Comun', 'Olla Comun San Cayetano 8', 'MIDIS-OC-1008', 'Silvia Ramos', '991000008', 'San Juan de Lurigancho'),
(9, 'Olla Comun', 'Olla Comun San Cayetano 9', 'MIDIS-OC-1009', 'Luisa Mendoza', '991000009', 'Independencia'),
(10, 'Olla Comun', 'Olla Comun San Cayetano 10', 'MIDIS-OC-1010', 'Sofia Castillo', '991000010', 'Carabayllo'),
(11, 'Olla Comun', 'Olla Comun Esperanza 11', 'MIDIS-OC-1011', 'Gloria Vasquez', '991000011', 'Puente Piedra'),
(12, 'Olla Comun', 'Olla Comun Esperanza 12', 'MIDIS-OC-1012', 'Patricia Herrera', '991000012', 'Comas'),
(13, 'Olla Comun', 'Olla Comun Esperanza 13', 'MIDIS-OC-1013', 'Beatriz Medina', '991000013', 'San Juan de Lurigancho'),
(14, 'Olla Comun', 'Olla Comun Esperanza 14', 'MIDIS-OC-1014', 'Monica Vargas', '991000014', 'Independencia'),
(15, 'Olla Comun', 'Olla Comun Esperanza 15', 'MIDIS-OC-1015', 'Rocio Castro', '991000015', 'Carabayllo'),
(16, 'Olla Comun', 'Olla Comun Esperanza 16', 'MIDIS-OC-1016', 'Yolanda Romero', '991000016', 'Puente Piedra'),
(17, 'Olla Comun', 'Olla Comun Esperanza 17', 'MIDIS-OC-1017', 'Irma Gutierrez', '991000017', 'Comas'),
(18, 'Olla Comun', 'Olla Comun Esperanza 18', 'MIDIS-OC-1018', 'Lucia Salazar', '991000018', 'San Juan de Lurigancho'),
(19, 'Olla Comun', 'Olla Comun Esperanza 19', 'MIDIS-OC-1019', 'Esther Aguilar', '991000019', 'Independencia'),
(20, 'Olla Comun', 'Olla Comun Esperanza 20', 'MIDIS-OC-1020', 'Nancy Paredes', '991000020', 'Carabayllo'),
(21, 'Olla Comun', 'Olla Comun Manos Unidas 21', 'MIDIS-OC-1021', 'Gladys Cruz', '991000021', 'Puente Piedra'),
(22, 'Olla Comun', 'Olla Comun Manos Unidas 22', 'MIDIS-OC-1022', 'Pilar Espinoza', '991000022', 'Comas'),
(23, 'Olla Comun', 'Olla Comun Manos Unidas 23', 'MIDIS-OC-1023', 'Miriam Silva', '991000023', 'San Juan de Lurigancho'),
(24, 'Olla Comun', 'Olla Comun Manos Unidas 24', 'MIDIS-OC-1024', 'Dora Vega', '991000024', 'Independencia'),
(25, 'Olla Comun', 'Olla Comun Manos Unidas 25', 'MIDIS-OC-1025', 'Julia Cardenas', '991000025', 'Carabayllo'),
(26, 'Olla Comun', 'Olla Comun Manos Unidas 26', 'MIDIS-OC-1026', 'Olga Benitez', '991000026', 'Puente Piedra'),
(27, 'Olla Comun', 'Olla Comun Manos Unidas 27', 'MIDIS-OC-1027', 'Norma Campos', '991000027', 'Comas'),
(28, 'Olla Comun', 'Olla Comun Manos Unidas 28', 'MIDIS-OC-1028', 'Sara Soto', '991000028', 'San Juan de Lurigancho'),
(29, 'Olla Comun', 'Olla Comun Manos Unidas 29', 'MIDIS-OC-1029', 'Vilma Rios', '991000029', 'Independencia'),
(30, 'Olla Comun', 'Olla Comun Manos Unidas 30', 'MIDIS-OC-1030', 'Hilda Lozano', '991000030', 'Carabayllo'),
(31, 'Olla Comun', 'Olla Comun Fe Viva 31', 'MIDIS-OC-1031', 'Flor Carrillo', '991000031', 'Puente Piedra'),
(32, 'Olla Comun', 'Olla Comun Fe Viva 32', 'MIDIS-OC-1032', 'Ines Mejia', '991000032', 'Comas'),
(33, 'Olla Comun', 'Olla Comun Fe Viva 33', 'MIDIS-OC-1033', 'Mercedes Guerrero', '991000033', 'San Juan de Lurigancho'),
(34, 'Olla Comun', 'Olla Comun Fe Viva 34', 'MIDIS-OC-1034', 'Lidia Pacheco', '991000034', 'Independencia'),
(35, 'Olla Comun', 'Olla Comun Fe Viva 35', 'MIDIS-OC-1035', 'Consuelo Bravo', '991000035', 'Carabayllo'),
(36, 'Comedor Popular', 'Comedor Santa Rosa 36', 'MIDIS-CP-2036', 'Bertha Solis', '991000036', 'Los Olivos'),
(37, 'Comedor Popular', 'Comedor Santa Rosa 37', 'MIDIS-CP-2037', 'Alicia Valenzuela', '991000037', 'San Martin de Porres'),
(38, 'Comedor Popular', 'Comedor Santa Rosa 38', 'MIDIS-CP-2038', 'Marlene Palacios', '991000038', 'Carabayllo'),
(39, 'Comedor Popular', 'Comedor Santa Rosa 39', 'MIDIS-CP-2039', 'Victoria Cabrera', '991000039', 'Comas'),
(40, 'Comedor Popular', 'Comedor Santa Rosa 40', 'MIDIS-CP-2040', 'Juana Alarcon', '991000040', 'Los Olivos'),
(41, 'Comedor Popular', 'Comedor Santa Rosa 41', 'MIDIS-CP-2041', 'Doris Miranda', '991000041', 'San Martin de Porres'),
(42, 'Comedor Popular', 'Comedor Santa Rosa 42', 'MIDIS-CP-2042', 'Celia Navarrete', '991000042', 'Carabayllo'),
(43, 'Comedor Popular', 'Comedor Santa Rosa 43', 'MIDIS-CP-2043', 'Susana Bustamante', '991000043', 'Comas'),
(44, 'Comedor Popular', 'Comedor Santa Rosa 44', 'MIDIS-CP-2044', 'Reyna Fuentes', '991000044', 'Los Olivos'),
(45, 'Comedor Popular', 'Comedor Santa Rosa 45', 'MIDIS-CP-2045', 'Magda Sandoval', '991000045', 'San Martin de Porres'),
(46, 'Comedor Popular', 'Comedor San Martin 46', 'MIDIS-CP-2046', 'Elba Cordova', '991000046', 'Carabayllo'),
(47, 'Comedor Popular', 'Comedor San Martin 47', 'MIDIS-CP-2047', 'Nelly Barrientos', '991000047', 'Comas'),
(48, 'Comedor Popular', 'Comedor San Martin 48', 'MIDIS-CP-2048', 'Clara Calderon', '991000048', 'Los Olivos'),
(49, 'Comedor Popular', 'Comedor San Martin 49', 'MIDIS-CP-2049', 'Sonia Cueva', '991000049', 'San Martin de Porres'),
(50, 'Comedor Popular', 'Comedor San Martin 50', 'MIDIS-CP-2050', 'Fanny Zamora', '991000050', 'Carabayllo'),
(51, 'Comedor Popular', 'Comedor San Martin 51', 'MIDIS-CP-2051', 'Teodora Ochoa', '991000051', 'Comas'),
(52, 'Comedor Popular', 'Comedor San Martin 52', 'MIDIS-CP-2052', 'Aida Vilchez', '991000052', 'Los Olivos'),
(53, 'Comedor Popular', 'Comedor San Martin 53', 'MIDIS-CP-2053', 'Lupe Aranda', '991000053', 'San Martin de Porres'),
(54, 'Comedor Popular', 'Comedor San Martin 54', 'MIDIS-CP-2054', 'Rita Zavaleta', '991000054', 'Carabayllo'),
(55, 'Comedor Popular', 'Comedor San Martin 55', 'MIDIS-CP-2055', 'Marina Pinedo', '991000055', 'Comas'),
(56, 'Bodega Aliada MYPE', 'Bodega Don Pepe 56', '10450000561', 'Jose Ramirez', '991000056', 'Puente Piedra'),
(57, 'Bodega Aliada MYPE', 'Bodega Don Pepe 57', '10450000571', 'Carlos Sanchez', '991000057', 'Carabayllo'),
(58, 'Bodega Aliada MYPE', 'Bodega Don Pepe 58', '10450000581', 'Manuel Torres', '991000058', 'Comas'),
(59, 'Bodega Aliada MYPE', 'Bodega Don Pepe 59', '10450000591', 'Jorge Lopez', '991000059', 'Puente Piedra'),
(60, 'Bodega Aliada MYPE', 'Bodega Don Pepe 60', '10450000601', 'Pedro Gomez', '991000060', 'Carabayllo'),
(61, 'Bodega Aliada MYPE', 'Minimarket El Ahorro 61', '10450000611', 'Luis Fernandez', '991000061', 'Comas'),
(62, 'Bodega Aliada MYPE', 'Minimarket El Ahorro 62', '10450000621', 'Victor Munoz', '991000062', 'Puente Piedra'),
(63, 'Bodega Aliada MYPE', 'Minimarket El Ahorro 63', '10450000631', 'Raul Delgado', '991000063', 'Carabayllo'),
(64, 'Bodega Aliada MYPE', 'Minimarket El Ahorro 64', '10450000641', 'Cesar Paredes', '991000064', 'Comas'),
(65, 'Bodega Aliada MYPE', 'Minimarket El Ahorro 65', '10450000651', 'Alberto Ruiz', '991000065', 'Puente Piedra'),
(66, 'Bodega Aliada MYPE', 'Restaurante Menu 66', '10450000661', 'Hugo Prado', '991000066', 'Carabayllo'),
(67, 'Bodega Aliada MYPE', 'Restaurante Menu 67', '10450000671', 'Mario Rivas', '991000067', 'Comas'),
(68, 'Bodega Aliada MYPE', 'Restaurante Menu 68', '10450000681', 'Walter Tello', '991000068', 'Puente Piedra'),
(69, 'Bodega Aliada MYPE', 'Restaurante Menu 69', '10450000691', 'Hernan Cano', '991000069', 'Carabayllo'),
(70, 'Bodega Aliada MYPE', 'Restaurante Menu 70', '10450000701', 'Felix Alva', '991000070', 'Comas');
GO

SET IDENTITY_INSERT Beneficiario OFF;
GO

-- ============================================================================
-- 4. PRODUCTO (70 Productos - nombre_producto <= 50, unidad_medida <= 10)
-- ============================================================================
SET IDENTITY_INSERT Producto ON;
GO

INSERT INTO Producto (id_producto, codigo_barras, nombre_producto, unidad_medida, precio_original, id_categoria) VALUES
(1, '7750100000014', 'Leche Entera UHT 1L Tottus', 'Litro', 4.20, 1),
(2, '7750100000021', 'Leche Semidescremada UHT 1L Gloria', 'Litro', 4.50, 1),
(3, '7750100000038', 'Yogur Fresa 1L Laive', 'Litro', 6.80, 1),
(4, '7750100000045', 'Yogur Vainilla 1L Gloria', 'Litro', 6.50, 1),
(5, '7750100000052', 'Queso Edam Tajado 200g Tottus', 'Paquete', 11.90, 1),
(6, '7750100000069', 'Queso Mozzarella 200g Bonle', 'Paquete', 10.50, 1),
(7, '7750100000076', 'Mantequilla con Sal 200g Gloria', 'Unidad', 8.20, 1),
(8, '7750100000083', 'Queso Fresco Pasteurizado 500g', 'Paquete', 14.50, 1),
(9, '7750100000090', 'Crema de Leche 250ml Nestle', 'Unidad', 5.60, 1),
(10, '7750100000106', 'Yogur Griego Natural 500g Danlac', 'Unidad', 9.80, 1),
(11, '7750100000113', 'Pan de Molde Blanco 500g Bimbo', 'Bolsa', 7.20, 2),
(12, '7750100000120', 'Pan de Molde Integral 500g Tottus', 'Bolsa', 6.50, 2),
(13, '7750100000137', 'Pan Hamburguesa 6 un Tottus', 'Paquete', 5.40, 2),
(14, '7750100000144', 'Pan Hot Dog 6 un Bimbo', 'Paquete', 5.60, 2),
(15, '7750100000151', 'Queque Vainilla Artesanal Tottus', 'Unidad', 8.90, 2),
(16, '7750100000168', 'Queque Marmoleado 400g Tottus', 'Unidad', 9.20, 2),
(17, '7750100000175', 'Tostadas Clasicas 180g Bimbo', 'Paquete', 4.50, 2),
(18, '7750100000182', 'Empanada de Carne Tradicional', 'Unidad', 3.80, 2),
(19, '7750100000199', 'Pionono Clasico Manjarblanco', 'Unidad', 12.00, 2),
(20, '7750100000205', 'Muffins de Chocolate 4 un', 'Paquete', 7.50, 2),
(21, '7750100000212', 'Pollo Fresco con Menudencia', 'Kilo', 9.20, 3),
(22, '7750100000229', 'Pechuga Pollo Especial San Fernando', 'Kilo', 16.50, 3),
(23, '7750100000236', 'Pierna con Encuentro de Pollo', 'Kilo', 10.80, 3),
(24, '7750100000243', 'Carne Molida Especial Res 500g', 'Bandeja', 14.90, 3),
(25, '7750100000250', 'Bisteck de Res Tottus 500g', 'Bandeja', 19.50, 3),
(26, '7750100000267', 'Chuleta de Cerdo Fresca 500g', 'Bandeja', 13.20, 3),
(27, '7750100000274', 'Guiso de Res Economico 500g', 'Bandeja', 15.00, 3),
(28, '7750100000281', 'Alitas de Pollo Marineras 600g', 'Bandeja', 12.40, 3),
(29, '7750100000298', 'Menudencia de Pollo San Fernando', 'Kilo', 4.50, 3),
(30, '7750100000304', 'Filete Merluza Congelado 1kg', 'Bolsa', 17.50, 4),
(31, '7750100000311', 'Jamon Ingles 200g Braedt', 'Paquete', 12.50, 5),
(32, '7750100000328', 'Jamonada de Pollo 250g San Fernando', 'Paquete', 5.90, 5),
(33, '7750100000335', 'Hot Dog de Pollo 500g San Fernando', 'Paquete', 8.50, 5),
(34, '7750100000342', 'Salchicha Huachana 250g Tottus', 'Paquete', 6.80, 5),
(35, '7750100000359', 'Chorizo Parrillero 4 un Braedt', 'Paquete', 13.90, 5),
(36, '7750100000366', 'Tocino Ahumado 200g Otto Kunz', 'Paquete', 14.80, 5),
(37, '7750100000373', 'Mortadela de Pollo 250g Laive', 'Paquete', 4.90, 5),
(38, '7750100000380', 'Cabana Sausage Artesanal 180g', 'Paquete', 11.20, 5),
(39, '7750100000397', 'Tomate Italiano Seleccionado', 'Kilo', 3.80, 6),
(40, '7750100000403', 'Cebolla Roja Seleccionada', 'Kilo', 2.90, 6),
(41, '7750100000410', 'Papa Amarilla Tottus Malla 2kg', 'Malla', 8.50, 6),
(42, '7750100000427', 'Platano Seda de Exportacion', 'Kilo', 3.20, 6),
(43, '7750100000434', 'Manzana Israel Seleccionada', 'Kilo', 4.50, 6),
(44, '7750100000441', 'Zanahoria Entera Seleccionada', 'Kilo', 2.20, 6),
(45, '7750100000458', 'Lechuga Seda Hidroponica 1 un', 'Unidad', 2.80, 6),
(46, '7750100000465', 'Palta Fuerte en Malla 1kg', 'Malla', 8.90, 6),
(47, '7750100000472', 'Mandarina Satsuma sin Pepa', 'Kilo', 4.20, 6),
(48, '7750100000489', 'Fresas Empacadas 500g', 'Bandeja', 6.90, 6),
(49, '7750100000496', 'Esparrago Verde Fresco 400g', 'Manojo', 7.50, 6),
(50, '7750100000502', 'Champinon Blanco Entero 200g', 'Bandeja', 5.80, 6),
(51, '7750100000519', 'Naranjas de Jugo Malla 2kg', 'Malla', 6.20, 6),
(52, '7750100000526', 'Limon Sutil Seleccionado 1kg', 'Bolsa', 5.50, 6),
(53, '7750100000533', 'Arroz Extra Tottus 1kg', 'Bolsa', 4.60, 7),
(54, '7750100000540', 'Fideos Tallarin Grueso Don Vittorio', 'Paquete', 3.40, 7),
(55, '7750100000557', 'Aceite Vegetal Primor 900ml', 'Botella', 8.90, 7),
(56, '7750100000564', 'Grated Atun Campomar 170g', 'Lata', 4.30, 7),
(57, '7750100000571', 'Filete de Atun Florida 170g', 'Lata', 6.20, 7),
(58, '7750100000588', 'Lenteja Criolla Tottus 500g', 'Bolsa', 3.90, 7),
(59, '7750100000595', 'Avena Tradicional 3 Negritos 350g', 'Bolsa', 2.80, 7),
(60, '7750100000601', 'Galleta Soda San Jorge 6 un', 'Paquete', 3.50, 7),
(61, '7750100000618', 'Salsa Pomarola Doypack 150g', 'Doypack', 2.10, 7),
(62, '7750100000625', 'Azucar Rubia Domani 1kg', 'Bolsa', 4.20, 7),
(63, '7750100000632', 'Gelatina Fresa Royal 150g', 'Caja', 3.80, 7),
(64, '7750100000649', 'Pure de Manzana Tottus 200g', 'Frasco', 3.20, 7),
(65, '7750100000656', 'Cafe Nescafe Tradicion 100g', 'Frasco', 13.50, 7),
(66, '7750100000663', 'Torta Helada Familiar Tottus', 'Unidad', 32.00, 2),
(67, '7750100000670', 'Pie Manzana Individual Tottus', 'Unidad', 5.50, 2),
(68, '7750100000687', 'Milhojas Manjarblanco Tottus', 'Unidad', 6.00, 2),
(69, '7750100000694', 'Jugo Naranja Natural 1L Huerto', 'Botella', 7.90, 1),
(70, '7750100000700', 'Masa Pascualina Tottus 400g', 'Paquete', 8.50, 2);
GO

SET IDENTITY_INSERT Producto OFF;
GO

-- ============================================================================
-- 5. LOTE_MERMA (70 Lotes - estado_lote <= 15, tipo_destino <= 50)
-- ============================================================================
SET IDENTITY_INSERT Lote_merma ON;
GO

INSERT INTO Lote_merma (id_lote, id_producto, id_sede, fecha_ingreso_merma, fecha_vencimiento, cantidad_disponible, tipo_destino, precio_rescate, estado_lote) VALUES
(1, 1, 1, '2026-06-02', '2026-06-05', 25.00, 'Donacion', 0.00, 'Entregado'),
(2, 2, 2, '2026-06-03', '2026-06-07', 30.00, 'Donacion', 0.00, 'Entregado'),
(3, 3, 3, '2026-06-04', '2026-06-09', 22.00, 'Venta MYPE', 1.70, 'Entregado'),
(4, 4, 4, '2026-06-05', '2026-06-08', 20.00, 'Venta MYPE', 1.60, 'Entregado'),
(5, 5, 5, '2026-06-06', '2026-06-10', 15.00, 'Donacion', 0.00, 'Entregado'),
(6, 6, 6, '2026-06-07', '2026-06-12', 18.00, 'Donacion', 0.00, 'Entregado'),
(7, 7, 7, '2026-06-08', '2026-06-11', 25.00, 'Donacion', 0.00, 'Entregado'),
(8, 8, 8, '2026-06-09', '2026-06-13', 12.00, 'Venta MYPE', 3.60, 'Entregado'),
(9, 9, 9, '2026-06-10', '2026-06-15', 30.00, 'Venta MYPE', 1.40, 'Entregado'),
(10, 10, 10, '2026-06-11', '2026-06-14', 16.00, 'Donacion', 0.00, 'Entregado'),
(11, 11, 1, '2026-06-12', '2026-06-16', 35.00, 'Donacion', 0.00, 'Entregado'),
(12, 12, 2, '2026-06-13', '2026-06-18', 30.00, 'Donacion', 0.00, 'Entregado'),
(13, 13, 3, '2026-06-14', '2026-06-17', 28.00, 'Venta MYPE', 1.35, 'Entregado'),
(14, 14, 4, '2026-06-15', '2026-06-19', 24.00, 'Venta MYPE', 1.40, 'Entregado'),
(15, 15, 5, '2026-06-16', '2026-06-21', 14.00, 'Donacion', 0.00, 'Entregado'),
(16, 16, 6, '2026-06-17', '2026-06-20', 18.00, 'Donacion', 0.00, 'Entregado'),
(17, 17, 7, '2026-06-18', '2026-06-22', 40.00, 'Donacion', 0.00, 'Entregado'),
(18, 18, 8, '2026-06-19', '2026-06-24', 45.00, 'Venta MYPE', 0.95, 'Entregado'),
(19, 19, 9, '2026-06-20', '2026-06-23', 15.00, 'Venta MYPE', 3.00, 'Entregado'),
(20, 20, 10, '2026-06-21', '2026-06-25', 20.00, 'Donacion', 0.00, 'Entregado'),
(21, 21, 1, '2026-06-22', '2026-06-27', 30.00, 'Donacion', 0.00, 'Entregado'),
(22, 22, 2, '2026-06-23', '2026-06-26', 25.00, 'Donacion', 0.00, 'Entregado'),
(23, 23, 3, '2026-06-24', '2026-06-28', 22.00, 'Venta MYPE', 2.70, 'Entregado'),
(24, 24, 4, '2026-06-25', '2026-06-30', 18.00, 'Venta MYPE', 3.70, 'Entregado'),
(25, 25, 5, '2026-06-26', '2026-06-29', 12.00, 'Donacion', 0.00, 'Entregado'),
(26, 26, 6, '2026-06-27', '2026-07-01', 20.00, 'Donacion', 0.00, 'Entregado'),
(27, 27, 7, '2026-06-28', '2026-07-03', 18.00, 'Donacion', 0.00, 'Entregado'),
(28, 28, 8, '2026-06-29', '2026-07-02', 26.00, 'Venta MYPE', 3.10, 'Entregado'),
(29, 29, 9, '2026-06-30', '2026-07-04', 35.00, 'Venta MYPE', 1.10, 'Entregado'),
(30, 30, 10, '2026-07-01', '2026-07-06', 10.00, 'Donacion', 0.00, 'Entregado'),
(31, 31, 1, '2026-07-02', '2026-07-05', 22.00, 'Donacion', 0.00, 'Entregado'),
(32, 32, 2, '2026-07-03', '2026-07-07', 30.00, 'Donacion', 0.00, 'Entregado'),
(33, 33, 3, '2026-07-04', '2026-07-09', 24.00, 'Venta MYPE', 2.10, 'Entregado'),
(34, 34, 4, '2026-07-05', '2026-07-08', 26.00, 'Venta MYPE', 1.70, 'Entregado'),
(35, 35, 5, '2026-07-06', '2026-07-10', 16.00, 'Donacion', 0.00, 'Entregado'),
(36, 36, 6, '2026-07-07', '2026-07-12', 15.00, 'Donacion', 0.00, 'Entregado'),
(37, 37, 7, '2026-07-08', '2026-07-11', 30.00, 'Donacion', 0.00, 'Entregado'),
(38, 38, 8, '2026-07-09', '2026-07-13', 18.00, 'Venta MYPE', 2.80, 'Entregado'),
(39, 39, 9, '2026-07-10', '2026-07-15', 55.00, 'Venta MYPE', 0.95, 'Entregado'),
(40, 40, 10, '2026-07-11', '2026-07-14', 25.00, 'Donacion', 0.00, 'Entregado'),
(41, 41, 1, '2026-07-12', '2026-07-16', 40.00, 'Donacion', 0.00, 'Entregado'),
(42, 42, 2, '2026-07-13', '2026-07-18', 50.00, 'Donacion', 0.00, 'Entregado'),
(43, 43, 3, '2026-07-14', '2026-07-17', 35.00, 'Venta MYPE', 1.10, 'Entregado'),
(44, 44, 4, '2026-07-15', '2026-07-19', 45.00, 'Venta MYPE', 0.55, 'Entregado'),
(45, 45, 5, '2026-07-16', '2026-07-21', 22.00, 'Donacion', 0.00, 'Entregado'),
(46, 46, 6, '2026-07-17', '2026-07-20', 25.00, 'Donacion', 0.00, 'Entregado'),
(47, 47, 7, '2026-07-18', '2026-07-22', 40.00, 'Donacion', 0.00, 'Entregado'),
(48, 48, 8, '2026-07-19', '2026-07-24', 30.00, 'Venta MYPE', 1.70, 'Entregado'),
(49, 49, 9, '2026-07-20', '2026-07-23', 22.00, 'Venta MYPE', 1.85, 'Entregado'),
(50, 50, 10, '2026-07-21', '2026-07-25', 20.00, 'Donacion', 0.00, 'Entregado'),
(51, 51, 1, '2026-07-22', '2026-07-27', 32.00, 'Donacion', 0.00, 'Entregado'),
(52, 52, 2, '2026-07-23', '2026-07-26', 38.00, 'Donacion', 0.00, 'Entregado'),
(53, 53, 3, '2026-07-24', '2026-07-28', 55.00, 'Venta MYPE', 1.15, 'Entregado'),
(54, 54, 4, '2026-07-25', '2026-07-30', 50.00, 'Venta MYPE', 0.85, 'Entregado'),
(55, 55, 5, '2026-07-26', '2026-07-29', 14.00, 'Donacion', 0.00, 'Entregado'),
(56, 56, 6, '2026-07-27', '2026-07-31', 45.00, 'Donacion', 0.00, 'Entregado'),
(57, 57, 7, '2026-07-28', '2026-08-02', 40.00, 'Donacion', 0.00, 'Entregado'),
(58, 58, 8, '2026-07-29', '2026-08-01', 35.00, 'Venta MYPE', 0.95, 'Entregado'),
(59, 59, 9, '2026-07-30', '2026-08-03', 32.00, 'Venta MYPE', 0.70, 'Entregado'),
(60, 60, 10, '2026-07-31', '2026-08-05', 25.00, 'Donacion', 0.00, 'Entregado'),
(61, 61, 1, '2026-08-01', '2026-08-04', 55.00, 'Donacion', 0.00, 'Entregado'),
(62, 62, 2, '2026-08-02', '2026-08-06', 45.00, 'Donacion', 0.00, 'Entregado'),
(63, 63, 3, '2026-08-03', '2026-08-08', 40.00, 'Venta MYPE', 0.95, 'Entregado'),
(64, 64, 4, '2026-08-04', '2026-08-07', 30.00, 'Venta MYPE', 0.80, 'Entregado'),
(65, 65, 5, '2026-08-05', '2026-08-09', 10.00, 'Donacion', 0.00, 'Entregado'),
(66, 66, 6, '2026-08-06', '2026-08-11', 8.00, 'Donacion', 0.00, 'Entregado'),
(67, 67, 7, '2026-08-07', '2026-08-10', 18.00, 'Donacion', 0.00, 'Entregado'),
(68, 68, 8, '2026-08-08', '2026-08-12', 24.00, 'Venta MYPE', 1.50, 'Entregado'),
(69, 69, 9, '2026-08-09', '2026-08-14', 22.00, 'Venta MYPE', 1.95, 'Entregado'),
(70, 70, 10, '2026-08-09', '2026-08-13', 28.00, 'Donacion', 0.00, 'Entregado');
GO

SET IDENTITY_INSERT Lote_merma OFF;
GO

-- ============================================================================
-- 6. PEDIDO_RESCATE (70 Pedidos - estado_pedido <= 15)
-- ============================================================================
SET IDENTITY_INSERT Pedido_rescate ON;
GO

INSERT INTO Pedido_rescate (id_pedido, id_beneficiario, id_sede, fecha_solicitud, costo_total, estado_pedido) VALUES
(1, 1, 1, '2026-06-02', 0.00, 'Entregado'),
(2, 2, 2, '2026-06-03', 0.00, 'Entregado'),
(3, 3, 3, '2026-06-04', 34.00, 'Entregado'),
(4, 4, 4, '2026-06-05', 26.00, 'Entregado'),
(5, 5, 5, '2026-06-06', 0.00, 'Entregado'),
(6, 6, 6, '2026-06-07', 0.00, 'Entregado'),
(7, 7, 7, '2026-06-08', 0.00, 'Entregado'),
(8, 8, 8, '2026-06-09', 36.25, 'Entregado'),
(9, 9, 9, '2026-06-10', 35.00, 'Entregado'),
(10, 10, 10, '2026-06-11', 0.00, 'Entregado'),
(11, 11, 1, '2026-06-12', 0.00, 'Entregado'),
(12, 12, 2, '2026-06-13', 0.00, 'Entregado'),
(13, 13, 3, '2026-06-14', 32.40, 'Entregado'),
(14, 14, 4, '2026-06-15', 28.00, 'Entregado'),
(15, 15, 5, '2026-06-16', 0.00, 'Entregado'),
(16, 16, 6, '2026-06-17', 0.00, 'Entregado'),
(17, 17, 7, '2026-06-18', 0.00, 'Entregado'),
(18, 18, 8, '2026-06-19', 38.00, 'Entregado'),
(19, 19, 9, '2026-06-20', 36.00, 'Entregado'),
(20, 20, 10, '2026-06-21', 0.00, 'Entregado'),
(21, 21, 1, '2026-06-22', 0.00, 'Entregado'),
(22, 22, 2, '2026-06-23', 0.00, 'Entregado'),
(23, 23, 3, '2026-06-24', 48.60, 'Entregado'),
(24, 24, 4, '2026-06-25', 55.88, 'Entregado'),
(25, 25, 5, '2026-06-26', 0.00, 'Entregado'),
(26, 26, 6, '2026-06-27', 0.00, 'Entregado'),
(27, 27, 7, '2026-06-28', 0.00, 'Entregado'),
(28, 28, 8, '2026-06-29', 68.20, 'Entregado'),
(29, 29, 9, '2026-06-30', 33.75, 'Entregado'),
(30, 30, 10, '2026-07-01', 0.00, 'Entregado'),
(31, 31, 1, '2026-07-02', 0.00, 'Entregado'),
(32, 32, 2, '2026-07-03', 0.00, 'Entregado'),
(33, 33, 3, '2026-07-04', 42.50, 'Entregado'),
(34, 34, 4, '2026-07-05', 37.40, 'Entregado'),
(35, 35, 5, '2026-07-06', 0.00, 'Entregado'),
(36, 36, 6, '2026-07-07', 0.00, 'Entregado'),
(37, 37, 7, '2026-07-08', 0.00, 'Entregado'),
(38, 38, 8, '2026-07-09', 42.00, 'Entregado'),
(39, 39, 9, '2026-07-10', 47.50, 'Entregado'),
(40, 40, 10, '2026-07-11', 0.00, 'Entregado'),
(41, 41, 1, '2026-07-12', 0.00, 'Entregado'),
(42, 42, 2, '2026-07-13', 0.00, 'Entregado'),
(43, 43, 3, '2026-07-14', 33.75, 'Entregado'),
(44, 44, 4, '2026-07-15', 22.00, 'Entregado'),
(45, 45, 5, '2026-07-16', 0.00, 'Entregado'),
(46, 46, 6, '2026-07-17', 0.00, 'Entregado'),
(47, 47, 7, '2026-07-18', 0.00, 'Entregado'),
(48, 48, 8, '2026-07-19', 43.13, 'Entregado'),
(49, 49, 9, '2026-07-20', 33.75, 'Entregado'),
(50, 50, 10, '2026-07-21', 0.00, 'Entregado'),
(51, 51, 1, '2026-07-22', 0.00, 'Entregado'),
(52, 52, 2, '2026-07-23', 0.00, 'Entregado'),
(53, 53, 3, '2026-07-24', 57.50, 'Entregado'),
(54, 54, 4, '2026-07-25', 38.25, 'Entregado'),
(55, 55, 5, '2026-07-26', 0.00, 'Entregado'),
(56, 56, 6, '2026-07-27', 0.00, 'Entregado'),
(57, 57, 7, '2026-07-28', 0.00, 'Entregado'),
(58, 58, 8, '2026-07-29', 29.25, 'Entregado'),
(59, 59, 9, '2026-07-30', 19.60, 'Entregado'),
(60, 60, 10, '2026-07-31', 0.00, 'Entregado'),
(61, 61, 1, '2026-08-01', 0.00, 'Entregado'),
(62, 62, 2, '2026-08-02', 0.00, 'Entregado'),
(63, 63, 3, '2026-08-03', 33.25, 'Entregado'),
(64, 64, 4, '2026-08-04', 20.00, 'Entregado'),
(65, 65, 5, '2026-08-05', 0.00, 'Entregado'),
(66, 66, 6, '2026-08-06', 0.00, 'Entregado'),
(67, 67, 7, '2026-08-07', 0.00, 'Entregado'),
(68, 68, 8, '2026-08-08', 30.00, 'Entregado'),
(69, 69, 9, '2026-08-09', 35.55, 'Entregado'),
(70, 70, 10, '2026-08-09', 0.00, 'Entregado');
GO

SET IDENTITY_INSERT Pedido_rescate OFF;
GO

-- ============================================================================
-- 7. DETALLE_PEDIDO_RESCATE (70 Ítems)
-- ============================================================================
SET IDENTITY_INSERT detalle_pedido_rescate ON;
GO

INSERT INTO detalle_pedido_rescate (id_detalle, id_pedido, id_lote, cantidad_solicitada, subtotal) VALUES
(1, 1, 1, 15.00, 0.00),
(2, 2, 2, 18.00, 0.00),
(3, 3, 3, 20.00, 34.00),
(4, 4, 4, 16.00, 26.00),
(5, 5, 5, 12.00, 0.00),
(6, 6, 6, 14.00, 0.00),
(7, 7, 7, 22.00, 0.00),
(8, 8, 8, 10.00, 36.25),
(9, 9, 9, 25.00, 35.00),
(10, 10, 10, 14.00, 0.00),
(11, 11, 11, 30.00, 0.00),
(12, 12, 12, 28.00, 0.00),
(13, 13, 13, 24.00, 32.40),
(14, 14, 14, 20.00, 28.00),
(15, 15, 15, 10.00, 0.00),
(16, 16, 16, 15.00, 0.00),
(17, 17, 17, 35.00, 0.00),
(18, 18, 18, 40.00, 38.00),
(19, 19, 19, 12.00, 36.00),
(20, 20, 20, 15.00, 0.00),
(21, 21, 21, 25.00, 0.00),
(22, 22, 22, 20.00, 0.00),
(23, 23, 23, 18.00, 48.60),
(24, 24, 24, 15.00, 55.88),
(25, 25, 25, 11.00, 0.00),
(26, 26, 26, 16.00, 0.00),
(27, 27, 27, 14.00, 0.00),
(28, 28, 28, 22.00, 68.20),
(29, 29, 29, 30.00, 33.75),
(30, 30, 30, 8.00, 0.00),
(31, 31, 31, 18.00, 0.00),
(32, 32, 32, 25.00, 0.00),
(33, 33, 33, 20.00, 42.50),
(34, 34, 34, 22.00, 37.40),
(35, 35, 35, 14.00, 0.00),
(36, 36, 36, 12.00, 0.00),
(37, 37, 37, 26.00, 0.00),
(38, 38, 38, 15.00, 42.00),
(39, 39, 39, 50.00, 47.50),
(40, 40, 40, 20.00, 0.00),
(41, 41, 41, 35.00, 0.00),
(42, 42, 42, 45.00, 0.00),
(43, 43, 43, 30.00, 33.75),
(44, 44, 44, 40.00, 22.00),
(45, 45, 45, 18.00, 0.00),
(46, 46, 46, 20.00, 0.00),
(47, 47, 47, 35.00, 0.00),
(48, 48, 48, 25.00, 43.13),
(49, 49, 49, 18.00, 33.75),
(50, 50, 50, 16.00, 0.00),
(51, 51, 51, 28.00, 0.00),
(52, 52, 52, 32.00, 0.00),
(53, 53, 53, 50.00, 57.50),
(54, 54, 54, 45.00, 38.25),
(55, 55, 55, 10.00, 0.00),
(56, 56, 56, 40.00, 0.00),
(57, 57, 57, 35.00, 0.00),
(58, 58, 58, 30.00, 29.25),
(59, 59, 59, 28.00, 19.60),
(60, 60, 60, 22.00, 0.00),
(61, 61, 61, 50.00, 0.00),
(62, 62, 62, 40.00, 0.00),
(63, 63, 63, 35.00, 33.25),
(64, 64, 64, 25.00, 20.00),
(65, 65, 65, 8.00, 0.00),
(66, 66, 66, 6.00, 0.00),
(67, 67, 67, 15.00, 0.00),
(68, 68, 68, 20.00, 30.00),
(69, 69, 69, 18.00, 35.55),
(70, 70, 70, 24.00, 0.00);
GO

SET IDENTITY_INSERT detalle_pedido_rescate OFF;
GO

-- ============================================================================
-- 8. ENTREGA_DESPACHO (70 Entregas - conformidad_recibida <= 15, firma <= 30)
-- ============================================================================
SET IDENTITY_INSERT Entrega_despacho ON;
GO

INSERT INTO Entrega_despacho (id_entrega, id_pedido, responsable_transporte, fecha_hora_salida, fecha_hora_recepcion, conformidad_recibida, firma_o_constancia) VALUES
(1, 1, 'Carlos Perez Chofer', '2026-06-02 08:30:00', '2026-06-02 09:45:00', 'Conforme', 'CONST-001'),
(2, 2, 'Luis Gomez Chofer', '2026-06-03 08:30:00', '2026-06-03 09:40:00', 'Conforme', 'CONST-002'),
(3, 3, 'Marco Diaz Chofer', '2026-06-04 09:00:00', '2026-06-04 10:15:00', 'Conforme', 'CONST-003'),
(4, 4, 'Jorge Ruiz Chofer', '2026-06-05 08:15:00', '2026-06-05 09:30:00', 'Conforme', 'CONST-004'),
(5, 5, 'Pedro Ramos Chofer', '2026-06-06 09:30:00', '2026-06-06 10:50:00', 'Conforme', 'CONST-005'),
(6, 6, 'Raul Castro Chofer', '2026-06-07 08:00:00', '2026-06-07 09:10:00', 'Conforme', 'CONST-006'),
(7, 7, 'Walter Soto Chofer', '2026-06-08 08:45:00', '2026-06-08 10:00:00', 'Conforme', 'CONST-007'),
(8, 8, 'Hugo Vega Chofer', '2026-06-09 09:10:00', '2026-06-09 10:25:00', 'Conforme', 'CONST-008'),
(9, 9, 'Felix Leon Chofer', '2026-06-10 08:20:00', '2026-06-10 09:40:00', 'Conforme', 'CONST-009'),
(10, 10, 'Mario Tello Chofer', '2026-06-11 08:30:00', '2026-06-11 09:50:00', 'Conforme', 'CONST-010'),
(11, 11, 'Carlos Perez Chofer', '2026-06-12 08:30:00', '2026-06-12 09:45:00', 'Conforme', 'CONST-011'),
(12, 12, 'Luis Gomez Chofer', '2026-06-13 08:30:00', '2026-06-13 09:40:00', 'Conforme', 'CONST-012'),
(13, 13, 'Marco Diaz Chofer', '2026-06-14 09:00:00', '2026-06-14 10:15:00', 'Conforme', 'CONST-013'),
(14, 14, 'Jorge Ruiz Chofer', '2026-06-15 08:15:00', '2026-06-15 09:30:00', 'Conforme', 'CONST-014'),
(15, 15, 'Pedro Ramos Chofer', '2026-06-16 09:30:00', '2026-06-16 10:50:00', 'Conforme', 'CONST-015'),
(16, 16, 'Raul Castro Chofer', '2026-06-17 08:00:00', '2026-06-17 09:10:00', 'Conforme', 'CONST-016'),
(17, 17, 'Walter Soto Chofer', '2026-06-18 08:45:00', '2026-06-18 10:00:00', 'Conforme', 'CONST-017'),
(18, 18, 'Hugo Vega Chofer', '2026-06-19 09:10:00', '2026-06-19 10:25:00', 'Conforme', 'CONST-018'),
(19, 19, 'Felix Leon Chofer', '2026-06-20 08:20:00', '2026-06-20 09:40:00', 'Conforme', 'CONST-019'),
(20, 20, 'Mario Tello Chofer', '2026-06-21 08:30:00', '2026-06-21 09:50:00', 'Conforme', 'CONST-020'),
(21, 21, 'Carlos Perez Chofer', '2026-06-22 08:30:00', '2026-06-22 09:45:00', 'Conforme', 'CONST-021'),
(22, 22, 'Luis Gomez Chofer', '2026-06-23 08:30:00', '2026-06-23 09:40:00', 'Conforme', 'CONST-022'),
(23, 23, 'Marco Diaz Chofer', '2026-06-24 09:00:00', '2026-06-24 10:15:00', 'Conforme', 'CONST-023'),
(24, 24, 'Jorge Ruiz Chofer', '2026-06-25 08:15:00', '2026-06-25 09:30:00', 'Conforme', 'CONST-024'),
(25, 25, 'Pedro Ramos Chofer', '2026-06-26 09:30:00', '2026-06-26 10:50:00', 'Conforme', 'CONST-025'),
(26, 26, 'Raul Castro Chofer', '2026-06-27 08:00:00', '2026-06-27 09:10:00', 'Conforme', 'CONST-026'),
(27, 27, 'Walter Soto Chofer', '2026-06-28 08:45:00', '2026-06-28 10:00:00', 'Conforme', 'CONST-027'),
(28, 28, 'Hugo Vega Chofer', '2026-06-29 09:10:00', '2026-06-29 10:25:00', 'Conforme', 'CONST-028'),
(29, 29, 'Felix Leon Chofer', '2026-06-30 08:20:00', '2026-06-30 09:40:00', 'Conforme', 'CONST-029'),
(30, 30, 'Mario Tello Chofer', '2026-07-01 08:30:00', '2026-07-01 09:50:00', 'Conforme', 'CONST-030'),
(31, 31, 'Carlos Perez Chofer', '2026-07-02 08:30:00', '2026-07-02 09:45:00', 'Conforme', 'CONST-031'),
(32, 32, 'Luis Gomez Chofer', '2026-07-03 08:30:00', '2026-07-03 09:40:00', 'Conforme', 'CONST-032'),
(33, 33, 'Marco Diaz Chofer', '2026-07-04 09:00:00', '2026-07-04 10:15:00', 'Conforme', 'CONST-033'),
(34, 34, 'Jorge Ruiz Chofer', '2026-07-05 08:15:00', '2026-07-05 09:30:00', 'Conforme', 'CONST-034'),
(35, 35, 'Pedro Ramos Chofer', '2026-07-06 09:30:00', '2026-07-06 10:50:00', 'Conforme', 'CONST-035'),
(36, 36, 'Raul Castro Chofer', '2026-07-07 08:00:00', '2026-07-07 09:10:00', 'Conforme', 'CONST-036'),
(37, 37, 'Walter Soto Chofer', '2026-07-08 08:45:00', '2026-07-08 10:00:00', 'Conforme', 'CONST-037'),
(38, 38, 'Hugo Vega Chofer', '2026-07-09 09:10:00', '2026-07-09 10:25:00', 'Conforme', 'CONST-038'),
(39, 39, 'Felix Leon Chofer', '2026-07-10 08:20:00', '2026-07-10 09:40:00', 'Conforme', 'CONST-039'),
(40, 40, 'Mario Tello Chofer', '2026-07-11 08:30:00', '2026-07-11 09:50:00', 'Conforme', 'CONST-040'),
(41, 41, 'Carlos Perez Chofer', '2026-07-12 08:30:00', '2026-07-12 09:45:00', 'Conforme', 'CONST-041'),
(42, 42, 'Luis Gomez Chofer', '2026-07-13 08:30:00', '2026-07-13 09:40:00', 'Conforme', 'CONST-042'),
(43, 43, 'Marco Diaz Chofer', '2026-07-14 09:00:00', '2026-07-14 10:15:00', 'Conforme', 'CONST-043'),
(44, 44, 'Jorge Ruiz Chofer', '2026-07-15 08:15:00', '2026-07-15 09:30:00', 'Conforme', 'CONST-044'),
(45, 45, 'Pedro Ramos Chofer', '2026-07-16 09:30:00', '2026-07-16 10:50:00', 'Conforme', 'CONST-045'),
(46, 46, 'Raul Castro Chofer', '2026-07-17 08:00:00', '2026-07-17 09:10:00', 'Conforme', 'CONST-046'),
(47, 47, 'Walter Soto Chofer', '2026-07-18 08:45:00', '2026-07-18 10:00:00', 'Conforme', 'CONST-047'),
(48, 48, 'Hugo Vega Chofer', '2026-07-19 09:10:00', '2026-07-19 10:25:00', 'Conforme', 'CONST-048'),
(49, 49, 'Felix Leon Chofer', '2026-07-20 08:20:00', '2026-07-20 09:40:00', 'Conforme', 'CONST-049'),
(50, 50, 'Mario Tello Chofer', '2026-07-21 08:30:00', '2026-07-21 09:50:00', 'Conforme', 'CONST-050'),
(51, 51, 'Carlos Perez Chofer', '2026-07-22 08:30:00', '2026-07-22 09:45:00', 'Conforme', 'CONST-051'),
(52, 52, 'Luis Gomez Chofer', '2026-07-23 08:30:00', '2026-07-23 09:40:00', 'Conforme', 'CONST-052'),
(53, 53, 'Marco Diaz Chofer', '2026-07-24 09:00:00', '2026-07-24 10:15:00', 'Conforme', 'CONST-053'),
(54, 54, 'Jorge Ruiz Chofer', '2026-07-25 08:15:00', '2026-07-25 09:30:00', 'Conforme', 'CONST-054'),
(55, 55, 'Pedro Ramos Chofer', '2026-07-26 09:30:00', '2026-07-26 10:50:00', 'Conforme', 'CONST-055'),
(56, 56, 'Raul Castro Chofer', '2026-07-27 08:00:00', '2026-07-27 09:10:00', 'Conforme', 'CONST-056'),
(57, 57, 'Walter Soto Chofer', '2026-07-28 08:45:00', '2026-07-28 10:00:00', 'Conforme', 'CONST-057'),
(58, 58, 'Hugo Vega Chofer', '2026-07-29 09:10:00', '2026-07-29 10:25:00', 'Conforme', 'CONST-058'),
(59, 59, 'Felix Leon Chofer', '2026-07-30 08:20:00', '2026-07-30 09:40:00', 'Conforme', 'CONST-059'),
(60, 60, 'Mario Tello Chofer', '2026-07-31 08:30:00', '2026-07-31 09:50:00', 'Conforme', 'CONST-060'),
(61, 61, 'Carlos Perez Chofer', '2026-08-01 08:30:00', '2026-08-01 09:45:00', 'Conforme', 'CONST-061'),
(62, 62, 'Luis Gomez Chofer', '2026-08-02 08:30:00', '2026-08-02 09:40:00', 'Conforme', 'CONST-062'),
(63, 63, 'Marco Diaz Chofer', '2026-08-03 09:00:00', '2026-08-03 10:15:00', 'Conforme', 'CONST-063'),
(64, 64, 'Jorge Ruiz Chofer', '2026-08-04 08:15:00', '2026-08-04 09:30:00', 'Conforme', 'CONST-064'),
(65, 65, 'Pedro Ramos Chofer', '2026-08-05 09:30:00', '2026-08-05 10:50:00', 'Conforme', 'CONST-065'),
(66, 66, 'Raul Castro Chofer', '2026-08-06 08:00:00', '2026-08-06 09:10:00', 'Conforme', 'CONST-066'),
(67, 67, 'Walter Soto Chofer', '2026-08-07 08:45:00', '2026-08-07 10:00:00', 'Conforme', 'CONST-067'),
(68, 68, 'Hugo Vega Chofer', '2026-08-08 09:10:00', '2026-08-08 10:25:00', 'Conforme', 'CONST-068'),
(69, 69, 'Felix Leon Chofer', '2026-08-09 08:20:00', '2026-08-09 09:40:00', 'Conforme', 'CONST-069'),
(70, 70, 'Mario Tello Chofer', '2026-08-09 08:30:00', '2026-08-09 09:50:00', 'Conforme', 'CONST-070');
GO

SET IDENTITY_INSERT Entrega_despacho OFF;
GO

-- ============================================================================
-- VERIFICACIÓN INMEDIATA DE REGISTROS
-- ============================================================================
SELECT 'Sede_Tottus' AS Tabla, COUNT(*) AS Total FROM Sede_Tottus
UNION ALL
SELECT 'Categoria', COUNT(*) FROM Categoria
UNION ALL
SELECT 'Beneficiario', COUNT(*) FROM Beneficiario
UNION ALL
SELECT 'Producto', COUNT(*) FROM Producto
UNION ALL
SELECT 'Lote_merma', COUNT(*) FROM Lote_merma
UNION ALL
SELECT 'Pedido_rescate', COUNT(*) FROM Pedido_rescate
UNION ALL
SELECT 'detalle_pedido_rescate', COUNT(*) FROM detalle_pedido_rescate
UNION ALL
SELECT 'Entrega_despacho', COUNT(*) FROM Entrega_despacho;
GO