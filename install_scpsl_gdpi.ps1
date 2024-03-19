function DeleteLeftoverFiles
{	
	Param (
		[string]$old_folder_path
	)
	
	# Delete existing installation folder
	if (Test-Path $old_folder_path) {
		Write-Output "������� ���������� ����� GoodbyeDPI"
		[void](Remove-Item $old_folder_path -Recurse -Confirm:$False -Force)
	}
}

# Set title and advertisement

$host.ui.RawUI.WindowTitle = "Welcome To Hell SCP:SL GoodbyeDPI downloader and installer"
Write-Host "��������� � ����������� ������� GoodbyeDPI ��� ���� ������� SCP:SL �� " -ForegroundColor white -nonewline
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
$os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match �(x64)�

# Finding GoodbyeDPI folder
$gdpi_folder = "WTH_GoodbyeDPI"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_folder + "\x86_64"
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_folder + "\x86"
}

# Checking if GoodbyeDPI is already installed. Ask to uninstall. If not accepted, exit script.
Write-Output "���������, ���������� �� ������ WTH_GoodbyeDPI"

$gdpi_service_exists = Get-Service -Name "WTH_GoodbyeDPI" -ErrorAction SilentlyContinue

if ($gdpi_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('������ ������������� ����� ������ WTH_GoodbyeDPI!' + [System.Environment]::NewLine + [System.Environment]::NewLine + '�������?' , "WTH SCP:SL GoodbyeDPI" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		# Deleting existing GoodbyeDPI service
		Write-Output "������������� � ������� ������ WTH_GoodbyeDPI"
		[void](sc.exe stop "WTH_GoodbyeDPI")
		[void](sc.exe delete "WTH_GoodbyeDPI")
		DeleteLeftoverFiles -old_folder_path (Split-Path $path -Parent)
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('������ ��������� ������ WTH_GoodbyeDPI ��� ����������� �������� � ����������� � ��������-��������� ���� SCP: Secret Laboratory.' + [System.Environment]::NewLine + [System.Environment]::NewLine + '����������?' , "WTH SCP:SL GoodbyeDPI" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path (Split-Path $path -Parent) -Parent

	DeleteLeftoverFiles -old_folder_path "$path\$gdpi_folder"
	
	[void](New-Item -Path "$path\$gdpi_folder" -ItemType Directory -Confirm:$False -Force)

	# Downloading latest GoodbyeDPI to installtion folder
	Write-Output "��������� ��������� ������ GoodbyeDPI"
			
	Invoke-RestMethod 'https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest' | % assets | ? name -like "*.zip" | % { 
		Invoke-WebRequest $_.browser_download_url -OutFile ("$path\" + $_.name) 
		$gdpi_archive_name = $_.name
	}

	# Unpack downloaded archive
	Write-Output "������������� �����"
	
	Expand-Archive -Path "$path\$gdpi_archive_name" -DestinationPath $path
	$unpacked_folder = "$path\$gdpi_archive_name".TrimEnd('.zip')
	Move-Item -Path "$unpacked_folder\*" -Destination "$path\$gdpi_folder"

	# Clean leftover zip file
	if (Test-Path "$path\$gdpi_archive_name") {[void](Remove-Item "$path\$gdpi_archive_name" -Confirm:$False -Force)}

	# Download SCP:SL website list File
	Write-Output "��������� whitelist ������� SCP: Secret Laboratory"
		
	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/REALMWTH/Powershell-GDPI-Install-Script/main/scpsl_domains.txt' -Destination "$path\$gdpi_folder"

	# Install Service
	Write-Output "������������� ������ WTH_GoodbyeDPI"
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_folder + "\x86_64\goodbyedpi.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_folder + "\x86\goodbyedpi.exe"
	}

	[void](cmd.exe /c "sc create `"WTH_GoodbyeDPI`" binPath= `"$exe_path -5 --blacklist `"`"$path\$gdpi_folder\scpsl_domains.txt`"`"")
	[void](sc.exe config "WTH_GoodbyeDPI" start= auto)
	[void](sc.exe description "GoodbyeDPI" "Passive Deep Packet Inspection blocker and Active DPI circumvention utility. Affects SCP:SL Domains only.")
	
	Write-Output "��������� ������ WTH_GoodbyeDPI"
	[void](sc.exe start "WTH_GoodbyeDPI")
	
	$result = [System.Windows.Forms.MessageBox]::Show('������ ������� ��������� ������ WTH_GoodbyeDPI.' + [System.Environment]::NewLine + [System.Environment]::NewLine + "��������� ����������������� ������ �������� SCP:SL.", "WTH SCP:SL GoodbyeDPI" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}