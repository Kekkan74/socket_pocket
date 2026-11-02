<#
.SYNOPSIS
    Preparar_USB.ps1 - Provisionamiento y Auditoría de Unidad USB para SOC-Bolsillo
.DESCRIPTION
    Verifica el entorno, valida el sistema de archivos del pendrive (evitando el límite de 4GB de FAT32),
    crea la estructura de carpetas requerida y descarga automáticamente 7za.exe si no está presente.
.AUTHOR
    Adry (Kekkan74)
#>

[CmdletBinding()]
param (
    [string]$RutaDestino = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [SOC-Bolsillo] Provisionamiento de Entorno USB Triage    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Comprobacion de privilegios
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] AVISO: Se recomienda ejecutar este script con privilegios de Administrador." -ForegroundColor Yellow
}

# 2. Verificacion del sistema de archivos de la unidad
try {
    $driveLetter = [System.IO.Path]::GetPathRoot($RutaDestino).Substring(0, 2)
    $volume = Get-Volume -DriveLetter ($driveLetter.Replace(":", "")) -ErrorAction SilentlyContinue
    if ($volume) {
        Write-Host "[i] Unidad detectada: $driveLetter ($($volume.FileSystemLabel)) - Formato: $($volume.FileSystem)" -ForegroundColor Green
        if ($volume.FileSystem -ieq "FAT32") {
            Write-Host "[!] ADVERTENCIA CRÍTICA: La unidad está formateada en FAT32." -ForegroundColor Red
            Write-Host "    FAT32 limita el tamaño máximo de archivo a 4 GB." -ForegroundColor Red
            Write-Host "    En triage con KAPE o sistemas con muchos logs, el archivo ZIP final puede superar los 4 GB." -ForegroundColor Yellow
            Write-Host "    -> Se recomienda encarecidamente formatear la unidad USB en NTFS o exFAT." -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "[i] No se pudo determinar el sistema de archivos de $RutaDestino (Ruta de red o carpeta local)." -ForegroundColor Gray
}

# 3. Creacion de estructura de carpetas
Write-Host "`n[+] Verificando estructura de directorios..." -ForegroundColor Cyan
$carpetas = @("Evidencias", "Herramientas", "KAPE", "docs")
foreach ($carpeta in $carpetas) {
    $targetPath = Join-Path $RutaDestino $carpeta
    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        Write-Host "  [+] Creada: $carpeta/" -ForegroundColor Green
    } else {
        Write-Host "  [OK] Existe: $carpeta/" -ForegroundColor Gray
    }
}

# 4. Descarga automatica de 7za.exe si no existe
$7zaPath = Join-Path $RutaDestino "Herramientas\7za.exe"
if (-not (Test-Path $7zaPath)) {
    Write-Host "`n[+] 7za.exe no encontrado en Herramientas/. Iniciando descarga automatizada..." -ForegroundColor Cyan
    $tempZip = Join-Path $env:TEMP "7z-extra.zip"
    $downloadUrl = "https://www.7-zip.org/a/7z2408-extra.7z" # Enlace directo oficial
    
    try {
        # Intentar obtener 7za desde repositorio oficial o mirror confiable
        Write-Host "  [-] Descargando binario 7-Zip CLI standalone..." -ForegroundColor Gray
        $wc = New-Object System.Net.WebClient
        # Alternativa liviana directa: descargar 7za.exe compilado
        $fallbackUrl = "https://raw.githubusercontent.com/develar/7zip-bin/master/win/x64/7za.exe"
        Invoke-WebRequest -Uri $fallbackUrl -OutFile $7zaPath -UseBasicParsing
        Write-Host "  [OK] 7za.exe instalado con exito en Herramientas\7za.exe" -ForegroundColor Green
    } catch {
        Write-Host "  [!] No se pudo descargar 7za.exe automaticamente ($($_.Exception.Message))." -ForegroundColor Yellow
        Write-Host "      Por favor, descarga 7za.exe manualmente siguiendo las instrucciones de Herramientas\README.md" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[OK] 7za.exe presente en Herramientas\7za.exe" -ForegroundColor Green
}

# 5. Auditoria de KAPE
$kapeExe = Join-Path $RutaDestino "KAPE\kape.exe"
if (-not (Test-Path $kapeExe)) {
    Write-Host "`n[!] AVISO: KAPE (kape.exe) no esta instalado en KAPE\." -ForegroundColor Yellow
    Write-Host "    Debido a la licencia de Kroll, KAPE debe ser descargado por el operador." -ForegroundColor Gray
    Write-Host "    1. Descarga KAPE desde: https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape" -ForegroundColor White
    Write-Host "    2. Extrae todos los archivos dentro de la carpeta: $RutaDestino\KAPE\" -ForegroundColor White
} else {
    Write-Host "`n[OK] KAPE suite detectada en KAPE\kape.exe" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [✔] Preparación completada. Pendrive listo para operar. " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
