@echo off
if "%1" == "" goto error
set CFDISTRO_HOME=%~dp0%\..\
set ANT_HOME=%CFDISTRO_HOME%\ant
set buildfile=build/build.xml
set args=%1
SHIFT
:Loop
IF "%1"=="" GOTO Continue
SET args=%args% -D%1%
SHIFT
IF "%1"=="" GOTO Continue
SET args=%args%=%1%
SHIFT
GOTO Loop
:Continue
if not exist %buildfile% (
	set buildfile="%CFDISTRO_HOME%\..\build.xml"
)
call %ANT_HOME%\bin\ant.bat -nouserlib -f %buildfile% %args%
goto end
:error
echo usage:
echo cfdistro.bat start
echo cfdistro.bat stop
:end