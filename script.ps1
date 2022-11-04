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
# local audit policies (https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/audit-policy)
[array]$policies = @(
    "Account Logon",
    "Account Management",
    "DS Access",
    "Logon/Logoff",
    "Object Access",
    "Policy Change",
    "Privilege Use",
    "Detailed Tracking",
    "System"
)

# firewall rules (https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/netsh-advfirewall-firewall-control-firewall-behavior)
[array]$firewallRules = @(
    "Remote Assistance (DCOM-In)",
    "Remote Assistance (PNRP-In)",
    "Remote Assistance (RA Server TCP-In)",
    "Remote Assistance (SSDP TCP-In)",
    "Remote Assistance (SSDP UDP-In)",
    "Remote Assistance (TCP-In)"
)

# dusable netFirewall Rules (https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=windowsserver2022-ps)
[array]$netFirewallRules = @(
    "sshTCP:22",
    "ftpTCP:21",
    "telnetTCP:23",
    "SMTPTCP:25",
    "POP3TCP:110",
    "SNMPTCP:161",
    "RDPTCP:3389"
)

log "local policies" "yellow"

For ($i = 0; $i -lt $policies.Length; $i++) {
    auditpol /set /category:$($policies[$i]) /success:enable /failure:enable | Out-Null
    $executedCommands++
}

log "Account Policies / Password Policies" "yellow"

net accounts /UNIQUEPW:24 /MAXPWAGE:60 /MINPWAGE:1 /MINPWLEN:12 /lockoutthreshold:5 | Out-Null
$executedCommands++

log "Guest Account" "yellow"

# disable guest account
Get-LocalUser Guest | Disable-LocalUser | Out-Null
$executedCommands++

log "Flush DNS" "yellow"; # Prevents phishing attacks, DNS poisoning, and other DNS-based attacks.

ipconfig /flushdns | Out-Null
$executedCommands++

log "Firewall features" "yellow"

# settings that apply to the per-profile configurations on the windows Firewall with Advanced Security
# https://learn.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallprofile?view=windowsserver2022-ps
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow -NotifyOnListen True -AllowUnicastResponseToMulticast True -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log
$executedCommands += 2

# disable firewall features
foreach ($fireWall in $firewallRules) {
    disableFirewallFeature $fireWall
    $executedCommands++
}

log "Firewall rules" "yellow"

# block netFirewall rules
foreach ($netFirewallRule in $netFirewallRules) {
    $rule = $netFirewallRule -split ":"
    blockNetFirewallRule $rule[0] $rule[1]
    $executedCommands++
}


log "done. executed $executedCommands commands" "green"

# make sure the program keeps running
$host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")

