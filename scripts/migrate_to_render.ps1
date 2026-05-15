Param(
  [Parameter(Mandatory = $true)]
  [string]$LocalUrl,

  [Parameter(Mandatory = $true)]
  [string]$RenderUrl
)

$ErrorActionPreference = "Stop"

function Assert-Tool {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Write-Error "L'outil '$Name' est introuvable. Installez les clients PostgreSQL (pg_dump/pg_restore/psql)."
  }
}

function Validate-Url {
  param([string]$Url, [string]$Label)
  if ([string]::IsNullOrWhiteSpace($Url)) {
    Write-Error "$Label est vide. Fournissez une URL valide (postgres:// ou postgresql://)."
  }
  if ($Url -notmatch '^postgres(ql)?://') {
    Write-Error "$Label doit commencer par 'postgres://' ou 'postgresql://'. Valeur actuelle: $Url"
  }
}

function Mask-Url {
  param([string]$Url)
  # Masque le mot de passe dans l'URL pour l'affichage
  return ($Url -replace '://([^:@/]+):([^@]+)@', '://$1:***@')
}

Assert-Tool -Name "pg_dump"
Assert-Tool -Name "pg_restore"
Assert-Tool -Name "psql"

Validate-Url -Url $LocalUrl  -Label "LocalUrl"
Validate-Url -Url $RenderUrl -Label "RenderUrl"

# Ajoute sslmode=require si absent (utile pour Render)
if ($RenderUrl -notmatch "sslmode=") {
  if ($RenderUrl -match "\?") {
    $RenderUrl = "$RenderUrl&sslmode=require"
  } else {
    $RenderUrl = "$RenderUrl?sslmode=require"
  }
}

# Dossier des artefacts
$OutDir = Join-Path -Path (Get-Location) -ChildPath "db_backups"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$dumpPath = Join-Path $OutDir "backup_full_$ts.dump"

Write-Host "Local URL   : $(Mask-Url $LocalUrl)"
Write-Host "Render URL  : $(Mask-Url $RenderUrl)"

Write-Host "==> Export local (format custom) ..."
pg_dump `
  --format=custom --blobs `
  --no-owner --no-privileges `
  --dbname="$LocalUrl" `
  --file="$dumpPath"

Write-Host "==> Test de connexion Render ..."
psql "$RenderUrl" -c "SELECT current_database(), current_user;" | Out-Host

Write-Host "==> Restauration vers Render (clean/if-exists) ..."
pg_restore `
  --clean --if-exists `
  --no-owner --no-privileges `
  --dbname="$RenderUrl" `
  "$dumpPath"

Write-Host "==> Vérifications rapides ..."
psql "$RenderUrl" -c "\dt"        | Out-Host
psql "$RenderUrl" -c "SELECT count(*) AS cards FROM cards;" | Out-Host
psql "$RenderUrl" -c "SELECT count(*) AS decks FROM decks;" | Out-Host

Write-Host ""
Write-Host "✅ Migration terminée."
Write-Host "Dump sauvegardé: $dumpPath"
