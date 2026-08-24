# WolfBite baseline: report, do not repair

Date observed: 2026-08-22

## Product and repository

- Product: WolfBite, a Flutter/Firebase WIC shopping assistant.
- Student fork: `https://github.com/closeabigaile/SEf26_project`
- Parent fork: `https://github.com/jacness12334/CSC510_P3_SRCG19`
- Original project: `https://github.com/SuyeshJadhav/CSC510_G19`
- Local clone: `/Users/abigailclose/Documents/CSC510/SEf26_project`
- Tested commit: `cc22b3c` (`main`, "receipt scanner updates").

## Commands and observations

The repository's `.metadata` identifies Flutter revision
`9f455d2486b6d785ea7ea706b65f09918e045cb1`, corresponding to Flutter 3.35.6
and Dart 3.9.2. That exact SDK was used from a temporary directory.

```text
cd /Users/abigailclose/Documents/CSC510/SEf26_project/Project3
flutter pub get
```

Result: PASS. Dependencies resolved and downloaded. The repository does not
commit a `pubspec.lock`; the generated lockfile is ignored, so dependency
resolution is not reproducible from the commit alone.

```text
flutter build web --release
```

Result: PASS. A release web build was produced.

```text
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

Result: PASS. The app served locally and displayed the WolfBite sign-in page.

```text
flutter test
```

Result: FAIL overall. Tests in the balances, login, and signup areas reached
passing results (22 tests passed before/among the compilation failures), but
five test files did not compile: the state, basket, scan, QR checkout, and APL
service areas. Fresh broad dependency resolution selected `cloud_firestore`
6.8.0 and `fake_cloud_firestore` 4.1.1; the fake package's `WriteBatch.update`
implementation no longer matches the interface required by the Firestore
package. This is evidence of dependency/code rot, not a repair made to the
project.

## Additional as-is findings

- `.github/workflows/flutter-ci.yml` uses `./Project2` as its working
  directory, but this commit contains `Project3`.
- The README's quick-start commands and several links also still refer to
  `Project2` or the original repository.
- The README advertises real-time order tracking, but the implemented routes
  are login, signup, scan, basket, balances, and receipt scanning; no order
  tracking module is present.
- No inherited source, workflow, dependency constraint, or test was edited.
  `git status --short` remained empty after the checks.

These are Project 1a findings. 
