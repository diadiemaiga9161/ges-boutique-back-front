@echo off
echo ========================================
echo   Ges Lafia - Deploy Ionic to Spring Boot
echo ========================================

set IONIC_WWW=C:\Users\Sniffer\Documents\alimentation-payement-back-front\ges-boutique-mobile\www
set SPRING_STATIC=C:\Users\Sniffer\Documents\alimentation-payement-back-front\alimentation-boutique-back\boutique\src\main\resources\static\mobile

echo.
echo [1/3] Build Ionic en production (base-href /mobile/)...
cd /d "C:\Users\Sniffer\Documents\alimentation-payement-back-front\ges-boutique-mobile"
call npx ng build --configuration production --base-href /mobile/
if %errorlevel% neq 0 (
    echo ERREUR: Build Ionic echoue
    pause
    exit /b 1
)
echo OK - Build Ionic termine

echo.
echo [2/3] Copie www/ vers static/mobile/...
if exist "%SPRING_STATIC%" rmdir /s /q "%SPRING_STATIC%"
mkdir "%SPRING_STATIC%"
xcopy /s /e /q "%IONIC_WWW%\*" "%SPRING_STATIC%\"
echo OK - Copie terminee

echo.
echo [3/3] Build du JAR Spring Boot...
cd /d "C:\Users\Sniffer\Documents\alimentation-payement-back-front\alimentation-boutique-back\boutique"
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ERREUR: Build Maven echoue
    pause
    exit /b 1
)
echo OK - JAR genere dans target/

echo.
echo ========================================
echo   SUCCES !
echo   Angular  : http://localhost:8080/
echo   Ionic PWA: http://localhost:8080/mobile/
echo   API      : http://localhost:8080/api/
echo ========================================
echo.
echo Pour lancer le jar :
echo   java -jar target\boutique-*.jar
echo.
pause
