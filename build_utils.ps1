# Build Powershell collection object from vagrant CLI
function Get-VagrantBoxes
{
    $matches = vagrant box list | Select-String -Pattern '(\S+)\s+\((\w+), ([\d.]+)\)' -AllMatches

    $boxes = @()
    foreach ($box in $matches)
    { 
        $boxes += [pscustomobject] @{
            "Vendor"   = $box.Matches.groups[1].value
            "Provider" = $box.Matches.groups[2].value
            "Version"  = $box.Matches.groups[3].value
        }
    }

    return $boxes
}

# Test of Vagrant Box is installed
function Test-VagrantBoxInstalled 
{
    [CmdletBinding()]
    Param
    (
        [string] $vendor,
        [string] $provider
    )

    return $null -ne (Get-VagrantBoxes | where {$_.Vendor -eq $vendor -and $_.Provider -eq $provider})
}

# Clone/Update Git repo
function Get-GitRepository
{
    [CmdletBinding()]
    Param
    (
        [string] $RepoPath,
        [string] $RepoURL
    )

    if ( (-not (Test-Path -Path $RepoPath)) )
    {
        & git @('clone',$RepoURL, $RepoPath)
    }
    else
    {
        & git @('-C',$RepoPath,'pull')
    }
}