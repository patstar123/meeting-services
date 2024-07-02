@echo off

cd %~dp0
cd ..

set PROJECT_DIR=%cd%
echo "PROJECT_DIR=%PROJECT_DIR%"

if not exist "%PROJECT_DIR%\out" (
    mkdir %PROJECT_DIR%\out
)

set GOPROXY=https://goproxy.cn
echo "GOPROXY=%GOPROXY%"

set CGO_CFLAGS=-I%PROJECT_DIR%\3rd\cxx\x64-mingw\include
set CGO_LDFLAGS=-L%PROJECT_DIR%\3rd\cxx\x64-mingw\lib

FOR /F "tokens=* delims=" %%l in (scripts\targets) DO call :TryGoBuild "%%l"
goto End

:TryGoBuild
set target=%1
if %target% == "" goto :eof
if %target:~1,1% == # goto :eof
if %target:~1,8% == cp_win64 goto :CP_WIN64
if %target:~1,3% == cp_ goto :eof

for /f "tokens=1,* delims= " %%i in ("%target%") do (
  set build_dir=%%i
  set out_name=%%j
)

set "out_name=%out_name:~0,-1%"
echo go build -o "%PROJECT_DIR%\out\%out_name%.exe" %build_dir%
go build -o "%PROJECT_DIR%\out\%out_name%.exe" %build_dir%
goto :eof

:CP_WIN64
echo ignore command "%target%"
goto :eof


:End

pause

@echo on