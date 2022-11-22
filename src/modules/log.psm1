Function log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    Write-Host $message
}

Export-ModuleMember -Function log