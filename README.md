# Flutter Firebase Notes — Portfolio

A small Flutter application demonstrating email/password authentication and a per-user notes CRUD with Cloud Firestore. This independent project is technical portfolio evidence, not a commercial product or a production-ready service.

## Implemented features

- Account registration, sign-in and sign-out using Firebase Authentication.
- Reactive navigation based on `authStateChanges()`.
- Create, read, update and delete note titles.
- Real-time note lists using Firestore `snapshots()` and `StreamBuilder`.
- Per-user collections and server-generated creation/update timestamps.
- Basic form validation, loading states and note-operation error feedback.

## Stack and platforms

Flutter, Dart, Firebase Core, Firebase Authentication, Cloud Firestore and Material UI. Web and Android are configured; iOS, macOS, Windows and Linux Firebase options are not configured.

Local tooling checked on 4 October 2026: Flutter 3.47.2 (stable), Dart 3.13.2. Dependencies are recorded in `pubspec.yaml` and `pubspec.lock`.

## Structure

```text
lib/
  main.dart                       Firebase initialization and session-based navigation
  firebase_options.dart           Generated Firebase client configuration
  screens/auth_screen.dart        Sign-in and registration UI
  screens/notes_screen.dart       Real-time notes UI and CRUD interactions
  services/firestore_service.dart Firestore access scoped to the current user
test/widget_test.dart             Authentication-form widget tests
firestore.rules                  Firestore access rules
firebase.json                    FlutterFire configuration and rules file reference
android/                         Android platform sources and configuration
web/                             Web platform sources and configuration
```

The app uses a small screen/service separation. No custom backend, additional state-management framework or unrelated architectural layers are included.

## Data model and security rules

Notes are stored at `users/{uid}/notes/{noteId}`. Documents contain `title`, `createdAt` and `updatedAt`; the list is ordered by creation time, newest first.

`firestore.rules` allows reads and writes only when the request is authenticated and its UID equals the user ID in that note's path. Other paths are not granted access by this ruleset. Client-side path selection alone is not an authorization boundary.

The rules file is an exact copy of the deployed rules text supplied by the project owner from Firebase Console on 4 October 2026. This preparation did not deploy rules or read user documents. Matching the actual deployed version was not independently checked through the console/API, and rules isolation is not covered by the current automated tests.

The rules enforce ownership, not a complete document-schema validation policy. This is a focused portfolio demo.

## Testing and verification

The four automated tests are **widget tests of the authentication form**:

1. Initial sign-in form rendering.
2. Switching to registration.
3. Switching back to sign-in.
4. Rejecting empty email/password fields.

They do not call Firebase Authentication, test the notes CRUD, verify session persistence or test Firestore Security Rules. The owner previously reported manual checks of registration, login, session behavior, logout and notes CRUD; these flows were not repeated against the live backend during this preparation.

On 4 October 2026:

- `flutter analyze`: `No issues found!`
- `flutter test`: four tests, `All tests passed!`
- Web: "flutter build web --release --no-wasm-dry-run" completed successfully (exit code 0). A non-fatal Cupertino font warning was emitted after removing the unused cupertino_icons dependency; no Cupertino widgets/icons are used by the application code.
- Android: debug build verification was stopped when Gradle attempted to install the missing Android SDK Platform 34 outside the project. No Android device was connected. Android runtime/release behavior was not verified.
- Web runtime smoke check: the release app started on localhost, displayed the authentication form, rejected empty credentials and switched between login/registration. No account was created, no credentials were submitted and no user documents were accessed.

Reproduce the local checks:

```bash
flutter pub get
flutter analyze
flutter test
```

## Run using your own Firebase project

1. Install a compatible Flutter SDK and the Firebase/FlutterFire CLI tools.
2. Run `flutter pub get`.
3. Create your own Firebase project and register Web and Android apps. Enable email/password Authentication and create a Cloud Firestore database.
4. Run `flutterfire configure --project=<your-project-id>` for Web and Android. For Android, use the package ID in `android/app/build.gradle.kts`, or update the package configuration consistently before registering it.
5. Confirm the generated `firebase_options.dart`, `google-services.json` and `firebase.json` all refer to your project. Review and deploy `firestore.rules` to **your own project** before using it; for example, `firebase deploy --only firestore:rules --project=<your-project-id>`.
6. Run `flutter run -d chrome`, or select an Android emulator/device shown by `flutter devices`.

Do not use the author's Firebase backend for your own development or store sensitive data in this demo. The checked-in Firebase files are client configuration, not administrative credentials. Firebase API keys identify the project; access control depends on Security Rules and the project's settings. API restrictions and quotas for the author's project were not audited in Firebase Console.

Android `local.properties`, IDE settings, caches, build output, service-account keys and signing credentials must remain local. Android release signing currently uses the scaffold's debug key configuration: this project is not prepared for Play Store distribution.

## Public demo

No verified public Hosting demo is available yet. No Hosting deployment was performed during this preparation.
