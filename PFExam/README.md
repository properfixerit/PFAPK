# PFExam local build

This project builds the PFExam Android app. The debug APK is for local testing.

## Files
- `app\build\outputs\apk\debug\app-debug.apk` — debug-signed APK for local testing
- update.json — update metadata for the APK
- Install-Update-Run.bat — installer helper for installing and launching the app on a connected device. If the installed app has a different signing key, the script asks before uninstalling it; uninstalling erases local app data.

## Package identity
- Application ID: com.ijtc.pfexam
- App name: PFExam

The debug signing key is not the release key. A debug-signed APK cannot update an installation signed with a different key. `GitUpload.bat` publishes this APK as a test build to `PFExam/Exam.apk`; do not use that upload to update release-signed installations.
