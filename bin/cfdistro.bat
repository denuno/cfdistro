@echo off
if "%1" == "" goto error
set ANT_HOME=%CD%\build\cfdistro\ant\
set var1=%1
SHIFT
:Loop
IF "%1"=="" GOTO Continue
SET var1=%var1% -D%1%
SHIFT
SET var1=%var1%=%1%
SHIFT
GOTO Loop
:Continue
call %CD%\build\cfdistro\ant\bin\ant.bat -nouserlib -f build/build.xml %var1%
goto end
:error
echo usage:
echo cfdistro.bat start
echo cfdistro.bat stop
:end