# Get path for javaw.exe
$javapath = (Get-Command java).Source
$javapath = $javapath -replace "java.exe","javaw.exe"
if (-not $javapath) { throw "[ERROR] Unable to find Java path" }

# Get path for ace.jar
$acepath = "$Env:USERPROFILE\Ubiquiti UniFi\lib\ace.jar"
if (-not (Test-Path $acepath)) { throw "[ERROR] Unable to find UniFi ace.jar" }

# Create scheduled task
$taskname = "Start-UniFi"
Unregister-ScheduledTask -TaskName $taskname -Confirm:$false -ErrorAction SilentlyContinue
$action = New-ScheduledTaskAction -Execute $javapath -Argument "-jar $($acepath)"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Principal $principal

# Add delayed start, as it's not supported by Register-ScheduledTask
$taskObj = Get-ScheduledTask -TaskName $taskname
$taskObj.Triggers[0].Delay = "PT1M"
$taskObj | Set-ScheduledTask
