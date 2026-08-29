@echo off
title Lost Phone - Demarrage SideTap + Tunnel
echo ============================================
echo  LOST PHONE - Rituel de demarrage
echo  Prerequis : iPhone branche USB, deverrouille,
echo  app WebDriverAgent ouverte une fois.
echo ============================================
set "PYTHONUTF8=1"

echo [1/2] Demarrage du harness SideTap...
start "SideTap harness" cmd /k ""%LOCALAPPDATA%\SideTap\app\phone-harness.cmd" up"

echo    Attente 25 s que le harness soit pret...
timeout /t 25 /nobreak >nul

echo [2/2] Ouverture du tunnel cloudflared...
echo    L'URL https://xxxx.trycloudflare.com va s'afficher ci-dessous :
echo    ============================================
"%USERPROFILE%\cloudflared.exe" tunnel --url http://127.0.0.1:8100
