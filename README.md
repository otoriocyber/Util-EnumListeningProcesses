# Util-EnumListeningProcesses
## Overview
This PowerShell script is designed to help users identify and analyze processes listening on non-local interfaces on a Windows system. It retrieves information about the processes, such as the process name, ID, path and associated ports & network interfaces. Additionally, if available, it fetches details about the Windows Service related to those processes.

## Example
Example from PCS 7 OS Server
![image](https://github.com/otoriocyber/Util-EnumListeningProcesses/assets/106976225/b05b1440-45ca-4bfd-99b0-a54530a1dd1a)

## Usage
### Powershell
```PS C:> .\EnumListeningProcesses.ps1 -OutputFile network_exposed_processes.txt```
### CMD
```C:> Powershell -f EnumListeningProcesses.ps1 network_exposed_processes.txt```
