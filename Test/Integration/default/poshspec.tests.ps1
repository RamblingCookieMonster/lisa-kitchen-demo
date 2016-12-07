Import-Module Poshspec

Describe 'Services' {
    Service w32time Status { Should Be Stopped }
    Service bits Status { Should Be Stopped }
}