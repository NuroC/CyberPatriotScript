Import-Module .\src\secpol\Get-Secpol.psm1
Import-Module .\src\secpol\Set-Secpol.psm1

Import-Module .\src\modules\log.psm1

# SECPOL (System Access)
$SecPool = Get-Secpol "C:\Windows\Temp\SecPool.cfg"

$SystemAccessSecPolConfig = Get-Content -Path '.\lib\secpol\System Access.json' | ConvertFrom-Json

$SystemAccessSecPolConfig.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $value = $_.Value

    $SecPool.'System Access'.$name = $value
}



$SecPool."Event Audit".AuditSystemEvents = 3

Set-SecPol -Object $SecPool -CfgFile "C:\Windows\Temp\SecPool.cfg"
# delete the file
Remove-Item -Path "C:\Windows\Temp\SecPool.cfg"
