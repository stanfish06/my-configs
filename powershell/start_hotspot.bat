REM create task as SYSTEM, then the window wont pop up
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0hotspot.ps1" -Action Start
