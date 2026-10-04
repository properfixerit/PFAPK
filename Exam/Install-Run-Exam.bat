@echo off
setlocal

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "APK=%TEMP%\Exam.apk"

if not exist "%ADB%" (
    echo Android Debug Bridge was not found.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/properfixerit/PFAPK/main/PFExam/Exam.apk' -OutFile '%APK%' -ErrorAction Stop } catch { exit 1 }"
if errorlevel 1 (
    echo APK download failed.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

"%ADB%" install -r "%APK%"
if errorlevel 1 (
    echo APK installation failed. Check that the phone is connected and authorized.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

"%ADB%" shell monkey -p com.pf.exam 1
if errorlevel 1 (
    echo The app was installed, but could not be launched.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

echo Exam was installed and launched successfully.
timeout /t 3 /nobreak >nul
exit /b 0
