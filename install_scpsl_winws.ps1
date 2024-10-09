function DeleteLeftoverFiles
{	
	Param (
		[string]$old_folder_path
	)
	
	# Delete existing installation folder
	if (Test-Path $old_folder_path) {
		Write-Output "Удаляем устаревшие файлы Winws"
		[void](Remove-Item $old_folder_path -Recurse -Confirm:$False -Force)
	}
}

# Set title and advertisement
$host.ui.RawUI.WindowTitle = "Welcome To Hell SCP:SL Winws downloader and installer"
Write-Host "Загрузчик и инсталлятор сервиса Winws для всех доменов SCP:SL, Discord и YouTube от " -ForegroundColor white -nonewline
Write-Host "Welcome To Hell" -ForegroundColor red
Write-Host "https://discord.scpsl.ru" -ForegroundColor white -BackgroundColor darkred
Write-Host ""

# Disable warnings and errors output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

# Do not prompt for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

# Determining Windows architecture
$os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’

$result = [System.Windows.Forms.MessageBox]::Show('Внимание!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Убедитесь, что у вас выключен VPN, GoodbyeDPI или Proxy. Этот обход конфликтует с VPN, Proxy и GoodbyeDPI.", "WTH SCP:SL Winws" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "Проверяем, установлен ли GoodbyeDPI"
$goodbyedpi = Get-Process goodbyedpi

if ($goodbyedpi) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден работающий GoodbyeDPI!' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Вам необходимо удалить, либо временно выключить GoodbyeDPI так как он конфликтует с Winws. Сейчас он будет принудительно выключен.", "WTH SCP:SL Winws" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	[void]($goodbyedpi | Stop-Process -Force)
}

# Finding Winws folder
$winws_folder = "WTH_Winws"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder
}

# Checking if Winws is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "Проверяем, установлен ли сервис WTH Winws"

$winws_service_exists = Get-Service -Name "WTH Winws" -ErrorAction SilentlyContinue

if ($winws_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('Найден установленный ранее сервис WTH Winws!' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Удалить?' , "WTH SCP:SL Winws" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing Winws service
		Write-Output "Останавливаем и удаляем сервис WTH Winws"
		[void](sc.exe stop "WTH Winws")
		[void](sc.exe delete "WTH Winws")
		DeleteLeftoverFiles -old_folder_path "$path"
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('Скрипт установит сервис WTH Winws для исправления проблемы с соединением с интернет-ресурсами игры SCP: Secret Laboratory, а также восстановит работоспособность Discord и YouTube.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Установить?' , "WTH SCP:SL Winws" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path $path -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$winws_folder"
	
	[void](New-Item -Path "$path\$winws_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest Winws to installtion folder
	Write-Output "Скачиваем последнюю версию Winws"
	
	Invoke-WebRequest -Uri "https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip" -OutFile "$path\zapret-win-bundle-master.zip"
	
	$winws_archive_name = "zapret-win-bundle-master.zip"

	# Unpack downloaded archive
	Write-Output "Распаковываем архив"
	
	Expand-Archive -Path "$path\$winws_archive_name" -DestinationPath $path
	$unpacked_folder = "$path\$winws_archive_name".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\zapret-winws\*" -Destination "$path\$winws_folder" -Force -Confirm:$False)
	
	# Delete leftovers
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$winws_archive_name") {[void](Remove-Item "$path\$winws_archive_name" -Confirm:$False -Force)}
	
	# Download SCP:SL, Discord and YouTube domains list File
	Write-Output "Скачиваем whitelist доменов SCP: Secret Laboratory, Discord и YouTube"
		
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/REALMWTH/Powershell-GDPI-Install-Script/refs/heads/main/list-general.txt' -Destination "$path\$winws_folder"
		
	# Install Service
	Write-Output "Устанавливаем сервис WTH Winws"
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $winws_folder + "\winws.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $winws_folder + "\winws.exe"
	}
	
	$binaryPathName = "$exe_path --wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443 --hostlist=`"$path\$winws_folder\list-general.txt`" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic=`"$path\$winws_folder\quic_initial_www_google_com.bin`" --new --filter-tcp=80 --hostlist=`"$path\$winws_folder\list-general.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=`"$path\$winws_folder\list-general.txt`" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls=`"$path\$winws_folder\tls_clienthello_www_google_com.bin`""
	[void](New-Service -Name "WTH Winws" -BinaryPathName $binaryPathName -StartupType Automatic -Description "Обход DPI by Welcome To Hell")
	
	Write-Output "Запускаем сервис WTH Winws"
	[void](Start-Service -Name "WTH Winws")
	
	$result = [System.Windows.Forms.MessageBox]::Show('Скрипт успешно установил сервис WTH Winws.' + [System.Environment]::NewLine + [System.Environment]::NewLine + "Проверьте соединение с Discord, YouTube и список серверов SCP:SL.", "WTH SCP:SL Winws" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}