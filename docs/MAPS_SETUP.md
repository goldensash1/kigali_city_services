# Google Maps setup (if map shows grey/blank)

The app uses **Google Maps** on the Directory detail screen and the Map View tab. If you see a grey or blank map:

1. **Enable the Maps SDKs** in Google Cloud Console:
   - Go to [Google Cloud Console](https://console.cloud.google.com/) and select project **kigalicityservices-250**.
   - Open **APIs & Services** → **Library**.
   - Search for and enable:
     - **Maps SDK for Android**
     - **Maps SDK for iOS**
2. Wait a few minutes and run the app again. Map tiles should load.

The API keys are already set in:
- **Android:** `android/app/src/main/AndroidManifest.xml` (`com.google.android.geo.API_KEY`)
- **iOS:** `ios/Runner/AppDelegate.swift` (reads from `GoogleService-Info.plist`)

If the map still does not load, check that billing is enabled for the project (Maps often requires an enabled billing account, though a free tier applies).
