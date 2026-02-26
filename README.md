# SafeNeck (Safety Necklace MVP)

SafeNeck is a wearable safety system MVP built around a Particle Boron device and a Flutter mobile app.

The necklace device detects fall/impact events, streams location and battery data, and publishes alerts through Particle Cloud. The companion app (Flutter) lets a signed-in user pair devices, monitor location, review alerts, and manage profile/notification settings.

## Repository Structure

- `safetynecklaceapp/` - Flutter mobile app (iOS + Android MVP)
- `device_code/main.c` - Particle Boron firmware used for the current hardware build
- `device_code/reference.c` - Reference firmware implementation with detection logic and alert publishing
- `device_code/DEVICE.md` - Hardware wiring, firmware behavior, and Particle/Firebase integration notes

## MVP Features

- Email/password authentication (Firebase Auth)
- Pair one or more necklace devices by device ID
- Home dashboard with live device cards and alert feed
- Real-time map view for paired device location
- Device detail view (battery, connectivity, sensor capability summary)
- Basic profile settings and notification preference toggles
- Account logout and account deletion flow (with Firebase Auth re-auth requirement caveat)

## System Overview

1. Particle Boron firmware reads GPS + IMU sensors.
2. Device publishes location/alert events to Particle Cloud.
3. Particle Webhooks forward events into Firebase Realtime Database.
4. Flutter app listens to Firebase and renders live status/alerts.

## Hardware / Firmware

See `device_code/DEVICE.md` for:

- Hardware parts list (Boron 404X, BNO085 IMU, PA1010D GPS)
- Wiring diagram (I2C daisy-chain)
- Firmware behavior (GPS publish cadence, fall detection thresholds, battery monitoring)
- Particle webhook example for Firebase Realtime Database

## Flutter App Setup (`safetynecklaceapp`)

Prerequisites:

- Flutter SDK (stable)
- Xcode + CocoaPods (for iOS)
- Android Studio / Android SDK (for Android)
- Firebase project with:
  - Authentication (Email/Password)
  - Realtime Database

Included Firebase files:

- `safetynecklaceapp/android/app/google-services.json`
- `safetynecklaceapp/ios/Runner/GoogleService-Info.plist`

If you change the app bundle/package ID, you must register new Firebase apps and replace both config files.

Run locally:

```bash
cd safetynecklaceapp
flutter pub get
flutter run
```

## Firebase Data Shape (App Expectations)

The app expects user-scoped data in Realtime Database under:

- `users/<uid>/devices/<deviceId>/...`
- `users/<uid>/alerts/<alertId>/...`
- `users/<uid>/profileData`
- `users/<uid>/notificationPrefs`

The device webhook should write the latest location into the paired device node and create alert records for fall/impact events.

## Store Submission Notes (MVP)

This repo now includes baseline app-readiness fixes (mobile Firebase initialization, release `INTERNET` permission, production app name labels, basic auth validation, non-placeholder docs).

Manual items still required before submission:

- Set your final Apple bundle ID and Android application ID, then regenerate Firebase config files
- Configure iOS signing/team and Android signing keystore
- Create App Store Connect / Play Console listings (descriptions, screenshots, icons, categories)
- Publish a privacy policy URL and complete Apple privacy + Google Data Safety disclosures
- Verify Firebase security rules and production database access controls
- Test release builds on physical iPhone and Android devices

## Release Validation Commands

```bash
cd safetynecklaceapp
flutter analyze
flutter test
flutter build ios --release
flutter build appbundle --release
```

## Security / Production Notes

- Do not rely on permissive Firebase Realtime Database rules in production.
- Rotate/reissue Firebase credentials if this repository is shared publicly.
- Account deletion in Firebase Auth may require recent re-authentication.

## Status

This repository is positioned for MVP submission preparation, not final production hardening. Expect to complete branding, legal/privacy assets, release signing, and end-to-end device webhook validation before launch.
