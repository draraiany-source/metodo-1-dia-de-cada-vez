@echo off
cd /d "C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2"
set LOG=tools\_aab_rebuild2.log
echo START %DATE% %TIME%> "%LOG%"
"C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat" build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html 1>>"%LOG%" 2>&1
echo EXIT_CODE=%ERRORLEVEL%>> "%LOG%"
echo END %DATE% %TIME%>> "%LOG%"
