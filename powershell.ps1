function Print-Title {
    echo "<h2 style='font-weight:normal;'>$args</h2>"
}
function Uloha-Operaky {
    Print-Title "názov stroja: <b>$($env:COMPUTERNAME)</b>"
    Print-Title "velkost pamate <b>$((Get-WMIObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum) b</b>"

    Print-Title "mac adresy:"
    Get-NetAdapter -Physical | select MacAddress, Name | ConvertTo-Html -Fragment

    Print-Title "ip adresy:"
    Get-NetIPAddress -AddressFamily IPv4 | select IPAddress, InterfaceAlias | ConvertTo-Html -Fragment

    Print-Title "pocet diskov: <b>$((Get-PhysicalDisk | Measure-Object).Count)</b>"

    Print-Title "logicke jednotky:"
    Get-WmiObject Win32_LogicalDisk | select DeviceId, Size | ConvertTo-Html -Fragment

    Print-Title "uzivatel login: <b>$env:USERNAME</b>"

    Print-Title "uzivatel cele meno <b>$((Get-WmiObject Win32_UserAccount -filter "name = '$env:USERNAME'").FullName)</b>"

    Print-Title "domovsky adresar <b>$env:USERPROFILE</b>"

    Print-Title "velkost domovskeho priecinku: <b>$((Get-ChildItem $env:USERPROFILE -File -Recurse | Measure-Object -property length -Sum).Sum) b</b>"

    # pre rychlost je zvoleny len domovsky adresar
    Print-Title "velkost vlastnych suborov v domovskom priecinku <b>$((Get-ChildItem $env:USERPROFILE -File -Recurse | where {(Get-Acl $_.FullName).Owner -eq "$env:USERDOMAIN\$env:USERNAME"} | Measure-Object -Property Length -Sum).Sum) b</b>"
    
    Print-Title "statisticke rozdelenie suborov v domovskom priecinku" 
    Get-ChildItem $env:USERPROFILE -File -Recurse | group Extension | select Name, Count | ConvertTo-Html -Fragment
}
ConvertTo-Html -Title "moj vystup" -Head "<style>table, table tr, table td { border-collapse: collapse; border: 1px solid black; padding: 3px; }</style>" -Body "$(Uloha-Operaky)" > vystup.html
Invoke-Item vystup.html
