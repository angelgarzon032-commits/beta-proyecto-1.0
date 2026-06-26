-- ============================================================
-- BASE DE DATOS PARA TIENDA ONLINE SEX SHOP
-- ============================================================

CREATE DATABASE IF NOT EXISTS sex_shop_db;
USE sex_shop_db;

-- ============================================================
-- 1. TABLA DE USUARIOS (Cliente y Administrador)
-- ============================================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    rol ENUM('cliente', 'administrador') NOT NULL DEFAULT 'cliente',
    teléfono VARCHAR(20),
    estado ENUM('activo', 'inactivo', 'bloqueado') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualización TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_correo (correo),
    INDEX idx_rol (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. TABLA DE CATEGORÍAS
-- ============================================================
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    imagen_url VARCHAR(255),
    activa TINYINT(1) DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. TABLA DE PRODUCTOS
-- ============================================================
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion LONGTEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    categoria_id INT NOT NULL,
    activo TINYINT(1) DEFAULT 1,
    calificacion_promedio DECIMAL(3, 2) DEFAULT 0,
    cantidad_reseñas INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualización TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT,
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria_id),
    INDEX idx_precio (precio),
    INDEX idx_stock (stock)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. TABLA DE IMÁGENES DE PRODUCTOS
-- ============================================================
CREATE TABLE imagenes_productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255),
    orden INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    INDEX idx_producto (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. TABLA DE PEDIDOS
-- ============================================================
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
    estado ENUM('pendiente', 'confirmado', 'procesando', 'enviado', 'entregado', 'cancelado', 'devuelto') DEFAULT 'pendiente',
    direccion_envio TEXT NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20),
    notas TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_envio DATETIME,
    fecha_entrega DATETIME,
    fecha_actualización TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    INDEX idx_usuario (usuario_id),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. TABLA DE ITEMS DEL PEDIDO
-- ============================================================
CREATE TABLE pedido_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    INDEX idx_pedido (pedido_id),
    INDEX idx_producto (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. TABLA DE PAGOS
-- ============================================================
CREATE TABLE pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    monto DECIMAL(12, 2) NOT NULL,
    metodo ENUM('tarjeta_credito', 'tarjeta_debito', 'transferencia', 'paypal', 'nequi', 'daviplata') NOT NULL,
    estado ENUM('pendiente', 'procesando', 'aprobado', 'rechazado', 'reembolsado') DEFAULT 'pendiente',
    referencia VARCHAR(100),
    numero_transaccion VARCHAR(100),
    detalles JSON,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_procesamiento DATETIME,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
    INDEX idx_pedido (pedido_id),
    INDEX idx_estado (estado),
    UNIQUE INDEX idx_referencia (referencia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. TABLA DE RESEÑAS Y COMENTARIOS
-- ============================================================
CREATE TABLE reseñas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion INT NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
    titulo VARCHAR(200),
    comentario TEXT,
    util_count INT DEFAULT 0,
    activa TINYINT(1) DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualización TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_producto (producto_id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_calificacion (calificacion),
    UNIQUE KEY unique_review (producto_id, usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. TABLA DE INVENTARIO (Historial de movimientos)
-- ============================================================
CREATE TABLE inventario_movimientos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste', 'devolución') NOT NULL,
    cantidad INT NOT NULL,
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    referencia VARCHAR(100),
    pedido_id INT,
    descripcion TEXT,
    usuario_id_responsable INT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE SET NULL,
    FOREIGN KEY (usuario_id_responsable) REFERENCES usuarios(id) ON DELETE SET NULL,
    INDEX idx_producto (producto_id),
    INDEX idx_tipo (tipo_movimiento),
    INDEX idx_fecha (fecha_creacion),
    INDEX idx_pedido (pedido_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. TABLA DE ENVÍOS
-- ============================================================
CREATE TABLE envios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    transportadora VARCHAR(100) NOT NULL,
    numero_seguimiento VARCHAR(100) UNIQUE,
    estado ENUM('preparando', 'recogida', 'en_transito', 'en_entrega_local', 'entregado', 'devuelto', 'incidencia') DEFAULT 'preparando',
    fecha_inicio DATETIME,
    fecha_entrega_estimada DATETIME,
    fecha_entrega_real DATETIME,
    ubicacion_actual VARCHAR(255),
    costo_envio DECIMAL(10, 2),
    firma_entrega VARCHAR(255),
    notas TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualización TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    INDEX idx_pedido (pedido_id),
    INDEX idx_estado (estado),
    INDEX idx_seguimiento (numero_seguimiento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. TABLA DE DIRECCIONES DE USUARIOS
-- ============================================================
CREATE TABLE direcciones_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo ENUM('envio', 'facturacion', 'ambas') DEFAULT 'envio',
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20),
    telefono VARCHAR(20),
    es_predeterminada TINYINT(1) DEFAULT 0,
    activa TINYINT(1) DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. TABLA DE CARRITO DE COMPRAS
-- ============================================================
CREATE TABLE carrito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_carrito (usuario_id, producto_id),
    INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS DE EJEMPLO
-- ============================================================

-- Usuarios
INSERT INTO usuarios (nombre, correo, contraseña, rol) VALUES
('Admin Principal', 'admin@sexshop.com', SHA2('admin123', 256), 'administrador'),
('Carlos González', 'carlos@example.com', SHA2('pass123', 256), 'cliente'),
('María López', 'maria@example.com', SHA2('pass123', 256), 'cliente'),
('Juan Pérez', 'juan@example.com', SHA2('pass123', 256), 'cliente');

-- Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Juguetes Íntimos', 'Vibradores y juguetes personales de calidad premium'),
('Lencería Erótica', 'Prendas de lencería diseñadas para aumentar la pasión'),
('Accesorios BDSM', 'Equipos y accesorios para juegos de rol y fantasías'),
('Potenciadores', 'Productos para mejorar el rendimiento sexual'),
('Lubricantes', 'Lubricantes de diferentes texturas y sabores'),
('Disfraces', 'Disfraces y ropa temática erótica');

-- Productos
INSERT INTO productos (nombre, descripcion, precio, stock, categoria_id) VALUES
('Vibrador Rosa Deluxe', 'Vibrador recargable con 8 modos de vibración, fabricado en silicona de grado médico. Impermeable y silencioso.', 89.99, 25, 1),
('Lencería Negra Sexy', 'Set de lencería en encaje negro con soporte y comodidad máxima. Tallas disponibles: S, M, L, XL.', 45.99, 40, 2),
('Kit BDSM Iniciante', 'Kit completo para principiantes con esposas, venda y fusta acolchada. Seguro y cómodo para todos.', 79.99, 15, 3),
('Gel Potenciador', 'Potenciador de desempeño en gel, efecto inmediato y duradero. Ingredientes naturales.', 34.99, 50, 4),
('Lubricante Premium Anal', 'Lubricante especializado para práctica anal, base aceitosa, larga duración y fácil limpieza.', 24.99, 60, 5),
('Disfraz de Enfermera Sexy', 'Disfraz completo de enfermera con accesorios incluidos. Talla única (S-M).', 39.99, 20, 6),
('Vibrador de Punto G', 'Diseño ergonómico dirigido al punto G con 10 patrones de vibración diferentes.', 99.99, 18, 1),
('Aceite de Masaje Sensual', 'Aceite corporal afrodisíaco con aroma a vainilla. 100ml. Calma y estimula.', 29.99, 35, 5);

-- Imágenes de productos
INSERT INTO imagenes_productos (producto_id, url_imagen, orden) VALUES
(1, '/images/productos/vibrador-rosa-1.jpg', 0),
(1, '/images/productos/vibrador-rosa-2.jpg', 1),
(2, '/images/productos/lenceria-negra-1.jpg', 0),
(2, '/images/productos/lenceria-negra-2.jpg', 1),
(3, '/images/productos/kit-bdsm-1.jpg', 0),
(4, '/images/productos/gel-potenciador-1.jpg', 0),
(5, '/images/productos/lubricante-anal-1.jpg', 0),
(6, '/images/productos/disfraz-enfermera-1.jpg', 0);

-- Direcciones de usuarios
INSERT INTO direcciones_usuario (usuario_id, tipo, nombres, apellidos, direccion, ciudad, departamento, telefono, es_predeterminada) VALUES
(2, 'ambas', 'Carlos', 'González', 'Carrera 5 #23-45, Apto 601', 'Bogotá', 'Cundinamarca', '3105551234', 1),
(3, 'envio', 'María', 'López', 'Calle 10 #5-67', 'Medellín', 'Antioquia', '3145552345', 1),
(4, 'ambas', 'Juan', 'Pérez', 'Avenida Paseo #100-200', 'Cali', 'Valle del Cauca', '3165553456', 1);

-- Reseñas
INSERT INTO reseñas (producto_id, usuario_id, calificacion, titulo, comentario) VALUES
(1, 2, 5, 'Excelente producto', 'Muy buena calidad, discreto y funciona perfecto. Recomendado.'),
(2, 3, 4, 'Bonito diseño', 'Se ve bien, aunque la talla podría ser más ajustada.'),
(1, 3, 5, 'Mejor compra', 'Superó mis expectativas en todos los aspectos.'),
(4, 4, 4, 'Bueno pero caro', 'Funciona bien, precio un poco elevado pero vale la pena.');

-- Pedidos
INSERT INTO pedidos (usuario_id, total, estado, direccion_envio, ciudad, departamento) VALUES
(2, 169.98, 'entregado', 'Carrera 5 #23-45, Apto 601', 'Bogotá', 'Cundinamarca'),
(3, 45.99, 'enviado', 'Calle 10 #5-67', 'Medellín', 'Antioquia'),
(4, 134.97, 'confirmado', 'Avenida Paseo #100-200', 'Cali', 'Valle del Cauca');

-- Items del pedido
INSERT INTO pedido_items (pedido_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 89.99, 89.99),
(1, 5, 1, 24.99, 24.99),
(1, 8, 1, 29.99, 29.99),
(2, 2, 1, 45.99, 45.99),
(3, 3, 1, 79.99, 79.99),
(3, 8, 1, 29.99, 29.99),
(3, 4, 1, 34.99, 34.99);

-- Pagos
INSERT INTO pagos (pedido_id, monto, metodo, estado, referencia, numero_transaccion) VALUES
(1, 169.98, 'tarjeta_credito', 'aprobado', 'TXN001', 'TC0001234567'),
(2, 45.99, 'transferencia', 'aprobado', 'TRF001', 'TRANS0001'),
(3, 134.97, 'nequi', 'procesando', 'NEQ001', 'NEQ0001234');

-- Envíos
INSERT INTO envios (pedido_id, transportadora, numero_seguimiento, estado, fecha_inicio, fecha_entrega_real, costo_envio) VALUES
(1, 'Servientrega', 'SER123456789', 'entregado', '2024-01-10 08:00:00', '2024-01-15 14:30:00', 15.00),
(2, 'TCC', 'TCC987654321', 'en_transito', '2024-01-18 09:00:00', NULL, 12.50),
(3, 'Envía', 'ENV456789123', 'preparando', NULL, NULL, 18.00);

-- Movimientos de inventario
INSERT INTO inventario_movimientos (producto_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva, referencia, descripcion) VALUES
(1, 'entrada', 30, 0, 30, 'ENTRADA-001', 'Compra inicial de stock'),
(1, 'salida', 1, 30, 29, 'PEDIDO-001', 'Venta en pedido 1'),
(2, 'entrada', 50, 0, 50, 'ENTRADA-002', 'Stock inicial'),
(2, 'salida', 1, 50, 49, 'PEDIDO-002', 'Venta en pedido 2'),
(3, 'entrada', 20, 0, 20, 'ENTRADA-003', 'Compra de proveedor'),
(3, 'salida', 1, 20, 19, 'PEDIDO-003', 'Venta en pedido 3');

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Vista: Resumen de productos con información completa
CREATE VIEW vista_productos_completa AS
SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    p.precio,
    p.stock,
    c.nombre as categoria,
    p.calificacion_promedio,
    p.cantidad_reseñas,
    p.activo
FROM productos p
JOIN categorias c ON p.categoria_id = c.id;

-- Vista: Pedidos con información del usuario
CREATE VIEW vista_pedidos_detalle AS
SELECT 
    pd.id as pedido_id,
    u.nombre as cliente,
    u.correo,
    pd.total,
    pd.estado,
    pd.ciudad,
    pd.departamento,
    pd.fecha_creacion,
    pd.fecha_actualización
FROM pedidos pd
JOIN usuarios u ON pd.usuario_id = u.id;

-- Vista: Ventas por categoría
CREATE VIEW vista_ventas_por_categoria AS
SELECT 
    c.nombre as categoria,
    COUNT(DISTINCT pd.id) as total_pedidos,
    SUM(pi.cantidad) as total_items_vendidos,
    SUM(pi.subtotal) as ingresos_totales,
    AVG(p.calificacion_promedio) as calificacion_promedio
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
LEFT JOIN pedido_items pi ON p.id = pi.producto_id
LEFT JOIN pedidos pd ON pi.pedido_id = pd.id
GROUP BY c.id, c.nombre;

-- Vista: Top productos más vendidos
CREATE VIEW vista_top_productos AS
SELECT 
    p.id,
    p.nombre,
    c.nombre as categoria,
    SUM(pi.cantidad) as cantidad_vendida,
    SUM(pi.subtotal) as ingresos,
    p.calificacion_promedio,
    COUNT(DISTINCT r.id) as total_reseñas
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN pedido_items pi ON p.id = pi.producto_id
LEFT JOIN reseñas r ON p.id = r.producto_id
GROUP BY p.id
ORDER BY cantidad_vendida DESC;

-- ============================================================
-- PROCEDIMIENTOS ALMACENADOS ÚTILES
-- ============================================================

-- Procedimiento: Registrar nueva compra y actualizar inventario
DELIMITER $$

CREATE PROCEDURE registrar_compra(
    IN p_usuario_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10,2),
    IN p_direccion TEXT,
    IN p_ciudad VARCHAR(100),
    IN p_departamento VARCHAR(100)
)
BEGIN
    DECLARE v_nuevo_stock INT;
    DECLARE v_pedido_id INT;
    
    START TRANSACTION;
    
    -- Verificar stock disponible
    SELECT stock INTO v_nuevo_stock FROM productos WHERE id = p_producto_id FOR UPDATE;
    
    IF v_nuevo_stock < p_cantidad THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
    
    -- Crear pedido
    INSERT INTO pedidos (usuario_id, total, estado, direccion_envio, ciudad, departamento)
    VALUES (p_usuario_id, p_cantidad * p_precio_unitario, 'pendiente', p_direccion, p_ciudad, p_departamento);
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    -- Agregar item al pedido
    INSERT INTO pedido_items (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_pedido_id, p_producto_id, p_cantidad, p_precio_unitario, p_cantidad * p_precio_unitario);
    
    -- Actualizar stock
    UPDATE productos SET stock = stock - p_cantidad WHERE id = p_producto_id;
    
    -- Registrar movimiento de inventario
    INSERT INTO inventario_movimientos (producto_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva, pedido_id, descripcion)
    VALUES (p_producto_id, 'salida', p_cantidad, v_nuevo_stock, v_nuevo_stock - p_cantidad, v_pedido_id, 'Venta por pedido');
    
    COMMIT;
    SELECT v_pedido_id as nuevo_pedido_id;
END$$

DELIMITER ;

-- Procedimiento: Procesar devolución de producto
DELIMITER $$

CREATE PROCEDURE procesar_devolucion(
    IN p_pedido_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_razon VARCHAR(255)
)
BEGIN
    DECLARE v_stock_actual INT;
    
    START TRANSACTION;
    
    -- Obtener stock actual
    SELECT stock INTO v_stock_actual FROM productos WHERE id = p_producto_id FOR UPDATE;
    
    -- Actualizar estado del pedido
    UPDATE pedidos SET estado = 'devuelto' WHERE id = p_pedido_id;
    
    -- Devolver stock
    UPDATE productos SET stock = stock + p_cantidad WHERE id = p_producto_id;
    
    -- Registrar movimiento
    INSERT INTO inventario_movimientos (producto_id, tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva, pedido_id, descripcion)
    VALUES (p_producto_id, 'devolución', p_cantidad, v_stock_actual, v_stock_actual + p_cantidad, p_pedido_id, CONCAT('Devolución: ', p_razon));
    
    COMMIT;
    SELECT 'Devolución procesada exitosamente' as mensaje;
END$$

DELIMITER ;

-- ============================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================
-- ============================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================
CREATE INDEX idx_pagos_fecha ON pagos(fecha_creacion);
CREATE INDEX idx_reseñas_activas ON reseñas(activa, fecha_creacion);
CREATE INDEX idx_envios_transportadora ON envios(transportadora, estado);
CREATE INDEX idx_productos_stock_bajo ON productos(stock);
-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
