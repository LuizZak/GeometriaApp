@SET CONFIG=%1
@if not defined CONFIG @SET CONFIG=debug

CALL build-win.cmd %CONFIG%

@if %errorlevel% neq 0 @exit /b %errorlevel%

@echo Executing...

chcp 65001

%BIN_PATH%
