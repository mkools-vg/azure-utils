Function Test-Elevation {
    [Security.Principal.WindowsPrincipal] $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()            
    If (-not ($Identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Return $false
    }

    Return $true
}

Function Start-ResourceGroup {
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$GroupTier
    )

    $regex = New-Object "System.Text.RegularExpressions.Regex" `
        -ArgumentList @("^g2\d{2}$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if (-not ($regex.IsMatch($GroupTier))) {
        Write-Host "The group tier is not the correct format. Please provide the group tier in g2xx format"
        return
    }

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

    Write-Host "Starting resource group with tier $GroupTier..."

    Login-AzureRmAccount

    Select-AzureRmSubscription -SubscriptionName "Non-Production"

    $resourceGroupName = "lab17$GroupTier-rg"
    Get-AzureRmVM -ResourceGroupName $resourceGroupName | ForEach-Object {
        $name = $_.Name
        Write-Host "  Starting $name..."

        Start-AzureRmVM -Name $name -ResourceGroupName $resourceGroupName
    }
}

Export-ModuleMember -Function Start-ResourceGroup