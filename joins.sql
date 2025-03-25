USE vtaszfs;

-- Obtener la lista de todos los pedidos con los nombres de clientes usando INNER JOIN .

SELECT p.id as Id_Pedido, p.fecha as Fecha_Pedido, c.nombre as Nombre_Cliente
FROM pedidos as p
INNER JOIN clientes as c ON p.cliente_id = c.id
ORDER BY p.fecha DESC;

-- Listar los productos y proveedores que los suministran con INNER JOIN .

SELECT p.nombre as Nombre_Producto, p.precio as Precio_Producto, pv.nombre as Proveedor_Producto
FROM productos as p
INNER JOIN proveedores as pv ON p.proveedor_id = pv.id
ORDER BY p.nombre ASC;

-- Mostrar los pedidos y las ubicaciones de los clientes con LEFT JOIN .

SELECT p.id as Id_Pedido, p.fecha as Fecha_pedido, u.direccion as Direccion_Cliente
FROM pedidos AS p
LEFT JOIN entidad_ubicaciones as eu ON p.cliente_id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id
ORDER BY p.fecha DESC;

--  Consultar los empleados que han registrado pedidos, incluyendo empleados sin pedidos ( LEFT JOIN ).

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
WHERE p.id = 1 -- Aqui se puede reemplzar por el ID requerido o usando un procedimiento almacenado o funcion
ORDER BY p.fecha DESC;

--  Mostrar productos que no han sido pedidos ( RIGHT JOIN ).

SELECT p.id AS Id_Producto, p.nombre AS Nombre_Producto
FROM detalles_pedido AS dp
RIGHT JOIN productos AS p ON dp.producto_id = p.id
WHERE dp.producto_id IS NULL
ORDER BY p.nombre ASC;

-- Mostrar el total de pedidos y ubicación de clientes usando múltiples JOIN .

SELECT COUNT(DISTINCT p.id) AS Total_Pedidos, COUNT(DISTINCT u.id) AS Total_Ubicaciones
FROM pedidos AS p
LEFT JOIN entidad_ubicaciones AS eu ON p.cliente_id = eu.entidad_id AND eu.entidad_tipo = 'clientes'
LEFT JOIN ubicaciones AS u ON eu.ubicacion_id = u.id;

--  Unir Proveedores , Productos , y TiposProductos para un listado completo de inventario.

SELECT tp.tipo_nombre AS Tipo_Producto, p.nombre AS Nombre_Producto, pv.nombre AS Nombre_Proveedor
FROM productos AS p
INNER JOIN tipos_productos AS tp ON p.tipo_id = tp.id
INNER JOIN proveedores AS pv ON p.proveedor_id = pv.id
ORDER BY tp.tipo_nombre ASC;