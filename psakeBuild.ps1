properties {
    $script = "$PSScriptRoot\Configurations\ExampleConfig.ps1"
    $server = $Server
    $repo = $Repo
}

task default -depends Analyze, Test

task BuildEnvironment {
    exec { 
		iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))  
		choco feature enable -n allowGlobalConfirmation
        choco install ruby --version 2.2.4 
     	choco install ruby2.devkit virtualbox vagrant 
	}
    
    # Fails since path isnt reloaded after choco install
    # $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")`
    exec { vagrant plugin install vagrant-winrm }
    
    exec { gem install test-kitchen kitchen-vagrant kitchen-dsc kitchen-pester winrm winrm-fs }
    
    # Install vagrant box if not installed
    $vendor = 'mwrock/Windows2012R2'
    $provider = 'virtualbox'

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

    $virtualBox = $boxes | Where {$_.Vendor -eq $vendor -and $_.Provider -eq $provider}

    if($null -eq $virtualBox)
    {
        exec { vagrant box add $vendor --provider $provider }
    }
    else
    {
        Write-Host "Box already installed"
    }
    
}

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
    
    # Add current location to temp PSModulePath
    $env:psmodulepath += ";$PSScriptRoot\Modules"

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