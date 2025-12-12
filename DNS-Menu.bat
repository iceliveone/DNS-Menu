
@echo off
set logFile=%~dp0dns-log.txt
set backupFile=%~dp0dns-backup.txt

:menu
cls
echo =========================================
echo   DNS-Server Auswahl (IPv4 + IPv6)
echo =========================================
echo [1] Cloudflare Gaming
echo [2] Cloudflare Familie
echo [3] Cloudflare Malware-Block
echo [4] Google DNS
echo [5] Quad9 Sicher
echo [6] Quad9 ECS
echo [7] Quad9 Unsecured
echo [B] Backup aktueller DNS
echo [R] Restore DNS
echo [0] Beenden
echo =========================================
set /p choice="Bitte Auswahl eingeben: "

for /f "tokens=1,*" %%a in ('netsh interface show interface ^| findstr /C:"Connected"') do set iface=%%b

if /I "%choice%"=="B" (
    netsh interface ipv4 show dnsservers name="%iface%" > "%backupFile%"
    echo %date% %time% - Backup erstellt >> "%logFile%"
    echo Backup gespeichert unter %backupFile%
    pause
    goto menu
)

if /I "%choice%"=="R" (
    echo Restore manuell durchführen (Batch kann nicht automatisch parsen)
    type "%backupFile%"
    echo %date% %time% - Restore ausgeführt >> "%logFile%"
    pause
    goto menu
)

if "%choice%"=="1" call :setdns "1.1.1.1" "1.0.0.1"
if "%choice%"=="2" call :setdns "1.1.1.2" "1.0.0.2"
if "%choice%"=="3" call :setdns "1.1.1.3" "1.0.0.3"
if "%choice%"=="4" call :setdns "8.8.8.8" "8.8.4.4"
if "%choice%"=="5" call :setdns "9.9.9.9" "149.112.112.112"
if "%choice%"=="6" call :setdns "9.9.9.11" "149.112.112.11"
if "%choice%"=="7" call :setdns "9.9.9.10" "149.112.112.10"
if "%choice%"=="0" exit
goto menu

:setdns
netsh interface ipv4 set dns name="%iface%" static %1
netsh interface ipv4 add dns name="%iface%" %2 index=2
echo %date% %time% - DNS gesetzt auf %1 %2 >> "%logFile%"
echo Fertig!
pause
goto menu
