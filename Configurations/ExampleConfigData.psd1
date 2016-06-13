<#
 The configuration data should have a psd1 extension for PowerShell Data.
 The following nested hash table/array is the PS equivallent of a JSON string.
 As much of the specific version dependant or configuration settings for installation should
 be housed in this document to separate configuration from the DSC resources.
#>

@{
    AllNodes = @(

        <# 
         # All Servers - Indicated by NodeName * (asterisk)
         # These settings are intended to be applied globally to any server running the configuration.
         #>
        @{
            NodeName = "*"
            ExampleFolder = "c:\dsc\Example"
         },

        # QA Server
        @{
            NodeName = "QA_SERVER" # Target Server
         }
        
        <#PROD Server
        @{
            NodeName = "PROD_SERVER"
        }
        #>
    );

}