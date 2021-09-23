@echo Building project...

swift build
@if %errorlevel% neq 0 @exit /b %errorlevel%

@echo Preparing binary...

@for /f %%i in ('swift build --show-bin-path') do @set BIN_DIR=%%i

@SET BIN_NAME=GeometriaApp.exe
@SET WINDOWS_SOURCE_PATH=Sources\GeometriaWindows

@SET MANIFEST_PATH=%WINDOWS_SOURCE_PATH%\GeometriaApp.exe.manifest
@SET BIN_PATH=%BIN_DIR%\%BIN_NAME%

mt -nologo -manifest %MANIFEST_PATH% -outputresource:%BIN_PATH%

@echo Done building!
