<#
    .Synopsis
    Build script (https://github.com/nightroman/Invoke-Build)

    .Description
    Hah
#>

# Set up some variables
if($ENV:BHProjectPath)
{
    $ProjectRoot = $ENV:BHProjectPath
    "Build variables:"
    Get-Item ENV:BH* | Format-Table -AutoSize
}
else
{
    $ProjectRoot = ( Resolve-Path "$PSScriptRoot/.." ).Path
}

$lines = '----------------'

$Verbose = @{}
if($ENV:BHCommitMessage -match "!verbose")
{
    $Verbose = @{Verbose = $True}
}

# Some function we'll use
function Invoke-Tests {
    [cmdletbinding()]
    param(
        $TestPath
    )
    $PSVersion = $PSVersionTable.PSVersion.Major
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $TestResults = Invoke-Pester -Path $TestPath -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
} # Invoke-Tests

# Default task is 'deploy'
Task . Deploy

# Deploy task runs init>test>deployment
Task Deploy Init, Test, Deployment, TestDeploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details $(Get-Date):"
    Get-Item ENV:BH*
    if ($Verbose.Verbose)
    {
        "`nPSVersionTable:"
        $PSVersionTable

        "`nModule Paths"
        $ENV:PSModulePath -split ';'

        "`nModules Loaded:"
        Get-Module | Select Name, Path

        "`nModules Available:"
        Get-Module -ListAvailable | Select Name, Path
    }
    "`n"
}

Task Test {
    $lines
    Invoke-Tests $ProjectRoot\Test\Integration\
    "`n"
}

Task Deployment {
    $lines

    $Params = @{
        Path = $ProjectRoot
        Force = $true
    }
    # Consider gating deployment
    if (
        $ENV:BHBuildSystem -eq 'AppVeyor' -and  # you might gate deployments to your build system
        $ENV:BHBranchName -eq "master" -and    # you might have another deployment for dev, or use tagged deployments based on branch
        $ENV:BHCommitMessage -match '!deploy'  # you might add a trigger via commit message
    )
    {
        $Tag = 'Prod'
    }
    else
    {
        $Tag = 'Local'
    }

    "Deploying with tag [$Tag]"
    $DeployOutput = Invoke-PSDeploy @Verbose @Params -Tags $Tag
    if ($Verbose.Verbose)
    {
        $DeployOutput
    }
    "`n"
}

Task TestDeploy { # Did it actuall deploy?
    $lines
    Invoke-Tests $ProjectRoot\Test\Operational\
    "`n"
}