# Mapeo Táctico MITRE ATT&CK // SOC-Bolsillo

El conjunto de artefactos recolectados por **SOC-Bolsillo** (volátiles + target `KapeTriage`) permite a los analistas del SOC y respondedores a incidentes detectar, reconstruir y correlacionar actividades asociadas a las siguientes tácticas y técnicas de **MITRE ATT&CK Enterprise Matrix**:

---

## Matriz de Cobertura Forense

| Táctica MITRE | ID Técnica | Nombre de Técnica | Artefacto Recolectado en SOC-Bolsillo | Capacidad de Detección / Análisis |
| :--- | :--- | :--- | :--- | :--- |
| **Initial Access & Execution** | **T1204** | User Execution: Malicious File | `Prefetch (.pf)`, `LNK Files`, `JumpLists` | Reconstruye qué archivo abrió el usuario, ruta exacta, volumen de origen y marcas de tiempo de primera y última ejecución. |
| **Execution** | **T1059** | Command and Scripting Interpreter | `Security.evtx` (Event ID 4688), `Microsoft-Windows-PowerShell%4Operational.evtx` (Event ID 4104) | Permite auditar comandos de PowerShell ejecutados (Script Block Logging), parámetros CLI sospechosos (`-enc`, `-w hidden`, `-nop`). |
| **Execution** | **T1047** | Windows Management Instrumentation | `Microsoft-Windows-WMI-Activity%4Operational.evtx` | Detecta persistencia o ejecuciones remotas iniciadas a través de WMI providers. |
| **Persistence** | **T1547.001** | Registry Run Keys / Startup Folder | Registros `NTUSER.DAT` y `SOFTWARE` (`\CurrentVersion\Run`, `\RunOnce`) | Identifica binarios maliciosos configurados para iniciarse automáticamente en el arranque o inicio de sesión. |
| **Persistence** | **T1053.005** | Scheduled Task | `C:\Windows\System32\Tasks\*` | Permite examinar definiciones XML de tareas programadas sospechosas, ejecutables asociados y disparadores temporales. |
| **Defense Evasion** | **T1070.001** | Clear Windows Event Logs | `Security.evtx` (Event ID 1102), `System.evtx` (Event ID 104) | Registra si el atacante intentó vaciar los logs de eventos para ocultar sus huellas forenses. |
| **Defense Evasion** | **T1036** | Masquerading | `Amcache.hve`, `AppCompatCache (Shimcache)` | Correlaciona hashes SHA-1 de ejecutables, nombres originales de compilación y rutas para detectar malware disfrazado (p. ej. `svchost.exe` en `C:\Users\AppData`). |
| **Credential Access** | **T1003.002** | Security Account Manager (SAM) | Hives `SAM` y `SYSTEM` en disco | Permite extraer hashes NTLM locales para análisis offline de compromiso de cuentas de administrador local. |
| **Discovery** | **T1049** | System Network Connections Discovery | `netstat_conexiones.txt` | Captura conexiones salientes hacia servidores de mando y control (C2), túneles inversos o puertos remotos anómalos. |
| **Discovery** | **T1016** | System Network Configuration Discovery | `cache_dns.txt`, `tabla_arp.txt` | Revela resoluciones de dominios sospechosos, balizas periódicas y mapeo de dispositivos de red local. |
| **Discovery** | **T1057** | Process Discovery | `procesos_activos.txt` | Identifica procesos huérfanos, inyecciones de procesos y ejecutables corriendo desde ubicaciones anómalas (`\Temp\`, `\Downloads\`). |
| **Lateral Movement** | **T1021.001** | Remote Desktop Protocol | `TerminalServices-LocalSessionManager.evtx`, `TerminalServices-RDPClient.evtx` | Rastrea sesiones RDP entrantes/salientes, nombres de estaciones de trabajo remotas e IPs origen. |

---

## Cadena de Correlación Forense Recomendada

```text
1. [netstat_conexiones.txt] Identificar IP remota C2 sospechosa y PID
                     ↓
2. [procesos_activos.txt] Mapear PID con nombre de proceso, ruta y usuario
                     ↓
3. [Prefetch / Amcache] Obtener hash del binario, timestamps y volumen
                     ↓
4. [Security.evtx (4688)] Extraer línea de comandos completa y proceso padre
                     ↓
5. [$MFT / $UsnJrnl] Reconstruir creación de archivos y borrados anti-forenses
```
