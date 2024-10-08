@echo off
echo.
FSUTIL DIRTY query %SystemDrive% >NUL || (
	echo Запрашиваем права администратора.
    PowerShell "Start-Process -FilePath cmd.exe -Args '/C CHDIR /D %CD% & "%0"' -Verb RunAs"
    EXIT
)	
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Запустите файл от имени администратора.
	echo.
	pause
	exit
)
Powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/REALMWTH/Powershell-GDPI-Install-Script/refs/heads/main/install_scpsl_winws.ps1'))"