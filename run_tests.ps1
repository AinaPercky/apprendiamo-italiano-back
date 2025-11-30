# Script PowerShell pour démarrer le serveur et lancer les tests
# run_tests.ps1

Write-Host "╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                           ║" -ForegroundColor Cyan
Write-Host "║           DÉMARRAGE DU SERVEUR ET TESTS - APPRENDIAMO ITALIANO            ║" -ForegroundColor Cyan
Write-Host "║                                                                           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le serveur est déjà en cours d'exécution
Write-Host "🔍 Vérification du serveur..." -ForegroundColor Yellow
$serverRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/" -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        $serverRunning = $true
        Write-Host "✅ Le serveur est déjà en cours d'exécution" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Le serveur n'est pas en cours d'exécution" -ForegroundColor Yellow
}

# Démarrer le serveur si nécessaire
if (-not $serverRunning) {
    Write-Host "🚀 Démarrage du serveur..." -ForegroundColor Yellow
    $serverJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        uvicorn app.main:app --reload
    }
    
    Write-Host "⏳ Attente du démarrage du serveur (10 secondes)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Vérifier que le serveur a bien démarré
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Serveur démarré avec succès" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Impossible de démarrer le serveur" -ForegroundColor Red
        Stop-Job -Job $serverJob
        Remove-Job -Job $serverJob
        exit 1
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                         EXÉCUTION DES TESTS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Lancer les tests
python test_comprehensive_api.py

# Si nous avons démarré le serveur, l'arrêter
if (-not $serverRunning -and $serverJob) {
    Write-Host ""
    Write-Host "🛑 Arrêt du serveur..." -ForegroundColor Yellow
    Stop-Job -Job $serverJob
    Remove-Job -Job $serverJob
    Write-Host "✅ Serveur arrêté" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                              TERMINÉ" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
