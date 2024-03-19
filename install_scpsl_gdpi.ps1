# Set title and advertisement

$host.ui.RawUI.WindowTitle = "Welcome To Hell SCP:SL GDPI downloader and installer"
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

# Finding program files folder
$gdpi_folder = "WTH_GoodbyeDPI"
if ($os_type -eq "True") {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_folder
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_folder
}

Write-Output "Path: " + $path

# Checking if GoodbyeDPI is already installed.

Write-Output "���������, �������� �� ������������� ������� �� ����"

if ((CheckIfNtpClientIsRunning) -eq $False)
{
	$result = [System.Windows.Forms.MessageBox]::Show('�� �������� ������������� ������� ����� ��������.' + [System.Environment]::NewLine + '��� ����� ���������� ���������� SSL ���������� � ����������� �������� SCP:SL.' + [System.Environment]::NewLine + [System.Environment]::NewLine + '�������� ������������� ������� ����� ��������?' , "������������� �������" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		RestartNtpClient -setNtpServer $False
	}
}

Write-Output "���������, �������� �� ���������� � ������� NTP ��������"

if ((CheckCurrentNtpServer) -eq $False)
{
	$result = [System.Windows.Forms.MessageBox]::Show('������������� �������, ����������� ��� ��������� SSL ���������� � ����������� �������� SCP:SL, � ������������� NTP ��������, ����������! ������ �� �������� �� �������.' + [System.Environment]::NewLine + '�������� NTP ������ �� ru.pool.ntp.org?' , "������������� �������" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		RestartNtpClient -setNtpServer $True
	}
}

Write-Output "���������, ��������� �� NTP ������ ru.pool.ntp.org"

$ntp_server = (w32tm /query /source) -Split ","
$ntp_server = $ntp_server[0].Trim(" ")
if (-Not($ntp_server -Match 'ru.pool.ntp.org'))
{
	$result = [System.Windows.Forms.MessageBox]::Show('������������� �������� NTP ������ �� ru.pool.ntp.org' + [System.Environment]::NewLine + '��������� ������ NTP ������?' , "������������� �������" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		SetNtpServer
	}
}

# Checking if DNS servers are 1.1.1.1 and 1.0.0.1 for active network adapter with internet connection

Write-Output "���������, ����������� �� ��������������� DNS ������� �� ���������� ������� ����������, ������������� � ���������"

$PhysAdapter = Get-NetAdapter -Physical
$DnsAddress = $PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4
$PrimaryDNS = '1.1.1.1'
$SecondaryDNS = '1.0.0.1'

if (-Not($DnsAddress.ServerAddresses[0] -eq $PrimaryDNS -and $DnsAddress.ServerAddresses[1] -eq $SecondaryDNS))
{
	$result = [System.Windows.Forms.MessageBox]::Show('������������� ���������� Cloudflare DNS ������� ��� �������� �������� ����������. ����������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		$PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
		Clear-DnsClientCache
	}
}

# Checking if internet connection to download websites is working

Write-Output "��������� ����������� ���������� ���������� � ������� ��� ����������� ���������� ������������ SCP:SL"

$ProgressPreference = 'SilentlyContinue'

try {
    [void](Invoke-WebRequest -URI "https://download.microsoft.com" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('���������� ���������� ���������� � ������ download.microsoft.com' + [System.Environment]::NewLine + [System.Environment]::NewLine + '��������� ���� ��������-����������.' , "������" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

try {
    [void](Invoke-WebRequest -URI "https://download.mono-project.com" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('���������� ���������� ���������� � ������ download.mono-project.com' + [System.Environment]::NewLine + [System.Environment]::NewLine + '��������� ���� ��������-����������.' , "������" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

try {
    [void](Invoke-WebRequest -URI "https://dot.net" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('���������� ���������� ���������� � ������ dot.net' + [System.Environment]::NewLine + [System.Environment]::NewLine + '��������� ���� ��������-����������.' , "������" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

$ProgressPreference = 'Continue'

Write-Output "������������� ��������� ������� NuGet"
[void](Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue -ForceBootstrap)

Write-Output "��������� �������� ��������� ��� PSGallery"
$policy = Get-PSRepository -Name PSGallery

if ($policy)
{
	if (-Not($policy.InstallationPolicy -eq 'Trusted'))
	{
		Write-Output "���������� ���������� �������� ��������� ��� PSGallery"
		[void](Set-PSRepository PSGallery -InstallationPolicy Trusted)
	}
	else
	{
		Write-Output "�������� ��������� ��� PSGallery ��� ���� ����������� ��� ����������"
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('���������� Microsoft Visual C++ Redistributable?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Write-Output "������������� Powershell ������ VcRedist"
	[void](Install-Module -Name VcRedist -Confirm:$False -Force)

	Write-Output "������� ��� ������ Microsoft Visual C++ Redistributable"
	[void](Uninstall-VcRedist -Confirm:$False)

	$temp_dir = "C:\WTH_Temp"
	if (test-path $temp_dir) {[void](Remove-Item $temp_dir -Recurse -Confirm:$False -Force)}
	[void](New-Item -Path 'C:\WTH_Temp' -ItemType Directory -Confirm:$False -Force)

	Write-Output "DirectX Redist (June 2010)"
	$directx = "$temp_dir\directx_Jun2010_redist.exe"
	Start-BitsTransfer -Source 'https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe' -Destination $directx
	cmd /c start /wait $directx /Q /C /T:"$temp_dir\DirectX\"
	cmd /c start /wait "$temp_dir\DirectX\DXSETUP.exe" /silent
	del $directx
	if (test-path $temp_dir) {[void](Remove-Item $temp_dir\DirectX -Recurse -Confirm:$False -Force)}

	Write-Output "Microsoft Visual C++ 2005-2022"
	$Redists_unsupported = Get-VcList -Export Unsupported | Where-Object { $_.Release -in "2005", "2008", "2010" } | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force
	$Redists = Get-VcList -Release 2012, 2013, 2022 | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force

	Remove-Module -Name VcRedist
	Uninstall-Module -Name VcRedist -AllVersions -Force
}

if (-Not(Test-Path -Path $env:ProgramFiles\Mono\bin\mono.exe -PathType Leaf))
{
	$result = [System.Windows.Forms.MessageBox]::Show('���������� Mono?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		Write-Output "Mono Stable"
		$MonoPathx86 = "$temp_dir\mono-latest-x86-stable.msi"
		$MonoPathx64 = "$temp_dir\mono-latest-x64-stable.msi"
		Start-BitsTransfer -Source 'https://download.mono-project.com/archive/mono-latest-x86-stable.msi' -Destination $MonoPathx86
		Start-BitsTransfer -Source 'https://download.mono-project.com/archive/mono-latest-x64-stable.msi' -Destination $MonoPathx64
		cmd /c start /wait msiexec /i "$MonoPathx86" /q
		del $MonoPathx86
		cmd /c start /wait msiexec /i "$MonoPathx64" /q
		del $MonoPathx64
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('������������� ���������� �������������� �����������. ����������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Write-Output ".NET Framework 3.5 � ������� ���������� 1 (SP1)"
	[void](Dism /online /Enable-Feature /FeatureName:"NetFx3" /quiet) 
	Write-Output "DirectPlay"
	[void](dism /online /Enable-Feature /FeatureName:DirectPlay /All /quiet)
	
	$dotnetscript = "$temp_dir\dotnet-install.ps1"
	Start-BitsTransfer -Source 'https://dot.net/v1/dotnet-install.ps1' -Destination $dotnetscript
	Write-Output ".NET Runtime 6"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 6.0 -Runtime windowsdesktop) 
	Write-Output ".NET Runtime 7"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 7.0 -Runtime windowsdesktop) 
	Write-Output ".NET Runtime 8"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop) 
	
	del $dotnetscript
}

[void](Remove-Item $temp_dir -Recurse -Force -Confirm:$False)

$result = [System.Windows.Forms.MessageBox]::Show('������������� ������������. �������������?' , "��� ����������� ������� �����������!" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Restart-computer -Force -Confirm:$False
}