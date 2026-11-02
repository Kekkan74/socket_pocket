@echo off
echo === INICIANDO TRIAGE FORENSE 100%% AUTOMATIZADO ===
set EVIDENCIAS=%~dp0Evidencias\%COMPUTERNAME%
mkdir "%EVIDENCIAS%\Volatil" 2>nul
mkdir "%EVIDENCIAS%\Kape" 2>nul

echo [1/3] Recolectando evidencias volatiles (Red y Procesos)...
netstat -ano > "%EVIDENCIAS%\Volatil\netstat_conexiones.txt"
ipconfig /displaydns > "%EVIDENCIAS%\Volatil\cache_dns.txt"
tasklist /v > "%EVIDENCIAS%\Volatil\procesos_activos.txt"
arp -a > "%EVIDENCIAS%\Volatil\tabla_arp.txt"

echo [2/3] Ejecutando KAPE (Artefactos de disco)...
:: KAPE ya esta en modo silencioso con --gui off
%~dp0KAPE\kape.exe --tsource C: --target KapeTriage --tdest "%EVIDENCIAS%\Kape" --tflush --gui off

echo [3/3] Cifrando y comprimiendo evidencias (Password: SOC2026)...
:: Se anade -y para que 7-Zip no pregunte si quiere sobrescribir archivos
%~dp0Herramientas\7za.exe a -tzip -p"SOC2026" -mem=AES256 "%~dp0Evidencias\%COMPUTERNAME%_Evidencia.zip" "%EVIDENCIAS%" -y >nul

echo [!] Limpiando archivos temporales...
rmdir /s /q "%EVIDENCIAS%"

echo === EXTRACCION COMPLETADA ===
echo La ventana se cerrara sola en 5 segundos...
:: timeout hace que el programa espere 5 segundos y se cierre sin pedir intervencion
timeout /t 5 >nul
