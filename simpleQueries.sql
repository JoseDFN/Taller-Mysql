USE vtaszfs;

-- Seleccionar todos los productos con precio mayor a $50.

SELECT p.nombre AS Producto, p.precio AS Precio
FROM productos AS p
WHERE p.precio > 50.00;

--  Consultar clientes registrados en una ciudad específica.

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

--  Seleccionar proveedores que suministran más de 5 productos.

SELECT pv.id as Id_Proveedor, pv.nombre as Nombre_Proveedor, COUNT(p.id) as Total_Productos
FROM proveedores as pv
INNER JOIN productos as p ON pv.id = p.proveedor_id
GROUP BY pv.id, pv.nombre
HAVING COUNT(pv.id) > 5
ORDER BY COUNT(p.id) DESC;

-- Listar clientes que no tienen dirección registrada en UbicacionCliente .

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

-- Consultar el tipo de productos disponibles en TiposProductos .

SELECT id, tipo_nombre, descripcion
FROM tipos_productos;

-- Seleccionar los 3 productos más caros.

SELECT id AS Id_Producto, nombre AS Nombre_Producto, precio AS Precio
FROM productos
ORDER BY precio DESC
LIMIT 3;

-- Consultar el cliente con el mayor número de pedidos

SELECT c.nombre AS Nombre_Cliente, COUNT(p.id) AS Numero_Pedidos
FROM clientes AS c
INNER JOIN pedidos AS p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
ORDER BY Numero_Pedidos DESC
LIMIT 1;