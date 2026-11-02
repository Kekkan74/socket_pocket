# KAPE (Kroll Artifact Parser and Extractor)

Este directorio aloja la suite portable **KAPE**, desarrollada por Eric Zimmerman / Kroll, utilizada para la adquisición forense quirúrgica de artefactos de disco.

---

### ¿Por qué KAPE en Triage de Respuesta a Incidentes?

En incidentes reales (ransomware, compromiso de credenciales, movimiento lateral), realizar una imagen completa de disco de 1 TB o 2 TB puede tardar horas. **KAPE** recolecta los artefactos de mayor valor forense en cuestión de minutos, accediendo incluso a archivos bloqueados por el kernel de Windows mediante lectura directa de bajo nivel (VSS / Raw Disk Access).

### Target Utilizado: `KapeTriage`

El script ejecuta:
```cmd
kape.exe --tsource C: --target KapeTriage --tdest "%EVIDENCIAS%\Kape" --tflush --gui off
```

- `--tsource C:`: Unidad de origen del sistema operativo Windows.
- `--target KapeTriage`: Perfil compuesto que agrupa los principales artefactos forenses de Windows:
  - **Archivos maestros del sistema:** `$MFT`, `$LogFile`, `$Extend\$UsnJrnl`.
  - **Evidencias de ejecución:** Prefetch (`.pf`), Amcache (`Amcache.hve`), Shimcache (`SYSTEM\AppCompatCache`).
  - **Registros del sistema (Hives):** `SAM`, `SYSTEM`, `SOFTWARE`, `SECURITY`, `NTUSER.DAT`, `UsrClass.dat`.
  - **Registros de eventos de Windows:** `C:\Windows\System32\winevt\Logs\*.evtx` (Seguridad 4624, 4688, PowerShell 4104, Sysmon, Defender).
  - **Interacción del usuario:** Accesos directos (`.lnk`), JumpLists (`AutomaticDestinations`), Recycle Bin (`$Recycle.Bin`).
  - **Persistencia y red:** Tareas programadas (`Schedule`), SRUM (`System Resource Usage Monitor`), BITS.
- `--tdest`: Directorio de destino estructurado.
- `--tflush`: Limpia el directorio de destino antes de iniciar para evitar mezclas con incidentes previos.
- `--gui off`: Modo CLI silencioso esencial para automatización desatendida.

---

### Instrucciones de Instalación

1. Descarga KAPE de forma oficial y gratuita desde el portal de Kroll:
   👉 [https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape](https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape)
2. Descomprime el contenido de KAPE dentro de esta carpeta (`KAPE/`), asegurándote de que `kape.exe` quede en la ruta relativa esperada:
   ```text
   KAPE/
   ├── kape.exe
   ├── gkape.exe
   ├── Targets/
   └── Modules/
   ```
3. Ejecuta `gkape.exe` una vez para actualizar los Targets y Modules si es una instalación nueva (`Sync: Get latest targets/modules`).
