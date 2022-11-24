# SECPOL
Import-Module .\src\secpol\Get-Secpol
Import-Module .\src\secpol\Set-Secpol

$SystemAccessSecPolConfig = Get-Content -Path '.\lib\secpol\System Access.json' | ConvertFrom-Json
$EventAuditSecPolConfig = Get-Content -Path '.\lib\secpol\Event Audit.json' | ConvertFrom-Json

# basic modules
Import-Module .\src\modules\log

# firewall modules
Import-Module '.\src\Firewalls\Firewall Rules.psm1'
Import-Module '.\src\Firewalls\firewall.psm1'

#Tasks
Import-Module .\src\tasks\tasks.psm1

# unsecure services
Import-Module .\src\services\services.psm1

# SSH
Import-Module .\src\SSH\sshconf.psm1
# SECPOL (System Access)
$SecPool = Get-Secpol "C:\Windows\Temp\SecPool.cfg"


$SystemAccessSecPolConfig.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $value = $_.Value

    $SecPool.'System Access'.$name = $value
}

$EventAuditSecPolConfig.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $value = $_.Value

    $SecPool.'Event Audit'.$name = $value
}

Set-SecPol -Object $SecPool -CfgFile "C:\Windows\Temp\SecPool.cfg"

set-FirewallRule;
set-Firewall;

disableTasks;

disableUnsecureServices;

setSSHconfig;