properties {
    $script = "$PSScriptRoot\Configurations\ExampleConfig.ps1"
    $server = $Server
    $repo = $Repo
}

task default -depends Analyze, Test

task Analyze {

    # Custom Resource Dependency
    if ( (-not (Test-Path -Path 'Modules/MiscUtilities')) )
    {
        & git @('clone','https://github.com/Xainey/MiscUtilities.git', 'Modules/MiscUtilities')
    }
    else
    {
        & git @('-C','Modules/MiscUtilities','pull')
    }
    
    # xPSDSC Resource Dependency
    if ( (-not (Test-Path -Path 'Modules/xPSDesiredStateConfiguration')) )
    {
        & git @('clone','https://github.com/PowerShell/xPSDesiredStateConfiguration.git', 'Modules/xPSDesiredStateConfiguration')
    }
    else 
    {
        & git @('-C','Modules/xPSDesiredStateConfiguration','pull')
    }
    
    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

task Test -depends Analyze {
    # Run test-kitchen to build VM for integration tests
    
    exec { kitchen test --destroy always }
}

task Deploy -depends Analyze, Test {
   
    # Copy DSC Custom Resources to $server
    $PSmodules = "\\$server\c$\Program Files\WindowsPowerShell\Modules"
    Copy-Item -Path "Modules\*" -Destination $PSmodules -Recurse -Force

    # Load Config
    $ConfigFile = "Configurations\ExampleConfig.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop
    
    # Create .MOF
    Invoke-Expression -Command "ExampleConfig -ConfigurationData .\Configurations\ExampleConfigData.psd1"

    # Start Configuration on Target Server
    Start-DscConfiguration -Path .\ExampleConfig -ComputerName $server -Verbose -Wait -Force 
}