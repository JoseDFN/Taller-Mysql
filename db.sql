-- Creación de la base de datos
CREATE DATABASE vtaszfs;
USE vtaszfs;

-- Tabla clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

-- Tabla ubicaciones
CREATE TABLE ubicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50)
);

CREATE TABLE entidad_ubicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ubicacion_id INT,
    entidad_id INT,
    entidad_tipo VARCHAR(25), -- Ejemplo: 'clientes', 'proveedores'
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id)
);

CREATE TABLE puestos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    descripcion TEXT
);

CREATE TABLE datos_empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(30),
    puesto_id INT,
    salario DECIMAL(8,2),
    fecha_contratacion DATE,
    FOREIGN KEY (puesto_id) REFERENCES puestos(id)
);

-- Tabla proveedores reducida a datos básicos
CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(45)
);

CREATE TABLE contacto_proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    proveedor_id INT,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE empleados_proveedores (
    empleado_id INT,
    proveedor_id INT,
    PRIMARY KEY (empleado_id, proveedor_id),
    FOREIGN KEY (empleado_id) REFERENCES datos_empleados(id),
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

-- Tabla tipos_productos
DROP TABLE IF EXISTS tipos_productos;
CREATE TABLE tipos_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_nombre VARCHAR(130),
    descripcion TEXT,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES tipos_productos(id)
);

-- Tabla productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(75),
    precio DECIMAL(10, 2),
    proveedor_id INT,
    tipo_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
    FOREIGN KEY (tipo_id) REFERENCES tipos_productos(id)
);

-- Tabla pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    empleado_id INT,
    fecha DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (empleado_id) REFERENCES datos_empleados(id)
);

-- Tabla detalles_pedido
CREATE TABLE detalles_pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    precio DECIMAL(10, 2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE historial_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    fecha_cambio DATETIME NOT NULL,
    tipo_cambio VARCHAR(50),
    descripcion TEXT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

CREATE TABLE telefonos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    telefono VARCHAR(20),
    tipo VARCHAR(50),  -- Ej. 'movil', 'fijo', etc.
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- 1. Tabla auxiliar para mantener el total de cada pedido.
CREATE TABLE pedido_totales (
    pedido_id INT PRIMARY KEY,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_pedido_totales FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

-- 2. Tabla para registrar cambios de salario de empleados.
CREATE TABLE historial_salarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    old_salary DECIMAL(8,2) NOT NULL,
    new_salary DECIMAL(8,2) NOT NULL,
    change_date DATETIME NOT NULL,
    CONSTRAINT fk_historial_salarios_empleado FOREIGN KEY (empleado_id) REFERENCES datos_empleados(id)
);

-- 3. Tabla para registrar actividades en la base de datos (por ejemplo, modificaciones en proveedores).
CREATE TABLE log_actividades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    accion VARCHAR(50) NOT NULL,
    entidad VARCHAR(50) NOT NULL,
    descripcion TEXT,
    fecha DATETIME NOT NULL
);

-- 4. Tabla para registrar cambios en contratos o información de empleados.
CREATE TABLE historial_contratos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    cambio VARCHAR(50) NOT NULL,
    descripcion TEXT,
    fecha DATETIME NOT NULL,
    CONSTRAINT fk_historial_contratos_empleado FOREIGN KEY (empleado_id) REFERENCES datos_empleados(id)
);

ALTER TABLE entidad_ubicaciones
ADD CONSTRAINT uc_entidad_ubicacion UNIQUE (entidad_id, entidad_tipo, ubicacion_id);