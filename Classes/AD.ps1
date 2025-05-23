class AD {

    static [System.Object] GetAllEndpoints([int]$days_inactive) {
        $Endpoints = @();
        try {       
            $cutoff = (Get-Date).AddDays(-$days_inactive);
            $Endpoints = Get-ADcomputer -Filter {Enabled -eq $true -and LastLogonDate -gt $cutoff} -Properties LastLogonDate | Select-Object Name, OperatingSystemm, LastLogonDate;
        }
        catch {
            Write-LogError -module "AD" -message "Failed to query Active Directory";
            $Endpoints = $null
        }
        return $Endpoints;
    }

    static [System.Object] GetAllServersEnabled() {
        $Results = @();
        $json = Get-Content '.\etc\Config\config.json' | ConvertFrom-Json;
        $Uniquejson = $json.Servers.Prefix | Select-Object -Unique;
        if(($Uniquejson).Count -gt 1){
            try {
                $ADQuery = Get-ADcomputer -Filter {Enabled -eq $true} -Properties LastLogonDate | Select-Object Name, OperatingSystemm, LastLogonDate;
                $Results += $Uniquejson | ForEach-Object {
                $CurrentPrefix = $_;
                $ADQuery | Where-Object {$_.Name -like "$($CurrentPrefix)*"}
                }
            }catch {
                Write-LogError -module "AD" -message "Failed to query Active Directory";
            }
        }
        if(($Uniquejson).Count -eq 0){Write-LogError -module "AD" -message "Failed to find any prefixes for Servers";}
        return $Results
    }

    static [System.Object] GetGroup ([string]$filter,[string]$op,[string]$group) {
        return Get-ADGroup -Filter  "$($filter) -$($op) '*$($group)*'"
    }  

    static [System.Object] GetGroupComputers([string]$group_name) {
            $group_info = Get-ADGroupMember -Identity $group_name -ErrorAction SilentlyContinue | Where-Object { $_.ObjectClass -eq "computer" } | Select-Object -ExpandProperty Name
            if($group_info){return $group_info}else{return $Error}
    }

    static [System.Object] GetADInfo([string] $server) {
        $info = @();
        try {
            $ad_info = Get-ADComputer $server -Properties LastLogonDate, Created, OperatingSystem | Select-Object LastLogonDate, Created, OperatingSystem 
            # Get AD description
            $description = (Get-ADComputer $server -Property Description).Description
            if(!($description)){$description = "N/A"}
            $info = [PSCustomObject]@{
                Name = $server
                LastLogonDate = $ad_info.LastLogonDate
                Created = $ad_info.Created
                OperatingSystem = $ad_info.OperatingSystem
            }
        }
        catch {
            Write-Warning -Message "Failed to find AD object for: $server";
            $info = [PSCustomObject]@{
                Name = $server
                LastLogonDate = 'N/A'
                Created = 'N/A'
                OperatingSystem = 'N/A'
            }
        }
        return $info
    }
}