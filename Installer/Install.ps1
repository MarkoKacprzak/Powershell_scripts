# Import other scripts
############################
. .\Utilities.ps1
. .\Config.ps1
. .\GetTools.ps1

# Global variabels
############################
$script:startTime = get-date

<#
.SYNOPSIS
Removes personal ssh-keys that where installed by
the installer script and changes CustusX3 git protocol
to be https.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 31.08.2012
#>
$scriptpath = $MyInvocation.MyCommand.Path
Function ConvertTo-DeveloperMachine{
    #Remove private ssh-keys
    $ssh_dir = "~/.ssh"
    rmdir $ssh_dir -Recurse #-WhatIf

    $dir = Split-Path $scriptpath
    Remove-Item "$dir\id_rsa.pub" -Force #-WhatIf
    Remove-Item "$dir\id_rsa" -Force #-WhatIf
    Remove-Item "$dir\known_hosts" -Force #-WhatIf

    #Change git protocol to https to enable promting every time one wants to push
    $git_config = "$script:CX_WORKSPACE\CustusX3\CustusX3\.git\config"
    (Get-Content $git_config) | 
    ForEach-Object {$_ -replace "git@github.com:", "https://github.com/"} | Set-Content $git_config #-WhatIf
    
    #Change git config names
    git config --global user.name "Developer"
    git config --global user.email "developer@sintef.no"
    
    Write-Host "Machine converted to developer machine." -ForegroundColor Green
}

<#
.SYNOPSIS
Installs tools, sets up developer environment
and builds CustusX and required libraries.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 20.06.2012

.EXAMPLE
Install-CustusXDevelopmentEnvironment -tool_package 'developer' -tool_actions 'all' -lib_package 'all' -lib_actions @('all') -cmake_generator 'NMake Makefiles JOM' -build_type 'Debug' -target_archs @('x86', 'x64') -ssh_keys 'replace'

.EXAMPLE
Install-CustusXDevelopmentEnvironment -tool_package 'partial' -tool_actions 'all' -tools @('eclipse, console2') -lib_package 'partial' -lib_actions @('all') -libs @('CustusX3') -cmake_generator 'NMake Makefiles JOM' -build_type 'Release' -target_archs @('x86', 'x64') -ssh_keys 'append'
#>
Function Install-CustusXDevelopmentEnvironment {
    param(
        ## Used for testing, will not install anything.
        [Parameter(Mandatory=$false)]
        [bool]$dummy=$false,
        
        ## Select tool installation package
        [Parameter(Mandatory=$true)]
        [ValidateSet('developer', 'minimum', 'partial')]
        [string]$tool_package,
        
        ## Select which actions should be preformed on the tools
        [Parameter(Mandatory=$true)]
        [ValidateSet('all', 'download', 'install', 'environment')]
        [string[]]$tool_actions,
        
        ## Select which tools to processed (will only work with tool_package=partial)
        [Parameter(Mandatory=$false)]
        [ValidateSet('7-Zip', 'cppunit', 'jom', 'git', 'svn', 'cmake', 'python', 'perl', 'eclipse', 'qt', 'boost', 'MSVC2010Express', 'console2')]
        [string[]]$tools="",
        
        ## Select library installation package
        [Parameter(Mandatory=$true)]
        [ValidateSet('all', 'partial')]
        [string]$lib_package,
        
        ## Select which actions should be preformed on the libraries
        [Parameter(Mandatory=$true)]
        [ValidateSet('all', 'checkout', 'clean_configure', 'configure', 'build')]
        [string[]]$lib_actions,
        
        ## Select which libraries to process (will only work with lib_package=partial)
        [Parameter(Mandatory=$false)]
        [ValidateSet('ITK', 'VTK', 'OpenCV', 'OpenIGTLink', 'IGSTK', 'UltrasonixSDK', 'CustusX3')]
        [string[]]$libs="",
        
        ## Select which generator to use with CMake
        [Parameter(Mandatory=$true)]
        [ValidateSet('Eclipse CDT4 - NMake Makefiles', 'NMake Makefiles JOM')]
        [string]$cmake_generator,
        
        ## Select build type
        [Parameter(Mandatory=$true)]
        [ValidateSet('Debug', 'Release')]
        [string]$build_type,
        
        ## Select which target architectures to build for
        [Parameter(Mandatory=$true)]
        [ValidateSet('x86', 'x64')]
        [string[]]$target_archs,
        
        ## Select whether to replace or append the new ssh-keys to your local ssh-keys
        [Parameter(Mandatory=$true)]
        [ValidateSet('append', 'replace')]
        [string[]]$ssh_keys
    )
    
    # Handle parameters
    ############################
    if($dummy){
        Write-Host '$dummy: '$dummy -ForegroundColor Yellow
        Write-Host '$tool_package: '$tool_package -ForegroundColor Yellow
        Write-Host '$tool_actions: '$tool_actions -ForegroundColor Yellow
        Write-Host '$tools: '$tools -ForegroundColor Yellow
        Write-Host '$lib_package: '$lib_package -ForegroundColor Yellow
        Write-Host '$lib_actions: '$lib_actions -ForegroundColor Yellow
        Write-Host '$libs: '$libs -ForegroundColor Yellow
        Write-Host '$cmake_generator: '$cmake_generator -ForegroundColor Yellow
        Write-Host '$build_type: '$build_type -ForegroundColor Yellow
        Write-Host '$target_archs: '$target_archs -ForegroundColor Yellow
        Write-Host "Dummy exit." -ForegroundColor Green
        return
    }
    
    $checkout=$false
    $configure=$false
    $build=$false
    $checkout_command="--checkout"
    $config_command="--configure"
    $build_command="--build"
    foreach( $action in $lib_actions){
        switch($action){
            "all"{$checkout=$true; $configure=$true; $build=$true; break}
            "checkout"{$checkout=$true}
            "clean_configure"{$configure=$true; $config_command="--configure_clean"}
            "configure"{$configure=$true}
            "build"{$build=$true}
            default{Write-Host "Found library action that was not supporte." -ForegroundColor Red; return "Configuration error."}
        }
    }
    
    $selected_libs = ""
    switch ($lib_package){
        "all" {$selected_libs = "--all"}
        "partial" {$selected_libs = $libs}
        default { Write-Host "Could not figure out which libraries where selected." -ForegroundColor Red; return "Configuration error."}
    }
    
    $build_qt = $false
    if((($tool_package -contains "partial") -and ($tools -contains "qt"))-or ($tool_package -contains "developer") -or ($tool_package -contains "full"))
        {$build_qt=$true}
    
    $generator_command=@("")
    switch($cmake_generator){
        'Eclipse CDT4 - NMake Makefiles'{$generator_command=""}
        'NMake Makefiles JOM'{$generator_command=@("--jom", "-j", "$script:CX_CORES")}
        default{Write-Host "Could not figure out which cmake generator to use." -ForegroundColor Red; return "Configuration error."}
    }
    
    $build_type_command=""
    switch($build_type){
        "Debug"{$build_type_command=@("--build_type", "Debug")}
        "Release"{$build_type_command=@("--build_type", "Release")}
        default{Write-Host "Could not figure out which build type to use." -ForegroundColor Red; return "Configuration error."}
    }
    
    $ssh_append=$true
    if($ssh_keys -eq "replace")
        {$ssh_append = $false}
    
    # Run
    ############################
    ResizeWindowBuffer
    Write-Host "Running the installer script." -ForegroundColor Magenta

    # Get system info
    #####
    $os_arch = Get-OsArchitecture
    Write-Host "* You are on a $os_arch operating system *" -ForegroundColor DarkYellow

    $cores = Get-Cores
    Write-Host "* You have $cores core(s) available *" -ForegroundColor DarkYellow

    # Check requirements
    #####
    if($os_arch -ne "64-bit")
        {Write-Host "This script only works for 64-bit Windows" -ForegroundColor Red; return "Abort."}
    
    $32bit_compiler = Find-Compiler "x86"
    $64bit_compiler = Find-Compiler "x64"
    if(!$32bit_compiler)
        {Write-Host "* You do NOT have a 32 bit compiler available. *" -ForegroundColor DarkYellow}
    if(!$64bit_compiler)
        {Write-Host "* You do NOT have a 64 bit compiler available. *" -ForegroundColor DarkYellow}
    
    $build32bit = ($32bit_compiler -and ($target_archs -contains "x86"))
    $build64bit = ($64bit_compiler -and ($target_archs -contains "x64"))

    # Setup SSH
    #####
    Write-Host "`n***** SSH Configuration*****" -ForegroundColor Yellow
    Install-SSHKey "./id_rsa.pub" "./id_rsa" "./known_hosts" -append $ssh_append
    
    # Get tools
    #####

    Write-Host "`n***** TOOLS *****" -ForegroundColor Yellow
    $success = main $tool_package $tool_actions -tools:$tools
    if(!($success -eq $true))
        {Write-Host "Script failed when getting tools."; return}
        
    # Build Qt
    #####
    if($build_qt -and $build64bit){
        ### BUILDING 64 bit Qt ###
        $qt_64buildbin_dir = $script:CX_QT_BUILD_X64+"\bin"
        $configure = "configure $script:CX_QT_CONFIG_OPTIONS"
        if(Test-QtConfigured $script:CX_QT_BUILD_X64)
            {$configure = "echo Qt already configured, skipping."}
        $batch_64bit = @"
echo ***** Building Qt 64 bit using jom with $cores core(s) *****
call "$script:CX_MSVC_VCVARSALL" x64
cd $script:CX_QT_BUILD_X64
set PATH=$qt_64buildbin_dir;%PATH%
$configure
jom /j $cores
"@

        $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
        Add-Content $tempFile64 $batch_64bit
        cmd /C "$tempFile64"

        Remove-Item $tempFile64
    }

    if($build_qt -and $build32bit){
        ### BUILDING 32 bit Qt ###
        $qt_32buildbin_dir = $script:CX_QT_BUILD_X86+"\bin"
        $configure = "configure $script:CX_QT_CONFIG_OPTIONS"
        if(Test-QtConfigured $script:CX_QT_BUILD_X86)
            {$configure = "echo Qt already configured, skipping."}
        $batch_32bit = @"
echo ***** Building Qt 32 bit using jom with $cores core(s) *****
call "$script:CX_MSVC_VCVARSALL" x86
cd $script:CX_QT_BUILD_X86
set PATH=$qt_32buildbin_dir;%PATH%
$configure
jom /j $cores
"@

        $tempFile32 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
        Add-Content $tempFile32 $batch_32bit
        cmd /C "$tempFile32"

        Remove-Item $tempFile32
    }

    if($checkout){
        # Checkout libs
        #####
        Write-Host "`n***** LIBS CHECKOUT *****" -ForegroundColor Yellow
        python .\cxInstaller.py $checkout_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS $selected_libs
        # There is a bug in the script, where IGSTK tries to access information in the CustusX folder,
        # which doesn't exist at that time
        if(($lib_package -eq "all") -or (($lib_package -eq "partial") -and ($libs -contains "IGSTK"))){
            python .\cxInstaller.py $checkout_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS IGSTK
        }
    }

    if($configure -or $build){
        # Configure and build libs
        #####
        Write-Host "`n***** LIBS CONFIGURE AND/OR BUILD *****" -ForegroundColor Yellow

        # 64 bit #
        if($build64bit){
            Write-Host "* 64 bit *" -ForegroundColor DarkYellow
          
            $configureAndBuild64 = @"
call $script:CX_CXVARS_64
"@
            if($configure){
                $configureAndBuild64 += @"
`n
python .\cxInstaller.py $config_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS $selected_libs
"@
            }
            if($build){
                $configureAndBuild64 += @"
`n
python .\cxInstaller.py $build_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS $selected_libs
"@
            }
            $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
            Add-Content $tempFile64 $configureAndBuild64
            cmd /C "$tempFile64"

            Remove-Item $tempFile64
        }

        # 32 bit #
        if($build32bit){
            Write-Host "* 32 bit *" -ForegroundColor DarkYellow
            
            $configureAndBuild32 = @"
call $script:CX_CXVARS_86
"@
            if($configure){
                $configureAndBuild32 += @"
`n
python .\cxInstaller.py $config_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS $selected_libs
"@
            }
            if($build){
                $configureAndBuild32 += @"
`n
python .\cxInstaller.py $build_command $generator_command $build_type_command $script:CX_INSTALL_COMMON_OPTIONS $selected_libs
"@
            }
            $tempFile32 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
            Add-Content $tempFile32 $configureAndBuild32
            cmd /C "$tempFile32"

            Remove-Item $tempFile32
        }
    }

    Write-Host "`nInstallation process took $(GetElapsedTime $script:startTime)" -ForegroundColor Green
}