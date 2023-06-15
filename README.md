# Util-EnumListeningProcesses
## Overview
This PowerShell script is designed to help users identify and analyze processes listening on non-local interfaces on a Windows system. It retrieves information about the processes, such as the process name, ID, path and associated ports & network interfaces. Additionally, if available, it fetches details about the Windows Service related to those processes.

## Example
Partial screenshot from PCS 7 OS Server results (with simple Excel formatting):

![image](https://github.com/otoriocyber/Util-EnumListeningProcesses/assets/106976225/610b1849-5de8-4a68-bacd-6816bbf38e13)

## Usage
* Output file is in a CSV format, recommanded to load into spreadsheet software such as Excel or Google Sheets.
### Powershell
```PS C:> .\EnumListeningProcesses.ps1 -OutputFile network_exposed_processes.csv```
### CMD
```C:> Powershell -f EnumListeningProcesses.ps1 network_exposed_processes.csv```
