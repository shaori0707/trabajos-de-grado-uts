
-- ===== Actualización de requisitos (prórrogas, 3 integrantes, docente único) =====
ALTER TABLE proyectos
    ADD COLUMN motivo_tercer VARCHAR(30) NULL,
    ADD COLUMN prorroga_correcciones INT NOT NULL DEFAULT 0;
-- El evaluador ahora es un docente (menú "Docente Director" / "Docente Evaluador")
UPDATE usuarios SET rol = 'docente' WHERE rol = 'evaluador';
