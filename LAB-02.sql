CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);
INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');

CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);
INSERT INTO usuarios_segura (usuario, password_hash) VALUES (
    'juan',
    crypt('Password123', gen_salt('bf'))
);

SELECT usuario, password_hash = crypt('Password123', password_hash) AS contraseña_correcta 
FROM usuarios_segura WHERE usuario = 'juan';


CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

INSERT INTO clientes_protegidos (nombre, rfc_cifrado) 
VALUES ('Ana López', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));

SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc 
FROM clientes_protegidos;


SHOW ssl;
SHOW ssl_min_protocol_version;
SELECT inet_client_addr(), inet_client_port();
SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();

