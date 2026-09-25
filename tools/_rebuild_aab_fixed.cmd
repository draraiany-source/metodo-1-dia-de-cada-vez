@echo off
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
set GRADLE_USER_HOME=C:\Users\Lenovo\.gradle
set TEMP=C:\Users\Lenovo\AppData\Local\Temp
set TMP=C:\Users\Lenovo\AppData\Local\Temp
cd /d "C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2"
set LOG=tools\_aab_rebuild_fixed.log
echo START %DATE% %TIME%> "%LOG%"
echo JAVA_HOME=%JAVA_HOME%>> "%LOG%"
echo GRADLE_USER_HOME=%GRADLE_USER_HOME%>> "%LOG%"
"%JAVA_HOME%\bin\java.exe" -version >> "%LOG%" 2>&1

REM Clear corrupt sandbox gradle transform if present
if exist "C:\Users\Lenovo\AppData\Local\Temp\cursor-sandbox-cache" (
  echo CLEANING_SANDBOX_GRADLE_CACHE>> "%LOG%"
  rmdir /s /q "C:\Users\Lenovo\AppData\Local\Temp\cursor-sandbox-cache" >> "%LOG%" 2>&1
)

cd android
call gradlew.bat --stop >> "..\%LOG%" 2>&1
cd ..

"C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat" build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html 1>>"%LOG%" 2>&1
echo EXIT_CODE=%ERRORLEVEL%>> "%LOG%"
echo END %DATE% %TIME%>> "%LOG%"
if exist "build\app\outputs\bundle\release\app-release.aab" (
  for %%I in ("build\app\outputs\bundle\release\app-release.aab") do (
    echo AAB_BYTES=%%~zI>> "%LOG%"
    echo AAB_MTIME=%%~tI>> "%LOG%"
  )
)
