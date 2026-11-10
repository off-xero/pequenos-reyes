# Cambios · portal de apoderados, inscripciones y limpieza

## 1. Portal de apoderados y cuentas para iniciar sesión
**Problema:** las cuentas de la base (`@ejemplo.cl`) tenían el marcador `demo-sin-contrasena` y
`DEMO_PASSWORD` venía vacía, así que nadie podía iniciar sesión. La barra "Ver el portal como"
dependía de la identidad demo, que está desactivada por defecto, y se ocultaba sola.

- `HITO-3/backend/.env.example`: `DEMO_PASSWORD=PequenosReyes2026` con la lista de cuentas.
- Nuevo `GET /auth/cuentas-prueba` (solo development/test; 404 en producción): correos y roles para
  la pantalla de login, nunca contraseñas. La API avisa en el log si falta `DEMO_PASSWORD`.
- Frontend reorganizado según el diagrama (Portal apoderados → Sesión apoderado → Autenticación):
  - `services/auth.js` (reemplaza `authApi.js` y `sesionApi.js`).
  - `hooks/useSesionApoderado.js` (nuevo): login, logout y errores del portal.
  - `context/SesionProvider.jsx`: solo sesión real con token; también controla el modal del portal.
  - `LoginForm.jsx`: muestra las cuentas de prueba (clic = completa el correo).
  - `PortalApoderados.jsx`: apoderado ve a sus hijos; personal/dirección ve accesos a sus herramientas.
  - `BarraSesion.jsx` (nuevo) reemplaza `BarraSesionDemo.jsx`: muestra la cuenta y "Cerrar sesión".
  - Se eliminó el envío de `X-Usuario-Id` desde React: todas las llamadas usan `Authorization: Bearer`.

## 2. Inscripción a actividades y comprobantes de pago simulados
**Problema:** las tablas `actividades_escolares` y `categorias_actividad` no tenían datos, así que la
sección caía a un modo alternativo (pedía "ID Apoderado (demo)" y el nombre exacto del alumno), los
filtros quedaban vacíos y el apoderado no tenía dónde ver sus comprobantes.

- `sql/seed/S006__actividades_escolares_demo.sql`: 4 categorías y 4 actividades (fechas relativas).
- `sql/migraciones/V008__pagos_por_usuario.sql`: cada comprobante guarda la cuenta que lo emitió.
- Nuevo `GET /pagos/mios`: "Mis comprobantes" de la cuenta de la sesión.
- `FlujoInscripcionEventos.jsx` reescrito: el párvulo se elige de los hijos de la sesión (o de todos
  los alumnos si es personal), RUT validado, tarjetas con categoría/organizador/indicaciones,
  "Mis comprobantes", comprobante completo (medio y fecha), estados vacíos y botón "Iniciar sesión".
- Corregido: al crear o publicar una actividad no se actualizaba el catálogo de inscripción.

## 3. Gestión de actividades y de organizadores/categorías
- Solo se muestran con sesión autorizada: educadora y dirección ven *Gestión y publicación de
  actividades escolares*; solo dirección ve *Administración de organizadores y categorías*.
  La API vuelve a verificar el rol en cada petición.
- El campo hora usa `type="time"` (evita el 400 por formato).

## 4. Limpieza y organización
- Pruebas del backend movidas a `HITO-3/backend/tests/` (CI actualizado).
- `app/services/_init_.py` → `__init__.py` (nombre mal escrito).
- Eliminados: `package-lock.json` vacío de la raíz, logo duplicado `Logo de Jardin.png`,
  `styles/PreMatricula.css` (sin uso), `SeccionPendiente.jsx` y `data/secciones.js` (lista vacía).
- `favicon.ico` movido a `frontend-react/public/` (antes apuntaba a un `/vite.svg` inexistente).
- Corregido: claves React duplicadas en `ContactoSeccion.jsx`.
- README de la raíz y del frontend actualizados (cómo levantar, cuentas, recorrido de prueba).

## Pruebas realizadas
- Frontend: 144/144 pruebas `node --test` (se actualizaron las que esperaban `X-Usuario-Id`).
- Migraciones V001–V008 y semillas S001–S006 aplicadas dos veces sobre PostgreSQL 16 real (idempotentes).
- Recorrido en navegador (Playwright) como visitante, apoderado, educadora y dirección contra una
  API simulada con las mismas reglas de permisos: login, portal, inscripción, comprobante,
  verificación, crear/publicar actividad, crear organizador/categoría y confirmar pago. Sin errores de consola.
- Backend: se agregaron pruebas en `tests/tests_hu20.py` para `/pagos/mios` y `/auth/cuentas-prueba`.
  **No se pudieron ejecutar aquí** (sin FastAPI disponible): correr
  `APP_ENV=test python -m unittest discover -v -s tests -p "tests_*.py"` o dejar que lo haga el CI.

## Segunda ronda (errores reportados al probar)
Causa común: el volumen de PostgreSQL ya existía, así que V008 y las semillas nuevas nunca se aplicaron
(solo corrían con un volumen vacío).
- **Migraciones automáticas:** nuevo servicio `migraciones` en `docker-compose.yml`; corre
  `sql/migrar.sh` en cada `up` antes de la API. Probado sobre una base "vieja" (V001–V007): aplica
  V008 y carga S006/S007 sin tocar lo existente.
- **Sección de inscripción en blanco** ("servicio no disponible"): `/pagos/mios` fallaba (faltaba la
  columna de V008) y eso tumbaba toda la sección. Ahora solo el catálogo es imprescindible; si falla
  otra consulta se muestra un aviso y el resto funciona.
- **Crear actividad sin categorías:** se cargan con S006; si no hay, el formulario lo explica. Crear
  una categoría u organizador actualiza al instante las listas de las otras secciones.
- **Documentos "Hay datos que corregir":** la tabla estaba vacía y React mostraba una copia local
  (`data/documentos.json`, ids `"doc-01"`) que la API rechazaba al editar. Nueva semilla
  `S007__documentos_demo.sql`; React ya no usa la copia local (si la API falla muestra "Reintentar").

## Cómo actualizar si ya tienen los contenedores
```bash
cd HITO-3/backend
# agregar DEMO_PASSWORD=PequenosReyes2026 al .env si no está
docker compose up -d --build     # el servicio migraciones aplica V008, S006 y S007
```
