@echo off
:: ai workspace 초기 설정 (Windows 실행기)
:: PowerShell 스크립트를 실행합니다
powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1" %*
