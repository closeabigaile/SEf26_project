# Installing WolfBite

These instructions cover Team 7's CSC 510 Project 2 application running locally
in Chrome. The application is in `Project3`, an inherited folder name.

## 1. Install the prerequisites

- **[Flutter SDK](https://docs.flutter.dev/install) 3.47.2:** Matches the version
  configured in CI. Download that version from the
  [SDK archive](https://docs.flutter.dev/install/archive).
- **[Git](https://git-scm.com/downloads/):** Used to clone the repository.
- **[Google Chrome](https://www.google.com/chrome/):** Used to run the web app.
- **Internet access:** Needed to download packages and use Firebase services.

Dart is included with Flutter. A code editor is optional.

Open a terminal and check your tools:

```bash
flutter --version
git --version
flutter doctor
flutter devices
```

Confirm Flutter reports version `3.47.2` and Chrome appears in the device list.
`flutter doctor` may also report missing tools for other platforms; those tools
are needed only if you are developing for those platforms.

## 2. Download the project

Run these commands from the folder where you want to keep the project:

```bash
git clone https://github.com/closeabigaile/SEf26_project.git
cd SEf26_project/Project3
```

If you already have a checkout, open its `Project3` folder instead of cloning
again. To test work on a different branch, switch to that branch before the
next step. Run all remaining commands from `Project3`.

## 3. Install application dependencies

```bash
flutter pub get
```

This downloads the packages declared in `pubspec.yaml`, using `pubspec.lock`
when possible. If the lockfile changes unexpectedly, review the change before
committing it. CI uses `flutter pub get --enforce-lockfile` to require the
recorded dependency resolution.

## 4. Review Firebase setup

The repository includes client configuration for the shared Firebase project,
`wolfbyte-proj1`. Normal application startup uses those files; it does not
require a Firebase CLI login or a downloaded service-account key.

See [Firebase Setup](Project3/FIREBASE_SETUP.md) if configuration needs to change.
Catalog access requires signing in through the application. Accounts from the
previous Firebase project do not automatically transfer to this project.

The shared project already has an imported NC APL catalog, as recorded in the
[upload report](Project3/FIREBASE_UPLOAD.md). Re-importing it is not an installation
step. Catalog maintenance and its additional tools are documented separately.

## 5. Run the application

```bash
flutter run -d chrome
```

Keep the terminal open while using the app. Use the sign-up screen to create an
application account, then log in, or log in with an existing account for this
Firebase project. A new account may initially have an empty basket and no
allowance entries.

To stop the app, press `q` in the terminal running Flutter.

## 6. Check the installation

Confirm that the app opens, you can sign in, and a known catalog product can be
looked up. Add an item and check that it appears in the basket. These steps
check live behavior separately from automated tests.

```bash
# Run the Flutter tests
flutter test

# Check that the web app builds
flutter build web --release
```

The build is saved in `Project3/build/web/` relative to the repository root.
Building does not publish the app online. See
[Contributing](Project3/CONTRIBUTING.md#8-testing-and-checks) for the additional
formatting, analysis, Python, and JavaScript checks.

## Troubleshooting

| Problem | What to check |
| ------- | ------------- |
| `flutter` is not found | Finish the Flutter installation, add its `bin` folder to your PATH, and reopen the terminal. |
| `pubspec.yaml` is not found | Run Flutter commands from `SEf26_project/Project3`. |
| Chrome is not listed | Install Chrome, restart the terminal, and run `flutter devices` again. |
| Dependency installation fails | Check the Flutter version, internet connection, and the specific error from `flutter pub get`. Avoid upgrading packages just to bypass an error. |
| Sign-in or catalog access fails | Check the displayed error, internet connection, application account, and Firebase configuration. Report permission errors to the maintainers rather than changing database rules. |

## Other platforms

Android and iOS require their own development tools and a configured device or
emulator. Native builds and device behavior have not yet been verified for this
version. Linux desktop is not configured in the current Firebase options;
this does not prevent using the web app in Chrome on Linux.

<!-- BEFORE FINAL SUBMISSION:
Repeat these steps from a fresh clone of the submission version and record
the tested operating system, Flutter version, commit, and observed results.
Add platform-specific installation instructions only after verification.
-->
