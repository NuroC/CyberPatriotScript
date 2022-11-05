[int]$executedCommands = 0;

# if the program doesnt have admin, it asks for it and restarts the program
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList $MyInvocation.MyCommand.Definition
    Exit
}

# log function
function log {
    param ( [string]$message, [string]$color )
    Write-Host $message -ForegroundColor $color
}

function disableFirewallFeature {
    param ( [string]$ruleName )
    netsh advfirewall firewall set rule name=$ruleName new enable=no | Out-Null
}

function blockNetFirewallRule {
    param (
        [string]$DisplayName,
        [int]$LocalPort
    )
    New-NetFirewallRule -DisplayName $DisplayName -Direction Inbound -Action Block -LocalPort $LocalPort -Protocol TCP | Out-Null
}

function readFile {
    param ( [string]$path )
    $file = Get-Content $path
    return $file
}

function disableFeature {
    param ( [string]$featureName )
    dism /online /disable-feature /featurename:$featureName /norestart | Out-Null
}

function disableService {
    param ( [string]$serviceName )
    Set-Service -Name $serviceName  -Status Stopped -StartupType Disabled -erroraction 'silentlycontinue' | Out-Null
}

function enableService {
    param ( [string]$serviceName )
    Set-Service -Name $serviceName  -Status Running -StartupType Automatic -erroraction 'silentlycontinue' | Out-Null
}


# local audit policies (https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/audit-policy)
[array]$policies = @( "Account Logon", "Account Management", "DS Access", "Logon/Logoff", "Object Access", "Policy Change", "Privilege Use", "Detailed Tracking", "System")
# firewall rules (https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/netsh-advfirewall-firewall-control-firewall-behavior)
[array]$firewallRules = @("Remote Assistance (DCOM-In)", "Remote Assistance (PNRP-In)", "Remote Assistance (RA Server TCP-In)", "Remote Assistance (SSDP TCP-In)", "Remote Assistance (SSDP UDP-In)", "Remote Assistance (TCP-In)")
# dusable netFirewall Rules (https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=windowsserver2022-ps)
[array]$netFirewallRules = @("sshTCP:22", "ftpTCP:21", "telnetTCP:23", "SMTPTCP:25", "POP3TCP:110", "SNMPTCP:161", "RDPTCP:3389", "OpenSSH:22")
[array]$disableFeatures = @('IIS-WebServerRole', 'IIS-WebServer', 'IIS-CommonHttpFeatures', 'IIS-HttpErrors', 'IIS-HttpRedirect', 'IIS-ApplicationDevelopment', 'IIS-NetFxExtensibility', 'IIS-NetFxExtensibility45', 'IIS-HealthAndDiagnostics', 'IIS-HttpLogging', 'IIS-LoggingLibraries', 'IIS-RequestMonitor', 'IIS-HttpTracing', 'IIS-Security', 'IIS-URLAuthorization', 'IIS-RequestFiltering', 'IIS-IPsecurity', 'IIS-Performance', 'IIS-HttpCompressionDynamic', 'IIS-WebServerManagementTools', 'IIS-ManagementScriptingTools', 'IIS-IIS6ManagementCompatibility', 'IIS-Metabase', 'IIS-HostableWebCore', 'IIS-StaticContent', 'IIS-DefaultDocument', 'IIS-DirectoryBrowsing', 'IIS-WebDAV', 'IIS-WebSockets', 'IIS-ApplicationInit', 'IIS-ASPNET', 'IIS-ASPNET45', 'IIS-ASP', 'IIS-CGI', 'IIS-ISAPIExtensions', 'IIS-ISAPIFilter', 'IIS-ServerSideIncludes', 'IIS-CustomLogging', 'IIS-BasicAuthentication', 'IIS-HttpCompressionStatic', 'IIS-ManagementConsole', 'IIS-ManagementService', 'IIS-WMICompatibility', 'IIS-LegacyScripts', 'IIS-LegacySnapIn', 'IIS-FTPServer', 'IIS-FTPSvc', 'IIS-FTPExtensibility', 'TelnetClient', 'TelnetServer', "SMB1Protocol")
[array]$servicesToDisable = @('bthserv', 'Browser', 'MapsBroker', 'Fax', 'lfsvc', 'irmon', 'SharedAccess', 'lltdsvc', 'MSiSCSI', 'p2pimsvc', 'p2psvc', 'PNRPsvc', 'PhoneSvc', 'PlugPlay', 'PNRPAutoReg', 'wercplsupport', 'RasAuto', 'SessionEnv', 'TermService', 'UmRdpService', 'vmicrdv', 'RpcLocator', 'RemoteRegistry', 'RemoteAccess', 'SNMPTRAP', 'SSDPSRV', 'upnphost', 'WerSvc', 'WMPNetworkSvc', 'icssvc', 'WpnService', 'WinRM', 'WpnUserService_2275c', 'xbgm', 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc')
[array]$servicesToEnable = @('msiserver','RpcSs', 'gpsvc', 'BFE', 'SamSs', 'RpcEptMapper', 'DcomLaunch', 'BDESVC', 'CryptSvc', 'WEPHOSTSVC', 'Dhcp', 'nsi', 'Dnscache', 'Group', 'Power', 'Sense', 'WdNisSvc', 'WinDefend', 'SecurityHealthService', 'MpsSvc', 'wuauserv', 'LanmanServer', 'EventLog', 'Wecsvc')

# enable Services
for ($i = 0; $i -lt $servicesToEnable.Length; $i++) {
    enableService $servicesToEnable[$i] | Out-Null
    $executedCommands++
    $progress = [math]::Round((($i + 1) / $servicesToEnable.Length) * 100)
    Write-Progress -Activity "Enabling features" -Status "Enabling $($servicesToEnable[$i])" -PercentComplete $progress
}

log "Enabled $($servicesToEnable.Length) services" "Green"

For ($i = 0; $i -lt $policies.Length; $i++) {
    auditpol /set /category:$($policies[$i]) /success:enable /failure:enable | Out-Null
    $executedCommands++
}

log "Sucessfully set audit policies" "Green"

net accounts /UNIQUEPW:24 /MAXPWAGE:60 /MINPWAGE:1 /MINPWLEN:12 /lockoutthreshold:5
$executedCommands++

log "Sucessfully set local account policies" "Green"

# disable guest and administrator account
Get-LocalUser Guest | Disable-LocalUser
Get-LocalUser Administrator | Disable-LocalUser
$executedCommands += 2;

log "Sucessfully disabled guest and administrator account" "Green"

ipconfig /flushdns
$executedCommands++
log "Sucessfully flushed DNS" "Green"

# settingsd that apply to the per-profile configurations on the windows Firewall with Advanced Security
# https://learn.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallprofile?view=windowsserver2022-ps
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True | Out-Null
Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log | Out-Null
$executedCommands += 2

log "Sucessfully set firewall profile settings" "Green"

# disable firewall features

for ($i = 0; $i -lt $firewallRules.Length; $i++) {
    disableFirewallFeature ($firewallRules[$i]) | Out-Null
    $executedCommands++

    $progress = [math]::Round((($i + 1) / $firewallRules.Length) * 100, 0)
    Write-Progress -Activity "Disabling firewall rules" -Status "Disabling $($firewallRules[$i])" -PercentComplete $progress
}

log "Sucessfully disabled firewall rules" "Green"

netsh advfirewall firewall set rule group="Network Discovery" new enable=No | Out-Null
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No | Out-Null

netsh advfirewall firewall add rule name="block_RemoteRegistry_in" dir=in service="RemoteRegistry" action=block enable=yes | Out-Null
netsh advfirewall firewall add rule name="block_RemoteRegistry_out" dir=out service="RemoteRegistry" action=block enable=yes | Out-Null

log "Sucessfully disabled network discovery and file and printer sharing" "Green"

# disable services

for ($i = 0; $i -lt $servicesToDisable.Length; $i++) {
    disableService $servicesToDisable[$i] | Out-Null
    $executedCommands++
    $progress = [math]::Round((($i + 1) / $servicesToDisable.Length) * 100)
    Write-Progress -Activity "Disabling features" -Status "Disabling $($servicesToDisable[$i])" -PercentComplete $progress
}

log "Sucessfully disabled $($servicesToDisable.Length) services" "Green"

# block netFirewall rules
Set-Service -Name sshd -StartupType Automatic -Status Running -ErrorAction SilentlyContinue | Out-Null


New-NetFireWallRule -DisplayName "OpenSSH" -Protocol TCP -LocalPort 22 -Action Allow -Enabled True -Direction Inbound | Out-Null
New-NetFireWallRule -DisplayName "OpenSSH" -Protocol TCP -LocalPort 22 -Action Allow -Enabled True -Direction Outbound | Out-Null
$executedCommands += 4

log "Sucessfully set OpenSSH firewall rules" "Green"

# set the windows defender firewall to block all incoming connections
for ($i = 0; $i -lt $netFirewallRules.Length; $i++) {
    $rule = $netFirewallRules[$i] -split ":"
    blockNetFirewallRule $rule[0] $rule[1]
    $executedCommands++
    $progress = [math]::Round((($i + 1) / $netFirewallRules.Length) * 100)
    Write-Progress -Activity "Blocking netFirewall rules" -Status "Blocking $($netFirewallRules[$i])" -PercentComplete $progress
}
#Block multiple insecure protocols by pre-existing rules
Set-NetFirewallRule -DisplayName "*IPv6*","*ICMP*","*SMB*","*UPnP*","*FTP*","*Telnet*" -Action Block -Enabled True -Profile Any
$executedCommands += 1


log "Sucessfully blocked netFirewall rules" "Green"

# disable features
for ($i = 0; $i -lt $disableFeatures.Length; $i++) {
    disableFeature $disableFeatures[$i] | Out-Null
    $executedCommands++
    $progress = [math]::Round((($i + 1) / $disableFeatures.Length) * 100)
    Write-Progress -Activity "Disabling features" -Status "Disabling $($disableFeatures[$i])" -PercentComplete $progress
}

log "Sucessfully disabled bad / unneeded features" "Green"

Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
$executedCommands++
log "Sucessfully disabled SMB1" "Green"



log "done. executed $executedCommands commands" "green"


# make sure the program keeps running
$host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")

