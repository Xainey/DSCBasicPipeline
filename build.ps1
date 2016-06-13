[cmdletbinding()]
param(
    [string[]] 
    $Task = 'default',

    [string]
    $Server = 'localhost',
    
    [string]
    $Repo = '\\Server\DSCRepo'
)

# Not-Availiable on servers without WMF5 and Internet access.
# May want to just check for modules and fail if missing if Internet access is restricted.
if (!(Get-Module -Name Pester -ListAvailable)) { Install-Module -Name Pester }
if (!(Get-Module -Name PSake -ListAvailable)) { Install-Module -Name PSake }
if (!(Get-Module -Name PSDeploy -ListAvailable)) { Install-Module -Name PSDeploy }
if (!(Get-Module -Name PSScriptAnalyzer -ListAvailable)) { Install-Module -Name PSScriptAnalyzer }

Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" `
    -taskList $Task `
    -parameters @{"Server" = $Server; "Repo" = $Repo} `
    -Verbose:$VerbosePreference

exit ( [int]( -not $psake.build_success ) )