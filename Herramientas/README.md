# Herramientas Auxiliares / Helper Binaries

Este directorio contiene los binarios portables necesarios para el empaquetado seguro y cifrado de los artefactos forenses.

---

### 1. `7za.exe` (7-Zip Standalone CLI)

- **Propósito:** Comprimir en formato `.zip` y cifrar los artefactos recolectados usando **AES-256** sin requerir instalación previa ni depender de software del host víctima.
- **Licencia:** GNU LGPL / unRAR restriction (Igor Pavlov).
- **Parámetros utilizados en triage:**
  - `a`: Añadir a archivo comprimido.
  - `-tzip`: Formato ZIP estándar compatible con laboratorios SIEM/DFIR.
  - `-p"SOC2026"`: Clave de cifrado simétrico (personalizable).
  - `-mem=AES256`: Algoritmo criptográfico AES con longitud de clave de 256 bits.
  - `-y`: Asume 'Sí' a todas las consultas de sobrescritura para permitir ejecución 100% desatendida.

#### Descarga Manual:
1. Visita [https://www.7-zip.org/download.html](https://www.7-zip.org/download.html).
2. Descarga el paquete **7-Zip Extra: standalone console version** (`7z2408-extra.7z` o versión equivalente).
3. Extrae el archivo `7za.exe` (o la versión x64) directamente en esta carpeta (`Herramientas/7za.exe`).

> **Nota:** Puedes aprovisionar este binario de forma totalmente automatizada ejecutando el script [`Preparar_USB.ps1`](../Preparar_USB.ps1) desde la raíz del proyecto.
