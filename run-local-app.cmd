@echo off
setlocal

set "ROOT=%~dp0"
set "BACKEND_DIR=%ROOT%backend"
set "FRONTEND_DIR=%ROOT%mutfak_asistanim"
set "NODE_EXE=C:\Users\edanu\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"

start "Mutfak Backend" cmd /k "cd /d ""%BACKEND_DIR%"" && mvnw.cmd -Dspring-boot.run.profiles=local spring-boot:run"
start "Mutfak Web" cmd /k "cd /d ""%FRONTEND_DIR%"" && flutter build web --dart-define=API_BASE_URL=http://localhost:8081 && ""%NODE_EXE%"" serve_web.js"
