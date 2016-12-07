Describe 'Deployment' {
    It 'Deployed a thing' {
        Test-Path C:\project\Start-Build.ps1 | Should Be $True
    }
}