<#

    .SYNOPSIS
        Kick off the build process!

    .DESCRIPTION
        * Not in Kitchen environment?  Kick off kitchen test, which runs this again...
        * In Kitchen environment?
            * Grab dependencies
            * Kick off invoke-build

    .EXAMPLE
        # On a Windows system and not worried about dirty state? Kick off the build
        . Start-Build.ps1 -Verify -Provision

    .EXAMPLE
        # Have vagrant, want to ensure a clean build image?
        . Start-Build.ps1

    .PARAMETER Task
        What Invoke-Build Task do you want to run

    .PARAMETER Kitchen
        Whether to kick off this build in Test-Kitchen.

        Default: True, if we can't see $ENV:Temp\Kitchen. In other words, if we aren't in Kitchen, run Kitchen

        Uses bundle exec kitchen test

    .PARAMETER Action
        Provision and or Verify
        Provision: Bootstrap PSDepend, install dependencies
        Verify: Run Invoke-Build to test/deploy

        Defaults to Provision
#>
param(
    [ValidateSet('.', 'Test', 'Deploy')]
    $Task = '.',

    [bool]$Kitchen = $( -not (Test-Path $ENV:Temp\Kitchen -ErrorAction SilentlyContinue )),

    [ValidateSet('Provision', 'Verify')]
    [string[]]$Action = 'Provision'
)

if($Kitchen)
{
    bundle exec kitchen test
    return
}

# Verify is only called from verify stage...  So provision here.
if($Action -contains 'Provision')
{
    # dependencies
    if(-not (Get-Module -ListAvailable PSDepend))
    {
        & (Resolve-Path "$PSScriptRoot\data\build\helpers\Install-PSDepend.ps1")
    }
    $Requirements = "$PSScriptRoot\data\build\requirements.psd1"

    "Installing requirements:"
    Get-Content $Requirements
    Import-Module PSDepend
    Invoke-PSDepend -Path $Requirements -Force

    # Do some things!
    #  * Compile and apply MOFs that you'll test in the verify stage
    #  * Import a module from your repo to test in the verify stage
    #  * Do things you want to do before running the actual build file

}

if($Action -contains 'Verify')
{
    # kick off the actual build
    Import-Module InvokeBuild
    Invoke-Build -File "$PSScriptRoot\build\build.ps1" -Task Deploy
}