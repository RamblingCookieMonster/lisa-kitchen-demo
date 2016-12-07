@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
    }

    # Grab some modules without depending on PowerShellGet
    'InvokeBuild' = @{ DependencyType = 'PSGalleryNuget' }
    'PSDeploy' = @{ DependencyType = 'PSGalleryNuget' }
    'BuildHelpers' = @{ DependencyType = 'PSGalleryNuget' }
    'Pester' = @{ DependencyType = 'PSGalleryNuget' }
    'PoshSpec' = @{ DependencyType = 'PSGalleryNuget' }
    'PSScriptAnalyzer' = @{ DependencyType = 'PSGalleryNuget' }

    # Grab a piece of a GitHub module without git.exe
    'powershell/demo_ci' = @{
        DependencyType = 'GitHub'
        Version = 'master'
        Parameters = @{
            ExtractPath = 'Assets/DscPipelineTools'
        }
    }
}