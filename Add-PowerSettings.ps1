$powerSchemeName = "answersIT High Performance"
$powerSchemeDesc = "Recommended power values for when your computer is plugged into a power outlet."
$monitorTimeoutAC = $null
$monitorTimeoutDC = $null
$diskTimeoutAC = 0
$diskTimeoutDC = $null
$standbyTimeoutAC = 0
$standbyTimeoutDC = $null
$hibernateTimeoutAC = 0
$hibernateTimeoutDC = $null

Function Get-Laptop {
    Param([string]$computer = "localhost")
    $isLaptop = $false
    If(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}) { $isLaptop = $true }
    If(Get-WmiObject -Class win32_battery -ComputerName $computer) { $isLaptop = $true }
    $isLaptop
}

If(Get-Laptop) {
    Write-Verbose "This is a laptop, we will not disable hiberfil.sys"
}
Else {
    Write-Verbose "This is not a laptop, disabling hiberfil.sys with powercfg -h off"
    powercfg -h off
}

Filter Find-Guid () {
    Write-Output $_.split(":")[1].split("(")[0].replace(" ","")
}

Function Change-Power-Setting {
    $flag = $args[0]
    $value = $args[1]
    if ($value -ne $null) {
        Write-Verbose "executing: powercfg -change $flag $value"
        powercfg -change $flag $value
    } Else {
        Write-Warning "no value supplied for $flag"
    }
}

$ourGuid = powercfg /L | findstr "$powerSchemeName" | Find-Guid
if(!$ourGuid) {
    $oldGuid = powercfg -getactivescheme | Find-Guid
    $ourGuid = powercfg -duplicatescheme $oldGuid | Find-Guid | Select-Object -First 1
    powercfg -changename "$ourGuid" "$powerSchemeName" "$powerSchemeDesc"
    Write-Verbose "Created GUID: $ourGuid ($powerSchemeName)"
}

powercfg -setactive $ourGuid
Change-Power-Setting -monitor-timeout-ac $monitorTimeoutAC
Change-Power-Setting -monitor-timeout-dc $monitorTimeoutDC
Change-Power-Setting -disk-timeout-ac $diskTimeoutAC
Change-Power-Setting -disk-timeout-dc $diskTimeoutDC
Change-Power-Setting -standby-timeout-ac $standbyTimeoutAC
Change-Power-Setting -standby-timeout-dc $standbyTimeoutDC
Change-Power-Setting -hibernate-timeout-ac $hibernateTimeoutAC
Change-Power-Setting -hibernate-timeout-dc $hibernateTimeoutDC
powercfg -getactivescheme | Write-Output
