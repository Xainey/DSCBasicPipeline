properties {
    $script = "$PSScriptRoot\Configurations\ExampleConfig.ps1"
    $server = $Server
    $repo = $Repo
}

Include ".\build_utils.ps1"

# Manual Tasks run from build.ps1
task default -depends JenkinsAnalyze, JenkinsTest
task Analyze -depends JenkinsAnalyze
task Test    -depends JenkinsAnalyze, JenkinsTest
task Deploy  -depends JenkinsAnalyze, JenkinsTest, JenkinsDeploy

task BuildEnvironment {
    exec { 
		iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))  
		choco feature enable -n allowGlobalConfirmation
        choco install ruby --version 2.2.4 
     	choco install ruby2.devkit virtualbox vagrant 
	}
    
    # Fails since path isnt reloaded after choco install
    # $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    exec { vagrant plugin install vagrant-winrm }
    
    exec { gem install test-kitchen kitchen-vagrant kitchen-dsc kitchen-pester winrm winrm-fs }
    
    # Install vagrant box if not installed
    $vendor = 'mwrock/Windows2012R2'
    $provider = 'virtualbox'

    if(Test-VagrantBoxInstalled -vendor $vendor -provider $provider)
    {
        exec { vagrant box add $vendor --provider $provider }
    }
    else
    {
        Write-Host "Box already installed"
    }
}

task JenkinsAnalyze {
    # Custom Resource Dependency
    Get-GitRepository `
        -RepoPath 'Modules/MiscUtilities' `
        -RepoURL 'https://github.com/Xainey/MiscUtilities.git'
    
    # xPSDSC Resource Dependency
    Get-GitRepository `
        -RepoPath 'Modules/xPSDesiredStateConfiguration' `
        -RepoURL 'https://github.com/PowerShell/xPSDesiredStateConfiguration.git'
    
    # Add current location to temp PSModulePath
    $env:psmodulepath += ";$PSScriptRoot\Modules"

    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

task JenkinsTest {
    # Run test-kitchen to build VM for integration tests
    exec { kitchen test --destroy always }
}

task JenkinsDeploy {
    # Add current location modules to temp PSModulePath
    $env:psmodulepath += ";$PSScriptRoot\Modules"

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