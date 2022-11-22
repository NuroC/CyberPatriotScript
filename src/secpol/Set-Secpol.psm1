Function Set-SecPol($Object, $CfgFile){
    $SecPool.psobject.Properties.GetEnumerator() | ForEach-Object{
         "[$($_.Name)]"
         $_.Value | ForEach-Object{
             $_.psobject.Properties.GetEnumerator() | ForEach-Object{
                 "$($_.Name)=$($_.Value)"
             }
         }
     } | out-file $CfgFile -ErrorAction Stop
     secedit /configure /db c:\windows\security\local.sdb /cfg "$CfgFile" /areas SECURITYPOLICY
 }

 Export-ModuleMember -Function Set-SecPol