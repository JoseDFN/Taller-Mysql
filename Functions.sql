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
