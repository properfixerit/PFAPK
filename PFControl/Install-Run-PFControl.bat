@echo off
setlocal

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

if not exist "%ADB%" (
    echo Android Debug Bridge was not found.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

set "APK=%TEMP%\PFControl.apk"
echo Downloading the latest PFControl.apk from PFAPK...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/properfixerit/PFAPK/main/PFControl/PFControl.apk' -OutFile '%APK%' -ErrorAction Stop } catch { exit 1 }"
if errorlevel 1 (
    echo APK download failed.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

echo Using downloaded APK: "%APK%"
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

"%ADB%" uninstall ij.tc.pfcontrol
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
"%ADB%" shell monkey -p ij.tc.pfcontrol 1
if errorlevel 1 (
    echo The app was installed, but could not be launched.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

echo PFControl was installed and launched successfully.
timeout /t 3 /nobreak >nul
exit /b 0
