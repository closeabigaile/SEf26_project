# Fresh-clone installation check — October 19, 2026

This record checks [INSTALL.md](../../../INSTALL.md) against commit
[`3f1379ec15be9b7b093e5a291c6e05a9c50bf603`](https://github.com/closeabigaile/SEf26_project/commit/3f1379ec15be9b7b093e5a291c6e05a9c50bf603),
available on `test_all_milestones` when checked. It is the committed base of
`docs/ReadMe_Update`, not the eventual submission commit. Uncommitted
documentation edits were not copied into this checkout.

## Environment

| Item | Observed value |
| --- | --- |
| Date | October 19, 2026 (EDT) |
| Platform | macOS 26.6.2, build 25G83, Apple Silicon (`arm64`) |
| Flutter | 3.47.2, stable, revision `d3b14c8769` |
| Dart | 3.13.2 |
| Git | 2.50.1 (Apple Git-155) |
| Chrome | 155.0.8059.85 |
| Target | Chrome/web |

The source was freshly cloned from GitHub into a temporary directory. Flutter,
Chrome, and a Pub package cache were already installed. This checks a fresh
source checkout, not SDK installation on a clean OS or an empty package cache.

`flutter devices` detected Chrome. `flutter doctor` passed Flutter, Chrome,
connected-device, and network checks. It reported a missing Android SDK,
incomplete Xcode, and missing CocoaPods; native platforms were not tested.

## Procedure and results

From a temporary parent directory:

```sh
git clone https://github.com/closeabigaile/SEf26_project.git
cd SEf26_project
git checkout --detach 3f1379ec15be9b7b093e5a291c6e05a9c50bf603
git rev-parse HEAD
git status --porcelain
cd Project3
```

The initial working tree was clean. These commands ran from `Project3` using
the existing SDK and included Firebase client configuration. No catalog upload,
Firebase CLI login, dependency upgrade, or application-code change was needed.

| Command | Result | Evidence |
| --- | --- | --- |
| `flutter pub get` | Exit 0; dependencies resolved; `pubspec.lock` unchanged. | [Dependency output](pub-get.txt) |
| `flutter test` | Exit 0; **377 tests passed**. | [Full test output](flutter-test.txt) |
| `flutter build web --release` | Exit 0; generated `build/web`. | [Build output](build-web.txt) |
| `flutter run -d chrome --web-port 8766` | Launched Chrome and connected to the debug service. The explicit port identifies this check. | [Startup output](run-chrome-startup.txt) |
| `git status --porcelain` after setup, tests, build, and launch | Empty; no tracked or unignored changes in the fresh checkout. | Observed during this check. |

Dependency resolution reported 63 packages with newer versions outside the
current constraints. This informational notice did not prevent installation
or change the lockfile. The build's Wasm dry run succeeded; no separate Wasm
application was manually tested.

Saved logs preserve command output, with trailing whitespace normalized and
the temporary checkout path replaced by `<fresh-clone>`. Startup output ends before interactive app use and contains
no sign-in credentials.

## Live checks and human review

Abigail Close completed the requested live check in the fresh Chrome session
and reported: "Did the live check. everything looks good."

| Live check | Result |
| --- | --- |
| Application renders and sign-in succeeds | Passed, reported by Abigail Close. |
| Look up a known catalog product | Passed, reported by Abigail Close. |
| Add the product and confirm it appears in My Basket | Passed, reported by Abigail Close. |

These are human-reported results, separate from the automated test and build
results above. The product name/UPC was not supplied, so no specific product
or catalog coverage is claimed. No corrections or errors were reported.

## Submission follow-up

Repeat the fresh-clone check for the final submission commit and record its
hash, environment, results, and human reviewer. This record does not verify
GitHub Pages publication, native platforms, camera scanning, or every feature.
