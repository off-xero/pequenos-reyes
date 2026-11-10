-- S007 · HU-27: documentos institucionales de DEMOSTRACIÓN (ficticios).
--
-- Antes la tabla quedaba vacía y React mostraba una copia local (data/documentos.json) con ids de
-- texto ("doc-01"): al editarlos la API respondía 400. Ahora los documentos viven en PostgreSQL.
-- Idempotente: no duplica ni pisa cambios hechos desde el panel de dirección.

INSERT INTO documentos_institucionales (titulo, categoria, descripcion, url_archivo, vigente)
VALUES
    ('Reglamento Interno 2026', 'Reglamentos', 'Normas de convivencia y funcionamiento del establecimiento (documento demo).', NULL, TRUE),
    ('Protocolo de Seguridad Escolar', 'Protocolos', 'Procedimientos ante emergencias y evacuación (documento demo).', NULL, TRUE),
    ('Formulario de Autorización de Salida', 'Formularios', 'Autorización para retiro de alumnos por terceros (documento demo).', NULL, TRUE)
ON CONFLICT (titulo) DO NOTHING;
