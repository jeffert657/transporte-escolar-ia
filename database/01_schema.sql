-- =====================================================================
-- Sistema web con machine learning para el control del transporte escolar
-- Caso: U.E. Marcelo Quiroga Santa Cruz (El Alto, Bolivia)
-- Modelo relacional obtenido del diagrama de clases (Tarea 2)
-- Motor: MySQL 8 / MariaDB 10.x   ·   Codificación: utf8mb4
-- =====================================================================

CREATE DATABASE IF NOT EXISTS transporte_escolar
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE transporte_escolar;

-- ---------------------------------------------------------------------
-- 1. ROL: tipos de usuario del sistema (administrador, conductor, padre, estudiante)
-- ---------------------------------------------------------------------
CREATE TABLE rol (
  id_rol      INT AUTO_INCREMENT PRIMARY KEY,
  nombre_rol  VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. USUARIO: superclase con los datos comunes de todas las personas
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
  id_usuario        INT AUTO_INCREMENT PRIMARY KEY,
  ci                VARCHAR(15)  NOT NULL UNIQUE,
  nombre            VARCHAR(60)  NOT NULL,
  apellido_paterno  VARCHAR(60)  NOT NULL,
  apellido_materno  VARCHAR(60),
  email             VARCHAR(120) UNIQUE,
  telefono          VARCHAR(20),
  direccion         VARCHAR(150),
  fecha_nacimiento  DATE,
  username          VARCHAR(40)  NOT NULL UNIQUE,
  password_hash     VARCHAR(255) NOT NULL,
  activo            BOOLEAN      NOT NULL DEFAULT TRUE,
  ultimo_acceso     DATETIME,
  id_rol            INT          NOT NULL,
  CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Subclases de USUARIO (herencia: una tabla por subclase, relación 1:1)
-- ---------------------------------------------------------------------
CREATE TABLE administrador (
  id_admin       INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario     INT NOT NULL UNIQUE,
  cargo          VARCHAR(60),
  nivel_permiso  TINYINT NOT NULL DEFAULT 1,
  CONSTRAINT fk_admin_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE padre (
  id_padre          INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario        INT NOT NULL UNIQUE,
  relacion_general  VARCHAR(30),
  notificar_por     VARCHAR(20) NOT NULL DEFAULT 'WEB',
  CONSTRAINT fk_padre_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE conductor (
  id_conductor         INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario           INT NOT NULL UNIQUE,
  licencia             VARCHAR(20) NOT NULL UNIQUE,
  fecha_contratacion   DATE,
  CONSTRAINT fk_conductor_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE estudiante (
  id_estudiante       INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario          INT NOT NULL UNIQUE,
  grado               VARCHAR(30) NOT NULL,
  codigo_biometrico   VARCHAR(64) UNIQUE,
  CONSTRAINT fk_estudiante_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. ESTUDIANTE_PADRE: clase asociativa (muchos a muchos con atributo parentesco)
-- ---------------------------------------------------------------------
CREATE TABLE estudiante_padre (
  id_estudiante  INT NOT NULL,
  id_padre       INT NOT NULL,
  parentesco     VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_estudiante, id_padre),
  CONSTRAINT fk_ep_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
    ON DELETE CASCADE,
  CONSTRAINT fk_ep_padre FOREIGN KEY (id_padre) REFERENCES padre(id_padre)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. RUTA y PARADA (composición: una parada no existe sin su ruta)
-- ---------------------------------------------------------------------
CREATE TABLE ruta (
  id_ruta          INT AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(80) NOT NULL UNIQUE,
  descripcion      VARCHAR(255),
  horario_salida   TIME NOT NULL,
  dias_semana      VARCHAR(30) NOT NULL DEFAULT 'LUN-VIE'
) ENGINE=InnoDB;

CREATE TABLE parada (
  id_parada  INT AUTO_INCREMENT PRIMARY KEY,
  id_ruta    INT NOT NULL,
  nombre     VARCHAR(80) NOT NULL,
  latitud    DECIMAL(10,7) NOT NULL,
  longitud   DECIMAL(10,7) NOT NULL,
  orden      INT NOT NULL,
  CONSTRAINT uq_parada_orden UNIQUE (id_ruta, orden),
  CONSTRAINT fk_parada_ruta FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. BUS: un conductor por bus (1:1) y una ruta por bus (Ruta 1 — 0..* Bus)
-- ---------------------------------------------------------------------
CREATE TABLE bus (
  id_bus        INT AUTO_INCREMENT PRIMARY KEY,
  placa         VARCHAR(10) NOT NULL UNIQUE,
  modelo        VARCHAR(60),
  capacidad     INT NOT NULL CHECK (capacidad > 0),
  estado        VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE',
  latitud       DECIMAL(10,7),
  longitud      DECIMAL(10,7),
  id_conductor  INT UNIQUE,
  id_ruta       INT,
  CONSTRAINT fk_bus_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor)
    ON DELETE SET NULL,
  CONSTRAINT fk_bus_ruta FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. ASIGNACION_ESTUDIANTE_RUTA: en qué ruta y en qué parada sube cada estudiante
-- ---------------------------------------------------------------------
CREATE TABLE asignacion_estudiante_ruta (
  id_asignacion  INT AUTO_INCREMENT PRIMARY KEY,
  id_estudiante  INT NOT NULL,
  id_ruta        INT NOT NULL,
  id_parada      INT NOT NULL,
  activo         BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_asig_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
    ON DELETE CASCADE,
  CONSTRAINT fk_asig_ruta FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta),
  CONSTRAINT fk_asig_parada FOREIGN KEY (id_parada) REFERENCES parada(id_parada)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. ASISTENCIA_BIOMETRICA: cada vez que el estudiante marca su huella al subir o bajar
-- ---------------------------------------------------------------------
CREATE TABLE asistencia_biometrica (
  id_asistencia  INT AUTO_INCREMENT PRIMARY KEY,
  id_estudiante  INT NOT NULL,
  id_bus         INT NOT NULL,
  tipo           ENUM('SUBIDA','BAJADA') NOT NULL,
  fecha_hora     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  latitud        DECIMAL(10,7),
  longitud       DECIMAL(10,7),
  metodo         VARCHAR(20) NOT NULL DEFAULT 'HUELLA',
  CONSTRAINT fk_asis_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
  CONSTRAINT fk_asis_bus FOREIGN KEY (id_bus) REFERENCES bus(id_bus),
  INDEX idx_asis_fecha (fecha_hora)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. NOTIFICACION: avisos que recibe el padre (subida, bajada, retraso, bloqueo)
-- ---------------------------------------------------------------------
CREATE TABLE notificacion (
  id_notificacion   INT AUTO_INCREMENT PRIMARY KEY,
  id_padre          INT NOT NULL,
  id_estudiante     INT,
  titulo            VARCHAR(100) NOT NULL,
  mensaje           VARCHAR(255) NOT NULL,
  tipo              VARCHAR(30)  NOT NULL,
  leida             BOOLEAN      NOT NULL DEFAULT FALSE,
  fecha_hora_envio  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_noti_padre FOREIGN KEY (id_padre) REFERENCES padre(id_padre)
    ON DELETE CASCADE,
  CONSTRAINT fk_noti_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. EMERGENCIA: botón de pánico del conductor
-- ---------------------------------------------------------------------
CREATE TABLE emergencia (
  id_emergencia  INT AUTO_INCREMENT PRIMARY KEY,
  id_conductor   INT NOT NULL,
  id_bus         INT NOT NULL,
  fecha_hora     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo           VARCHAR(40) NOT NULL,
  atendida       BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_emer_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor),
  CONSTRAINT fk_emer_bus FOREIGN KEY (id_bus) REFERENCES bus(id_bus)
) ENGINE=InnoDB;
