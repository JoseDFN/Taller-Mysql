-- 1. Listar todos los pedidos y el cliente asociado.
SELECT p.id AS Id_Pedido, p.fecha AS Fecha_Pedido, c.nombre AS Nombre_Cliente
FROM pedidos AS p
INNER JOIN clientes AS c ON p.cliente_id = c.id
ORDER BY p.fecha DESC;

-- 2. Mostrar la ubicación de cada cliente en sus pedidos.
SELECT p.id AS Id_Pedido, p.fecha AS Fecha_Pedido, c.nombre AS Nombre_Cliente, u.direccion AS Direccion_Cliente, u.ciudad AS Ciudad
FROM pedidos AS p
INNER JOIN clientes AS c ON p.cliente_id = c.id
LEFT JOIN entidad_ubicaciones AS eu ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
ORDER BY p.fecha DESC;

-- 3. Listar productos junto con el proveedor y tipo de producto.
SELECT p.id AS Id_Producto, p.nombre AS Nombre_Producto, p.precio AS Precio, pv.nombre AS Nombre_Proveedor, tp.tipo_nombre AS Tipo_Producto
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
INNER JOIN entidad_ubicaciones AS eu ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
WHERE u.ciudad = 'CiudadEjemplo'
ORDER BY de.nombre;

-- 5. Consultar los 5 productos más vendidos.
-- Se calcula la suma de la cantidad vendida (según 'detalles_pedido') por cada producto.
SELECT p.nombre AS Nombre_Producto, SUM(dp.cantidad) AS Total_Vendido
FROM productos AS p
INNER JOIN detalles_pedido AS dp ON p.id = dp.producto_id
GROUP BY p.id, p.nombre
ORDER BY Total_Vendido DESC
LIMIT 5;

-- 6. Obtener la cantidad total de pedidos por cliente y ciudad.
SELECT c.nombre AS Nombre_Cliente, u.ciudad AS Ciudad, COUNT(p.id) AS Total_Pedidos
FROM clientes AS c
INNER JOIN pedidos AS p ON c.id = p.cliente_id
INNER JOIN entidad_ubicaciones AS eu ON c.id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
GROUP BY c.id, c.nombre, u.ciudad
ORDER BY c.nombre, u.ciudad;

-- 7. Listar clientes y proveedores en la misma ciudad.
-- Se unen a través de la tabla 'ubicaciones' y la tabla 'entidad_ubicaciones'.
SELECT c.nombre AS Nombre_Cliente, pv.nombre AS Nombre_Proveedor, u.ciudad AS Ciudad
FROM clientes AS c
INNER JOIN entidad_ubicaciones AS ecu ON c.id = ecu.entidad_id AND ecu.entidad_tipo = 'clientes'
INNER JOIN ubicaciones AS u ON ecu.ubicacion_id = u.id
INNER JOIN entidad_ubicaciones AS eup ON u.id = eup.ubicacion_id AND eup.entidad_tipo = 'proveedores'
INNER JOIN proveedores AS pv ON eup.entidad_id = pv.id
ORDER BY u.ciudad, c.nombre, pv.nombre;

-- 8. Mostrar el total de ventas agrupado por tipo de producto.
SELECT tp.tipo_nombre AS Tipo_Producto, SUM(dp.cantidad * dp.precio) AS Total_Ventas
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
WHERE prod.proveedor_id = 1 -- Reemplazar por el ID del proveedor deseado
ORDER BY de.nombre;

-- 10. Obtener el ingreso total de cada proveedor a partir de los productos vendidos.
SELECT pv.nombre AS Nombre_Proveedor, SUM(dp.cantidad * dp.precio) AS Ingreso_Total
FROM productos AS p
INNER JOIN proveedores AS pv ON p.proveedor_id = pv.id
INNER JOIN detalles_pedido AS dp ON p.id = dp.producto_id
GROUP BY pv.id, pv.nombre
ORDER BY Ingreso_Total DESC;