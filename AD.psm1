. "$PSScriptRoot\Classes\AD.ps1"
function Get-ADInfo([string]$Server){[AD]::new().GetADInfo($Server);}
function Get-ADEndpoints($Days = 1){[AD]::new().GetAllEndpoints($Days);}
function Get-AllServersEnabled(){[AD]::new().GetAllServersEnabled($Days);}