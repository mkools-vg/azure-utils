@{
    ModuleToProcess   = "azure-utils.psm1"

    ModuleVersion     = "0.0.1"

    GUID              = "d6cec517-b141-46dc-9fa7-47fc02107606"

    Author            = "Maarten Kools"

    Copyright         = "(c) 2017 Maarten Kools and contributors"

    Description       = "Provides an assortment of utility functions to work with Azure"

    PowerShellVersion = "4.0"

    FunctionsToExport = @(
        "Start-ResourceGroup"
    )

    CmdletsToExport   = @()

    VariablesToExport = @()

    AliasesToExport   = @("??")

    PrivateData       = @{
        PSData = @{
            Tags       = @("azure", "powershell")

            ProjectUri = "https://github.com/mkools-vg/azure-utils"
        }
    }
}