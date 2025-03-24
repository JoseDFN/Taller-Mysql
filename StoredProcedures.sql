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
