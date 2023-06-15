<#
.SYNOPSIS
This script is an open-source project provided by OTORIO Company for the community under the GNU General Public License (GPL) 3.0. It lists the listening processes in Windows and provides details about the ports and related services, if available.

.DESCRIPTION
This script is designed to help users identify and analyze listening processes on a Windows system. It retrieves information about the processes, such as the process name, ID, and associated ports. Additionally, if available, it fetches details about the services related to those processes.

.PARAMETER OutputFile
Specifies the path and filename for the output file (csv format).

.NOTES
Company: OTORIO LTD
License: GNU General Public License (GPL) 3.0
Created: 1 May 2023
Author: OTORIO LTD
Version: 1.0

.LINK
Company Website: www.otorio.com
License Information: https://www.gnu.org/licenses/gpl-3.0.html

.EXAMPLE
	PS C:> .\EnumListeningProcesses.ps1 -OutputFile network_exposed_processes.csv
OR
	C:> Powershell -f EnumListeningProcesses.ps1 network_exposed_processes.csv

#>

param (
[Parameter(Mandatory=$true)]
[string]$OutputFile
)

$procs = @{}; 

# Collection of listening connections 
$netstat_raw = netstat -nao # Get-NetTCPConnection may not be supported on some environments
$stats = $netstat_raw | findstr "LISTENING" | findstr -v '127.0.0.1' 
$stats += $netstat_raw | findstr "*:*" | findstr -v '127.0.0.1' 
foreach ($s in $stats){
	# Aggregate connections per process ID
	$s_pid = [int]($s -split ' ')[-1]
	if (-not $procs[$s_pid]) {$procs[$s_pid] = new-object -type System.Collections.ArrayList}
	$procs[$s_pid].Add($s) | Out-Null
}

# Collection of listening UDP connections 
$stats = netstat -naop UDP  | findstr "*:*" | findstr -v '127.0.0.1' 
foreach ($s in $stats){
	# Aggregate connections per process ID
	$s_pid = [int]($s -split ' ')[-1]
	if (-not $procs[$s_pid]) {$procs[$s_pid] = new-object -type System.Collections.ArrayList}
	$procs[$s_pid].Add($s) | Out-Null
}

# Collection of processes and services details
$services = @{}; Get-CimInstance -class win32_service | foreach {$services[[int]$_.processid]=$_}
$procs_data = $procs.keys | foreach{get-process -id $_} | Select-Object ID, Name, Service, Description, Path, ListeningOn | Sort-Object Name

# Aggregating connections per process and adding related service details if exists.
foreach ($p in $procs_data){
	if ($services[$p.id]){
		$p.Service = $services[$p.id].displayName
		$p.Description = $services[$p.id].Description
	}
	if ((-not $p.Description) -and $p.path -and (Test-Path $p.path)){
		# Collect description based on executatble
		$p.Description = (get-ChildItem $p.path).VersionInfo.FileDescription
	}
	$p.ListeningOn = ($procs[$p.id] | select -Unique | foreach {($_ -split '\s+')[1, 2] -join ' '}) -join ', '
}

# Write output to file as CSV
try {
	$procs_data | Export-csv -Path $OutputFile -NoTypeInformation
} catch {
	$procs_data | Export-csv -Path $OutputFile
}
