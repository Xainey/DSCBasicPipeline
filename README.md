## Overview
An example of using the Release Pipeline Model with PowerShell-based tools to manage DSC Deployments.

**WIP**: The goal is to run tasks using Jenkins as a CI Server.

* DSC Resource Dependencies are loaded via *git* in `psakeBuild.ps1`
* Target Servers should be defined in `ExampleConfigData.psd1`
* DSC Resources are copied to Target Deploy Server using
```
$PSmodules = "\\$server\c$\Program Files\WindowsPowerShell\Modules"
Copy-Item -Path "Modules\*" -Destination $PSmodules -Recurse -Force
``` 

## Requirements

* Test-Kichen
* Kitchen-DSC
* Pester
* PSake
* PSScriptAnalyzer

## Usage
A ```psake``` script has been created to manage the various operations related to testing and deployment of ```ExampleConfig.ps1```

### Build Operations

* Test the script via Pester and Script Analyzer  
```powershell
.\build.ps1
```
    
* Test the script with Test-Kitchen/Kitchen-DSC 
```powershell
.\build.ps1 -Task Test
```
    
* Test the script with Script Analyzer only
```powershell
.\build.ps1 -Task Analyze
```
    
* Deploy the script via PSDeploy, $server should be set in `ExampleConfigData.psd1` to generate .mof  
```powershell
.\build.ps1 -Task Deploy -Server $server
```

* Create the Test-Kitchen Build Environment
```powershell
.\build.ps1 -Task BuildEnvironment
```

# VSCode Tasks
Tasks added to `.vscode\tasks.json` to run *Test-Kitchen* and Psake Tasks on local machine.

* **PSakeAnalyze**: Runs build.ps1 Analyze
* **PSakeTest**: Runs build.ps1 Test 
* **PSakeDeploy**: Runs build.ps1 Deploy. Default deploy $server in build.ps1 parms.
* **PesterUnitTests**: Runs Pester against Unit .tests.ps1 in `Tests\Unit`
* **KitchenCreate**: Runs Kitchen Create
* **KitchenConverge**: Runs Kitchen Converge
* **KitchenVerify**: Runs Kitchen Verify
* **KitchenDestroy**: Runs Kitchen Destroy