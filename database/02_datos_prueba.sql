-- =====================================================================
-- Datos de PRUEBA para verificar el esquema y las consultas.
-- Son datos ficticios de desarrollo, no información real de la unidad educativa.
-- La contraseña de todos los usuarios de prueba es un hash de ejemplo.
-- =====================================================================
USE transporte_escolar;

INSERT INTO rol (nombre_rol) VALUES ('ADMINISTRADOR'), ('CONDUCTOR'), ('PADRE'), ('ESTUDIANTE');

INSERT INTO usuario (ci, nombre, apellido_paterno, apellido_materno, email, telefono, username, password_hash, id_rol) VALUES
('1000001', 'Admin',   'Prueba', NULL, 'admin@prueba.local',   '70000001', 'admin',     '$2y$10$hashdeejemplo', 1),
('1000002', 'Conductor','Uno',   NULL, 'cond1@prueba.local',   '70000002', 'conductor1','$2y$10$hashdeejemplo', 2),
('1000003', 'Conductor','Dos',   NULL, 'cond2@prueba.local',   '70000003', 'conductor2','$2y$10$hashdeejemplo', 2),
('1000004', 'Padre',   'Uno',    NULL, 'padre1@prueba.local',  '70000004', 'padre1',    '$2y$10$hashdeejemplo', 3),
('1000005', 'Padre',   'Dos',    NULL, 'padre2@prueba.local',  '70000005', 'padre2',    '$2y$10$hashdeejemplo', 3),
('1000006', 'Estudiante','A',    NULL, NULL,                   NULL,       'est_a',     '$2y$10$hashdeejemplo', 4),
('1000007', 'Estudiante','B',    NULL, NULL,                   NULL,       'est_b',     '$2y$10$hashdeejemplo', 4),
('1000008', 'Estudiante','C',    NULL, NULL,                   NULL,       'est_c',     '$2y$10$hashdeejemplo', 4);

INSERT INTO administrador (id_usuario, cargo, nivel_permiso) VALUES (1, 'Encargado de transporte', 3);
INSERT INTO conductor (id_usuario, licencia, fecha_contratacion) VALUES (2, 'LIC-0001', '2025-02-01'), (3, 'LIC-0002', '2025-02-01');
INSERT INTO padre (id_usuario, relacion_general, notificar_por) VALUES (4, 'Madre', 'WEB'), (5, 'Padre', 'WEB');
INSERT INTO estudiante (id_usuario, grado, codigo_biometrico) VALUES (6, '3ro Primaria', 'HUELLA-A'), (7, '5to Primaria', 'HUELLA-B'), (8, '1ro Secundaria', 'HUELLA-C');
INSERT INTO estudiante_padre (id_estudiante, id_padre, parentesco) VALUES (1, 1, 'Madre'), (2, 1, 'Madre'), (3, 2, 'Padre');

INSERT INTO ruta (nombre, descripcion, horario_salida) VALUES
('Ruta Norte', 'Zona norte hacia la unidad educativa', '06:45:00'),
('Ruta Sur',   'Zona sur hacia la unidad educativa',   '06:50:00');

INSERT INTO parada (id_ruta, nombre, latitud, longitud, orden) VALUES
(1, 'Parada N1', -16.5000000, -68.1900000, 1),
(1, 'Parada N2', -16.5050000, -68.1950000, 2),
(2, 'Parada S1', -16.5300000, -68.2000000, 1);

INSERT INTO bus (placa, modelo, capacidad, estado, latitud, longitud, id_conductor, id_ruta) VALUES
('1234-ABC', 'Minibús', 20, 'EN_RUTA', -16.5020000, -68.1920000, 1, 1),
('5678-DEF', 'Microbús', 25, 'DISPONIBLE', -16.5310000, -68.2010000, 2, 2);

INSERT INTO asignacion_estudiante_ruta (id_estudiante, id_ruta, id_parada) VALUES (1, 1, 1), (2, 1, 2), (3, 2, 3);

-- Registros de hoy: A y B suben al bus 1; B ya bajó; C sube al bus 2
INSERT INTO asistencia_biometrica (id_estudiante, id_bus, tipo, fecha_hora, latitud, longitud) VALUES
(1, 1, 'SUBIDA', NOW() - INTERVAL 30 MINUTE, -16.5000000, -68.1900000),
(2, 1, 'SUBIDA', NOW() - INTERVAL 25 MINUTE, -16.5050000, -68.1950000),
(2, 1, 'BAJADA', NOW() - INTERVAL 5 MINUTE,  -16.5100000, -68.1990000),
(3, 2, 'SUBIDA', NOW() - INTERVAL 20 MINUTE, -16.5300000, -68.2000000);

INSERT INTO notificacion (id_padre, id_estudiante, titulo, mensaje, tipo) VALUES
(1, 1, 'Subió al bus', 'Su hijo(a) subió al bus 1234-ABC.', 'SUBIDA');

INSERT INTO emergencia (id_conductor, id_bus, tipo, atendida) VALUES (1, 1, 'Falla mecánica', FALSE);
