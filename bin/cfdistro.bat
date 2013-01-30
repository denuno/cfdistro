@echo off
if "%1" == "" goto error
set ANT_HOME=%CD%\..\ant
set buildfile="build/build.xml"
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
# if build dir exists run its build
if not exist %buildfile% (
	set buildfile="%CD%\..\build.xml"
)
call %ANT_HOME%\bin\ant.bat -nouserlib -f %buildfile% %args%
goto end
:error
echo usage:
echo cfdistro.bat start
echo cfdistro.bat stop
:end