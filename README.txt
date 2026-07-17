SIG-GLORIA - APP CONECTADA A SQLITE
===================================

Esta versión conecta la app con la base SQLite usando un servidor local en Python.

Contenido:
- index.html: aplicación principal.
- server.py: servidor local que conecta la app con SQLite.
- iniciar_app.bat: acceso rápido para Windows.
- base_datos/database.sql: script de base de datos.
- base_datos/sig_gloria.sqlite: base SQLite con datos de ejemplo.

Mejoras incluidas:
- Login con código de autenticación demo.
- Se retiró el registro libre de usuarios y la opción “Olvidaste tu contraseña”.
- Registro de clientes con DNI/RUC, ubicación, teléfono, correo y tipo de comprobante.
- Catálogo editable de productos Gloria, precios y estado.
- Dashboard dinámico calculado desde pedidos, inventario, clientes y calidad.
- Los pedidos usan precios del catálogo y actualizan los indicadores del dashboard.

Cómo abrir con base de datos:
1. Extraer el ZIP.
2. Abrir la carpeta SIG_GLORIA_APP_CONECTADA.
3. Si estás en Windows, hacer doble clic en iniciar_app.bat.
4. Si no funciona el .bat, abrir una terminal en esta carpeta y ejecutar:
   python server.py
5. Abrir en el navegador:
   http://localhost:8000

Credenciales:
- Administrador: admin@gloria.com / admin123 / Código: 123456
- Administrador alterno: jeffer / 123456 / Código: 123456
- Cliente: cliente@gloria.com / cliente123 / Código: 123456

Importante:
- Para que use SQLite, debe abrirse con http://localhost:8000.
- Si se abre index.html con doble clic, la app funciona, pero usará LocalStorage del navegador como respaldo.
- No se necesita instalar librerías de Python; server.py usa módulos estándar.
