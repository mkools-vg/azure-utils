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