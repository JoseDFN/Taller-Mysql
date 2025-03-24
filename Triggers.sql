-- 1. Enunciado: Crear un trigger que registre en HistorialSalarios cada cambio de salario de empleados.
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

-- 2. Enunciado: Crear un trigger que evite borrar productos con pedidos activos.
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

-- 3. Enunciado: Un trigger que registre en HistorialPedidos cada actualización en Pedidos.
DELIMITER $$
CREATE TRIGGER trg_registrar_actualizacion_pedido
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO historial_pedidos (pedido_id, fecha_cambio, tipo_cambio, descripcion)
    VALUES (OLD.id, NOW(), 'UPDATE', CONCAT('Actualización: cliente_id de ', OLD.cliente_id, ' a ', NEW.cliente_id, ', empleado_id de ', OLD.empleado_id, ' a ', NEW.empleado_id));
END$$
DELIMITER ;

-- 4. Enunciado: Crear un trigger que actualice el inventario al registrar un pedido.
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

-- 5. Enunciado: Un trigger que evite actualizaciones de precio a menos de $1.
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

-- 6. Enunciado: Crear un trigger que registre la fecha de creación de un pedido en HistorialPedidos.
DELIMITER $$
CREATE TRIGGER trg_registrar_creacion_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    INSERT INTO historial_pedidos (pedido_id, fecha_cambio, tipo_cambio, descripcion)
    VALUES (NEW.id, NOW(), 'INSERT', 'Pedido creado');
END$$
DELIMITER ;

-- 7. Enunciado: Crear un trigger que mantenga el precio total de cada pedido.
-- Dado que la tabla 'pedidos' no almacena el total, se utiliza la tabla auxiliar 'pedido_totales'
-- para registrar el total calculado (suma de cantidad * precio de cada detalle de pedido).
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

-- 8. Enunciado: Crear un trigger para validar que UbicacionCliente no esté vacío al crear un cliente.
-- Se verifica que, luego de insertar un cliente, exista un registro en 'entidad_ubicaciones' con entidad_tipo 'clientes'.
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

-- 9. Enunciado: Crear un trigger que registre en LogActividades cada modificación en Proveedores.
DELIMITER $$
CREATE TRIGGER trg_log_modificacion_proveedor
AFTER UPDATE ON proveedores
FOR EACH ROW
BEGIN
    INSERT INTO log_actividades (accion, entidad, descripcion, fecha)
    VALUES ('UPDATE', 'proveedores', CONCAT('Proveedor ID ', OLD.id, ' modificado.'), NOW());
END$$
DELIMITER ;

-- 10. Enunciado: Crear un trigger que registre en HistorialContratos cada cambio en Empleados.
DELIMITER $$
CREATE TRIGGER trg_registrar_cambio_empleado
AFTER UPDATE ON datos_empleados
FOR EACH ROW
BEGIN
    INSERT INTO historial_contratos (empleado_id, cambio, descripcion, fecha)
    VALUES (OLD.id, 'UPDATE', CONCAT('Cambio en empleado: puesto_id de ', OLD.puesto_id, ' a ', NEW.puesto_id, ' y salario de ', OLD.salario, ' a ', NEW.salario), NOW());
END$$
DELIMITER ;
