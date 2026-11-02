<#
.SYNOPSIS
    Generar_Hash_Custodia.ps1 - Verificación Criptográfica y Cadena de Custodia DFIR
.DESCRIPTION
    Calcula los hashes SHA-256 y SHA-1 de los archivos comprimidos de evidencias generados
    por SOC-Bolsillo, generando un registro formal de integridad para cadena de custodia.
.AUTHOR
    Adry (Kekkan74)
#>

[CmdletBinding()]
param (
    [string]$CarpetaEvidencias = (Join-Path $PSScriptRoot "Evidencias"),
    [string]$Analista = $env:USERNAME,
    [string]$CasoID = "INC-" + (Get-Date -Format "yyyyMMdd-HHmm")
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [SOC-Bolsillo] Auditoría de Integridad y Cadena Custodia " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Test-Path $CarpetaEvidencias)) {
    Write-Error "La carpeta de evidencias no existe: $CarpetaEvidencias"
    exit 1
}

$archivos = Get-ChildItem -Path $CarpetaEvidencias -Filter "*_Evidencia.zip"

if ($archivos.Count -eq 0) {
    Write-Host "[!] No se encontraron archivos de evidencia (*_Evidencia.zip) en $CarpetaEvidencias" -ForegroundColor Yellow
    exit 0
}

$registroCustodia = Join-Path $CarpetaEvidencias "Cadena_Custodia.txt"
$timestampUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$reportHeader = @"
================================================================================
          REGISTRO FORMAL DE CADENA DE CUSTODIA (DFIR INTEGRITY LOG)
================================================================================
Caso ID:            $CasoID
Analista a Cargo:   $Analista
Host Operador:      $env:COMPUTERNAME
Fecha/Hora (UTC):   $timestampUtc
Estándar Cripto:    FIPS 180-4 (SHA-256) / RFC 3174 (SHA-1)
================================================================================

"@

Add-Content -Path $registroCustodia -Value $reportHeader -Encoding UTF8

foreach ($archivo in $archivos) {
    Write-Host "`n[+] Analizando archivo: $($archivo.Name)" -ForegroundColor Cyan
    Write-Host "    Tamaño: $([Math]::Round($archivo.Length / 1MB, 2)) MB ($($archivo.Length) bytes)" -ForegroundColor Gray

    $sha256 = (Get-FileHash -Path $archivo.FullName -Algorithm SHA256).Hash
    $sha1 = (Get-FileHash -Path $archivo.FullName -Algorithm SHA1).Hash

    Write-Host "    SHA-256: $sha256" -ForegroundColor Green
    Write-Host "    SHA-1:   $sha1" -ForegroundColor Yellow

    $entry = @"
[EVIDENCIA FORENSE]
Nombre de Archivo: $($archivo.Name)
Ruta Completa:     $($archivo.FullName)
Tamaño en Bytes:   $($archivo.Length)
Fecha Modificación:$($archivo.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")) UTC
Hash SHA-256:      $sha256
Hash SHA-1:        $sha1
--------------------------------------------------------------------------------
"@
    Add-Content -Path $registroCustodia -Value $entry -Encoding UTF8
}

Write-Host "`n[OK] Registro de integridad guardado exitosamente en:" -ForegroundColor Green
Write-Host "     $registroCustodia" -ForegroundColor White
