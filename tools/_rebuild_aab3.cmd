@echo off
cd /d "C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2"
set LOG=tools\_aab_rebuild3.log
echo START %DATE% %TIME%> "%LOG%"
cd android
call gradlew.bat --stop >> "..\%LOG%" 2>&1
cd ..
echo DAEMONS_STOPPED>> "%LOG%"
"C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat" build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html 1>>"%LOG%" 2>&1
echo EXIT_CODE=%ERRORLEVEL%>> "%LOG%"
echo END %DATE% %TIME%>> "%LOG%"
if exist "build\app\outputs\bundle\release\app-release.aab" (
  for %%I in ("build\app\outputs\bundle\release\app-release.aab") do (
    echo AAB_BYTES=%%~zI>> "%LOG%"
    echo AAB_MTIME=%%~tI>> "%LOG%"
  )
)
