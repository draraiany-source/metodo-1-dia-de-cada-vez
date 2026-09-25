@echo off
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2"
set LOG=tools\_aab_rebuild_verbose.log
echo START %DATE% %TIME%> "%LOG%"
echo JAVA_HOME=%JAVA_HOME%>> "%LOG%"
"%JAVA_HOME%\bin\java.exe" -version >> "%LOG%" 2>&1
"C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat" build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html -v 1>>"%LOG%" 2>&1
echo EXIT_CODE=%ERRORLEVEL%>> "%LOG%"
echo END %DATE% %TIME%>> "%LOG%"
