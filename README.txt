SIG-GLORIA - APP CONECTADA A SQLITE
===================================

Esta versión conecta la app con la base SQLite usando un servidor local.

Contenido:
- index.html: aplicación principal.
- server.py: servidor local que conecta la app con SQLite.
- iniciar_app.bat: acceso rápido para Windows.
- base_datos/database.sql: script de base de datos.
- base_datos/sig_gloria.sqlite: base SQLite con datos de ejemplo.

Cómo abrir con base de datos:
1. Extraer el ZIP.
2. Abrir la carpeta SIG_GLORIA_APP_CONECTADA.
3. Si estás en Windows, hacer doble clic en iniciar_app.bat.
4. Si no funciona el .bat, abrir una terminal en esta carpeta y ejecutar:
   python server.py
5. Abrir en el navegador:
   http://localhost:8000

Credenciales:
- Administrador: admin@gloria.com / admin123
- Administrador alterno: jeffer / 123456
- Cliente: cliente@gloria.com / cliente123

Cómo revisar en Visual Studio Code:
1. Abrir Visual Studio Code.
2. File > Open Folder.
3. Seleccionar la carpeta SIG_GLORIA_APP_CONECTADA.
4. Revisar index.html, server.py y la carpeta base_datos.

Importante:
- Para que use SQLite, debe abrirse con http://localhost:8000.
- Si se abre index.html con doble clic, la app funciona, pero usará LocalStorage
  del navegador como respaldo.
- No se necesita instalar librerías de Python; server.py usa módulos estándar.
