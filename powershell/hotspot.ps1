param(
    [ValidateSet("Start","Stop","Status")]
    [string]$Action
)

# Function to call UWP APIs
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]

function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait()
    $netTask.Result
}

function Get-TetheringManager {
    $profile = [Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType = WindowsRuntime]::GetInternetConnectionProfile()
    if (-not $profile) {
        Write-Host "No active internet connection found." -ForegroundColor Red
        return $null
    }
    return [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType = WindowsRuntime]::CreateFromConnectionProfile($profile)
}

function Start-Hotspot {
    $tm = Get-TetheringManager
    if ($tm) {
        $result = Await ($tm.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
        if ($result.Status -eq "Success") {
            Write-Host "Hotspot started successfully!" -ForegroundColor Green
        } else {
            Write-Host "Failed to start hotspot: $($result.Status)" -ForegroundColor Red
        }
    }
}

function Stop-Hotspot {
    $tm = Get-TetheringManager
    if ($tm) {
        $result = Await ($tm.StopTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
        if ($result.Status -eq "Success") {
            Write-Host "Hotspot stopped successfully!" -ForegroundColor Yellow
        } else {
            Write-Host "Failed to stop hotspot: $($result.Status)" -ForegroundColor Red
        }
    }
}

function Show-Status {
    $taskExists = schtasks /Query /TN "HotspotAlwaysOn" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Always-On is ENABLED" -ForegroundColor Green
    } else {
        Write-Host "Always-On is DISABLED" -ForegroundColor Yellow
    }
    $tm = Get-TetheringManager
    if ($tm) {
        Write-Host "Current Hotspot State: $($tm.TetheringOperationalState)" -ForegroundColor Cyan
    }
}

switch ($Action) {
    "Start" { Start-Hotspot }
    "Stop" { Stop-Hotspot }
    "Status" { Show-Status }
}
# run powershell.exe -ExecutionPolicy Bypass -File "./hotspot.ps1" -Action something
