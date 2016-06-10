#$sut = "$PSScriptRoot\ExampleConfig.ps1"

Describe 'ExampleConfig' {
    Context 'Create Shortcut' {
        
        $shortcutPath = 'c:\dsc\Example\Notepad.lnk'
        $targetPath   = 'c:\Windows\System32\notepad.exe'
        
        It 'creates a Notepad shortcut' {
            $shortcutPath | Should Exist
        }
        
        It 'has the correct target' {
            $shell = New-Object -COM WScript.Shell
            $target = $shell.CreateShortcut($shortcutPath).TargetPath
            $target | Should Be $targetPath
        }
        
        It 'should pass' {
            $true | Should Be $true
        }
    }
}