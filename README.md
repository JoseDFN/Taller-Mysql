# Taller MySQL - Documentación de Consultas, Soluciones y Pruebas

Este documento reúne la descripción de cada consulta y script del proyecto, junto con su solución y forma de prueba. Las secciones se presentan en el siguiente orden:

1. **Normalización** (comandos DDL en `db.sql`)
2. **Joins** (consultas en `joins.sql`)
3. **Consultas Simples** (consultas en `simpleQueries.sql`)
4. **Consultas Multitabla** (consultas en `multiTableQueries.sql`)
5. **Subconsultas** (consultas en `SubQueries.sql`)
6. **Procedimientos Almacenados** (procedimientos en `StoredProcedures.sql`)
7. **Funciones Definidas por el Usuario** (funciones en `Functions.sql`)
8. **Triggers** (triggers en `Triggers.sql`)
9. **Ejercicios Combinados de Funciones y Consultas** (consultas y funciones en `FunctionsQueries.sql`)

---

 ## 1. Normalización

Esta sección incluye los comandos DDL definidos en el archivo `db.sql` para la creación y estructuración de la base de datos. Se establecen las tablas, relaciones, llaves primarias y foráneas, y demás restricciones necesarias para garantizar la integridad de la información. Con estos scripts se logra la normalización de la base de datos, facilitando su mantenimiento y optimizando la ejecución de las consultas.

**Descripción:**  
- **Creación de la Base de Datos:** Se crea la base de datos `vtaszfs` y se selecciona para usar.  
- **Definición de Tablas Principales:** Se crean las tablas para almacenar información de clientes, ubicaciones, empleados, proveedores, productos, pedidos, detalles de pedido, entre otros.  
- **Relaciones y Restricciones:** Se definen llaves primarias, llaves foráneas y restricciones de unicidad, las cuales aseguran la integridad referencial y evitan datos duplicados.  
- **Tablas Auxiliares y de Historial:** Se incluyen tablas auxiliares como `pedido_totales` o de registro de cambios como `historial_salarios`, `log_actividades` y `historial_contratos` para mantener un control detallado de las operaciones.

**Prueba:**  
Para validar que la normalización se ha realizado correctamente, se recomienda:
1. Ejecutar el script `db.sql` en un entorno MySQL.
2. Utilizar la consulta `SHOW TABLES;` para verificar la creación de todas las tablas.
3. Revisar las relaciones mediante `DESCRIBE <nombre_de_tabla>;` en cada tabla para confirmar las definiciones de llaves primarias y foráneas.

A continuación se muestra el contenido completo del script de normalización:

```sql:db.sql
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
    entidad_tipo VARCHAR(50), -- Ejemplo: 'clientes', 'proveedores'
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id)
);

CREATE TABLE puestos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

CREATE TABLE datos_empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    puesto_id INT,
    salario DECIMAL(10,2),
    fecha_contratacion DATE,
    FOREIGN KEY (puesto_id) REFERENCES puestos(id)
);

-- Tabla proveedores reducida a datos básicos
CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
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
    tipo_nombre VARCHAR(100),
    descripcion TEXT,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES tipos_productos(id)
);

-- Tabla productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
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

-- Tabla auxiliar para mantener el total de cada pedido.
CREATE TABLE pedido_totales (
    pedido_id INT PRIMARY KEY,
    total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_pedido_totales FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

-- Tabla para registrar cambios de salario de empleados.
CREATE TABLE historial_salarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    old_salary DECIMAL(10,2) NOT NULL,
    new_salary DECIMAL(10,2) NOT NULL,
    change_date DATETIME NOT NULL,
    CONSTRAINT fk_historial_salarios_empleado FOREIGN KEY (empleado_id) REFERENCES datos_empleados(id)
);

-- Tabla para registrar actividades en la base de datos (por ejemplo, modificaciones en proveedores).
CREATE TABLE log_actividades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    accion VARCHAR(50) NOT NULL,
    entidad VARCHAR(50) NOT NULL,
    descripcion TEXT,
    fecha DATETIME NOT NULL
);

-- Tabla para registrar cambios en contratos o información de empleados.
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
```

## 2. Joins

Esta sección presenta las consultas que combinan datos de múltiples tablas utilizando diversas técnicas JOIN, tales como INNER JOIN, LEFT JOIN, RIGHT JOIN y combinaciones múltiples. Cada consulta demuestra cómo relacionar la información de diferentes tablas para obtener conjuntos de resultados integrados.

**Descripción:**  
- **INNER JOIN:** Combina registros que tienen coincidencias en ambas tablas.  
- **LEFT JOIN:** Incluye todos los registros de la tabla de la izquierda y los coincidentes de la tabla de la derecha.  
- **RIGHT JOIN:** Devuelve todos los registros de la tabla de la derecha y los coincidentes de la tabla de la izquierda.  
- **Uso de funciones de agrupación y ordenamiento:** Algunas consultas cuentan registros o agrupan resultados para obtener resúmenes.

**Prueba:**  
Para probar estas consultas, se recomienda:
1. Ejecutar cada consulta en un entorno MySQL.
2. Verificar que los resultados coincidan con la información almacenada en las tablas.
3. Ajustar condiciones (por ejemplo, IDs o nombres) para validar diferentes escenarios.

A continuación se muestra el contenido completo del archivo `joins.sql`:

```sql:joins.sql
-- Obtener la lista de todos los pedidos con los nombres de clientes usando INNER JOIN .

SELECT p.id as Id_Pedido, p.fecha as Fecha_Pedido, c.nombre as Nombre_Cliente
FROM pedidos as p
INNER JOIN clientes as c ON p.cliente_id = c.id
ORDER BY p.fecha DESC;

-- Listar los productos y proveedores que los suministran con INNER JOIN .

SELECT p.nombre as Nombre_Producto, p.precio as Precio_Producto, pv.nombre as Proveedor_Producto
FROM productos as p
INNER JOIN proveedores as pv ON p.proveedor_id = pv.id
ORDER BY p.nombre ASC

-- Mostrar los pedidos y las ubicaciones de los clientes con LEFT JOIN .

SELECT p.id as Id_Pedido, p.fecha as Fecha_pedido, u.direccion as Direccion_Cliente
FROM pedidos AS p
LEFT JOIN entidad_ubicaciones as eu ON p.cliente_id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
ORDER BY p.fecha DESC;

-- Consultar los empleados que han registrado pedidos, incluyendo empleados sin pedidos (LEFT JOIN).

SELECT de.nombre AS Nombre_Empleado, p.id AS Pedido_Id, p.fecha AS Fecha_Pedido
FROM datos_empleados AS de
LEFT JOIN pedidos AS p ON de.id = p.empleado_id
ORDER BY p.fecha DESC;

-- Obtener el tipo de producto y los productos asociados con INNER JOIN .

SELECT tp.tipo_nombre AS Tipo_Producto, p.nombre AS Nombre_Producto, p.precio AS Precio_Producto
FROM productos AS p
INNER JOIN tipos_productos AS tp ON p.tipo_id = tp.id
ORDER BY tp.tipo_nombre;

-- Listar todos los clientes y el número de pedidos realizados con COUNT y GROUP BY .

SELECT c.nombre AS Nombre_Cliente, COUNT(p.id) AS Numero_Pedidos
FROM clientes AS c
LEFT JOIN pedidos as p ON c.id = p.cliente_id
GROUP BY c.nombre
ORDER BY c.nombre ASC;

-- Combinar Pedidos y Empleados para mostrar qué empleados gestionaron pedidos específicos

SELECT de.nombre AS Nombre_Empleado, p.id AS Pedido_Id, p.fecha AS Fecha_Pedido
FROM datos_empleados AS de
INNER JOIN pedidos AS p ON de.id = p.empleado_id
WHERE p.id = 1 -- Aquí se puede reemplazar por el ID requerido o usar un procedimiento almacenado o función
ORDER BY p.fecha DESC;

-- Mostrar productos que no han sido pedidos (RIGHT JOIN).

SELECT p.id AS Id_Producto, p.nombre AS Nombre_Producto
FROM detalles_pedido AS dp
RIGHT JOIN productos AS p ON dp.producto_id = p.id
WHERE dp.producto_id IS NULL
ORDER BY p.nombre ASC;

-- Mostrar el total de pedidos y ubicación de clientes usando múltiples JOIN.

SELECT COUNT(DISTINCT p.id) AS Total_Pedidos, COUNT(DISTINCT u.id) AS Total_Ubicaciones
FROM pedidos AS p
LEFT JOIN entidad_ubicaciones AS eu ON p.cliente_id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id;

-- Unir Proveedores, Productos y TiposProductos para un listado completo de inventario.

SELECT tp.tipo_nombre AS Tipo_Producto, p.nombre AS Nombre_Producto, pv.nombre AS Nombre_Proveedor
FROM productos AS p
INNER JOIN tipos_productos AS tp ON p.tipo_id = tp.id
INNER JOIN proveedores AS pv ON p.proveedor_id = pv.id
ORDER BY tp.tipo_nombre ASC;
```

## 3. Consultas Simples

Esta sección agrupa consultas directas y básicas que permiten obtener información específica de cada una de las tablas de la base de datos. Se incluyen consultas para filtrar, ordenar y agrupar datos según criterios como precios, fechas, ciudades, entre otros, lo que facilita la verificación y análisis de los datos.

**Descripción:**
- **Filtrado de Productos:** Selecciona productos con precios mayores a un valor dado.
- **Consultas de Clientes:** Permite listar clientes registrados en una ciudad específica y detectar aquellos sin dirección registrada.
- **Consultas de Empleados:** Muestra empleados contratados recientemente, considerando un intervalo de tiempo determinado.
- **Consultas de Proveedores:** Identifica proveedores que suministran más de 5 productos.
- **Agregaciones:** Calcula el total de ventas por cliente y el salario promedio de los empleados.
- **Ordenamiento y Límites:** Ordena productos por precio y determina el cliente con el mayor número de pedidos.

**Prueba:**
Para validar el funcionamiento de estas consultas, se recomienda:
1. Ejecutar cada consulta en un entorno MySQL.
2. Comparar los resultados con los datos almacenados en la base de datos.
3. Ajustar los parámetros (por ejemplo, la ciudad o el intervalo de fechas) para cubrir diferentes escenarios.

A continuación se muestra el contenido completo del archivo `simpleQueries.sql`:

```sql:simpleQueries.sql
-- Seleccionar todos los productos con precio mayor a $50.

SELECT p.nombre AS Producto, p.precio AS Precio
FROM productos AS p
WHERE p.precio > 50.00;

-- Consultar clientes registrados en una ciudad específica.

SELECT c.nombre AS Nombre_Cliente, u.ciudad AS Ciudad
FROM clientes AS c
INNER JOIN entidad_ubicaciones AS eu ON c.id = eu.entidad_id
INNER JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
WHERE u.ciudad = 'Bucaramanga'; -- Reemplazar por la ciudad requerida

-- Mostrar empleados contratados en los últimos 2 años.

SELECT e.nombre AS Nombre_Empleado, e.fecha_contratacion AS Fecha_Contratacion
FROM datos_empleados as e
WHERE e.fecha_contratacion >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
ORDER BY e.fecha_contratacion DESC;

-- Seleccionar proveedores que suministran más de 5 productos.

SELECT pv.id as Id_Proveedor, pv.nombre as Nombre_Proveedor, COUNT(p.id) as Total_Productos
FROM proveedores as pv
INNER JOIN productos as p ON pv.id = p.proveedor_id
GROUP BY pv.id, pv.nombre
HAVING COUNT(pv.id) > 5
ORDER BY Total_Producto DESC;

-- Listar clientes que no tienen dirección registrada en UbicacionCliente.

SELECT c.nombre AS Nombre_Cliente
FROM clientes AS c
LEFT JOIN entidad_ubicaciones AS eu ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
WHERE eu.entidad_id IS NULL;

-- Calcular el total de ventas por cada cliente.

SELECT c.nombre AS Nombre_Cliente, SUM(dp.cantidad * dp.precio) AS Total_Ventas
FROM clientes AS c
INNER JOIN pedidos AS p ON c.id = p.cliente_id
INNER JOIN detalles_pedido AS dp ON p.id = dp.pedido_id
GROUP BY c.id, c.nombre
ORDER BY Total_Ventas DESC;

-- Mostrar el salario promedio de los empleados.

SELECT AVG(salario) AS Salario_Promedio
FROM datos_empleados;

-- Consultar el tipo de productos disponibles en TiposProductos.

SELECT id, tipo_nombre, descripcion
FROM tipos_productos;

-- Seleccionar los 3 productos más caros.

SELECT id AS Id_Producto, nombre AS Nombre_Producto, precio AS Precio
FROM productos
ORDER BY precio DESC
LIMIT 3;

-- Consultar el cliente con el mayor número de pedidos.

SELECT c.nombre AS Nombre_Cliente, COUNT(p.id) AS Numero_Pedidos
FROM clientes AS c
INNER JOIN pedidos AS p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
ORDER BY Numero_Pedidos DESC
LIMIT 1;
```

## 4. Consultas Multitabla

Esta sección presenta consultas que combinan datos provenientes de dos o más tablas para obtener información integrada y detallada. Cada consulta muestra cómo relacionar diversas tablas aprovechando los JOINs (INNER, LEFT, etc.) para responder a requerimientos que involucran múltiples entidades, tales como pedidos con sus clientes, productos con proveedores y tipos, o la agrupación de datos por ciudad y cliente.

**Descripción:**  
- **Listar Pedidos y Clientes:** Obtiene todos los pedidos junto con el nombre del cliente correspondiente.
- **Mostrar Ubicación en Pedidos:** Combina pedidos con la información de ubicación de los clientes.
- **Productos, Proveedores y Tipos:** Relaciona productos con sus proveedores y categorías.
- **Empleados en Pedidos por Ciudad:** Consulta empleados que gestionan pedidos de clientes en una ciudad específica.
- **Productos Más Vendidos:** Calcula la suma de cantidad vendida para identificar los productos más vendidos.
- **Pedidos por Cliente y Ciudad:** Agrupa los pedidos por cliente y ciudad.
- **Clientes y Proveedores en la Misma Ciudad:** Muestra clientes y proveedores ubicados en la misma ciudad.
- **Ventas por Tipo de Producto:** Agrupa y suma ventas según la categoría de producto.
- **Empleados según Proveedor:** Selecciona empleados que procesaron pedidos de productos de un proveedor específico.
- **Ingreso Total del Proveedor:** Calcula los ingresos totales obtenidos por cada proveedor basados en la venta de sus productos.

**Prueba:**  
Para validar estas consultas se recomienda:
1. Ejecutarlas en un entorno MySQL.
2. Verificar que los resultados correspondan a la información de la base de datos.
3. Ajustar condiciones (como `<ID_PROVEEDOR>` o `'CiudadEjemplo'`) para probar distintos escenarios.

A continuación se muestra el contenido completo del archivo `multiTableQueries.sql`:

```sql:multiTableQueries.sql
-- 1. Listar todos los pedidos y el cliente asociado.
SELECT p.id AS Id_Pedido, 
       p.fecha AS Fecha_Pedido, 
       c.nombre AS Nombre_Cliente
FROM pedidos AS p
INNER JOIN clientes AS c ON p.cliente_id = c.id
ORDER BY p.fecha DESC;

-- 2. Mostrar la ubicación de cada cliente en sus pedidos.
SELECT p.id AS Id_Pedido,
       p.fecha AS Fecha_Pedido,
       c.nombre AS Nombre_Cliente,
       u.direccion AS Direccion_Cliente,
       u.ciudad AS Ciudad
FROM pedidos AS p
INNER JOIN clientes AS c ON p.cliente_id = c.id
LEFT JOIN entidad_ubicaciones AS eu 
    ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
ORDER BY p.fecha DESC;

-- 3. Listar productos junto con el proveedor y tipo de producto.
SELECT p.id AS Id_Producto,
       p.nombre AS Nombre_Producto, 
       p.precio AS Precio,
       pv.nombre AS Nombre_Proveedor,
       tp.tipo_nombre AS Tipo_Producto
FROM productos AS p
INNER JOIN proveedores AS pv ON p.proveedor_id = pv.id
INNER JOIN tipos_productos AS tp ON p.tipo_id = tp.id
ORDER BY p.nombre;

-- 4. Consultar todos los empleados que gestionan pedidos de clientes en una ciudad específica.
-- (Reemplazar 'CiudadEjemplo' por la ciudad requerida).
SELECT DISTINCT de.nombre AS Nombre_Empleado
FROM datos_empleados AS de
INNER JOIN pedidos AS p ON de.id = p.empleado_id
INNER JOIN clientes AS c ON p.cliente_id = c.id
INNER JOIN entidad_ubicaciones AS eu 
    ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
WHERE u.ciudad = 'Bucaramanga' -- Agregar ciudad deseada
ORDER BY de.nombre;

-- 5. Consultar los 5 productos más vendidos.
-- Se calcula la suma de la cantidad vendida (según 'detalles_pedido') por cada producto.
SELECT p.nombre AS Nombre_Producto, 
       SUM(dp.cantidad) AS Total_Vendido
FROM productos AS p
INNER JOIN detalles_pedido AS dp ON p.id = dp.producto_id
GROUP BY p.id, p.nombre
ORDER BY Total_Vendido DESC
LIMIT 5;

-- 6. Obtener la cantidad total de pedidos por cliente y ciudad.
SELECT c.nombre AS Nombre_Cliente,
       u.ciudad AS Ciudad,
       COUNT(p.id) AS Total_Pedidos
FROM clientes AS c
INNER JOIN pedidos AS p ON c.id = p.cliente_id
INNER JOIN entidad_ubicaciones AS eu 
    ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
GROUP BY c.id, c.nombre, u.ciudad
ORDER BY c.nombre, u.ciudad;

-- 7. Listar clientes y proveedores en la misma ciudad.
-- Se unen a través de la tabla 'ubicaciones' y la tabla 'entidad_ubicaciones'.
SELECT c.nombre AS Nombre_Cliente,
       pv.nombre AS Nombre_Proveedor,
       u.ciudad AS Ciudad
FROM clientes AS c
INNER JOIN entidad_ubicaciones AS ecu 
    ON c.id = ecu.entidad_id AND ecu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON ecu.ubicacion_id = u.id
INNER JOIN entidad_ubicaciones AS eup 
    ON u.id = eup.ubicacion_id AND eup.entidad_tipo = 'proveedores'
INNER JOIN proveedores AS pv ON eup.entidad_id = pv.id
ORDER BY u.ciudad, c.nombre, pv.nombre;

-- 8. Mostrar el total de ventas agrupado por tipo de producto.
SELECT tp.tipo_nombre AS Tipo_Producto,
       SUM(dp.cantidad * dp.precio) AS Total_Ventas
FROM detalles_pedido AS dp
INNER JOIN productos AS p ON dp.producto_id = p.id
INNER JOIN tipos_productos AS tp ON p.tipo_id = tp.id
GROUP BY tp.id, tp.tipo_nombre
ORDER BY Total_Ventas DESC;

-- 9. Listar empleados que gestionan pedidos de productos de un proveedor específico.
-- (Reemplazar <ID_PROVEEDOR> por el identificador del proveedor deseado).
SELECT DISTINCT de.nombre AS Nombre_Empleado
FROM datos_empleados AS de
INNER JOIN pedidos AS p ON de.id = p.empleado_id
INNER JOIN detalles_pedido AS dp ON p.id = dp.pedido_id
INNER JOIN productos AS prod ON dp.producto_id = prod.id
WHERE prod.proveedor_id = <ID_PROVEEDOR>
ORDER BY de.nombre;

-- 10. Obtener el ingreso total de cada proveedor a partir de los productos vendidos.
SELECT pv.nombre AS Nombre_Proveedor,
       SUM(dp.cantidad * dp.precio) AS Ingreso_Total
FROM productos AS p
INNER JOIN proveedores AS pv ON p.proveedor_id = pv.id
INNER JOIN detalles_pedido AS dp ON p.id = dp.producto_id
GROUP BY pv.id, pv.nombre
ORDER BY Ingreso_Total DESC;
```

## 5. Subconsultas

Esta sección presenta consultas que utilizan subconsultas para realizar cálculos y filtrar datos de manera anidada. Las subconsultas permiten resolver requerimientos complejos, como la obtención del máximo o promedio, la comparación de resultados agregados y la realización de cálculos dinámicos en función de la información de otras tablas.

**Descripción:**  
- **Producto más caro por categoría:** Se utiliza una subconsulta para determinar, para cada categoría, el producto que tiene el precio máximo.  
- **Cliente con mayor total en pedidos:** Se emplean subconsultas para calcular el total de cada cliente y luego se filtra al cliente cuyo total es el máximo.  
- **Empleados con salario superior al promedio:** Se utiliza una subconsulta en la cláusula WHERE para comparar el salario de cada empleado contra el promedio general.  
- **Productos con pedidos frecuentes:** Se cuentan los pedidos de cada producto a través de una subconsulta y se filtran aquellos que han sido solicitados más de 5 veces.  
- **Pedidos con total mayor al promedio:** Se calcula el total de cada pedido mediante una subconsulta y se compara con el promedio de todos los pedidos.  
- **Proveedores con más productos:** Se listan los proveedores ordenados por la cantidad de productos que manejan, obtenida mediante una subconsulta.  
- **Comparación de precio de producto con el promedio en su tipo:** Se determina si el precio de cada producto supera el promedio de su categoría.  
- **Clientes con pedidos superiores a la media:** Se muestra a los clientes que han realizado un número de pedidos mayor que la media general.  
- **Productos cuyo precio supera el promedio general:** Se utiliza una subconsulta para obtener el precio promedio de todos los productos y filtrar aquellos con valor superior.  
- **Empleados con salario menor al promedio de su departamento:** Se compara el salario individual con el promedio de salarios dentro del mismo puesto utilizando subconsultas.

**Prueba:**  
Para validar estas consultas, se recomienda:
1. Ejecutarlas en un entorno MySQL.
2. Verificar que las subconsultas retornan los valores esperados para cada condición.
3. Ajustar condiciones y parámetros para probar diferentes escenarios de datos.

A continuación se muestra el contenido completo del archivo `SubQueries.sql`:

```sql:SubQueries.sql
-- 1. Consultar el producto más caro en cada categoría.
SELECT 
    tp.tipo_nombre AS Tipo_Producto,
    p.nombre AS Producto,
    p.precio AS Precio
FROM productos p
INNER JOIN tipos_productos tp ON p.tipo_id = tp.id
WHERE p.precio = (
    SELECT MAX(p2.precio)
    FROM productos p2
    WHERE p2.tipo_id = tp.id
);

-- 2. Encontrar el cliente con mayor total en pedidos.
SELECT 
    c.nombre AS Nombre_Cliente,
    (SELECT SUM(dp.cantidad * dp.precio)
     FROM pedidos p
     INNER JOIN detalles_pedido dp ON p.id = dp.pedido_id
     WHERE p.cliente_id = c.id) AS Total_Pedidos
FROM clientes c
WHERE (SELECT SUM(dp.cantidad * dp.precio)
       FROM pedidos p
       INNER JOIN detalles_pedido dp ON p.id = dp.pedido_id
       WHERE p.cliente_id = c.id)
      = (
         SELECT MAX(Total)
         FROM (
              SELECT SUM(dp2.cantidad * dp2.precio) AS Total
              FROM pedidos p2
              INNER JOIN detalles_pedido dp2 ON p2.id = dp2.pedido_id
              GROUP BY p2.cliente_id
         ) AS sub
      );

-- 3. Listar empleados que ganan más que el salario promedio.
SELECT 
    nombre AS Nombre_Empleado, 
    salario AS Salario
FROM datos_empleados
WHERE salario > (SELECT AVG(salario) FROM datos_empleados);

-- 4. Consultar productos que han sido pedidos más de 5 veces.
SELECT 
    p.nombre AS Nombre_Producto,
    (SELECT COUNT(*)
     FROM detalles_pedido dp
     WHERE dp.producto_id = p.id) AS Veces_Pedido
FROM productos p
WHERE (SELECT COUNT(*)
       FROM detalles_pedido dp
       WHERE dp.producto_id = p.id) > 5;

-- 5. Listar pedidos cuyo total es mayor al promedio de todos los pedidos.
SELECT 
    p.id AS Id_Pedido,
    (SELECT SUM(dp.cantidad * dp.precio) 
     FROM detalles_pedido dp 
     WHERE dp.pedido_id = p.id) AS Total_Pedido
FROM pedidos p
WHERE (SELECT SUM(dp.cantidad * dp.precio) 
       FROM detalles_pedido dp 
       WHERE dp.pedido_id = p.id)
      > (
         SELECT AVG(Total)
         FROM (
              SELECT p2.id, SUM(dp2.cantidad * dp2.precio) AS Total
              FROM pedidos p2
              INNER JOIN detalles_pedido dp2 ON p2.id = dp2.pedido_id
              GROUP BY p2.id
         ) AS sub
      );

-- 6. Seleccionar los 3 proveedores con más productos.
SELECT 
    pv.nombre AS Nombre_Proveedor,
    (SELECT COUNT(*) 
     FROM productos p 
     WHERE p.proveedor_id = pv.id) AS Total_Productos
FROM proveedores pv
ORDER BY (SELECT COUNT(*) FROM productos p WHERE p.proveedor_id = pv.id) DESC
LIMIT 3;

-- 7. Consultar productos con precio superior al promedio en su tipo.
SELECT 
    p.nombre AS Nombre_Producto, 
    p.precio AS Precio, 
    tp.tipo_nombre AS Tipo_Producto
FROM productos p
INNER JOIN tipos_productos tp ON p.tipo_id = tp.id
WHERE p.precio > (
    SELECT AVG(p2.precio)
    FROM productos p2
    WHERE p2.tipo_id = p.tipo_id
);

-- 8. Mostrar clientes que han realizado más pedidos que la media.
SELECT 
    c.nombre AS Nombre_Cliente,
    (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id) AS Total_Pedidos
FROM clientes c
WHERE (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id)
      > (
         SELECT AVG(TotalPedidos)
         FROM (
              SELECT COUNT(*) AS TotalPedidos
              FROM pedidos 
              GROUP BY cliente_id
         ) AS sub
      );

-- 9. Encontrar productos cuyo precio es mayor que el promedio de todos los productos.
SELECT 
    p.nombre AS Nombre_Producto, 
    p.precio AS Precio
FROM productos p
WHERE p.precio > (SELECT AVG(precio) FROM productos);

-- 10. Mostrar empleados cuyo salario es menor al promedio del departamento.
SELECT 
    de.nombre AS Nombre_Empleado, 
    de.salario AS Salario,
    (SELECT AVG(de2.salario)
     FROM datos_empleados de2
     WHERE de2.puesto_id = de.puesto_id) AS Salario_Promedio_Departamento
FROM datos_empleados de
WHERE de.salario < (SELECT AVG(de2.salario)
                    FROM datos_empleados de2
                    WHERE de2.puesto_id = de.puesto_id);
```

## 6. Procedimientos Almacenados

Esta sección contiene procedimientos almacenados que ayudan a automatizar operaciones y consolidar lógicas de negocio. Los procedimientos almacenados permiten encapsular consultas SQL complejas y operaciones en la base de datos, facilitando su reutilización y mantenimiento.

**Descripción:**  
- **Actualizar Precio por Proveedor:** Procedimiento para actualizar el precio de todos los productos de un proveedor específico.  
- **Obtener Dirección de Cliente:** Procedimiento que retorna la dirección de un cliente basándose en su ID.  
- **Registrar Pedido Nuevo:** Procedimiento para insertar un nuevo pedido y su detalle asociado dentro de una transacción.  
- **Calcular Total de Ventas de un Cliente:** Procedimiento que suma el total de ventas de un cliente a partir de sus pedidos y detalles de pedido.  
- **Obtener Empleados por Puesto:** Procedimiento que lista los empleados según su puesto.  
- **Actualizar Salario por Puesto:** Procedimiento que incrementa el salario de los empleados de un determinado puesto en un porcentaje dado.  
- **Listar Pedidos entre Fechas:** Procedimiento para listar pedidos realizados entre dos fechas específicas.  
- **Aplicar Descuento a Productos por Categoría:** Procedimiento que actualiza el precio de productos de una categoría aplicando un descuento.  
- **Listar Proveedores por Tipo de Producto:** Procedimiento que retorna proveedores vinculados a un tipo de producto.  
- **Obtener Pedido de Mayor Valor:** Procedimiento que determina el pedido con mayor valor total basado en sus detalles.

**Prueba:**  
Para probar estos procedimientos, se recomienda:
1. Ejecutar cada procedimiento en un entorno MySQL.
2. Llamar al procedimiento correspondiente desde un cliente MySQL (por ejemplo, usando `CALL spNombreProcedimiento(parametros);`).
3. Verificar los resultados con consultas posteriores a la ejecución del procedimiento.

A continuación se muestra el contenido completo del archivo `StoredProcedures.sql`:

```sql:StoredProcedures.sql
-- 1. Crear un procedimiento para actualizar el precio de todos los productos de un proveedor.
DELIMITER $$
CREATE PROCEDURE spActualizarPrecioPorProveedor (
    IN p_proveedor_id INT,
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    UPDATE productos
    SET precio = p_nuevo_precio
    WHERE proveedor_id = p_proveedor_id;
END$$
DELIMITER ;

-- 2. Un procedimiento que devuelva la dirección de un cliente por ID.
DELIMITER $$
CREATE PROCEDURE spObtenerDireccionCliente (
    IN p_cliente_id INT
)
BEGIN
    SELECT u.direccion, u.ciudad, u.estado, u.codigo_postal, u.pais
    FROM entidad_ubicaciones eu
    INNER JOIN ubicaciones u ON eu.ubicacion_id = u.id
    WHERE eu.entidad_id = p_cliente_id AND eu.entidad_tipo = 'clientes';
END$$
DELIMITER ;

-- 3. Crear un procedimiento que registre un pedido nuevo y sus detalles.
-- Se insertará un nuevo pedido y, a continuación, se registrará un detalle asociado.
DELIMITER $$
CREATE PROCEDURE spRegistrarPedidoNuevo (
    IN p_cliente_id INT,
    IN p_empleado_id INT,
    IN p_fecha DATE,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_precio DECIMAL(10,2)
)
BEGIN
    DECLARE v_pedido_id INT;

    START TRANSACTION;
    
    INSERT INTO pedidos (cliente_id, empleado_id, fecha)
    VALUES (p_cliente_id, p_empleado_id, p_fecha);
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    INSERT INTO detalles_pedido (pedido_id, producto_id, cantidad, precio)
    VALUES (v_pedido_id, p_producto_id, p_cantidad, p_precio);
    
    COMMIT;
END$$
DELIMITER ;

-- 4. Un procedimiento para calcular el total de ventas de un cliente.
DELIMITER $$
CREATE PROCEDURE spCalcularTotalVentasCliente (
    IN p_cliente_id INT
)
BEGIN
    SELECT SUM(dp.cantidad * dp.precio) AS Total_Ventas
    FROM pedidos p
    INNER JOIN detalles_pedido dp ON p.id = dp.pedido_id
    WHERE p.cliente_id = p_cliente_id;
END$$
DELIMITER ;

-- 5. Crear un procedimiento para obtener los empleados por puesto.
DELIMITER $$
CREATE PROCEDURE spObtenerEmpleadosPorPuesto (
    IN p_puesto_id INT
)
BEGIN
    SELECT id, nombre, puesto_id, salario, fecha_contratacion
    FROM datos_empleados
    WHERE puesto_id = p_puesto_id;
END$$
DELIMITER ;

-- 6. Un procedimiento que actualice el salario de empleados por puesto.
-- Se aplicará un incremento porcentual (por ejemplo, 0.10 para un aumento del 10%).
DELIMITER $$
CREATE PROCEDURE spActualizarSalarioEmpleadosPorPuesto (
    IN p_puesto_id INT,
    IN p_factor DECIMAL(5,2)
)
BEGIN
    UPDATE datos_empleados
    SET salario = salario * (1 + p_factor)
    WHERE puesto_id = p_puesto_id;
END$$
DELIMITER ;

-- 7. Crear un procedimiento que liste los pedidos entre dos fechas.
DELIMITER $$
CREATE PROCEDURE spListarPedidosEntreFechas (
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT p.id AS Id_Pedido, p.fecha AS Fecha_Pedido, c.nombre AS Nombre_Cliente
    FROM pedidos p
    INNER JOIN clientes c ON p.cliente_id = c.id
    WHERE p.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY p.fecha;
END$$
DELIMITER ;

-- 8. Un procedimiento para aplicar un descuento a productos de una categoría.
-- El descuento se aplica multiplicando el precio por (1 - p_descuento), donde p_descuento es el porcentaje (por ejemplo 0.10 para 10%).
DELIMITER $$
CREATE PROCEDURE spAplicarDescuentoAProductosPorCategoria (
    IN p_tipo_id INT,
    IN p_descuento DECIMAL(5,2)
)
BEGIN
    UPDATE productos
    SET precio = precio * (1 - p_descuento)
    WHERE tipo_id = p_tipo_id;
END$$
DELIMITER ;

-- 9. Crear un procedimiento que liste todos los proveedores de un tipo de producto.
DELIMITER $$
CREATE PROCEDURE spListarProveedoresPorTipoProducto (
    IN p_tipo_id INT
)
BEGIN
    SELECT DISTINCT pv.id AS Id_Proveedor, pv.nombre AS Nombre_Proveedor
    FROM proveedores pv
    INNER JOIN productos p ON pv.id = p.proveedor_id
    WHERE p.tipo_id = p_tipo_id;
END$$
DELIMITER ;

-- 10. Un procedimiento que devuelva el pedido de mayor valor.
-- Se calcula el total de cada pedido a partir de la suma de sus detalles y se retorna el que tenga el mayor valor.
DELIMITER $$
CREATE PROCEDURE spObtenerPedidoMayorValor ()
BEGIN
    SELECT p.id AS Id_Pedido, c.nombre AS Nombre_Cliente, sub.Total_Pedido
    FROM pedidos p
    INNER JOIN clientes c ON p.cliente_id = c.id
    INNER JOIN (
         SELECT dp.pedido_id, SUM(dp.cantidad * dp.precio) AS Total_Pedido
         FROM detalles_pedido dp
         GROUP BY dp.pedido_id
         ORDER BY Total_Pedido DESC
         LIMIT 1
    ) AS sub ON p.id = sub.pedido_id;
END$$
DELIMITER ;
```

## 7. Funciones Definidas por el Usuario

Esta sección contiene las funciones definidas por el usuario que encapsulan lógicas reutilizables para realizar cálculos y recuperaciones de información a partir de los datos almacenados en la base de datos. Estas funciones permiten, por ejemplo, calcular totales, aplicar descuentos, convertir valores o extraer información específica de alguna tabla.

**Descripción:**
- **fnDiasTranscurridos:** Recibe una fecha y devuelve la cantidad de días transcurridos desde esa fecha hasta el día actual.
- **fnTotalConImpuesto:** Calcula el total de un monto aplicando un impuesto del 16%.
- **fnTotalPedidosCliente:** Devuelve el total (cantidad de pedidos o suma de valores) de pedidos realizados por un cliente.
- **fnAplicarDescuento:** Aplica un descuento a un precio, utilizando un porcentaje de descuento.
- **fnClienteConDireccion:** Indica si un cliente tiene una dirección registrada (retorna 1 si la hay, 0 en caso contrario).
- **fnSalarioAnual:** Calcula el salario anual de un empleado, asumiendo que el valor almacenado es mensual.
- **fnTotalVentasTipoProducto:** Calcula el total de ventas de un tipo de producto, basado en sus detalles de pedido.
- **fnObtenerNombreCliente:** Retorna el nombre de un cliente a partir de su ID.
- **fnTotalPedido:** Calcula el total de un pedido sumando los productos de cantidad y precio de cada detalle.
- **fnProductoEnInventario:** Verifica la existencia de un producto (en ausencia de un campo de stock, se asume que si aparece en la tabla, está en inventario).

**Prueba:**
Para probar estas funciones se recomienda:
1. Crear las funciones ejecutando el script `Functions.sql` en un entorno MySQL.
2. Invocar cada función mediante una consulta SELECT, por ejemplo:
   ```sql
   SELECT fnDiasTranscurridos('2023-01-01');
   ```
3. Verificar los resultados de acuerdo a los datos actuales en la base de datos.

A continuación se muestra el contenido completo del archivo `Functions.sql`:

```sql:Functions.sql
-- 1. Función que recibe una fecha y devuelve los días transcurridos desde esa fecha hasta hoy.
DELIMITER $$
CREATE FUNCTION fnDiasTranscurridos(p_fecha DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(CURDATE(), p_fecha);
END$$
DELIMITER ;

-- 2. Función para calcular el total con impuesto de un monto.
-- Se asume un impuesto del 16%.
DELIMITER $$
CREATE FUNCTION fnTotalConImpuesto(p_monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_monto * 1.16;
END$$
DELIMITER ;

-- 3. Función que devuelve el total de pedidos de un cliente específico.
DELIMITER $$
CREATE FUNCTION fnTotalPedidosCliente(p_cliente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM pedidos
    WHERE cliente_id = p_cliente_id;
    RETURN total;
END$$
DELIMITER ;

-- 4. Función para aplicar un descuento a un producto.
-- p_descuento es un valor decimal representando el porcentaje de descuento (ejemplo: 0.10 para 10%).
DELIMITER $$
CREATE FUNCTION fnAplicarDescuento(p_precio DECIMAL(10,2), p_descuento DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_precio * (1 - p_descuento);
END$$
DELIMITER ;

-- 5. Función que indica si un cliente tiene dirección registrada.
-- Devuelve 1 si tiene dirección y 0 si no la tiene.
DELIMITER $$
CREATE FUNCTION fnClienteConDireccion(p_cliente_id INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
    IF EXISTS (
       SELECT 1 FROM entidad_ubicaciones 
       WHERE entidad_id = p_cliente_id AND entidad_tipo = 'clientes'
    ) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END$$
DELIMITER ;

-- 6. Función que devuelve el salario anual de un empleado.
-- Se asume que el salario en la tabla es mensual.
DELIMITER $$
CREATE FUNCTION fnSalarioAnual(p_empleado_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE salario_mensual DECIMAL(10,2);
    SELECT salario INTO salario_mensual
    FROM datos_empleados
    WHERE id = p_empleado_id;
    RETURN salario_mensual * 12;
END$$
DELIMITER ;

-- 7. Función para calcular el total de ventas de un tipo de producto.
DELIMITER $$
CREATE FUNCTION fnTotalVentasTipoProducto(p_tipo_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalVentas DECIMAL(10,2);
    SELECT IFNULL(SUM(dp.cantidad * dp.precio), 0) INTO totalVentas
    FROM detalles_pedido dp
    INNER JOIN productos p ON dp.producto_id = p.id
    WHERE p.tipo_id = p_tipo_id;
    RETURN totalVentas;
END$$
DELIMITER ;

-- 8. Función para devolver el nombre de un cliente por ID.
DELIMITER $$
CREATE FUNCTION fnObtenerNombreCliente(p_cliente_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE nombreCliente VARCHAR(100);
    SELECT nombre INTO nombreCliente
    FROM clientes
    WHERE id = p_cliente_id;
    RETURN nombreCliente;
END$$
DELIMITER ;

-- 9. Función que recibe el ID de un pedido y devuelve su total.
DELIMITER $$
CREATE FUNCTION fnTotalPedido(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalPedido DECIMAL(10,2);
    SELECT IFNULL(SUM(dp.cantidad * dp.precio), 0) INTO totalPedido
    FROM detalles_pedido dp
    WHERE dp.pedido_id = p_pedido_id;
    RETURN totalPedido;
END$$
DELIMITER ;

-- 10. Función que indique si un producto está en inventario.
-- Dado que no existe campo de stock, se asume que si el producto existe (está en la tabla), está en inventario.
-- Devuelve 1 si existe, 0 de lo contrario.
DELIMITER $$
CREATE FUNCTION fnProductoEnInventario(p_producto_id INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
    IF EXISTS (
       SELECT 1 FROM productos WHERE id = p_producto_id
    ) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END$$
DELIMITER ;
```

## 8. Triggers

Esta sección contiene triggers que se ejecutan automáticamente en respuesta a ciertos eventos en la base de datos, como inserciones, actualizaciones o eliminaciones. Los triggers permiten realizar acciones complementarias, como registrar cambios, evitar modificaciones indebidas o mantener integridad referencial y lógica de negocio.

**Descripción:**  
- **Registro de Cambios de Salario:** Un trigger que registra cada cambio de salario en la tabla `historial_salarios` cuando se actualiza la tabla `datos_empleados`.
- **Prevención de Borrado de Productos con Pedidos Activos:** Un trigger que impide borrar un producto si existen registros asociados en la tabla `detalles_pedido`.
- **Registro de Actualizaciones en Pedidos:** Un trigger que almacena en `historial_pedidos` la información de cada actualización en la tabla `pedidos`.
- **Actualización de Inventario:** Un trigger que ajusta el inventario (stock) cuando se inserta un detalle de pedido.
- **Validación de Precio Mínimo:** Un trigger que previene la actualización de un producto a un precio menor a $1.
- **Registro de Creación de Pedidos:** Un trigger que inserta un registro en `historial_pedidos` cuando se crea un nuevo pedido.
- **Actualización del Total de Pedidos:** Un trigger que mantiene actualizado el total de cada pedido en la tabla auxiliar `pedido_totales` tras la inserción de un detalle de pedido.
- **Validación de Registro de Dirección para Clientes:** Un trigger que impide insertar un cliente sin direccion registrada en `entidad_ubicaciones`.
- **Registro de Cambios en Proveedores:** Un trigger que registra en `log_actividades` cualquier modificación en la tabla `proveedores`.
- **Registro de Cambios de Contrato en Empleados:** Un trigger que almacena en `historial_contratos` las modificaciones realizadas en los contratos o datos de los empleados.

**Prueba:**  
Para probar estos triggers se recomienda:
1. Ejecutar las operaciones (INSERT, UPDATE, DELETE) sobre las tablas relevantes.
2. Verificar que se realicen las acciones esperadas, como la inserción de registros en las tablas de historial.
3. Intentar realizar operaciones que deberían ser bloqueadas (por ejemplo, borrar un producto con pedidos activos) y confirmar que el trigger impide la acción.

A continuación se muestra el contenido completo del archivo `Triggers.sql`:

```sql:Triggers.sql
-- 1. Crear un trigger que registre en HistorialSalarios cada cambio de salario de empleados.
DELIMITER $$
CREATE TRIGGER trg_registrar_cambio_salario
AFTER UPDATE ON datos_empleados
FOR EACH ROW
BEGIN
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO historial_salarios (empleado_id, old_salary, new_salary, change_date)
        VALUES (OLD.id, OLD.salario, NEW.salario, NOW());
    END IF;
END$$
DELIMITER ;

-- 2. Crear un trigger que evite borrar productos con pedidos activos.
DELIMITER $$
CREATE TRIGGER trg_no_borrar_producto_con_pedidos
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM detalles_pedido dp WHERE dp.producto_id = OLD.id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede borrar el producto, tiene pedidos activos';
    END IF;
END$$
DELIMITER ;

-- 3. Un trigger que registre en HistorialPedidos cada actualización en Pedidos.
DELIMITER $$
CREATE TRIGGER trg_registrar_actualizacion_pedido
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO historial_pedidos (pedido_id, fecha_cambio, tipo_cambio, descripcion)
    VALUES (OLD.id, NOW(), 'UPDATE', CONCAT('Actualización: cliente_id de ', OLD.cliente_id, ' a ', NEW.cliente_id, ', empleado_id de ', OLD.empleado_id, ' a ', NEW.empleado_id));
END$$
DELIMITER ;

-- 4. Crear un trigger que actualice el inventario al registrar un pedido.
DELIMITER $$
CREATE TRIGGER trg_actualizar_inventario
AFTER INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.producto_id;
END$$
DELIMITER ;

-- 5. Un trigger que evite actualizaciones de precio a menos de $1.
DELIMITER $$
CREATE TRIGGER trg_evitar_precio_bajo
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio < 1.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio no puede ser menor a $1';
    END IF;
END$$
DELIMITER ;

-- 6. Crear un trigger que registre la fecha de creación de un pedido en HistorialPedidos.
DELIMITER $$
CREATE TRIGGER trg_registrar_creacion_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO historial_pedidos (pedido_id, fecha_cambio, tipo_cambio, descripcion)
    VALUES (NEW.id, NOW(), 'INSERT', 'Pedido creado');
END$$
DELIMITER ;

-- 7. Crear un trigger que mantenga el precio total de cada pedido.
DELIMITER $$
CREATE TRIGGER trg_actualizar_total_pedido_aux
AFTER INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    -- Calcular el total actual del pedido
    SELECT IFNULL(SUM(dp.cantidad * dp.precio), 0) INTO v_total
    FROM detalles_pedido dp
    WHERE dp.pedido_id = NEW.pedido_id;
    
    -- Si el pedido ya tiene registro en 'pedido_totales', lo actualiza, sino lo inserta.
    IF EXISTS (SELECT 1 FROM pedido_totales WHERE pedido_id = NEW.pedido_id) THEN
        UPDATE pedido_totales
        SET total = v_total
        WHERE pedido_id = NEW.pedido_id;
    ELSE
        INSERT INTO pedido_totales (pedido_id, total)
        VALUES (NEW.pedido_id, v_total);
    END IF;
END$$
DELIMITER ;

-- 8. Crear un trigger para validar que UbicacionCliente no esté vacío al crear un cliente.
DELIMITER $$
CREATE TRIGGER trg_validar_direccion_cliente
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
       SELECT 1 FROM entidad_ubicaciones 
       WHERE entidad_id = NEW.id AND entidad_tipo = 'clientes'
    ) THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'El cliente debe tener una dirección registrada en UbicacionCliente';
    END IF;
END$$
DELIMITER ;

-- 9. Crear un trigger que registre en LogActividades cada modificación en Proveedores.
DELIMITER $$
CREATE TRIGGER trg_log_modificacion_proveedor
AFTER UPDATE ON proveedores
FOR EACH ROW
BEGIN
    INSERT INTO log_actividades (accion, entidad, descripcion, fecha)
    VALUES ('UPDATE', 'proveedores', CONCAT('Proveedor ID ', OLD.id, ' modificado.'), NOW());
END$$
DELIMITER ;

-- 10. Crear un trigger que registre en HistorialContratos cada cambio en Empleados.
DELIMITER $$
CREATE TRIGGER trg_registrar_cambio_empleado
AFTER UPDATE ON datos_empleados
FOR EACH ROW
BEGIN
    INSERT INTO historial_contratos (empleado_id, cambio, descripcion, fecha)
    VALUES (OLD.id, 'UPDATE', CONCAT('Cambio en empleado: puesto_id de ', OLD.puesto_id, ' a ', NEW.puesto_id, ' y salario de ', OLD.salario, ' a ', NEW.salario), NOW());
END$$
DELIMITER ;
```

## 9. Ejercicios Combinados de Funciones y Consultas

Esta sección integra funciones definidas por el usuario con consultas SQL para resolver requerimientos complejos de manera integral. Se combinan cálculos personalizados y consultas de filtrado y selección para presentar soluciones completas a tareas específicas, como aplicar descuentos condicionados, calcular edades, totales, impuestos, y generar informes combinados.

**Descripción:**
- **CalcularDescuento:** Función que recibe el tipo del producto y su precio original, aplicando un descuento del 10% si el producto pertenece a la categoría "Electrónica".
- **Consulta de Descuento en Productos:** Muestra el nombre del producto, su precio original y el precio con el descuento aplicado.
- **CalcularEdad:** Función para calcular la edad a partir de la fecha de nacimiento.
- **Consulta para Clientes Adultos:** Filtra y muestra clientes que tienen más de 18 años.
- **CalcularImpuesto:** Función que aplica un impuesto del 15% al precio de un producto.
- **Consulta de Impuesto en Productos:** Muestra el precio original y el precio final con el impuesto aplicado.
- **TotalPedidosCliente:** Función que calcula el total acumulado de los pedidos de un cliente sumando (cantidad * precio) en cada detalle.
- **Consulta de Total de Pedidos:** Muestra el nombre del cliente y el total de sus pedidos, filtrando aquellos con totales superiores a $1000.
- **SalarioAnual:** Función que convierte el salario mensual de un empleado a anual.
- **Consulta de Salario Anual:** Lista empleados con un salario anual mayor a $50,000.
- **Bonificacion:** Función que calcula una bonificación (del 10%) sobre el salario de un empleado.
- **Consulta de Salario Ajustado:** Muestra el salario base y el salario ajustado (incluyendo la bonificación) de cada empleado.
- **DiasDesdeUltimoPedido:** Función que calcula los días transcurridos desde el último pedido de un cliente.
- **Consulta de Clientes Recientes:** Lista clientes que han realizado un pedido en los últimos 30 días.
- **TotalInventarioProducto:** Función que calcula el valor total del inventario de un producto multiplicando su stock por su precio.
- **Consulta de Inventario:** Muestra productos cuyo valor total en inventario supera los $500.
- **HistorialPrecios y RegistroCambioPrecio:** Crea la tabla HistorialPrecios y un trigger para registrar cambios en el precio de productos.
- **ReporteVentasMensuales:** Procedimiento que genera un reporte de ventas mensuales por empleado.
- **Consulta de Producto más Vendido por Proveedor:** Obtiene el producto más vendido para cada proveedor.
- **EstadoStock:** Función que clasifica el estado del stock de un producto como "Alto", "Medio" o "Bajo".
- **ActualizarInventario:** Trigger que decrementa el stock de un producto al insertar un detalle de pedido, validando que haya stock suficiente.
- **ClientesInactivos:** Procedimiento que informa sobre los clientes que no han realizado pedidos en los últimos 6 meses.

**Prueba:**
Para verificar el funcionamiento de estos ejercicios combinados se recomienda:
1. Ejecutar el script `FunctionsQueries.sql` en un entorno MySQL.
2. Invocar cada función y consulta mediante comandos SELECT para validar su comportamiento.
3. Ejecutar procedimientos y triggers para comprobar la actualización de datos, la generación de registros de historial y la validación de condiciones (por ejemplo, stock insuficiente o descuentos aplicados).

A continuación se muestra el contenido completo del archivo `FunctionsQueries.sql`:

```sql:FunctionsQueries.sql
-- Enunciado: Función CalcularDescuento
-- Objetivo: Crear una función que reciba el tipo_id del producto y el precio original,
-- y aplique un descuento del 10% si el producto pertenece a la categoría 'Electrónica'.
DELIMITER $$
CREATE FUNCTION CalcularDescuento(p_tipo_id INT, p_precio_original DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_tipo_nombre VARCHAR(100);
    DECLARE v_precio_final DECIMAL(10,2);
    
    SELECT tipo_nombre INTO v_tipo_nombre
    FROM tipos_productos
    WHERE id = p_tipo_id;
    
    IF v_tipo_nombre = 'Electrónica' THEN
        SET v_precio_final = p_precio_original * 0.90; -- Aplica descuento del 10%
    ELSE
        SET v_precio_final = p_precio_original;
    END IF;
    
    RETURN v_precio_final;
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar el nombre del producto, el precio original y el precio con descuento.
SELECT p.nombre AS Producto, 
       p.precio AS Precio_Original, 
       CalcularDescuento(p.tipo_id, p.precio) AS Precio_Con_Descuento
FROM productos p;

-- Enunciado: Función CalcularEdad
-- Objetivo: Crear una función que reciba la fecha de nacimiento y calcule la edad en años.
DELIMITER $$
CREATE FUNCTION CalcularEdad(p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar todos los clientes y filtrar aquellos mayores de 18 años.
SELECT nombre, fecha_nacimiento, CalcularEdad(fecha_nacimiento) AS Edad
FROM clientes
WHERE CalcularEdad(fecha_nacimiento) > 18;

-- Enunciado: Función CalcularImpuesto
-- Objetivo: Crear una función que reciba el precio de un producto y le aplique un impuesto del 15%.
DELIMITER $$
CREATE FUNCTION CalcularImpuesto(p_precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_precio * 1.15;
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar el nombre del producto, el precio original y el precio final con impuesto incluido.
SELECT nombre, 
       precio AS Precio_Original, 
       CalcularImpuesto(precio) AS Precio_Final_Impuesto
FROM productos;

-- Enunciado: Función TotalPedidosCliente
-- Objetivo: Crear una función que reciba el ID de un cliente y calcule el total acumulado de sus pedidos,
-- sumando (cantidad * precio) de cada detalle de pedido.
DELIMITER $$
CREATE FUNCTION TotalPedidosCliente(p_cliente_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT IFNULL(SUM(dp.cantidad * dp.precio),0) INTO v_total
    FROM pedidos p
    INNER JOIN detalles_pedido dp ON p.id = dp.pedido_id
    WHERE p.cliente_id = p_cliente_id;
    RETURN v_total;
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar el nombre del cliente y el total de sus pedidos,
-- filtrando aquellos con total mayor a $1000.
SELECT c.nombre AS Cliente, TotalPedidosCliente(c.id) AS Total_Pedidos
FROM clientes c
WHERE TotalPedidosCliente(c.id) > 1000;

-- Enunciado: Función SalarioAnual
-- Objetivo: Crear una función que reciba el salario mensual de un empleado y calcule su salario anual multiplicándolo por 12.
DELIMITER $$
CREATE FUNCTION SalarioAnual(p_salario_mensual DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_salario_mensual * 12;
END$$
DELIMITER ;

-- Enunciado: Consulta para listar el nombre del empleado y su salario anual,
-- filtrando aquellos con un salario anual mayor a $50,000.
SELECT nombre, SalarioAnual(salario) AS Salario_Anual
FROM datos_empleados
WHERE SalarioAnual(salario) > 50000;

-- Enunciado: Función Bonificacion
-- Objetivo: Crear una función que reciba el salario de un empleado y calcule una bonificación del 10%.
DELIMITER $$
CREATE FUNCTION Bonificacion(p_salario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_salario * 0.10;
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar el salario ajustado de cada empleado (salario + bonificación).
SELECT nombre, salario, salario + Bonificacion(salario) AS Salario_Ajustado
FROM datos_empleados;

-- Enunciado: Función DiasDesdeUltimoPedido
-- Objetivo: Crear una función que reciba el ID de un cliente y calcule los días transcurridos desde su último pedido.
DELIMITER $$
CREATE FUNCTION DiasDesdeUltimoPedido(p_cliente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_ultimo DATE;
    DECLARE v_dias INT;
    
    SELECT MAX(fecha) INTO v_ultimo FROM pedidos WHERE cliente_id = p_cliente_id;
    
    IF v_ultimo IS NULL THEN
        RETURN NULL;
    ELSE
        SET v_dias = DATEDIFF(CURDATE(), v_ultimo);
        RETURN v_dias;
    END IF;
END$$
DELIMITER ;

-- Enunciado: Consulta para listar solo a los clientes que hayan realizado un pedido en los últimos 30 días.
SELECT c.nombre, DiasDesdeUltimoPedido(c.id) AS Dias_Ultimo_Pedido
FROM clientes c
WHERE DiasDesdeUltimoPedido(c.id) <= 30;

-- Enunciado: Función TotalInventarioProducto
-- Objetivo: Crear una función que reciba el ID de un producto y calcule el total en inventario multiplicando su stock por el precio.
DELIMITER $$
CREATE FUNCTION TotalInventarioProducto(p_producto_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    SELECT stock, precio INTO v_stock, v_precio FROM productos WHERE id = p_producto_id;
    SET v_total = v_stock * v_precio;
    RETURN v_total;
END$$
DELIMITER ;

-- Enunciado: Consulta para mostrar el nombre del producto y su total en inventario,
-- filtrando aquellos con inventario superior a $500.
SELECT nombre, TotalInventarioProducto(id) AS Inventario_Total
FROM productos
WHERE TotalInventarioProducto(id) > 500;

-- Enunciado: Crear la tabla HistorialPrecios para almacenar el historial de cambios de precios de los productos.
CREATE TABLE HistorialPrecios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    precio_antiguo DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME,
    CONSTRAINT fk_historial_precios_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Enunciado: Crear el trigger RegistroCambioPrecio en la tabla Productos.
-- Objetivo: Cada vez que el precio de un producto cambie, registrar el producto, el precio antiguo, el nuevo precio y la fecha del cambio.
DELIMITER $$
CREATE TRIGGER RegistroCambioPrecio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO HistorialPrecios (producto_id, precio_antiguo, precio_nuevo, fecha_cambio)
        VALUES (OLD.id, OLD.precio, NEW.precio, NOW());
    END IF;
END$$
DELIMITER ;

-- Enunciado: Procedimiento ReporteVentasMensuales
-- Objetivo: Crear un procedimiento almacenado que reciba como parámetros el mes y el año,
-- y devuelva una lista de empleados con el total de ventas que gestionaron en ese período.
DELIMITER $$
CREATE PROCEDURE ReporteVentasMensuales(IN p_mes INT, IN p_anio INT)
BEGIN
    SELECT de.nombre AS Empleado, 
           IFNULL(SUM(dp.cantidad * dp.precio), 0) AS Total_Ventas
    FROM datos_empleados de
    LEFT JOIN pedidos p ON de.id = p.empleado_id
    LEFT JOIN detalles_pedido dp ON p.id = dp.pedido_id
    WHERE MONTH(p.fecha) = p_mes AND YEAR(p.fecha) = p_anio
    GROUP BY de.id, de.nombre;
END$$
DELIMITER ;

-- Enunciado: Consulta para obtener el producto más vendido por cada proveedor.
-- Se utiliza una subconsulta para calcular la cantidad total vendida por cada producto.
SELECT pv.nombre AS Proveedor, 
       p.nombre AS Producto,
       (SELECT SUM(dp.cantidad)
        FROM detalles_pedido dp
        WHERE dp.producto_id = p.id) AS Total_Vendido
FROM productos p
INNER JOIN proveedores pv ON p.proveedor_id = pv.id
WHERE (SELECT SUM(dp.cantidad)
       FROM detalles_pedido dp
       WHERE dp.producto_id = p.id) = (
         SELECT MAX(TotalVendido)
         FROM (
             SELECT producto_id, SUM(cantidad) AS TotalVendido
             FROM detalles_pedido
             WHERE producto_id IN (SELECT id FROM productos WHERE proveedor_id = pv.id)
             GROUP BY producto_id
         ) AS Totales
);

-- Enunciado: Función EstadoStock
-- Objetivo: Crear una función que reciba la cantidad de stock de un producto y la clasifique en "Alto", "Medio" o "Bajo".
DELIMITER $$
CREATE FUNCTION EstadoStock(p_cantidad INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF p_cantidad >= 100 THEN
        RETURN 'Alto';
    ELSEIF p_cantidad >= 50 THEN
        RETURN 'Medio';
    ELSE
        RETURN 'Bajo';
    END IF;
END$$
DELIMITER ;

-- Enunciado: Consulta para listar todos los productos y mostrar su estado de stock.
SELECT nombre, stock, EstadoStock(stock) AS Estado_Stock
FROM productos;

-- Enunciado: Crear el trigger ActualizarInventario en la tabla DetallesPedido.
-- Objetivo: Al insertar un nuevo registro en DetallesPedido, disminuir el stock del producto,
-- y prevenir la inserción si la cantidad solicitada excede el stock disponible.
DELIMITER $$
CREATE TRIGGER ActualizarInventario
BEFORE INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM productos WHERE id = NEW.producto_id;
    
    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para el pedido';
    ELSE
        UPDATE productos
        SET stock = stock - NEW.cantidad
        WHERE id = NEW.producto_id;
    END IF;
END$$
DELIMITER ;

-- Enunciado: Procedimiento ClientesInactivos
-- Objetivo: Crear un procedimiento almacenado que genere un informe de clientes que no han realizado pedidos en los últimos 6 meses.
DELIMITER $$
CREATE PROCEDURE ClientesInactivos()
BEGIN
    SELECT c.nombre AS Cliente, MAX(p.fecha) AS Ultimo_Pedido
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.cliente_id
    GROUP BY c.id, c.nombre
    HAVING (Ultimo_Pedido IS NULL OR Ultimo_Pedido < DATE_SUB(CURDATE(), INTERVAL 6 MONTH));
END$$
DELIMITER ;
```