Function Test-Elevation {
    [Security.Principal.WindowsPrincipal] $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()            
    If (-not ($Identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Return $false
    }

    Return $true
}

Function Invoke-Login {
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Profile
    )

    if (-not (Login-AzureRmAccount)) {
        return $false
    }

    $profileDir = Split-Path -Path $Profile

    if (-not (Test-Path $profileDir)) {
        New-Item $profileDir -ItemType Directory | Out-Null
    }
    
    Save-AzureRmProfile -Path $Profile -Force

    return $true
}

Function Start-ResourceGroup {
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ResourceGroupName
    )

    Write-Host "Checking for AzureRM modules..."
    if (-not (Get-Module -ListAvailable -Name "AzureRM*")) {
        if (-not (Get-Module -ListAvailable -Name "PowerShellGet")) {
            Write-Host "You need to have PowerShellGet installed. Please visit https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.3.1#how-to-get-powershellget"
            return
        }
        
        if (-not (Test-Elevation)) {
            Write-Host "This script requires elevation. Please start a PowerShell session as an Administrator"
            return
        }

        Install-Module AzureRM
        Import-Module AzureRM
    }

    Write-Host "Starting resource group $ResourceGroupName..."

    $profile = Join-Path $env:LOCALAPPDATA -ChildPath "azure-utils" | Join-Path -ChildPath "profile.json"
    if (-not (Test-Path $profile)) {
        if (-not (Invoke-Login $profile)) {
            return
        }
    }
    else {
        Select-AzureRmProfile -Path $profile
        
        if (-not (Get-AzureRmSubscription)) {
            if (-not (Invoke-Login $profile)) {
                return
            } 
        }
    }

    Select-AzureRmSubscription -SubscriptionName "Non-Production"

    Get-AzureRmVM -ResourceGroupName $ResourceGroupName | ForEach-Object {
        $name = $_.Name
        Write-Host "  Starting $name..."

        Start-AzureRmVM -Name $name -ResourceGroupName $ResourceGroupName
    }
}

Export-ModuleMember -Function Start-ResourceGroup