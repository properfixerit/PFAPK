# PFControl APK build, install ও প্রকাশ

এই folder-টি `properfixerit/PFAPK` repository-এর `PFControl` প্রকাশনা folder-এর
জন্য। Android application ID `com.ijtc.pfcontrol`।

## Release তৈরি

1. Source project `J:\My Drive\AndroidData\PFControl`-এর
   `app\build.gradle.kts`-এ versionCode/versionName নির্ধারণ করুন।
2. PowerShell থেকে project root-এ release build চালান:

   ```powershell
   .\gradlew.bat assembleRelease
   ```

3. Gradle-এর `app\build\outputs\apk\release\app-release-unsigned.apk` একই
   release keystore দিয়ে sign করুন। Signing key নিরাপদে backup রাখুন এবং
   password source control বা upload-এ দেবেন না। অন্য key দিয়ে sign করলে
   installed app update হবে না।
4. Signed APK-টি এই folder-এ `PFControl.apk` নামে রাখুন। Install helper-এর
   জন্য একই APK `Exam.apk` এবং `PFControl-release-signed.apk` নামেও রাখা হয়।
5. `update.json`-এ build-এর version এবং `PFControl.apk`-এর lowercase SHA-256
   checksum দিন:

   ```powershell
   (Get-FileHash -LiteralPath ".\PFControl.apk" -Algorithm SHA256).Hash.ToLowerInvariant()
   ```

   Manifest-এ `apkFileName` হবে `PFControl.apk`; URL হবে
   `https://raw.githubusercontent.com/properfixerit/PFAPK/main/PFControl/PFControl.apk`।
6. `GitUpload.bat` চালিয়ে confirmation দিলে APK, updater manifest, install BAT
   এবং README `PFAPK` repository-এর `PFControl` folder-এ push হবে। অন্য files,
   যেমন `index.html`, অপরিবর্তিত থাকবে।

`GitUpload.bat` Git for Windows, GitHub write access এবং configured Git author
name/email চায়। Push করার আগে BAT APK checksum ও manifest URL/name মিলিয়ে দেখে।

## Local install

USB debugging-সহ Android device যুক্ত করে `Install-Update-Run-PFControl.bat`
চালান। এটি `PFControl.apk` install/update করে `com.ijtc.pfcontrol` চালু করবে।
Signing mismatch হলে uninstall/reinstall করার আগে confirmation চায়; uninstall
করলে app data মুছে যায়।

## বর্তমান local artifact

- Application ID: `com.ijtc.pfcontrol`
- Version: `1.2` (`versionCode: 3`)
- Release APK: `PFControl.apk` (signed)
- Debug APK: `PFControl-debug.apk` (debug keystore; release/update-এ ব্যবহার করবেন না)
- Updater metadata: `update.json`
