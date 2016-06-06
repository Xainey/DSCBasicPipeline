properties {
    $script = "$PSScriptRoot\ExampleConfig.ps1"
    $server = $BuildServer
}

#SMB Share for DSC Resources and Packages
$repo = "\\REPOSERVER\DSCRepo"
# Clone https://github.com/Xainey/MiscUtilities.git to $repo\Resources

task default -depends Analyze, Test

task Analyze {
        
    # Copy to build server modules, analyze will fail if these modules cant be imported.
    $PSmodules = Join-Path $env:ProgramFiles "WindowsPowerShell\Modules"
    Copy-Item -Path "$repo\Resources\*" -Destination $PSmodules -Recurse -Force
    
    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

task Test {
    $testResults = Invoke-Pester -Path $PSScriptRoot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Deploy -depends Analyze, Test {
   
    # Copy DSC Custom Resources to $server
    $PSmodules = "\\$server\c$\Program Files\WindowsPowerShell\Modules"
    Copy-Item -Path "$repo\Resources\*" -Destination $PSmodules -Recurse -Force

    # Load Config
    $ConfigFile = ".\ExampleConfig.ps1"
    . $ConfigFile -Verbose -ErrorAction Stop
    
    # Create .MOF
    Invoke-Expression -Command "ExampleConfig -ConfigurationData .\ExampleConfigData.psd1"

    # Start Configuration
    Start-DscConfiguration -Path .\ExampleConfig -ComputerName $server -Verbose -Wait -Force 
}