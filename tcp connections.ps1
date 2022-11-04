## View TCP Conections and associated Process
netstat -ano | Where-Object{$_ -match 'LISTENING|TCP'} | ForEach-Object{
    $split = $_.Trim() -split "\s+"
    New-Object -Type pscustomobject -Property @{
        "Proto" = $split[0]
        "Local Address" = $split[1]
        "Foreign Address" = $split[2]
        # Some might not have a state. Check to see if the last element is a number. If it is ignore it
        "State" = if($split[3] -notmatch "\d+"){$split[3]}else{""}
        # The last element in every case will be a PID
        "Process Name" = $(Get-Process -Id $split[-1]).ProcessName
    }
} | Select "Proto", "Local Address", "Foreign Address", "State", "Process Name" 


#make sure the program keeps running
$host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")

