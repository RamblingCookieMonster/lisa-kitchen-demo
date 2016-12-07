<#
    .Synopsis
    Build script (https://github.com/nightroman/Invoke-Build)

    .Description
    Hah
#>

# Set up some variables
$ParentPath = ( Resolve-Path "$PSScriptRoot/.." ).Path
Set-BuildEnvironment -Path $ParentPath
if($ENV:BHProjectPath)
{
    $ProjectRoot = $ENV:BHProjectPath
}

$lines = '----------------'

$Verbose = @{}
if($ENV:BHCommitMessage -match "!verbose")
{
    $Verbose = @{Verbose = $True}
}

# Default task is 'deploy'
Task . Deploy

# Deploy task runs init>test>deployment
Task Deploy Init, Test, Deployment

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details $(Get-Date):"
    Get-Item ENV:BH* | Format-Table -Autosize
    if($Verbose.Verbose)
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
    $PSVersion = $PSVersionTable.PSVersion.Major
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $TestResults = Invoke-Pester -Path $ProjectRoot\Test\Integration\Default -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

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
    "`n"
}

Task Deployment {
    $lines

    # Gate deployment
    if(
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    )
    {
        $Params = @{
            Path = $ProjectRoot
            Whatif = $true
        }

        Invoke-PSDeploy @Verbose @Params
    }
    else
    {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)"
    }
}