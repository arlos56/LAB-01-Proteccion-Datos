CREATE ROLE soporte NOLOGIN;
CREATE TABLE clientes (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    rfc VARCHAR(13),
    edad INTEGER,
    ciudad VARCHAR(80),
    codigo_postal VARCHAR(10),
    fecha_alta DATE DEFAULT CURRENT_DATE
);

INSERT INTO clientes (nombre, correo, telefono, rfc, edad, ciudad, codigo_postal, fecha_alta) VALUES
('Ana López', 'ana.lopez@example.test', '6671234567', 'LOAA850315ABC', 41, 'Culiacán', '80000', '2015-10-22'),
('Carlos Pérez', 'carlos.perez@example.test', '6672345678', 'PECA900720DEF', 35, 'Culiacán', '80100', '2020-10-22'),
('María García', 'maria.garcia@example.test', '6673456789', 'GAMA780912GHI', 47, 'Mazatlán', '82000', '2022-11-03'),
('Luis Torres', 'luis.torres@example.test', '6674567890', 'TOLU920201JKL', 34, 'Los Mochis', '81200', '2023-06-23'),
('Laura Sánchez', 'laura.sanchez@example.test', '6675678901', 'SALA880525MNO', 38, 'Culiacán', '80200', '2021-07-23');



CREATE VIEW v_clientes_soporte AS 
SELECT id, nombre, 
       CONCAT(LEFT(correo, 2), '*****', SUBSTRING(correo FROM POSITION('@' IN correo))) AS correo, 
       CONCAT('******', RIGHT(telefono, 4)) AS telefono,
       CONCAT('*********', RIGHT(rfc, 4)) AS rfc 
FROM clientes;

GRANT USAGE ON SCHEMA public TO soporte;
GRANT SELECT ON v_clientes_soporte TO soporte;
REVOKE ALL ON clientes FROM soporte;



CREATE SCHEMA pii;
CREATE SCHEMA analitica;

CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY, 
    cliente_id BIGINT UNIQUE REFERENCES public.clientes(id)
);

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO pii.mapa_cliente (token, cliente_id)
SELECT gen_random_uuid(), id FROM clientes;

CREATE TABLE analitica.clientes AS 
SELECT m.token AS cliente_token, c.edad, c.ciudad, c.codigo_postal, c.fecha_alta
FROM pii.mapa_cliente m
JOIN clientes c ON c.id = m.cliente_id;

CREATE ROLE analista NOLOGIN;
GRANT USAGE ON SCHEMA analitica TO analista;
GRANT SELECT ON analitica.clientes TO analista;


SELECT 
    CASE 
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+' 
    END AS rango_edad, 
    LEFT(codigo_postal, 2) AS region, 
    COUNT(*) AS total
FROM clientes 
GROUP BY 1, 2 
HAVING COUNT(*) >= 5;

INSERT INTO clientes
(nombre, correo, telefono, rfc, edad, ciudad, codigo_postal)
VALUES
('Ana López', 'ana.lopez@example.test', '6671234567', 'LOAA850315ABC', 41, 'Culiacán', '80000'),
('Carlos Pérez', 'carlos.perez@example.test', '6672345678', 'PECA900720DEF', 35, 'Culiacán', '80100'),
('María García', 'maria.garcia@example.test', '6673456789', 'GAMA780912GHI', 47, 'Mazatlán', '82000'),
('Luis Torres', 'luis.torres@example.test', '6674567890', 'TOLU920201JKL', 34, 'Los Mochis', '81200'),
('Laura Sánchez', 'laura.sanchez@example.test', '6675678901', 'SALA880525MNO', 38, 'Culiacán', '80200');

SELECT * FROM clientes;


SELECT * FROM clientes WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';