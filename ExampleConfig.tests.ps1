#$sut = "$PSScriptRoot\ExampleConfig.ps1"

Describe 'Unit Tests' {
    Context 'Some Test' {
        #$func = Get-Command -Name $sut
        
        it 'runs a test' {
            $true | should be $true    
        }
    }
}