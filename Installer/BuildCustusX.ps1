$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Push-Location $psScriptRoot
. ./Utilities.ps1
. ./Config.ps1
Pop-Location

<#
.SYNOPSIS
Convenience functionds for checking out, configuring and building CustusX.

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 05.09.2012

.EXAMPLE
CX3_64bit_Release_jom
#>
Function CX3_64bit_Release_jom{
    python .\cxInstaller.py --full --all --jom -j $script:CX_CORES --build_type Release --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_64bit_Release_Eclipse{
    python .\cxInstaller.py --full --all --build_type Release --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_64bit_Debug_jom{
    python .\cxInstaller.py --full --all --jom -j $script:CX_CORES --build_type Debug --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_64bit_Debug_Eclipse{
    python .\cxInstaller.py --full --all --build_type Debug --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_32bit_Release_jom{
    python .\cxInstaller.py --full --all --b32 --jom -j $script:CX_CORES --build_type Release --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_32bit_Release_Eclipse{
    python .\cxInstaller.py --full --all --b32 $script:CX_CORES --build_type Release --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_32bit_Debug_jom{
    python .\cxInstaller.py --full --all --b32 --jom -j $script:CX_CORES --build_type Debug --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}
Function CX3_32bit_Debug_Eclipse{
    python .\cxInstaller.py --full --all --b32 --build_type Debug --silent-mode --static --user $script:CX_MEDTEK_USERNAME 
}