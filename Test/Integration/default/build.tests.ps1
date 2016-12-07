Describe 'Build Prerequisites' {
    It 'Deployed successfully' {
        Get-Module PoshSpec -ListAvailable | Should Not BeNullOrEmpty
    }
}