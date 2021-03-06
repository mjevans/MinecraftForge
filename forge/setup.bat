echo off
pushd .. >nul

  if "%1"=="-skipdecompile" (
    @echo  | cmd /C updatenames.bat -f
  ) ELSE (
    if not exist "runtime\bin\fernflower.jar" (
      pushd forge
        ..\runtime\bin\python\python_mcp download_fernflower.py
      popd
    )
    if not exist "runtime\bin\fernflower.jar" (
      echo Failed to download fernflower, install it manually and re-run setup.
      exit 1
    )
    rmdir /S /Q src
    @echo | cmd /C decompile.bat
  )
  
  
  rmdir /S /Q src_base
  rmdir /S /Q src_work

  pushd src >nul
    del minecraft\net\minecraft\src\MLProp.java
    copy ..\forge\MLProp.java minecraft\net\minecraft\src\MLProp.java
    del minecraft_server\net\minecraft\src\MLProp.java
    copy ..\forge\MLProp.java minecraft_server\net\minecraft\src\MLProp.java
  popd >nul

  @echo | cmd /C updatemd5.bat -f

  mkdir src_base
  mkdir src_work

  xcopy /Y /E /Q src\* src_base
  xcopy /Y /E /Q src\* src_work

  pushd src_work >nul
    @setlocal enabledelayedexpansion
    @echo off
  
    set PATH=..\forge\bin;%PATH%
    echo Applying patches
    for /f %%i in ('find ../forge/patches -type f') do (
      set file=%%i
      rem Have to do this to filter out .svn entries 
      if /I "!file:~-6!" EQU ".patch" (
        ..\runtime\bin\python\python_mcp ..\forge\lfcr.py %%i ..\forge\temp.patch
        ..\runtime\bin\applydiff.exe -uf -p2 -i ..\forge\temp.patch
        del ..\forge\temp.patch >nul 1>nul
      )
    )
  popd >nul
popd >nul
echo finished
pause