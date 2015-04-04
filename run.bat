@call setenv
if "%1" == "1" goto run

call %ADB% uninstall %PACKAGE%
call %ADB% install bin/%APPNAME%.apk

:run
call %ADB% shell logcat -c
call %ADB% shell am start -n %PACKAGE%/%PACKAGE%.%MAIN_CLASS%
call %ADB% shell logcat Harbour:I *:S > log.txt