@echo off
chcp 65001 > nul
echo ============================================================
echo   DEPLOY COMPLET - Angular + Ionic + Spring Boot (5 boutiques)
echo ============================================================

set BASE=C:\Users\Sniffer\Documents\alimentation-payement-back-front
set ANGULAR=%BASE%\Alimentation-ges01 -payement
set IONIC=%BASE%\ges-boutique-mobile
set SPRING=%BASE%\alimentation-boutique-back\boutique
set STATIC=%SPRING%\src\main\resources\static
set VPS=root@213.156.134.139

echo.
echo [1/5] Nettoyage des anciens fichiers statiques...
if exist "%STATIC%\*.js" del /q "%STATIC%\*.js" > nul 2>&1
if exist "%STATIC%\*.css" del /q "%STATIC%\*.css" > nul 2>&1
if exist "%STATIC%\index.html" del /q "%STATIC%\index.html" > nul 2>&1
if exist "%STATIC%\mobile" rmdir /s /q "%STATIC%\mobile"
echo OK

echo.
echo [2/5] Build Angular (front-office)...
cd /d "%ANGULAR%"
call ng build --configuration springboot
if %errorlevel% neq 0 (
    echo ERREUR: Build Angular echoue
    pause
    exit /b 1
)
echo OK - Angular -> static/

echo.
echo [3/5] Build Ionic (mobile PWA)...
cd /d "%IONIC%"
call ng build --configuration springboot
if %errorlevel% neq 0 (
    echo ERREUR: Build Ionic echoue
    pause
    exit /b 1
)
echo OK - Ionic -> static/mobile/ (outputPath springboot)

echo.
echo [4/5] Build du JAR Spring Boot...
cd /d "%SPRING%"
call mvn clean package -DskipTests -q
if %errorlevel% neq 0 (
    echo ERREUR: Build Maven echoue
    pause
    exit /b 1
)
echo OK - JAR genere dans target/

echo.
echo [5/5] Deploiement sur le VPS (5 boutiques)...
echo Copie du JAR vers le serveur...
scp "%SPRING%\target\boutique-*.jar" %VPS%:/opt/boutique/boutique-new.jar
if %errorlevel% neq 0 (
    echo ERREUR: SCP echoue - verifier la connexion SSH
    pause
    exit /b 1
)

echo Copie et redemarrage de toutes les boutiques...
ssh %VPS% "cp /opt/boutique/boutique-new.jar /opt/boutique/boutique-1.jar && cp /opt/boutique/boutique-new.jar /opt/boutique/boutique-2.jar && cp /opt/boutique/boutique-new.jar /opt/boutique/boutique-3.jar && cp /opt/boutique/boutique-new.jar /opt/boutique/boutique-4.jar && cp /opt/boutique/boutique-new.jar /opt/boutique/boutique-5.jar && systemctl daemon-reload && systemctl restart boutique boutique2 boutique3 boutique4 boutique5 && sleep 10 && systemctl is-active boutique boutique2 boutique3 boutique4 boutique5"
if %errorlevel% neq 0 (
    echo AVERTISSEMENT: Verifier le statut des services sur le VPS
)

echo.
echo ============================================================
echo   SUCCES !
echo   Boutique 1 : http://213.156.134.139:8080/
echo   Boutique 2 : http://213.156.134.139:8082/
echo   Boutique 3 : http://213.156.134.139:8083/
echo   Boutique 4 : https://barandjim.mg-consulting.site/
echo   Boutique 5 : https://boubandjim.mg-consulting.site/
echo   Ionic PWA  : https://barandjim.mg-consulting.site/mobile/
echo ============================================================
pause
