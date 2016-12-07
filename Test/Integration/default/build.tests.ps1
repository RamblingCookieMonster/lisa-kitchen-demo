Describe 'Build Prerequisites' {
    It 'bootstrapped successfully' {
        Get-Module PoshSpec -ListAvailable | Should Not BeNullOrEmpty
    }
}