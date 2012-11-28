$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Push-Location $psScriptRoot
. ./Utilities.ps1
. ./Config.ps1
Pop-Location

<#
.SYNOPSIS
Convenience functions for checking out, configuring and building CustusX.

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 09.10.2012

.EXAMPLE
Create-Release "v3.2.9"
Will create the CustusX v3.2.9 release
#>
Function Create-Release{
    param(
    ## The tag number where the release can be found in git.
    [Parameter(Mandatory=$false, Position=0)]
    [string]$tag="master"
    )

    $respons = Read-Host "Have you completed the Release Procedure? (y/n)"
    if(!$respons -like "y"){
        return "Finish the Release Procedure before continuing!"
    }
    
    CX3_64bit_static_Release_jom
    CX3_32bit_static_Release_jom
    
    $cx_folder = "$script:CX_WORKSPACE\CustusX3"
    $release64_folder = "$cx_folder\build_static_jom_Release"
    $release32_folder = "$cx_folder\build_static32_jom_Release"
    if((Test-Path $release64_folder) -and (Test-Path $release32_folder)){
        # find the 32bit jom (or eclipe) build
        Set-32bitEnvironment
        cd $release32_folder
        git chekout $tag
        git submodule update
        jom -j Get-Cores UltrasonixServer
        
        #copy UltrasonixServer.exe to ???
        
        # find the 64bit jom (or eclipse) build
        Set-64bitEnvironment
        cd $release64_folder
        git chekout $tag
        git submodule update
        jom -j Get-Cores PACKAGE
        
    }
}

Function Get-BuildList{
    $cx_folder = "$script:CX_WORKSPACE\CustusX3"
    #TODO
    #find all folder that should contain a build
    Get-ChildItem $cx_folder
}

<#
.SYNOPSIS
Convenience functions for checking out, configuring and building CustusX.

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 05.09.2012

.EXAMPLE
CX3_64bit_Release_jom
#>
Function CX3_64bit_Release_jom{
    $options = @("--full", "--all", "--jom", "-j", "$script:CX_CORES", "--build_type", "Release", "--silent_mode", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD");
    Set-64bitEnvironment
    Start-cxInstaller $options
}
Function CX3_64bit_static_Release_jom{
    $options = @("--full", "--all", "--jom", "-j", "$script:CX_CORES", "--build_type", "Release", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD");
    Set-64bitEnvironment
    Start-cxInstaller $options
}
Function CX3_64bit_static_Release_Eclipse{
    $options = @("--full", "--all", "--build_type", "Release", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-64bitEnvironment
    Start-cxInstaller $options
}
Function CX3_64bit_static_Debug_jom{
    $options = @("--full", "--all", "--jom", "-j", "$script:CX_CORES", "--build_type", "Debug", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-64bitEnvironment
    Start-cxInstaller $options
}
Function CX3_64bit_static_Debug_Eclipse{
    $options = @("--full", "--all", "--build_type", "Debug", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-64bitEnvironment
    Start-cxInstaller $options
}
Function CX3_32bit_static_Release_jom{
    $options = @("--full", "--all", "--b32", "--jom", "-j", "$script:CX_CORES", "--build_type", "Release", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-32bitEnvironment
    Start-cxInstaller $options
}
Function CX3_32bit_static_Release_Eclipse{
    $options = @("--full", "--all", "--b32", "$script:CX_CORES", "--build_type", "Release", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-32bitEnvironment
    Start-cxInstaller $options
}
Function CX3_32bit_static_Debug_jom{
    $options = @("--full", "--all", "--b32", "--jom", "-j", "$script:CX_CORES", "--build_type", "Debug", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-32bitEnvironment
    Start-cxInstaller $options
}
Function CX3_32bit_static_Debug_Eclipse{
    $options = @("--full", "--all", "--b32", "--build_type", "Debug", "--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD")
    Set-32bitEnvironment
    Start-cxInstaller $options
}

$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Function Start-cxInstaller{
    param(
    ## The options to send to the pyton script cxInstaller.py
    [Parameter(Mandatory=$true, Position=0)]
    [String[]]$options
    )
    $start = get-date
    if(Get-Command python){
        Push-Location $psScriptRoot
        python .\cxInstaller.py $options
        Pop-Location
        Add-Logging 'EMPHASIS' "[BuildCustusX.ps1] Running cxInstaller.py process took $(Get-ElapsedTime $start)"
    }else{
        Add-Logging 'ERROR' "[BuildCustusX.ps1] Could not find python, could not run cxInstaller.py"
    }
}