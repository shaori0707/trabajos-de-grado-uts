-- =====================================================================
--  proyecto_final_2.sql  (script ÚNICO: crea la base completa)
--  Importar en phpMyAdmin: pestaña Importar -> elegir este archivo.
--  ADVERTENCIA: empieza con DROP DATABASE: borra y recrea la base proyecto_final_2.
--  Haz un respaldo (respaldo_base_datos.bat) antes de importarlo.
--  Usuarios de prueba: ver el final del archivo (contraseñas cifradas con SHA2).
-- =====================================================================
-- =====================================================================
--  Base de datos: proyecto_final_2
--  Sistema de gestión y seguimiento de trabajos de grado - UTS
--  Generado a partir de las consultas SQL del código JSP del parcial.
--  Compatible con MySQL 5.7+/8 y MariaDB 10.4+ (XAMPP / phpMyAdmin).
--
--  CÓMO USARLO (phpMyAdmin):
--    1. Abre http://localhost/phpmyadmin
--    2. Pestaña "Importar" -> elige este archivo -> "Importar".
--       (o pestaña "SQL", pega todo el contenido y pulsa "Continuar")
--    3. El script crea la base (borra la anterior si existe), las tablas
--       y datos de prueba.
-- =====================================================================

DROP DATABASE IF EXISTS proyecto_final_2;
CREATE DATABASE proyecto_final_2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE proyecto_final_2;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. USUARIOS  (tabla unificada: admin, coordinador, docente, estudiante)
--    Director y evaluador NO son roles: son un "cargo" en
--    proyecto_docentes y el usuario tiene rol 'docente'.
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id              INT NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NULL,
    email           VARCHAR(150) NOT NULL,
    password        VARCHAR(255) NOT NULL,          -- el código compara texto plano
    rol             VARCHAR(20)  NOT NULL,          -- admin | coordinador (Comité) | docente | evaluador | estudiante
    codigo          VARCHAR(30)  NULL,              -- código estudiantil
    estado          INT          NOT NULL DEFAULT 1, -- 1 activo, 0 inactivo (login exige 1)
    recibo_pago     VARCHAR(255) NULL,              -- ruta/marca del recibo de pago
    companero_id    INT NULL,              -- compañero elegido por el estudiante
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_usuarios_email (email),
    KEY idx_usuarios_rol (rol),
    KEY idx_usuarios_codigo (codigo),
    CONSTRAINT fk_usuarios_companero FOREIGN KEY (companero_id)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_usuarios_rol CHECK (rol IN ('admin','coordinador','docente','evaluador','estudiante'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. IDEAS_PROYECTO  (banco de ideas)
--    estado: pendiente | aprobada | rechazada
-- ---------------------------------------------------------------------
CREATE TABLE ideas_proyecto (
    id                     INT NOT NULL AUTO_INCREMENT,
    titulo                 VARCHAR(255) NOT NULL,
    descripcion            TEXT NULL,
    objetivos              TEXT NULL,
    creado_por             INT NULL,
    estado                 VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    comentario_coordinador TEXT NULL,
    fecha_creacion         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_revision         DATETIME NULL,
    PRIMARY KEY (id),
    KEY idx_ideas_estado (estado),
    CONSTRAINT fk_ideas_creador FOREIGN KEY (creado_por)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_ideas_estado CHECK (estado IN ('pendiente','aprobada','rechazada'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PROYECTOS  (proyecto/anteproyecto de grado)
--    estado (flujo): propuesta -> revision_director -> aprobado_director
--                    -> aprobado_evaluador | correcciones_director | reprobado
--    (el código usa además: aprobado_coordinador, en_evaluacion, correcciones)
--    Las calificaciones son numéricas; el código las guarda con setString.
-- ---------------------------------------------------------------------
CREATE TABLE proyectos (
    id                          INT NOT NULL AUTO_INCREMENT,
    titulo                      VARCHAR(255) NOT NULL,
    descripcion                 TEXT NULL,
    estado                      VARCHAR(40) NOT NULL DEFAULT 'propuesta',
    creado_por                  INT NULL,
    fecha_creacion              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_limite                DATE NULL,

    -- Anteproyecto (lo sube el estudiante, lo califica el director)
    archivo_pdf                 VARCHAR(255) NULL,
    anteproyecto_fecha          DATETIME NULL,
    anteproyecto_revisado       DATETIME NULL,
    version_anteproyecto        INT NOT NULL DEFAULT 1,
    estado_anteproyecto         VARCHAR(30) NULL,   -- aprobado | correcciones | rechazado
    calificacion_anteproyecto   DECIMAL(4,2) NULL,
    comentario_anteproyecto     TEXT NULL,

    -- Director
    director_id                 INT NULL,
    aprobado_director           INT        NOT NULL DEFAULT 0,
    calificacion_director       DECIMAL(4,2) NULL,
    observaciones_director      TEXT NULL,
    comentario_director         TEXT NULL,
    fecha_aprobacion_director   DATETIME NULL,

    -- Evaluador
    evaluador_id                INT NULL,
    aprobado_evaluador          INT        NOT NULL DEFAULT 0,
    calificacion_evaluador      DECIMAL(4,2) NULL,
    comentario_evaluador        TEXT NULL,
    fecha_aprobacion_evaluador  DATETIME NULL,

    PRIMARY KEY (id),
    KEY idx_proyectos_estado (estado),
    CONSTRAINT fk_proyectos_creador FOREIGN KEY (creado_por)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_proyectos_director FOREIGN KEY (director_id)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_proyectos_evaluador FOREIGN KEY (evaluador_id)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. PROYECTO_ESTUDIANTES  (N:M proyecto - estudiante)
--    UNIQUE(estudiante_id): un estudiante solo puede estar en un proyecto.
-- ---------------------------------------------------------------------
CREATE TABLE proyecto_estudiantes (
    id               INT NOT NULL AUTO_INCREMENT,
    proyecto_id      INT NOT NULL,
    estudiante_id    INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_estudiante_un_proyecto (estudiante_id),
    KEY idx_pe_proyecto (proyecto_id),
    CONSTRAINT fk_pe_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pe_estudiante FOREIGN KEY (estudiante_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PROYECTO_DOCENTES  (N:M proyecto - docente, con cargo)
--    UNIQUE(proyecto_id, cargo): un solo director y un solo evaluador.
--    RESTRICT: no se puede borrar un docente con proyectos asignados
--    (hay que reasignar primero).
-- ---------------------------------------------------------------------
CREATE TABLE proyecto_docentes (
    id               INT NOT NULL AUTO_INCREMENT,
    proyecto_id      INT NOT NULL,
    docente_id       INT NOT NULL,
    cargo            VARCHAR(20) NOT NULL,           -- director | evaluador
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo           INT        NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_proyecto_cargo (proyecto_id, cargo),
    KEY idx_pd_docente (docente_id, cargo),
    CONSTRAINT fk_pd_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pd_docente FOREIGN KEY (docente_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pd_cargo CHECK (cargo IN ('director','evaluador'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. AVANCES  (entregas parciales que revisa el director)
--    estado: pendiente | aprobado | correcciones | rechazado
-- ---------------------------------------------------------------------
CREATE TABLE avances (
    id                  INT NOT NULL AUTO_INCREMENT,
    proyecto_id         INT NOT NULL,
    estudiante_id       INT NOT NULL,
    titulo              VARCHAR(255) NOT NULL,
    descripcion         TEXT NULL,
    ruta_archivo        VARCHAR(255) NULL,
    estado              VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    comentario_director TEXT NULL,
    version             INT NOT NULL DEFAULT 1,
    fecha_subida        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_revision      DATETIME NULL,
    PRIMARY KEY (id),
    KEY idx_avances_proyecto (proyecto_id, estado),
    CONSTRAINT fk_avances_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_avances_estudiante FOREIGN KEY (estudiante_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. CALIFICACIONES  (informe de calificaciones que ve el estudiante)
--    verInforme.jsp usa: rol_evaluador, nota, justificacion, evaluador_id
-- ---------------------------------------------------------------------
CREATE TABLE calificaciones (
    id                  INT NOT NULL AUTO_INCREMENT,
    proyecto_id         INT NOT NULL,
    evaluador_id        INT NOT NULL,
    rol_evaluador       VARCHAR(30) NULL,            -- Director | Evaluador
    nota                DECIMAL(4,2) NULL,
    justificacion       TEXT NULL,
    fecha_calificacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_cal_proyecto (proyecto_id),
    CONSTRAINT fk_cal_proyecto FOREIGN KEY (proyecto_id)
        REFERENCES proyectos (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cal_evaluador FOREIGN KEY (evaluador_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. MENSAJES  (mensajería interna)
--    Borrado lógico por lado: eliminado_remitente / eliminado_destinatario.
--    (docente/eliminar_mensaje.jsp usa además eliminado_por)
-- ---------------------------------------------------------------------
CREATE TABLE mensajes (
    id                     INT NOT NULL AUTO_INCREMENT,
    remitente_id           INT NOT NULL,
    destinatario_id        INT NOT NULL,
    asunto                 VARCHAR(255) NOT NULL,
    mensaje                TEXT NOT NULL,
    fecha_envio            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leido                  INT        NOT NULL DEFAULT 0,
    importante             INT        NOT NULL DEFAULT 0,
    eliminado_remitente    INT        NOT NULL DEFAULT 0,
    eliminado_destinatario INT        NOT NULL DEFAULT 0,
    eliminado_por          INT NULL,
    PRIMARY KEY (id),
    KEY idx_msj_destinatario (destinatario_id, eliminado_destinatario),
    KEY idx_msj_remitente (remitente_id, eliminado_remitente),
    CONSTRAINT fk_msj_remitente FOREIGN KEY (remitente_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_msj_destinatario FOREIGN KEY (destinatario_id)
        REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. CALENDARIO_ACADEMICO
--    tipo: reunion | entrega | sustentacion | plazo | otro
-- ---------------------------------------------------------------------
CREATE TABLE calendario_academico (
    id             INT NOT NULL AUTO_INCREMENT,
    titulo         VARCHAR(255) NOT NULL,
    descripcion    TEXT NULL,
    fecha_evento   DATE NOT NULL,
    tipo           VARCHAR(20) NOT NULL DEFAULT 'otro',
    creado_por     INT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_cal_fecha (fecha_evento),
    CONSTRAINT fk_calendario_creador FOREIGN KEY (creado_por)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. FORMATOS_GRADO
--     tipo: formato | guia | reglamento | acta | otro
-- ---------------------------------------------------------------------
CREATE TABLE formatos_grado (
    id           INT NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(255) NOT NULL,
    descripcion  TEXT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    tipo         VARCHAR(20) NOT NULL DEFAULT 'formato',
    subido_por   INT NULL,
    fecha_subida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo       INT        NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    KEY idx_formatos_tipo (tipo, activo),
    CONSTRAINT fk_formatos_usuario FOREIGN KEY (subido_por)
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  DATOS DE PRUEBA
--  Las contraseñas se escriben en texto plano aquí y el bloque 3 de la
--  migración v3 las cifra con SHA2(...,256); el login compara con SHA2.
-- =====================================================================

INSERT INTO usuarios (id, nombre, apellido, email, password, rol, codigo, estado, recibo_pago) VALUES
 (1, 'Administrador', 'Sistema',   'admin@uts.edu.co',        'Admin123', 'admin',       NULL,     1, NULL),
 (2, 'Carolina',      'Mendoza',   'coordinador@uts.edu.co',  'Coord123', 'coordinador', NULL,     1, NULL),
 (3, 'Diego',         'Alvarez',   'diego.alvarez@uts.edu.co','Doc12345', 'docente',     NULL,     1, NULL),
 (4, 'Juan',          'Perez',     'juan.perez@uts.edu.co',   'Doc12345', 'docente',     NULL,     1, NULL),
 (5, 'Marta',         'Rojas',     'marta.rojas@uts.edu.co',  'Doc12345', 'docente',     NULL,     1, NULL),
 (6, 'Laura',         'Gomez',     'laura.gomez@uts.edu.co',  'Est12345', 'estudiante',  '2201001', 1, 'simulado'),
 (7, 'Andres',        'Castro',    'andres.castro@uts.edu.co','Est12345', 'estudiante',  '2201002', 1, 'simulado'),
 (8, 'Sofia',         'Ramirez',   'sofia.ramirez@uts.edu.co','Est12345', 'estudiante',  '2201003', 1, 'simulado'),
 (9, 'Camilo',        'Torres',    'camilo.torres@uts.edu.co','Est12345', 'estudiante',  '2201004', 1, NULL);

INSERT INTO ideas_proyecto (titulo, descripcion, objetivos, creado_por, estado, fecha_revision) VALUES
 ('Sistema de gestión de inventarios para pymes',
  'Aplicación web para controlar entradas, salidas y existencias.',
  'Diseñar el modelo de datos; implementar el módulo de inventario; realizar pruebas.', 3, 'aprobada', NOW()),
 ('Plataforma de seguimiento de prácticas empresariales',
  'Sistema para registrar horas y evidencias de prácticas.',
  'Levantar requerimientos; desarrollar módulo de horas; validar con usuarios.', 4, 'aprobada', NOW()),
 ('App de monitoreo de transporte escolar',
  'Seguimiento en tiempo real de rutas escolares.',
  'Definir arquitectura; integrar mapas; probar notificaciones.', 5, 'pendiente', NULL);

-- Proyecto 1: en revisión del director (para probar el rol DIRECTOR)
-- Proyecto 2: ya aprobado por el director (para probar el rol EVALUADOR,
--             que solo ve proyectos aprobados por el director)
INSERT INTO proyectos (id, titulo, descripcion, estado, creado_por, director_id, evaluador_id,
                       aprobado_director, fecha_aprobacion_director) VALUES
 (1, 'Sistema de gestión de inventarios para pymes',
     'Aplicación web para controlar entradas, salidas y existencias.',
     'propuesta', 6, 3, 4, 0, NULL),
 (2, 'Plataforma de seguimiento de prácticas empresariales',
     'Sistema para registrar horas y evidencias de prácticas.',
     'aprobado_director', 8, 3, 4, 1, NOW());

-- El proyecto 2 ya tiene anteproyecto aprobado (para ver las fases en verde)
UPDATE proyectos SET archivo_pdf = 'anteproyectos/demo.pdf', anteproyecto_fecha = NOW(),
       estado_anteproyecto = 'aprobado', calificacion_anteproyecto = 4.2
 WHERE id = 2;

INSERT INTO proyecto_estudiantes (proyecto_id, estudiante_id) VALUES
 (1, 6), (1, 7),
 (2, 8), (2, 9);

-- Director y evaluador NO son roles de usuario: son el "cargo" del docente
-- en cada proyecto. Diego = director, Juan = evaluador, Marta = sin asignar.
INSERT INTO proyecto_docentes (proyecto_id, docente_id, cargo) VALUES
 (1, 3, 'director'), (1, 4, 'evaluador'),
 (2, 3, 'director'), (2, 4, 'evaluador');

UPDATE usuarios SET companero_id = 7 WHERE id = 6;
UPDATE usuarios SET companero_id = 6 WHERE id = 7;
UPDATE usuarios SET companero_id = 9 WHERE id = 8;
UPDATE usuarios SET companero_id = 8 WHERE id = 9;

-- Proyecto 2: un avance aprobado y otro pendiente (Informe I enviado, Informe II aún no)
INSERT INTO avances (proyecto_id, estudiante_id, titulo, descripcion, ruta_archivo, estado) VALUES
 (2, 8, 'Avance 1 - Levantamiento de requerimientos', 'Documento inicial.', 'avances/demo1.pdf', 'aprobado'),
 (2, 9, 'Avance 2 - Diseño de la base de datos',      'Modelo entidad-relación.', 'avances/demo2.pdf', 'pendiente');

INSERT INTO calendario_academico (titulo, descripcion, fecha_evento, tipo, creado_por) VALUES
 ('Límite para aprobar ideas del banco', 'Fecha máxima de aprobación de ideas.', '2026-09-05', 'plazo', 2),
 ('Entrega formato de anteproyecto',      'Subir el anteproyecto al sistema.',    '2026-10-15', 'entrega', 2),
 ('Sustentaciones finales',               'Sustentación ante evaluadores.',       '2026-12-10', 'sustentacion', 2);

-- FORMATOS DE GRADO: no se insertan datos de prueba a propósito.
-- Copia los archivos a la carpeta  formatos/  del proyecto (junto a admin/, estudiante/, etc.)
-- y registra cada uno con un INSERT como este (ruta relativa a la raíz del proyecto):
--
-- INSERT INTO formatos_grado (nombre, descripcion, ruta_archivo, tipo, subido_por)
-- VALUES ('Nombre visible', 'Descripción corta', 'formatos/archivo.docx', 'formato', 2);
--
-- tipo puede ser: formato | guia | reglamento | acta | otro


-- ################ MIGRACIÓN v3 (flujo por fases) ################
USE proyecto_final_2;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Configuración general (dominios de correo institucional, carga por director)
CREATE TABLE configuracion (
    clave       VARCHAR(50)  NOT NULL,
    valor       VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NULL,
    PRIMARY KEY (clave)
) ENGINE=InnoDB;
INSERT INTO configuracion (clave, valor, descripcion) VALUES
 ('dominios_correo', 'uts.edu.co,correo.uts.edu.co', 'Dominios aceptados como correo institucional (separados por coma)'),
 ('carga_promedio_director', '10', 'Promedio de proyectos por director (referencia para el Comité)');

-- 2. Periodos académicos y ventanas de cada fase (los define el Comité o el Administrador)
CREATE TABLE periodo_academico (
    id                      INT NOT NULL AUTO_INCREMENT,
    nombre                  VARCHAR(10) NOT NULL,              -- ejemplo: 2026.2
    fecha_inicio            DATE NOT NULL,
    fecha_fin               DATE NOT NULL,
    semana_limite_propuesta INT NOT NULL DEFAULT 12,
    activo                  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uq_periodo_nombre (nombre),
    CONSTRAINT chk_periodo_fechas CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;
CREATE TABLE ventana_fase (
    id         INT NOT NULL AUTO_INCREMENT,
    periodo_id INT NOT NULL,
    fase       INT NOT NULL,
    desde      DATE NOT NULL,
    hasta      DATE NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ventana (periodo_id, fase),
    CONSTRAINT fk_ventana_periodo FOREIGN KEY (periodo_id) REFERENCES periodo_academico (id) ON DELETE CASCADE,
    CONSTRAINT chk_ventana_fase CHECK (fase BETWEEN 1 AND 6),
    CONSTRAINT chk_ventana_fechas CHECK (hasta >= desde)
) ENGINE=InnoDB;

-- 3. Usuarios: cédula, nivel (tecnología/ingeniería), créditos verificados y contraseñas con hash
ALTER TABLE usuarios
    ADD COLUMN cedula VARCHAR(20) NULL AFTER apellido,
    ADD COLUMN nivel VARCHAR(12) NULL AFTER codigo,
    ADD COLUMN creditos_verificados INT NOT NULL DEFAULT 0 AFTER nivel,
    ADD UNIQUE KEY uq_usuarios_cedula (cedula),
    ADD CONSTRAINT chk_usuarios_nivel CHECK (nivel IS NULL OR nivel IN ('tecnologia','ingenieria'));
ALTER TABLE usuarios MODIFY password VARCHAR(255) NOT NULL;
UPDATE usuarios SET password = SHA2(password, 256);

-- 4. Ideas: nivel, origen (banco/propia), disponibilidad y periodo
ALTER TABLE ideas_proyecto
    ADD COLUMN nivel VARCHAR(12) NULL AFTER objetivos,
    ADD COLUMN origen VARCHAR(10) NOT NULL DEFAULT 'banco' AFTER nivel,
    ADD COLUMN disponible INT NOT NULL DEFAULT 1 AFTER estado,
    ADD COLUMN revisado_por INT NULL AFTER comentario_coordinador,
    ADD CONSTRAINT fk_ideas_revisor FOREIGN KEY (revisado_por) REFERENCES usuarios (id) ON DELETE SET NULL,
    ADD CONSTRAINT chk_ideas_origen CHECK (origen IN ('banco','propia')),
    ADD CONSTRAINT chk_ideas_nivel CHECK (nivel IS NULL OR nivel IN ('tecnologia','ingenieria'));

-- 5. Proyectos: código, idea, periodo, modalidad, fase y plazos
ALTER TABLE proyectos
    ADD COLUMN codigo VARCHAR(30) NULL,
    ADD COLUMN consecutivo INT NULL,
    ADD COLUMN idea_id INT NULL,
    ADD COLUMN periodo_id INT NULL,
    ADD COLUMN modalidad VARCHAR(40) NOT NULL DEFAULT 'Desarrollo tecnológico',
    ADD COLUMN fase_actual INT NOT NULL DEFAULT 1,
    ADD COLUMN estado_fase VARCHAR(25) NOT NULL DEFAULT 'En revisión',
    ADD COLUMN responsable VARCHAR(12) NOT NULL DEFAULT 'Comité',
    ADD COLUMN interdisciplinario INT NOT NULL DEFAULT 0,
    ADD COLUMN director_sugerido_id INT NULL,
    ADD COLUMN fecha_inicio_fase DATETIME NULL,
    ADD COLUMN fecha_limite_revision DATETIME NULL,
    ADD COLUMN fecha_aprobacion_propuesta DATETIME NULL,
    ADD COLUMN fecha_sustentacion DATE NULL,
    ADD COLUMN dias_prorroga INT NOT NULL DEFAULT 0,
    ADD COLUMN bloqueado INT NOT NULL DEFAULT 0,
    ADD COLUMN motivo_bloqueo VARCHAR(120) NULL,
    ADD COLUMN cancelado INT NOT NULL DEFAULT 0,
    ADD COLUMN pago_cubre_todos INT NOT NULL DEFAULT 0,
    ADD UNIQUE KEY uq_proyectos_codigo (codigo),
    ADD CONSTRAINT fk_proyectos_idea FOREIGN KEY (idea_id) REFERENCES ideas_proyecto (id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_proyectos_periodo FOREIGN KEY (periodo_id) REFERENCES periodo_academico (id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_proyectos_sugerido FOREIGN KEY (director_sugerido_id) REFERENCES usuarios (id) ON DELETE SET NULL,
    ADD CONSTRAINT chk_proyectos_fase CHECK (fase_actual BETWEEN 1 AND 6),
    ADD CONSTRAINT chk_proyectos_estado_fase CHECK (estado_fase IN ('Pendiente de entrega','En revisión','Aplazado','Rechazado','Finalizado')),
    ADD CONSTRAINT chk_proyectos_responsable CHECK (responsable IN ('Estudiante','Director','Evaluador','Comité'));

-- Un estudiante puede tener otro proyecto si el anterior se canceló o fue rechazado
-- (la regla "un solo proyecto activo" la valida la página con la cédula del estudiante)
ALTER TABLE proyecto_estudiantes DROP FOREIGN KEY fk_pe_estudiante;
ALTER TABLE proyecto_estudiantes DROP INDEX uq_estudiante_un_proyecto;
ALTER TABLE proyecto_estudiantes ADD KEY idx_pe_estudiante (estudiante_id),
    ADD CONSTRAINT fk_pe_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE CASCADE;

-- 6. Entregas (historial de versiones: solo enlaces URL, no archivos)
CREATE TABLE entrega (
    id            INT NOT NULL AUTO_INCREMENT,
    proyecto_id   INT NOT NULL,
    fase          INT NOT NULL,
    tipo          VARCHAR(20) NOT NULL,
    url           VARCHAR(500) NOT NULL,
    estudiante_id INT NOT NULL,
    version       INT NOT NULL DEFAULT 1,
    fecha         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_entrega_proyecto (proyecto_id, fase),
    CONSTRAINT fk_entrega_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyectos (id) ON DELETE CASCADE,
    CONSTRAINT fk_entrega_estudiante FOREIGN KEY (estudiante_id) REFERENCES usuarios (id) ON DELETE CASCADE,
    CONSTRAINT chk_entrega_url CHECK (url REGEXP '^https?://[^ ]+$'),
    CONSTRAINT chk_entrega_tipo CHECK (tipo IN ('Pago','F-124','Rejilla','Turnitin','F-125','F-129'))
) ENGINE=InnoDB;

-- 7. Revisiones (quién decidió, qué decidió y cuándo)
CREATE TABLE revision (
    id                  INT NOT NULL AUTO_INCREMENT,
    proyecto_id         INT NOT NULL,
    fase                INT NOT NULL,
    revisor_id          INT NOT NULL,
    rol_revisor         VARCHAR(12) NOT NULL,
    estado              VARCHAR(10) NOT NULL,
    observacion         TEXT NULL,
    firma               INT NOT NULL DEFAULT 0,
    cumple_general      INT NULL,
    cumple_especificos  INT NULL,
    fecha               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_revision_proyecto (proyecto_id, fase),
    CONSTRAINT fk_revision_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyectos (id) ON DELETE CASCADE,
    CONSTRAINT fk_revision_revisor FOREIGN KEY (revisor_id) REFERENCES usuarios (id) ON DELETE CASCADE,
    CONSTRAINT chk_revision_estado CHECK (estado IN ('Aprobado','Aplazado','Rechazado')),
    CONSTRAINT chk_revision_obs CHECK (estado = 'Aprobado' OR (observacion IS NOT NULL AND CHAR_LENGTH(TRIM(observacion)) > 0))
) ENGINE=InnoDB;

-- 8. Seguimientos del director, prórrogas y alertas de plagio
CREATE TABLE seguimiento (
    id          INT NOT NULL AUTO_INCREMENT,
    proyecto_id INT NOT NULL,
    director_id INT NOT NULL,
    nota        TEXT NOT NULL,
    fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_seg_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyectos (id) ON DELETE CASCADE,
    CONSTRAINT fk_seg_director FOREIGN KEY (director_id) REFERENCES usuarios (id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE prorroga (
    id                INT NOT NULL AUTO_INCREMENT,
    proyecto_id       INT NOT NULL,
    numero            INT NOT NULL,
    url_carta         VARCHAR(500) NOT NULL,
    url_pago          VARCHAR(500) NOT NULL,
    estado            VARCHAR(10) NOT NULL DEFAULT 'Pendiente',
    solo_correcciones INT NOT NULL DEFAULT 0,
    dias_otorgados    INT NOT NULL DEFAULT 180,
    fecha_solicitud   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_decision    DATETIME NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_prorroga_numero (proyecto_id, numero),
    CONSTRAINT fk_prorroga_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyectos (id) ON DELETE CASCADE,
    CONSTRAINT chk_prorroga_numero CHECK (numero >= 1),
    CONSTRAINT chk_prorroga_estado CHECK (estado IN ('Pendiente','Aprobada','Rechazada')),
    CONSTRAINT chk_prorroga_urls CHECK (url_carta REGEXP '^https?://[^ ]+$' AND url_pago REGEXP '^https?://[^ ]+$')
) ENGINE=InnoDB;
CREATE TABLE alerta_plagio (
    id          INT NOT NULL AUTO_INCREMENT,
    proyecto_id INT NOT NULL,
    docente_id  INT NOT NULL,
    detalle     TEXT NOT NULL,
    fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atendida    INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT fk_plagio_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyectos (id) ON DELETE CASCADE,
    CONSTRAINT fk_plagio_docente FOREIGN KEY (docente_id) REFERENCES usuarios (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. Calendario y base documental: enlaces
-- (el enlace del calendario se registra en la base documental)
ALTER TABLE formatos_grado ADD CONSTRAINT chk_formatos_url CHECK (ruta_archivo REGEXP '^https?://[^ ]+$');

-- 10. Las tablas del flujo anterior (avances por archivo y calificaciones) se reemplazan por entrega y revision
DROP TABLE IF EXISTS avances;
DROP TABLE IF EXISTS calificaciones;

-- 11. Director y evaluador viven en proyectos (una sola fuente); se eliminan columnas del flujo anterior
DROP TABLE IF EXISTS proyecto_docentes;
-- director y evaluador: no se puede borrar un docente que tenga proyectos (RESTRICT permite usar CHECK sobre estas columnas)
ALTER TABLE proyectos DROP FOREIGN KEY fk_proyectos_director, DROP FOREIGN KEY fk_proyectos_evaluador;
ALTER TABLE proyectos
    ADD CONSTRAINT fk_proyectos_director FOREIGN KEY (director_id) REFERENCES usuarios (id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_proyectos_evaluador FOREIGN KEY (evaluador_id) REFERENCES usuarios (id) ON DELETE RESTRICT;
ALTER TABLE proyectos
    DROP COLUMN estado, DROP COLUMN fecha_limite, DROP COLUMN archivo_pdf, DROP COLUMN anteproyecto_fecha,
    DROP COLUMN anteproyecto_revisado, DROP COLUMN version_anteproyecto, DROP COLUMN estado_anteproyecto,
    DROP COLUMN calificacion_anteproyecto, DROP COLUMN comentario_anteproyecto, DROP COLUMN aprobado_director,
    DROP COLUMN calificacion_director, DROP COLUMN observaciones_director, DROP COLUMN comentario_director,
    DROP COLUMN fecha_aprobacion_director, DROP COLUMN aprobado_evaluador, DROP COLUMN calificacion_evaluador,
    DROP COLUMN comentario_evaluador, DROP COLUMN fecha_aprobacion_evaluador,
    ADD CONSTRAINT chk_proyectos_dir_eval CHECK (director_id IS NULL OR evaluador_id IS NULL OR director_id <> evaluador_id);

SET FOREIGN_KEY_CHECKS = 1;

-- ################ DATOS DE PRUEBA v3 ################
USE proyecto_final_2;

-- Cédula, nivel y créditos de los usuarios de prueba (req. 7, 10 y 41)
UPDATE usuarios SET cedula = CONCAT('10', LPAD(id, 8, '0'));
UPDATE usuarios SET nivel = 'tecnologia', creditos_verificados = 1 WHERE rol = 'estudiante';

-- Periodo académico activo y ventanas de fase (req. 43). Fechas de ejemplo.
INSERT INTO periodo_academico (id, nombre, fecha_inicio, fecha_fin, semana_limite_propuesta, activo)
VALUES (1, '2026.2', '2026-08-03', '2026-12-11', 12, 1);
INSERT INTO ventana_fase (periodo_id, fase, desde, hasta) VALUES
 (1, 1, '2026-08-03', '2026-09-04'),
 (1, 2, '2026-08-17', '2026-10-23'),
 (1, 3, '2026-08-17', '2026-10-30'),
 (1, 4, '2026-11-02', '2026-12-04'),
 (1, 5, '2026-11-02', '2026-12-09'),
 (1, 6, '2026-12-07', '2026-12-11');

-- Ideas: nivel, origen y disponibilidad (la 1 y la 2 ya fueron tomadas por un proyecto)
UPDATE ideas_proyecto SET nivel = 'tecnologia', origen = 'banco', revisado_por = 2;
UPDATE ideas_proyecto SET disponible = 0 WHERE id IN (1, 2);

-- Proyecto 1: fase 1 (Pago), el Comité debe revisar el pago.
-- Proyecto 2: fase 2 (Propuesta I), responde el director.
UPDATE proyectos SET codigo = '65-20262-001', consecutivo = 1, idea_id = 1, periodo_id = 1,
       fase_actual = 1, estado_fase = 'En revisión', responsable = 'Comité',
       fecha_inicio_fase = NOW(), director_sugerido_id = 3
 WHERE id = 1;
UPDATE proyectos SET codigo = '65-20262-002', consecutivo = 2, idea_id = 2, periodo_id = 1,
       fase_actual = 2, estado_fase = 'En revisión', responsable = 'Director',
       fecha_inicio_fase = NOW(), fecha_limite_revision = DATE_ADD(NOW(), INTERVAL 5 DAY),
       pago_cubre_todos = 1, director_id = 3, evaluador_id = 4
 WHERE id = 2;

-- Entregas (solo enlaces URL, req. 34-35). Los enlaces son de ejemplo.
INSERT INTO entrega (proyecto_id, fase, tipo, url, estudiante_id, version) VALUES
 (1, 1, 'Pago',    'https://drive.google.com/ejemplo-pago-proyecto1', 6, 1),
 (2, 1, 'Pago',    'https://drive.google.com/ejemplo-pago-proyecto2', 8, 1),
 (2, 2, 'F-124',   'https://drive.google.com/ejemplo-f124-proyecto2', 8, 1),
 (2, 2, 'Rejilla', 'https://drive.google.com/ejemplo-rejilla-proyecto2', 8, 1);

-- Fase 1 del proyecto 2 aprobada por el Comité (trazabilidad, req. 50)
INSERT INTO revision (proyecto_id, fase, revisor_id, rol_revisor, estado, observacion, firma)
VALUES (2, 1, 2, 'Comité', 'Aprobado', NULL, 1);

-- Base documental: enlaces (req. 44). Reemplaza por los enlaces reales de la UTS.
INSERT INTO formatos_grado (nombre, descripcion, ruta_archivo, tipo, subido_por) VALUES
 ('Calendario académico', 'Enlace al calendario académico vigente', 'https://www.uts.edu.co/', 'otro', 2),
 ('Formato F-124 Propuesta', 'Formato de propuesta', 'https://www.uts.edu.co/', 'formato', 2),
 ('Formato F-125 Informe final', 'Formato de informe final', 'https://www.uts.edu.co/', 'formato', 2),
 ('Reglamento de trabajo de grado', 'Reglamento vigente', 'https://www.uts.edu.co/', 'reglamento', 2);

-- Evaluador: rol propio (distinto del docente director y del Comité).
-- Juan Pérez pasa a ser evaluador (clave de prueba: Eva12345).
UPDATE usuarios SET rol = 'evaluador', password = SHA2('Eva12345', 256) WHERE email = 'juan.perez@uts.edu.co';
-- La idea 2 pasa a ser de la docente Marta Rojas (el evaluador no propone ideas del banco).
UPDATE ideas_proyecto SET creado_por = 5 WHERE id = 2;


-- ===== Actualización de requisitos (prórrogas, 3 integrantes, docente único) =====
ALTER TABLE proyectos
    ADD COLUMN motivo_tercer VARCHAR(30) NULL,
    ADD COLUMN prorroga_correcciones INT NOT NULL DEFAULT 0;
-- El evaluador ahora es un docente (menú "Docente Director" / "Docente Evaluador")
UPDATE usuarios SET rol = 'docente' WHERE rol = 'evaluador';
