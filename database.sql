-- SIG-GLORIA
-- Script de base de datos referencial para revisión técnica.
-- La app puede ejecutarse con servidor local Python y base de datos SQLite.
-- Este script documenta el modelo relacional del prototipo.

CREATE TABLE usuarios (
  id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  correo TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  rol TEXT NOT NULL CHECK (rol IN ('ADMIN', 'CLIENTE')),
  estado TEXT NOT NULL DEFAULT 'ACTIVO',
  fecha_registro TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productores (
  id_productor INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  ubicacion TEXT,
  telefono TEXT,
  volumen_promedio_litros REAL,
  calidad TEXT,
  estado TEXT
);

CREATE TABLE controles_calidad (
  id_control INTEGER PRIMARY KEY AUTOINCREMENT,
  fecha_hora TEXT NOT NULL,
  lote TEXT NOT NULL,
  productor TEXT NOT NULL,
  grasa REAL,
  densidad REAL,
  temperatura REAL,
  resultado TEXT NOT NULL,
  usuario TEXT NOT NULL
);

CREATE TABLE productos (
  id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  presentacion TEXT NOT NULL,
  precio_unitario REAL NOT NULL,
  stock_estado TEXT NOT NULL
);

CREATE TABLE clientes (
  id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  dni_ruc TEXT,
  ubicacion TEXT,
  telefono TEXT,
  correo TEXT,
  tipo_comprobante TEXT,
  razon_social TEXT,
  estado TEXT
);

CREATE TABLE inventario (
  id_inventario INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  producto TEXT NOT NULL,
  lote TEXT NOT NULL,
  stock_disponible TEXT NOT NULL,
  vencimiento TEXT NOT NULL,
  ubicacion TEXT NOT NULL,
  estado TEXT NOT NULL
);

CREATE TABLE pedidos (
  id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  cliente TEXT NOT NULL,
  fecha_hora TEXT NOT NULL,
  canal TEXT NOT NULL,
  producto TEXT NOT NULL,
  presentacion TEXT NOT NULL,
  cantidad INTEGER NOT NULL,
  precio_unitario REAL NOT NULL,
  total REAL NOT NULL,
  estado TEXT NOT NULL
);

CREATE TABLE comprobantes (
  id_comprobante INTEGER PRIMARY KEY AUTOINCREMENT,
  pedido_codigo TEXT NOT NULL,
  tipo TEXT NOT NULL,
  serie TEXT NOT NULL,
  numero TEXT NOT NULL,
  estado TEXT NOT NULL DEFAULT 'GENERADO',
  fecha_emision TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_codigo) REFERENCES pedidos(codigo)
);

CREATE TABLE tickets_soporte (
  id_ticket INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  tipo TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  estado TEXT NOT NULL,
  fecha_hora TEXT NOT NULL
);

INSERT INTO usuarios(nombre, correo, password_hash, rol) VALUES
('Administrador SIG-GLORIA', 'admin@gloria.com', 'admin123', 'ADMIN'),
('Jeffer Zapata', 'jeffer', '123456', 'ADMIN'),
('Cliente SIG-GLORIA', 'cliente@gloria.com', 'cliente123', 'CLIENTE');

INSERT INTO productos(nombre, presentacion, precio_unitario, stock_estado) VALUES
('Leche evaporada Gloria', 'Caja x 48 latas 400 g', 185.50, 'Disponible'),
('Leche entera UHT Gloria', 'Caja x 12 unidades 1 L', 54.90, 'Disponible'),
('Yogurt Gloria fresa', 'Caja x 12 botellas 1 L', 65.00, 'Disponible'),
('Queso fresco Gloria', 'Caja x 12 unidades 500 g', 98.00, 'Stock bajo'),
('Mantequilla Gloria', 'Caja x 24 unidades 200 g', 71.50, 'Disponible'),
('Manjar blanco Gloria', 'Caja x 24 potes 200 g', 86.40, 'Disponible');

INSERT INTO clientes(codigo, nombre, dni_ruc, ubicacion, telefono, correo, tipo_comprobante, razon_social, estado) VALUES
('CL-001', 'Supermercado Lima', '20123456789', 'Lima, Lima', '987 111 222', 'compras@superlima.pe', 'Factura', 'Supermercado Lima S.A.C.', 'Activo'),
('CL-002', 'Mayorista Norte', '20456789123', 'Trujillo, La Libertad', '987 333 444', 'ventas@mayoristanorte.pe', 'Factura', 'Mayorista Norte S.A.C.', 'Activo'),
('CL-003', 'Portal Cliente SAC', '20555111222', 'Arequipa, Arequipa', '987 555 666', 'contacto@portalcliente.pe', 'Factura', 'Portal Cliente S.A.C.', 'Activo'),
('CL-004', 'Cliente Natural', '45678912', 'Lima, Lima', '987 777 888', 'cliente@correo.com', 'Boleta', '', 'Activo');

INSERT INTO productores(codigo, nombre, ubicacion, telefono, volumen_promedio_litros, calidad, estado) VALUES
('PR-001', 'Ganadería Santa Rosa', 'Arequipa, Arequipa', '987 654 321', 850, 'A', 'Activo'),
('PR-002', 'Fundo Los Alpes', 'Lima, Lima', '976 543 210', 620, 'B', 'Activo'),
('PR-003', 'Asoc. Lechera Norte', 'Trujillo, La Libertad', '969 852 147', 1200, 'A', 'Observado'),
('PR-004', 'La Campiña', 'Cusco, Cusco', '958 741 263', 540, 'A', 'Activo');

INSERT INTO controles_calidad(fecha_hora, lote, productor, grasa, densidad, temperatura, resultado, usuario) VALUES
('22/05/2026 10:15', 'L-2026-05-001', 'Ganadería La Esperanza', 3.68, 1.029, 4.1, 'Aprobado', 'Ana Gómez'),
('22/05/2026 09:47', 'L-2026-05-002', 'Agropecuaria El Sol', 3.45, 1.026, 4.3, 'Observado', 'Luis Quispe');

INSERT INTO inventario(codigo, producto, lote, stock_disponible, vencimiento, ubicacion, estado) VALUES
('PRD-001', 'Yogurt fresa 1L', 'L-301', '120 unid.', '03/06/2026 (12 días)', 'Almacén Central / Pasillo A', 'Salida prioritaria'),
('PRD-002', 'Leche entera 1L', 'L-204', '340 unid.', '06/06/2026 (15 días)', 'Almacén Central / Pasillo A', 'Disponible'),
('PRD-003', 'Queso fresco 500g', 'L-112', '85 unid.', '10/06/2026 (19 días)', 'Almacén Frío / Cámara 1', 'Stock bajo');

INSERT INTO pedidos(codigo, cliente, fecha_hora, canal, producto, presentacion, cantidad, precio_unitario, total, estado) VALUES
('P-1452', 'Supermercado Lima', '22/05/2026 10:15', 'Supermercados', 'Leche evaporada Gloria', 'Caja x 48 latas 400 g', 180, 185.50, 33390.00, 'Pendiente'),
('P-1453', 'Mayorista Norte', '22/05/2026 09:47', 'Mayoristas', 'Leche entera UHT Gloria', 'Caja x 12 unidades 1 L', 620, 54.90, 34038.00, 'Facturado'),
('P-1454', 'Portal Cliente SAC', '22/05/2026 08:30', 'Portal cliente', 'Yogurt Gloria fresa', 'Caja x 12 botellas 1 L', 130, 65.00, 8450.00, 'En despacho');

INSERT INTO comprobantes(pedido_codigo, tipo, serie, numero, estado) VALUES
('P-1452', 'FACTURA', 'F001', '00098765', 'GENERADO');

INSERT INTO tickets_soporte(codigo, tipo, descripcion, estado, fecha_hora) VALUES
('TK-001', 'Consulta de pedido', 'Cliente solicita estado de entrega del pedido P-1454', 'Abierto', '22/05/2026 11:05'),
('TK-002', 'Comprobante', 'Solicitud de reenvío de factura F-98765', 'Atendido', '21/05/2026 16:20');
