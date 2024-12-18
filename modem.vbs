# A gsm modem eszközazonosítóját a Device Managerben található Hardware ID alapján kell megadni
$deviceId = "USB\VID_XXXX&PID_XXXX"

function DeviceExists {
    param($id)
    $device = Get-PnpDevice -InstanceId $id
    return $device -ne $null
}

function RunDiagnostics {
    # Ez egy példa arra, hogyan lehet szimulálni egy eszközdiagnosztikát. 
    # Tegyük fel, hogy az eszköznek van egy saját diagnosztikai parancs vagy állapotellenőrző funkciója, amit meghívhatunk.
    # Az eredmény igaz vagy hamis lehet, ennek módosítására szükség lehet a valós diagnosztikai folyamatnak megfelelően.
    $result = Test-Connection "google.com" -Count 1 -Quiet
    return $result
}

function Remove-Device {
    param($id)
    $device = Get-PnpDevice -InstanceId $id
    if ($device) {
        Disable-PnpDevice -InstanceId $id -Confirm:$false
        Remove-PnpDevice -InstanceId $id -Confirm:$false
    }
}

function Restart-DeviceDetection {
    # Erőforrások újra keresése, hogy az operációs rendszer újra felismerje az eszközt
    Get-PnpDevice | Where-Object {$_.InstanceId -eq $global:deviceId} | Enable-PnpDevice
}

function StartApplication {
    Start-Process "c:\path\to\cica.exe"
}

if (DeviceExists $deviceId) {
    $diagnosticsSuccessful = RunDiagnostics
    if ($diagnosticsSuccessful) {
        StartApplication
    } else {
        Remove-Device $deviceId
        Start-Sleep -Seconds 5
        Restart-DeviceDetection
    }
} else {
    Write-Host "Device not found"
}