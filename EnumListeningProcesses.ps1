<#
.SYNOPSIS
This script is an open-source project provided by OTORIO Company for the community under the GNU General Public License (GPL) 3.0. It lists the listening processes in Windows and provides details about the ports and related services, if available.

.DESCRIPTION
This script is designed to help users identify and analyze listening processes on a Windows system. It retrieves information about the processes, such as the process name, ID, and associated ports. Additionally, if available, it fetches details about the services related to those processes.

.PARAMETER OutputFile
Specifies the path and filename for the output file.

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
	PS C:> .\EnumListeningProcesses.ps1 -OutputFile network_exposed_processes.txt
OR
	C:> Powershell -f EnumListeningProcesses.ps1 network_exposed_processes.txt

#>

param (
[Parameter(Mandatory=$true)]
[string]$OutputFile
)

$stats = netstat -nao | findstr LISTENING | findstr -v '127.0.0.1'
$procs = @{}
foreach ($s in $stats){
	$s_pid = [int]($s -split ' ')[-1]
	if (-not $procs[$s_pid]) {$procs[$s_pid] = new-object -type System.Collections.ArrayList}
	$procs[$s_pid].Add($s) | Out-Null
}
$services = @{}; Get-CimInstance -class win32_service | foreach {$services[[int]$_.processid]=$_.displayName}
$procs_data = $procs.keys | foreach{get-process -id $_} | Select-Object ID, Name, Service, Path, ListeningOn | Sort-Object Name

foreach ($p in $procs_data){
	$p.Service = $services[$p.id]
	$p.ListeningOn = ($procs[$p.id] | foreach {($_ -split '\s+')[1, 2] -join ' '}) -join ', '
}

$procs_data | Format-Table -AutoSize | Out-File -Width 100000 -FilePath $OutputFile