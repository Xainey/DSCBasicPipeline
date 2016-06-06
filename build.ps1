[cmdletbinding()]
param(
    [string[]] 
    $Task = 'default',

    [string]
    $Server = 'localhost'
)

# Not-Availiable on servers without WMF5 and Internet access.
# May want to just check for modules and fail if missing if Internet access is restricted.
if (!(Get-Module -Name Pester -ListAvailable)) { Install-Module -Name Pester }
if (!(Get-Module -Name PSake -ListAvailable)) { Install-Module -Name PSake }
if (!(Get-Module -Name PSDeploy -ListAvailable)) { Install-Module -Name PSDeploy }

Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -parameters @{"BuildServer" = $Server} -Verbose:$VerbosePreference