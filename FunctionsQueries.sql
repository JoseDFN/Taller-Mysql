USE vtaszfs;

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
SELECT p.nombre AS Producto, p.precio AS Precio_Original, CalcularDescuento(p.tipo_id, p.precio) AS Precio_Con_Descuento
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
SELECT nombre, precio AS Precio_Original, CalcularImpuesto(precio) AS Precio_Final_Impuesto
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
CREATE FUNCTION SalarioAnual(p_salario_mensual DECIMAL(8,2))
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
CREATE FUNCTION Bonificacion(p_salario DECIMAL(8,2))
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
    SELECT de.nombre AS Empleado, IFNULL(SUM(dp.cantidad * dp.precio), 0) AS Total_Ventas
    FROM datos_empleados de
    LEFT JOIN pedidos p ON de.id = p.empleado_id
    LEFT JOIN detalles_pedido dp ON p.id = dp.pedido_id
    WHERE MONTH(p.fecha) = p_mes AND YEAR(p.fecha) = p_anio
    GROUP BY de.id, de.nombre;
END$$
DELIMITER ;

-- Enunciado: Consulta para obtener el producto más vendido por cada proveedor.
-- Se utiliza una subconsulta para calcular la cantidad total vendida por cada producto.
SELECT pv.nombre AS Proveedor, p.nombre AS Producto,
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