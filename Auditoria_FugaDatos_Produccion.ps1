<#
.SYNOPSIS
    Auditor de Prevención de Fuga de Datos (DLP) para Entornos de Producción Audiovisual.
.DESCRIPTION
    Analiza correos enviados a través de Microsoft Graph API para detectar envíos a destinatarios
    externos con palabras clave confidenciales, adjuntos o exposición masiva de direcciones (RGPD).
#>

# 1. Conectar a Microsoft Graph con permisos de lectura de correo
Connect-MgGraph -Scopes "Mail.Read"

# --- CONFIGURACIÓN DE LA AUDITORÍA ---
$DominioInterno = "@tuproductora.com" # Cambiar por el dominio real del tenant de pruebas
$UsuarioAuditar = "me" # "me" analiza tu propio buzón, o indica el email de otro usuario
$PalabrasClave  = @("guion", "script", "call sheet", "rodaje", "contrato", "presupuesto", "dni", "iban", "confidencial", "casting")

Write-Host "Iniciando auditoría de fuga de datos en correos enviados..." -ForegroundColor Cyan

# 2. Consultar los últimos 100 mensajes enviados mediante Microsoft Graph
$MensajesEnviados = Get-MgUserMailFolderMessage -UserId $UsuarioAuditar -MailFolderId "SentItems" -Top 100 -Select "Subject,SentDateTime,ToRecipients,CcRecipients,BccRecipients,HasAttachments,BodyPreview"

$ResultadosAuditoria = @()

foreach ($Mensaje in $MensajesEnviados) {
    # Recopilar todos los destinatarios
    $Destinatarios = @()
    $Destinatarios += $Mensaje.ToRecipients.EmailAddress.Address
    $Destinatarios += $Mensaje.CcRecipients.EmailAddress.Address
    $Destinatarios += $Mensaje.BccRecipients.EmailAddress.Address
    
    # Filtrar correos externos (fuera del dominio interno)
    $Externos = $Destinatarios | Where-Object { $_ -and ($_ -notlike "*$DominioInterno*") }

    if ($Externos.Count -gt 0) {
        $TextoAnalizar = "$($Mensaje.Subject) $($Mensaje.BodyPreview)".ToLower()
        $Coincidencias = $PalabrasClave | Where-Object { $TextoAnalizar -match $_ }

        $Riesgo = "Bajo"
        $Motivo = "Envío externo estándar"

        # Regla 1: Adjunto + Palabra clave sensible
        if ($Mensaje.HasAttachments -and $Coincidencias.Count -gt 0) {
            $Riesgo = "ALTO"
            $Motivo = "Adjunto enviado al exterior + Palabras sensibles ($($Coincidencias -join ', '))"
        }
        # Regla 2: Solo palabra clave sensible en texto
        elseif ($Coincidencias.Count -gt 0) {
            $Riesgo = "MEDIO"
            $Motivo = "Posibles datos sensibles en texto ($($Coincidencias -join ', '))"
        }
        # Regla 3: Exposición masiva de correos sin Copia Oculta (RGPD)
        elseif ($Mensaje.ToRecipients.Count -gt 3 -and $Externos.Count -gt 3) {
            $Riesgo = "MEDIO"
            $Motivo = "Múltiples destinatarios externos en 'Para' sin usar Copia Oculta (Riesgo RGPD)"
        }

        if ($Riesgo -ne "Bajo") {
            $ResultadosAuditoria += [PSCustomObject]@{
                Fecha                 = $Mensaje.SentDateTime
                NivelRiesgo           = $Riesgo
                Asunto                = $Mensaje.Subject
                DestinatariosExternos = ($Externos -join "; ")
                TieneAdjuntos         = $Mensaje.HasAttachments
                MotivoAlerta          = $Motivo
            }
        }
    }
}

# 3. Exportar evidencias a CSV
$RutaInforme = ".\Auditoria_FugaDatos_Produccion.csv"
$ResultadosAuditoria | Export-Csv -Path $RutaInforme -NoTypeInformation -Encoding UTF8

Write-Host "Auditoría finalizada. Hallazgos detectados: $($ResultadosAuditoria.Count)" -ForegroundColor Green
Write-Host "Informe guardado en: $RutaInforme" -ForegroundColor Yellow

# Mostrar tabla resumen en consola
$ResultadosAuditoria | Format-Table Fecha, NivelRiesgo, Asunto, MotivoAlerta -AutoSize