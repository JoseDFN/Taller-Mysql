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
-- En este caso, asumiremos que el "departamento" se corresponde con el "puesto" de cada empleado.
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
