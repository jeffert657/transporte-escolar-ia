-- =====================================================================
-- Consultas SELECT que responden preguntas reales del proyecto
-- =====================================================================
USE transporte_escolar;

-- ---------------------------------------------------------------------
-- Pregunta 1 (administrador / conductor):
-- ¿Qué estudiantes están a bordo de cada bus en este momento?
-- Un estudiante está a bordo si su último registro biométrico de HOY es una SUBIDA.
-- ---------------------------------------------------------------------
SELECT b.placa,
       CONCAT(u.nombre, ' ', u.apellido_paterno) AS estudiante,
       e.grado,
       a.fecha_hora AS hora_subida
FROM asistencia_biometrica a
JOIN estudiante e ON e.id_estudiante = a.id_estudiante
JOIN usuario    u ON u.id_usuario    = e.id_usuario
JOIN bus        b ON b.id_bus        = a.id_bus
WHERE a.tipo = 'SUBIDA'
  AND DATE(a.fecha_hora) = CURDATE()
  AND a.fecha_hora = (SELECT MAX(a2.fecha_hora)
                      FROM asistencia_biometrica a2
                      WHERE a2.id_estudiante = a.id_estudiante
                        AND DATE(a2.fecha_hora) = CURDATE())
ORDER BY b.placa, estudiante;

-- ---------------------------------------------------------------------
-- Pregunta 2 (padre de familia):
-- ¿Dónde está ahora el bus de mi hijo y en qué parada debe subir?
-- (Ejemplo para el padre con id_padre = 1)
-- ---------------------------------------------------------------------
SELECT CONCAT(ue.nombre, ' ', ue.apellido_paterno) AS hijo,
       r.nombre      AS ruta,
       p.nombre      AS parada,
       b.placa       AS bus,
       b.latitud     AS latitud_bus,
       b.longitud    AS longitud_bus,
       CONCAT(uc.nombre, ' ', uc.apellido_paterno) AS conductor
FROM estudiante_padre ep
JOIN estudiante e   ON e.id_estudiante = ep.id_estudiante
JOIN usuario ue     ON ue.id_usuario   = e.id_usuario
JOIN asignacion_estudiante_ruta ar ON ar.id_estudiante = e.id_estudiante AND ar.activo = TRUE
JOIN ruta r         ON r.id_ruta   = ar.id_ruta
JOIN parada p       ON p.id_parada = ar.id_parada
JOIN bus b          ON b.id_ruta   = r.id_ruta
LEFT JOIN conductor c ON c.id_conductor = b.id_conductor
LEFT JOIN usuario uc  ON uc.id_usuario  = c.id_usuario
WHERE ep.id_padre = 1;

-- ---------------------------------------------------------------------
-- Pregunta 3 (administrador):
-- ¿Cuántos estudiantes subieron al bus por ruta en un día determinado,
-- frente a cuántos están asignados a esa ruta?
-- ---------------------------------------------------------------------
SELECT r.nombre AS ruta,
       COUNT(DISTINCT ar.id_estudiante) AS asignados,
       COUNT(DISTINCT CASE WHEN a.tipo = 'SUBIDA' THEN a.id_estudiante END) AS subieron
FROM ruta r
JOIN asignacion_estudiante_ruta ar ON ar.id_ruta = r.id_ruta AND ar.activo = TRUE
LEFT JOIN bus b ON b.id_ruta = r.id_ruta
LEFT JOIN asistencia_biometrica a
       ON a.id_estudiante = ar.id_estudiante
      AND a.id_bus = b.id_bus
      AND DATE(a.fecha_hora) = CURDATE()
GROUP BY r.id_ruta, r.nombre
ORDER BY r.nombre;

-- ---------------------------------------------------------------------
-- Pregunta 4 (administrador):
-- ¿Qué emergencias siguen sin atender y en qué bus ocurrieron?
-- ---------------------------------------------------------------------
SELECT em.id_emergencia,
       em.fecha_hora,
       em.tipo,
       b.placa,
       CONCAT(u.nombre, ' ', u.apellido_paterno) AS conductor,
       u.telefono
FROM emergencia em
JOIN bus b       ON b.id_bus       = em.id_bus
JOIN conductor c ON c.id_conductor = em.id_conductor
JOIN usuario u   ON u.id_usuario   = c.id_usuario
WHERE em.atendida = FALSE
ORDER BY em.fecha_hora DESC;
