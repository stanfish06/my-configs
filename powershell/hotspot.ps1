param(
    [ValidateSet("Start","Stop","EnableAlwaysOn","DisableAlwaysOn","Status")]
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

function Enable-AlwaysOn {
    $taskName = "HotspotAlwaysOn"
    $scriptPath = $MyInvocation.MyCommand.Path
    $startBoundary = (Get-Date).ToString("yyyy-MM-dd'T'HH:mm:ss")
    $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT5M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>$startBoundary</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File `"$scriptPath`" -Action Start</Arguments>
    </Exec>
  </Actions>
</Task>
"@

    $tempXml = "$env:TEMP\HotspotTask.xml"
    Set-Content -Path $tempXml -Value $xml -Encoding Unicode
    schtasks /Create /TN $taskName /XML $tempXml /F | Out-Null
    Remove-Item $tempXml
    Write-Host "Always-On enabled (checks every 5 min)" -ForegroundColor Green
}


function Disable-AlwaysOn {
    $taskName = "HotspotAlwaysOn"
    schtasks /Delete /TN $taskName /F | Out-Null
    Write-Host "Always-On disabled" -ForegroundColor Yellow
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
    "EnableAlwaysOn" { Enable-AlwaysOn }
    "DisableAlwaysOn" { Disable-AlwaysOn }
    "Status" { Show-Status }
}
# run powershell.exe -ExecutionPolicy Bypass -File "./hotspot.ps1" -Action something
