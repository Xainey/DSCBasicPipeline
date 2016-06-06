Configuration ExampleConfig
{

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration, MiscUtilities

    Node $AllNodes.NodeName
    {
        File ExampleFolder
        {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = $Node.ExampleFolder
        }
        
        CreateShortcut AddPublicNotepadShortcut
        {
            Ensure          = "Present"
            ShortcutPath    = $Node.ExampleFolder
            ShortcutName    = "Notepad"
            TargetPath      = "C:\Windows\System32\notepad.exe"
        }        
        
    }
}