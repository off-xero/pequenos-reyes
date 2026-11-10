-- V008 · HU-20/HU-23: cada comprobante simulado queda ligado a la cuenta que lo emitió.
--
-- Así el apoderado puede ver "Mis comprobantes" (GET /pagos/mios) sin acceder a los pagos de
-- otras familias. La columna es opcional: los comprobantes anteriores quedan sin cuenta.

ALTER TABLE inscripciones_pagos
    ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS ix_inscripciones_pagos_usuario ON inscripciones_pagos(usuario_id);
