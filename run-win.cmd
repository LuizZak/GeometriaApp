CALL build-win.cmd

@if %errorlevel% neq 0 @exit /b %errorlevel%

@echo Executing...

%BIN_PATH%
