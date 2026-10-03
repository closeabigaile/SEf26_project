# Firebase setup

The shared Firebase project is **`wolfbyte-proj1`** (project number
`108724297221`). Keep this ID even if the display name changes.

## App registrations

| Platform | Firebase app ID | Package / bundle |
| --- | --- | --- |
| Web and Windows | `1:108724297221:web:f1684df4d5c0b4f9cac66c` | Existing WolfBite Demo web app |
| Android | `1:108724297221:android:9b181d15eb9f18decac66c` | `com.example.wolfbite` |
| iOS and macOS | `1:108724297221:ios:e51d62978c53c753cac66c` | `com.example.wolfbite` |

Android and Apple registrations were added on October 3, 2026. Apple targets
share a registration because they use the same bundle ID. Windows uses the web
configuration. Linux remains unsupported by the existing Firebase options.

`lib/main.dart` initializes the default Firebase app from
`lib/firebase_options.dart`. Authentication and Firestore use that default app.
The Android build also uses `android/app/google-services.json`; the root
`google-services.json` is an identical convenience copy. Apple targets use their
respective `Runner/GoogleService-Info.plist` files. `.firebaserc` selects the same
project for Firebase CLI commands; `firebase.json` records FlutterFire app IDs.

These files contain public client configuration and are tracked in Git. They
were populated from official `firebase apps:sdkconfig` downloads, not by replacing
the project ID in the old team's configuration. Admin credentials, passwords,
and CLI login tokens must stay outside the repository.

## Verify locally

From `Project3`:

```sh
python3 scripts/verify_firebase_config.py
flutter build web --no-pub
```

The Python check reads local files only. It checks that the project, app IDs,
API keys, and native configurations agree. It does not verify credentials or
Firestore permissions. After changing Firebase configuration, fully restart the
app rather than relying on hot reload. Do not assume accounts from the previous
Firebase project exist in this one.

To retrieve updated public configuration with the Firebase CLI, sign in using
the Google account that can access this project, then use `firebase apps:list
--project wolfbyte-proj1` and `firebase apps:sdkconfig PLATFORM APP_ID --project
wolfbyte-proj1`. Keep the native files, Dart options, and metadata synchronized
and run the check before committing changes.

## APL boundary

`AplService.findByUpc` reads `apl/{barcode}` from the default Firestore database.
Configuring Firebase does not import or refresh the North Carolina APL.

The JSON importer explicitly targets `wolfbyte-proj1` and uses the existing
Firebase CLI login. It defaults to a read-only preview, requires `--write` for
upload, and refuses conflicting existing products. It does not require a
downloaded service-account key. See [upload instructions and results](FIREBASE_UPLOAD.md).

For the September 2, 2026 workbook, use the local
[APL conversion workflow](scripts/APL_CONVERSION.md). It preserves source rows
and creates reviewed JSON input. `scripts/import.js` now supports that JSON.

## Verification on October 3, 2026

- Configuration consistency check passed for all five configured platforms.
- Web release build passed with the updated configuration.
- The built web app reached its login screen with no browser startup warnings
  or errors. No sign-in or account creation was performed during that check.
- Existing four APL service tests passed using fake Firestore.
- Importer destination checks rejected missing/wrong-project credentials and
  accepted the expected project in an isolated mock (no database writes).
- An unauthenticated live APL request returned `PERMISSION_DENIED`. This does not
  establish whether signed-in application users can read the catalog; verify
  that next using an existing app account. Rules were not changed to allow access.
- Native device builds and authenticated basket persistence were not tested.

No APL products, participant records, authentication providers, or security rules
were changed as part of the initial configuration update. Subsequently, the
September 2 NC APL was uploaded and signed-in access verified. See
[the upload record](FIREBASE_UPLOAD.md). The deployed security rules were preserved.
