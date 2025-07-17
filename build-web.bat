@echo off

REM Build script for deploying the Flutter web app on Windows

echo 🏗️  Building Flutter Web App...

REM Clean previous builds
flutter clean

REM Get dependencies
flutter pub get

REM Build for web with release mode
flutter build web --release --web-renderer html

echo ✅ Flutter web build completed!
echo 📁 Build files are in: build/web/
echo.
echo 🚀 Ready for deployment to:
echo    - Vercel: vercel deploy
echo    - Firebase: firebase deploy
echo    - Netlify: drag build/web folder to netlify.com/drop
