@echo off
setlocal
cd /d "%~dp0"

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

if not exist "%ADB%" (
    echo Android Debug Bridge was not found.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

set "APK=%~dp0PFControl.apk"
if not exist "%APK%" (
    echo PFControl.apk was not found: "%APK%"
    timeout /t 5 /nobreak >nul
    exit /b 1
)

:install
echo Using PFControl APK: "%APK%"

"%ADB%" install -r -d "%APK%"
if not errorlevel 1 goto launch

echo.
echo Update failed. A different signing key may prevent installing over the existing app.
echo Uninstalling PFControl will erase its saved app data.
choice /C YN /N /M "Uninstall PFControl and install fresh? [Y/N] "
if errorlevel 2 (
    echo Installation cancelled.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

"%ADB%" uninstall com.ijtc.pfcontrol
if errorlevel 1 (
    echo Could not uninstall PFControl. Check the device connection and authorization.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

"%ADB%" install "%APK%"
if errorlevel 1 (
    echo Fresh APK installation failed.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

:launch
"%ADB%" shell monkey -p com.ijtc.pfcontrol 1
if errorlevel 1 (
    echo The app was installed, but could not be launched.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

echo PFControl was installed and launched successfully.
timeout /t 3 /nobreak >nul
exit /b 0
