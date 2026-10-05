@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

if not exist "%ADB%" (
    echo Android Debug Bridge was not found.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

set "APK=%~dp0app\build\outputs\apk\debug\app-debug.apk"
set "APP_PACKAGE=com.ijtc.pfcontrol"
set "NO_INSTALL=0"
if /I "%~1"=="noinstall" set "NO_INSTALL=1"
if /I "%~1"=="--no-install" set "NO_INSTALL=1"
if /I "%~1"=="/noinstall" set "NO_INSTALL=1"

if "%NO_INSTALL%"=="0" if not exist "%APK%" (
    echo Debug APK was not found: "%APK%"
    timeout /t 5 /nobreak >nul
    exit /b 1
)

if "%NO_INSTALL%"=="0" (
    echo Using App: "%APK%"
    "%ADB%" shell pm list packages | findstr /I /X /C:"package:%APP_PACKAGE%" >nul
    if errorlevel 1 (
        echo Package %APP_PACKAGE% is not installed. Installing fresh.
        "%ADB%" install "%APK%"
        if errorlevel 1 goto installFailed
    ) else (
        echo Package %APP_PACKAGE% is installed. Overwriting it.
        set "INSTALL_LOG=!TEMP!\app-install-!RANDOM!-!RANDOM!.log"
        "!ADB!" install -r -d "%APK%" >"!INSTALL_LOG!" 2>&1
        set "INSTALL_RESULT=!ERRORLEVEL!"
        type "!INSTALL_LOG!"
        if "!INSTALL_RESULT!"=="0" goto installed
        findstr /C:"INSTALL_FAILED_UPDATE_INCOMPATIBLE" "!INSTALL_LOG!" >nul
        if errorlevel 1 (
            del "!INSTALL_LOG!" >nul 2>nul
            goto installFailed
        )
        echo.
        echo The installed app uses a different signing key.
        echo Uninstalling it will erase its local app data.
        choice /C YN /N /M "Uninstall the existing app and install fresh? [Y/N] "
        if errorlevel 2 (
            del "!INSTALL_LOG!" >nul 2>nul
            echo Fresh installation cancelled.
            timeout /t 5 /nobreak >nul
            exit /b 1
        )
        "%ADB%" uninstall "%APP_PACKAGE%"
        if errorlevel 1 (
            del "!INSTALL_LOG!" >nul 2>nul
            goto installFailed
        )
        "%ADB%" install "%APK%"
        if errorlevel 1 (
            del "!INSTALL_LOG!" >nul 2>nul
            goto installFailed
        )
        del "!INSTALL_LOG!" >nul 2>nul
    )
)

:installed
:launch
if "%NO_INSTALL%"=="1" (
    "%ADB%" shell pm list packages "%APP_PACKAGE%" | findstr /I /C:"%APP_PACKAGE%" >nul
    if errorlevel 1 (
        echo Package %APP_PACKAGE% is not installed on the connected device.
        echo Run the installer first: Install-Update-Run.bat
        timeout /t 5 /nobreak >nul
        exit /b 1
    )
)

"%ADB%" shell monkey -p %APP_PACKAGE% 1
if errorlevel 1 (
    echo The app was installed, but could not be launched.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

echo App was launched successfully.
if "%NO_INSTALL%"=="0" echo App was installed and launched successfully.
exit /b 0

:installFailed
echo Installation failed. Check that the debug APK is valid and the device is connected.
timeout /t 5 /nobreak >nul
exit /b 1
