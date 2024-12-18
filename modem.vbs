# A gsm modem eszközazonosítóját a Device Managerben található Hardware ID alapján kell megadni
$deviceId = "USB\VID_XXXX&PID_XXXX"

function DeviceExists {
    param($id)
    $device = Get-PnpDevice -InstanceId $id
    return $device -ne $null
}

function RunDiagnostics {
    # A system.io.ports .net könyvtár kelleni fog ide
    $portName = "COM15" # A modemhez kapcsolódó soros port neve
    $baudRate = 9600   # Átviteli sebesség
    $timeOut = 5000    # Időtúllépés (ms)

    try {
        # A soros port inicializálása
        $port = New-Object System.IO.Ports.SerialPort $portName, $baudRate
        $port.Open()
        $port.WriteLine("AT") # AT parancs küldése
        Start-Sleep -Milliseconds 200 # Kis várakozás a válaszra

        $response = $port.ReadLine() # Válasz olvasása
        $port.Close()

        if ($response -match "OK") {
            Write-Host "Connection successful"
            return $true
        } else {
            Write-Host "No valid response from modem"
            return $false
        }
    } catch {
        Write-Error "Failed to communicate with GSM Modem: $_"
        return $false
    }
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