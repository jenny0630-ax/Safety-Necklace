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

## Store Listing Metadata Draft (MVP)

Use the following copy as a starting point for App Store Connect and Google Play. Update any claims to match the final shipped behavior (especially alerting, notifications, and device pairing flow).

### App Store (Apple)

- **App Name**: SafeNeck
- **Subtitle**: Safety necklace alerts and live tracking
- **Promotional Text**:
  Track paired SafeNeck devices in real time, review fall alerts, and manage your profile and notification preferences from one simple companion app.
- **Keywords**:
  safety,fall detection,gps tracker,wearable,elder care,personal safety,emergency alert,location tracking
- **Description**:

  SafeNeck is the mobile companion app for the SafeNeck safety necklace system.

  Pair your SafeNeck device, view live location updates, and review alerts triggered by the necklace hardware. The app is designed for MVP use with Firebase-backed account access and real-time data syncing.

  Key features:
  - Sign in with email and password
  - Pair one or more SafeNeck devices by device ID
  - View live device status and battery level
  - Open a map to monitor the latest device location
  - Review fall and device alerts
  - Manage profile and notification preferences

  Important:
  - SafeNeck requires a compatible SafeNeck hardware device
  - Mobile network/device telemetry accuracy depends on signal and GPS availability
  - This app is not a substitute for emergency services

- **What’s New (Version 1.0.0)**:
  Initial MVP release with device pairing, live tracking dashboard, map view, alerts, and account/profile settings.

### Google Play

- **App Name**: SafeNeck
- **Short Description** (80 chars max target):
  SafeNeck companion app for alerts, live tracking, and device status
- **Full Description**:

  SafeNeck is the companion app for the SafeNeck wearable safety necklace.

  Connect your account, pair a SafeNeck device, and monitor location, alerts, and device status in real time.

  With the SafeNeck app you can:
  - Pair devices using a device ID
  - See live device location on a map
  - Review alerts, including fall alerts
  - Check device battery and online status
  - Manage profile and notification preferences

  SafeNeck is built for the SafeNeck MVP hardware + cloud workflow and requires a compatible device.

  Notes:
  - GPS accuracy and update timing depend on device connectivity and environment
  - SafeNeck does not replace emergency response services

### Optional Marketing Variants (A/B Testing)

- **Subtitle Variant A**: Live fall alerts and device location
- **Subtitle Variant B**: Wearable safety tracking companion
- **Promo Text Variant A**: Monitor SafeNeck devices with live maps, alert history, and quick account controls.
- **Promo Text Variant B**: Stay connected to paired safety necklaces with real-time updates and alerts.

### Assets Checklist (Both Stores)

- App icon (already generated in this repo; verify final branding)
- iPhone screenshots (6.7" + 6.5" recommended)
- iPad screenshots (if iPad supported in release listing)
- Android phone screenshots
- Feature graphic (Google Play)
- Privacy policy URL
- Support URL
- Marketing URL (optional)

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
