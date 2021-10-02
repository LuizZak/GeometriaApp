@ECHO OFF
SETLOCAL

CALL build-win.cmd "%~1"

IF %errorlevel% neq 0 (
    EXIT /b %errorlevel%
)

ECHO Executing...

CHCP 65001

IF "%~1"=="" (
    SET CONFIG=debug
) ELSE (
    SET CONFIG=%1
)

FOR /f %%i IN ('swift build -c=%CONFIG% --show-bin-path') DO (
    SET BIN_DIR=%%i
)

CALL CONFIG 1> NUL
SET BIN_PATH=%BIN_DIR%\%BIN_NAME%

@ECHO ON

%BIN_PATH%
