# SafeNeck Flutter App

Flutter mobile companion app for the SafeNeck safety necklace MVP.

## What It Does

- Authenticates users with Firebase Auth (email/password)
- Streams paired device location and alerts from Firebase Realtime Database
- Shows a home dashboard, map view, device details, profile, and settings

## Run

```bash
flutter pub get
flutter run
```

## Important

- This project is currently configured with native Firebase files for the existing package/bundle ID.
- If you rename the app ID for store submission, regenerate:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

See the repo root README for hardware, firmware, webhook, and release checklist details.
