# ADR-001 — Mobile framework: Flutter

**Status:** Accepted (2026-11-16) · **Traces to:** R7, N1, F1–F3

## Context
One codebase must run on Android and iOS, including budget Android phones (about 3 GB RAM). The app runs an image classifier on the phone (ADR-002), so it needs reliable camera and gallery access, image decoding and resizing, and TFLite inference. The team may not have a Mac.

## Options
| Criterion | Flutter | React Native (Expo) |
|---|---|---|
| Camera / gallery | `camera`, `image_picker`: official, mature | `expo-camera`, `expo-image-picker`: mature |
| On-device ML | `tflite_flutter` (TensorFlow-maintained); preprocessing is plain Dart with the `image` package | `react-native-fast-tflite`: fast, but turning a gallery image into a pixel tensor needs extra native plugins (`vision-camera` + resize plugin) and a dev build |
| Performance on budget Android | Compiled to native code, its own renderer; consistent | Good with the new architecture; more native-module glue for ML |
| iOS build without a Mac | Codemagic free tier (500 macOS min/month) | EAS Build free tier; the smoothest option |
| Learning curve | Dart (new to most); one language for UI + ML preprocessing | JS/TS (more common), but the ML path spans JS + native plugins |
| Offline DB | `drift` (SQLite), type-safe | `expo-sqlite` |

## Decision
**Flutter (stable channel), Dart 3, Material 3.** The deciding factor is the ML pipeline. Decoding, cropping and resizing an image, then running TFLite, is short, well-documented Dart that behaves the same on both platforms. React Native would need several native plugins chained together, which is fragile for a student team. Codemagic covers iOS builds without a Mac.

## Consequences
- Developers must learn Dart and Flutter (well documented).
- iOS builds go through Codemagic (ADR-008). An Apple Developer account is still required for TestFlight.
- Supporting libraries: `flutter_riverpod` (state), `go_router` (navigation), `drift` (DB), `camera`, `image_picker`, `image`, `tflite_flutter`, `firebase_core`, `firebase_auth`, `cloud_firestore`.
