@{
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
    }

    'InvokeBuild' = @{ DependencyType = 'PSGalleryNuget' }
    'PSDeploy' = @{ DependencyType = 'PSGalleryNuget' }
    'BuildHelpers' = @{ DependencyType = 'PSGalleryNuget' }
    'Pester' = @{ DependencyType = 'PSGalleryNuget' }
    'PoshSpec' = @{ DependencyType = 'PSGalleryNuget' }
    'PSScriptAnalyzer' = @{ DependencyType = 'PSGalleryNuget' }
    'powershell/demo_ci' = @{
        DependencyType = 'GitHub'
        Version = 'master'
        Parameters = @{
            ExtractPath = 'Assets/DscPipelineTools'
        }
    }
}