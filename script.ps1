# this is a script to make the computer more secure.
# What it does:
# 1. It tries to set the "enforce password history" to 24


# if the program doesnt have admin, it asks for it and restarts the program
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator."
    Start-Process powershell.exe -Verb RunAs -ArgumentList $MyInvocation.MyCommand.Definition
    Exit
}

[int]$successfulTasks = 0;
[int]$totalTasks = 1
# function to easily log things
function log {
    param (
        [string]$message,
        [string]$color
    )
    Write-Host $message -ForegroundColor $color
}


log "Starting script..." "white"
log "Password policy" "yellow"

$totalTasks++
try {
    net accounts /uniquepw:24;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set enforce password history to 24" "Green"
} catch {
    log "Failed to set unique password" "Red";
    $successfulTasks--;
}

# set the max password age to 60 days
$totalTasks++
try {
    net accounts /maxpwage:60;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set max password age to 60 days" "Green"
} catch {
    log "Failed to set max password age" "Red";
    $successfulTasks--;
}

# set the min password age to 1 day
$totalTasks++
try {
    net accounts /minpwage:1;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set min password age to 1 day" "Green"
} catch {
    log "Failed to set min password age" "Red";
    $successfulTasks--;
}

# set the min password length to 12
$totalTasks++
try {
    net accounts /minpwlen:12;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set min password length to 12" "Green"
} catch {
    log "Failed to set min password length" "Red";
    $successfulTasks--;
}

log "Done. $successfulTasks/$totalTasks tasks were successful" "Green"

log "Lockout policy" "Yellow"

# set the lockout duration to 30 minutes
$totalTasks++
try {
    net accounts /lockoutduration:30;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set lockout duration to 30 minutes" "Green"
} catch {
    log "Failed to set lockout duration" "Red";
    $successfulTasks--;
}

# set the lockout threshold to 10 minutes
$totalTasks++
try {
    net accounts /lockoutthreshold:10;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set lockout threshold to 10 minutes" "Green"
} catch {
    log "Failed to set lockout threshold" "Red";
    $successfulTasks--;
}

# set the reset account lockout counter to 30 minutes
$totalTasks++
try {
    net accounts /lockoutwindow:30;
    $successfulTasks++
    log "[TASK] {$successfulTasks/$totalTasks} | Set reset account lockout counter to 30 minutes" "Green"
} catch {
    log "Failed to set reset account lockout counter" "Red";
    $successfulTasks--;
}

log "Done. $successfulTasks/$totalTasks tasks were successful" "Green"

log "Use smartScreen online services" "Yellow"


$host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
