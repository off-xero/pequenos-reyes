-- S006 · HU-17/18/20/23: categorías de actividad y actividades escolares de DEMOSTRACIÓN.
--
-- Sin estos datos la sección "Inscripción a actividades y comprobantes de pago simulados"
-- quedaba vacía. Todo es ficticio. Idempotente: se puede cargar varias veces sin duplicar.
-- Las fechas son relativas al día de carga (hora de Chile) para que siempre estén vigentes.

-- ---------- Categorías de actividad (HU-17) ----------
INSERT INTO categorias_actividad (nombre, descripcion, activa)
VALUES
    ('Taller familiar', 'Talleres con participación de las familias', TRUE),
    ('Salida pedagógica', 'Actividades fuera del jardín', TRUE),
    ('Celebración', 'Actos y celebraciones institucionales', TRUE),
    ('Estimulación del lenguaje', 'Actividades guiadas por fonoaudiología', TRUE)
ON CONFLICT (nombre) DO NOTHING;

-- ---------- Actividades escolares (HU-18) ----------
-- Dos publicadas con cupos, una publicada casi llena (para probar "sin cupos") y un borrador
-- que el personal puede publicar desde "Gestión y publicación de actividades escolares".
INSERT INTO actividades_escolares (titulo, fecha, hora, lugar, preparar, capacidad, cupos_ocupados, estado, categoria_id, organizador_id)
SELECT v.titulo, (now() AT TIME ZONE 'America/Santiago')::date + v.dias, v.hora, v.lugar, v.preparar,
       v.capacidad, v.ocupados, v.estado, c.id, o.id
FROM (VALUES
    ('Taller de cuentos con las familias', 6, '10:00', 'Biblioteca', 'Traer un cuento favorito de la casa', 15, 0, 'publicada', 'Taller familiar', 'educadora.demo@ejemplo.cl'),
    ('Visita al museo interactivo', 12, '09:30', 'Salida desde el jardín', 'Colación, agua y gorro', 20, 0, 'publicada', 'Salida pedagógica', 'educadora.demo@ejemplo.cl'),
    ('Juegos de sonidos y rimas', 9, '11:00', 'Sala de fonoaudiología', NULL, 2, 1, 'publicada', 'Estimulación del lenguaje', 'fono.demo@ejemplo.cl'),
    ('Celebración de fin de año', 30, '16:00', 'Patio central', 'Vestimenta de color azul', 60, 0, 'borrador', 'Celebración', 'educadora.demo@ejemplo.cl')
) AS v(titulo, dias, hora, lugar, preparar, capacidad, ocupados, estado, categoria, organizador_email)
JOIN categorias_actividad c ON c.nombre = v.categoria
JOIN organizadores o ON o.email = v.organizador_email
WHERE NOT EXISTS (SELECT 1 FROM actividades_escolares a WHERE a.titulo = v.titulo);
