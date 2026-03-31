# Script PowerShell pour restaurer la BD PostgreSQL locale dans Docker
# Usage: .\restore_db.ps1

Write-Host "🔄 Restauration de la base de données..." -ForegroundColor Cyan

# Vérifier que docker-compose est en cours d'exécution
Write-Host "1️⃣ Vérification du conteneur PostgreSQL..." -ForegroundColor Yellow
docker compose ps db

# Créer la DB cible si elle n'existe pas
Write-Host "2️⃣ Création de la base de données cible..." -ForegroundColor Yellow
docker compose exec -T db psql -U postgres -c "CREATE DATABASE apprendiamo_db;" 2>$null
Write-Host "✅ DB créée (ou déjà existante)" -ForegroundColor Green

# Restaurer le dump
Write-Host "3️⃣ Restauration des données..." -ForegroundColor Yellow
$backupFile = "backup_local.dump"

if (Test-Path $backupFile) {
    Get-Content $backupFile | docker compose exec -T db pg_restore -U postgres -d apprendiamo_db --clean --if-exists
    Write-Host "✅ Restauration terminée" -ForegroundColor Green
} else {
    Write-Host "❌ Fichier $backupFile non trouvé !" -ForegroundColor Red
    exit 1
}

# Vérifier rapidement
Write-Host "4️⃣ Vérification des tables..." -ForegroundColor Yellow
docker compose exec -T db psql -U postgres -d apprendiamo_db -c "\dt"

Write-Host "5️⃣ Vérification du nombre d'utilisateurs..." -ForegroundColor Yellow
docker compose exec -T db psql -U postgres -d apprendiamo_db -c "SELECT COUNT(*) as total_users FROM users;" 2>$null

Write-Host "✅ Migration complète !" -ForegroundColor Green
