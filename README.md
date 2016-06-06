## Overview
An example of using the Release Pipeline Model with PowerShell-based tools to manage DSC Deployments.

**This is still a major work in progress.**

## Usage
A ```psake``` script has been created to manage the various operations related to testing and deployment of ```ExampleConfig.ps1```

### Build Operations

* Test the script via Pester and Script Analyzer  
```powershell
.\build.ps1
```
    
* Test the script with Pester only  
```powershell
.\build.ps1 -Task Test
```
    
* Test the script with Script Analyzer only  
```powershell
.\build.ps1 -Task Analyze
```
    
* Deploy the script via PSDeploy  
```powershell
.\build.ps1 -Task Deploy -Server $server
```

# Unit/Integration Tests
Tasks could be added to `.vscode\tasks.json` to run test kitchen on local machine. 