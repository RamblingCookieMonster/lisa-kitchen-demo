Import-Module Poshspec

Describe 'Services' {
    Service bits Status { Should Be Stopped }
}