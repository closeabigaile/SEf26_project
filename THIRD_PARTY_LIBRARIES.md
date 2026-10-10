# Third-Party Libraries

WolfBite — Team 7, CSC 510 Project 2. Inventory reviewed on **2026-10-10**.

## Scope and evidence

This inventory lists all **115 packages in [pubspec.lock](Project3/pubspec.lock)**:
15 direct application dependencies, 5 direct development dependencies, and
95 transitive dependencies. Four of the 115 are supplied by the Flutter SDK.
It also records the Python dependencies and explicitly referenced Firebase and
Android tooling described below.

Inclusion means a dependency is declared or resolved by the project; it does
not mean every package is imported directly or used in every build. In particular,
`cupertino_icons`, `excel`, `fake_async`, `google_mlkit_commons`, and
`google_mlkit_text_recognition` remain declared dependencies even though the
README's shorter table omits them.

- **Dart versions and categories:** [pubspec.yaml](Project3/pubspec.yaml) and
  [pubspec.lock](Project3/pubspec.lock).
- **Hosted Dart licenses:** inspected `LICENSE` files from the matching package
  versions in the local Pub cache; `archive` also includes `LICENSE-other.md`.
  The tables link to each exact version's published license page.
- **SDK packages:** inspected the configured Flutter 3.47.2 SDK's license files.
  The lockfile's `0.0.0` SDK entries are placeholders, not separate release versions.
- **Python and other tooling:** declarations, package metadata, and upstream
  license sources are linked in their sections.

This is complete for the committed Dart lockfile and the identified declarations.
It is **not a resolved inventory of every native binary or external tool's own
transitive packages**: no committed CocoaPods, Gradle dependency, or Firebase CLI
npm lockfile establishes those full trees. Platform-specific dependencies may
vary with the target. Record those resolved inventories if native releases or
the external tooling are distributed; do not infer them from a Dart wrapper's license.

## Direct application dependencies

Declared under `dependencies` in `Project3/pubspec.yaml`.

| Package | Locked version / SDK | License summary | License source |
| --- | --- | --- | --- |
| `cloud_firestore` | 6.7.1 | BSD-3-Clause | [License](https://pub.dev/packages/cloud_firestore/versions/6.7.1/license) |
| `cupertino_icons` | 1.0.9 | MIT | [License](https://pub.dev/packages/cupertino_icons/versions/1.0.9/license) |
| `excel` | 4.0.6 | MIT | [License](https://pub.dev/packages/excel/versions/4.0.6/license) |
| `fake_async` | 1.3.3 | Apache-2.0 | [License](https://pub.dev/packages/fake_async/versions/1.3.3/license) |
| `firebase_auth` | 6.5.7 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_auth/versions/6.5.7/license) |
| `firebase_core` | 4.13.0 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_core/versions/4.13.0/license) |
| `flutter` | Flutter SDK 3.47.2 | BSD-3-Clause | [License](https://github.com/flutter/flutter/blob/d3b14c876900e553bc736ca19295fc09e3853e8e/LICENSE) |
| `go_router` | 16.3.0 | BSD-3-Clause | [License](https://pub.dev/packages/go_router/versions/16.3.0/license) |
| `google_mlkit_commons` | 0.11.1 | MIT | [License](https://pub.dev/packages/google_mlkit_commons/versions/0.11.1/license) |
| `google_mlkit_text_recognition` | 0.15.1 | MIT | [License](https://pub.dev/packages/google_mlkit_text_recognition/versions/0.15.1/license) |
| `http` | 1.6.0 | BSD-3-Clause | [License](https://pub.dev/packages/http/versions/1.6.0/license) |
| `image_picker` | 1.2.2 | BSD-3-Clause; bundled Apache-2.0 notice | [License](https://pub.dev/packages/image_picker/versions/1.2.2/license) |
| `mobile_scanner` | 7.4.0 | BSD-3-Clause | [License](https://pub.dev/packages/mobile_scanner/versions/7.4.0/license) |
| `provider` | 6.1.5+1 | MIT | [License](https://pub.dev/packages/provider/versions/6.1.5%2B1/license) |
| `qr_flutter` | 4.1.0 | BSD-3-Clause | [License](https://pub.dev/packages/qr_flutter/versions/4.1.0/license) |

## Direct development and test dependencies

Declared under `dev_dependencies` in `Project3/pubspec.yaml`.

| Package | Locked version / SDK | License summary | License source |
| --- | --- | --- | --- |
| `build_runner` | 2.15.1 | BSD-3-Clause | [License](https://pub.dev/packages/build_runner/versions/2.15.1/license) |
| `fake_cloud_firestore` | 4.2.0 | BSD-2-Clause | [License](https://pub.dev/packages/fake_cloud_firestore/versions/4.2.0/license) |
| `flutter_lints` | 5.0.0 | BSD-3-Clause | [License](https://pub.dev/packages/flutter_lints/versions/5.0.0/license) |
| `flutter_test` | Flutter SDK 3.47.2 | BSD-3-Clause | [License](https://github.com/flutter/flutter/blob/d3b14c876900e553bc736ca19295fc09e3853e8e/LICENSE) |
| `mockito` | 5.6.4 | Apache-2.0 | [License](https://pub.dev/packages/mockito/versions/5.6.4/license) |

## Transitive dependencies

Resolved through other packages and recorded as `transitive` in the lockfile.
This includes platform implementations and development/test support packages.

| Package | Locked version / SDK | License summary | License source |
| --- | --- | --- | --- |
| `_fe_analyzer_shared` | 93.0.0 | BSD-3-Clause | [License](https://pub.dev/packages/_fe_analyzer_shared/versions/93.0.0/license) |
| `_flutterfire_internals` | 1.3.76 | BSD-3-Clause | [License](https://pub.dev/packages/_flutterfire_internals/versions/1.3.76/license) |
| `analyzer` | 10.0.1 | BSD-3-Clause | [License](https://pub.dev/packages/analyzer/versions/10.0.1/license) |
| `antlr4` | 4.13.2 | BSD-3-Clause; bundled MIT notices | [License](https://pub.dev/packages/antlr4/versions/4.13.2/license) |
| `archive` | 3.6.1 | MIT; bundled BSD-3-Clause and bzip2-1.0.6 notices | [License](https://pub.dev/packages/archive/versions/3.6.1/license) |
| `args` | 2.7.0 | BSD-3-Clause | [License](https://pub.dev/packages/args/versions/2.7.0/license) |
| `async` | 2.13.1 | BSD-3-Clause | [License](https://pub.dev/packages/async/versions/2.13.1/license) |
| `boolean_selector` | 2.1.2 | BSD-3-Clause | [License](https://pub.dev/packages/boolean_selector/versions/2.1.2/license) |
| `build` | 4.0.7 | BSD-3-Clause | [License](https://pub.dev/packages/build/versions/4.0.7/license) |
| `build_config` | 1.3.2 | BSD-3-Clause | [License](https://pub.dev/packages/build_config/versions/1.3.2/license) |
| `build_daemon` | 4.1.2 | BSD-3-Clause | [License](https://pub.dev/packages/build_daemon/versions/4.1.2/license) |
| `built_collection` | 5.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/built_collection/versions/5.1.1/license) |
| `built_value` | 8.12.7 | BSD-3-Clause | [License](https://pub.dev/packages/built_value/versions/8.12.7/license) |
| `cel` | 0.5.4+1 | MIT | [License](https://pub.dev/packages/cel/versions/0.5.4%2B1/license) |
| `characters` | 1.4.1 | BSD-3-Clause | [License](https://pub.dev/packages/characters/versions/1.4.1/license) |
| `checked_yaml` | 2.0.4 | BSD-3-Clause | [License](https://pub.dev/packages/checked_yaml/versions/2.0.4/license) |
| `clock` | 1.1.2 | Apache-2.0 | [License](https://pub.dev/packages/clock/versions/1.1.2/license) |
| `cloud_firestore_platform_interface` | 8.0.6 | BSD-3-Clause | [License](https://pub.dev/packages/cloud_firestore_platform_interface/versions/8.0.6/license) |
| `cloud_firestore_web` | 5.7.2 | BSD-3-Clause | [License](https://pub.dev/packages/cloud_firestore_web/versions/5.7.2/license) |
| `code_builder` | 4.11.1 | BSD-3-Clause | [License](https://pub.dev/packages/code_builder/versions/4.11.1/license) |
| `collection` | 1.19.1 | BSD-3-Clause | [License](https://pub.dev/packages/collection/versions/1.19.1/license) |
| `convert` | 3.1.2 | BSD-3-Clause | [License](https://pub.dev/packages/convert/versions/3.1.2/license) |
| `cross_file` | 0.3.5+2 | BSD-3-Clause | [License](https://pub.dev/packages/cross_file/versions/0.3.5%2B2/license) |
| `crypto` | 3.0.7 | BSD-3-Clause | [License](https://pub.dev/packages/crypto/versions/3.0.7/license) |
| `dart_style` | 3.1.5 | BSD-3-Clause | [License](https://pub.dev/packages/dart_style/versions/3.1.5/license) |
| `equatable` | 2.1.0 | MIT | [License](https://pub.dev/packages/equatable/versions/2.1.0/license) |
| `fake_firebase_security_rules` | 0.5.4 | MIT | [License](https://pub.dev/packages/fake_firebase_security_rules/versions/0.5.4/license) |
| `file` | 7.0.1 | BSD-3-Clause | [License](https://pub.dev/packages/file/versions/7.0.1/license) |
| `file_selector_linux` | 0.9.4 | BSD-3-Clause | [License](https://pub.dev/packages/file_selector_linux/versions/0.9.4/license) |
| `file_selector_macos` | 0.9.5 | BSD-3-Clause | [License](https://pub.dev/packages/file_selector_macos/versions/0.9.5/license) |
| `file_selector_platform_interface` | 2.7.0 | BSD-3-Clause | [License](https://pub.dev/packages/file_selector_platform_interface/versions/2.7.0/license) |
| `file_selector_windows` | 0.9.3+5 | BSD-3-Clause | [License](https://pub.dev/packages/file_selector_windows/versions/0.9.3%2B5/license) |
| `firebase_auth_platform_interface` | 9.0.6 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_auth_platform_interface/versions/9.0.6/license) |
| `firebase_auth_web` | 6.2.6 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_auth_web/versions/6.2.6/license) |
| `firebase_core_platform_interface` | 8.1.0 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_core_platform_interface/versions/8.1.0/license) |
| `firebase_core_web` | 3.10.0 | BSD-3-Clause | [License](https://pub.dev/packages/firebase_core_web/versions/3.10.0/license) |
| `fixnum` | 1.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/fixnum/versions/1.1.1/license) |
| `flutter_plugin_android_lifecycle` | 2.0.34 | BSD-3-Clause | [License](https://pub.dev/packages/flutter_plugin_android_lifecycle/versions/2.0.34/license) |
| `flutter_web_plugins` | Flutter SDK 3.47.2 | BSD-3-Clause | [License](https://github.com/flutter/flutter/blob/d3b14c876900e553bc736ca19295fc09e3853e8e/LICENSE) |
| `glob` | 2.1.3 | BSD-3-Clause | [License](https://pub.dev/packages/glob/versions/2.1.3/license) |
| `graphs` | 2.3.2 | BSD-3-Clause | [License](https://pub.dev/packages/graphs/versions/2.3.2/license) |
| `http_multi_server` | 3.2.2 | BSD-3-Clause | [License](https://pub.dev/packages/http_multi_server/versions/3.2.2/license) |
| `http_parser` | 4.1.2 | BSD-3-Clause | [License](https://pub.dev/packages/http_parser/versions/4.1.2/license) |
| `image_picker_android` | 0.8.13+17 | BSD-3-Clause; bundled Apache-2.0 notice | [License](https://pub.dev/packages/image_picker_android/versions/0.8.13%2B17/license) |
| `image_picker_for_web` | 3.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/image_picker_for_web/versions/3.1.1/license) |
| `image_picker_ios` | 0.8.13+3 | BSD-3-Clause; bundled Apache-2.0 notice | [License](https://pub.dev/packages/image_picker_ios/versions/0.8.13%2B3/license) |
| `image_picker_linux` | 0.2.2 | BSD-3-Clause | [License](https://pub.dev/packages/image_picker_linux/versions/0.2.2/license) |
| `image_picker_macos` | 0.2.2+1 | BSD-3-Clause | [License](https://pub.dev/packages/image_picker_macos/versions/0.2.2%2B1/license) |
| `image_picker_platform_interface` | 2.11.1 | BSD-3-Clause | [License](https://pub.dev/packages/image_picker_platform_interface/versions/2.11.1/license) |
| `image_picker_windows` | 0.2.2 | BSD-3-Clause | [License](https://pub.dev/packages/image_picker_windows/versions/0.2.2/license) |
| `io` | 1.0.5 | BSD-3-Clause | [License](https://pub.dev/packages/io/versions/1.0.5/license) |
| `json_annotation` | 4.12.0 | BSD-3-Clause | [License](https://pub.dev/packages/json_annotation/versions/4.12.0/license) |
| `leak_tracker` | 11.0.2 | BSD-3-Clause | [License](https://pub.dev/packages/leak_tracker/versions/11.0.2/license) |
| `leak_tracker_flutter_testing` | 3.0.10 | BSD-3-Clause | [License](https://pub.dev/packages/leak_tracker_flutter_testing/versions/3.0.10/license) |
| `leak_tracker_testing` | 3.0.2 | BSD-3-Clause | [License](https://pub.dev/packages/leak_tracker_testing/versions/3.0.2/license) |
| `lints` | 5.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/lints/versions/5.1.1/license) |
| `logger` | 2.7.0 | MIT | [License](https://pub.dev/packages/logger/versions/2.7.0/license) |
| `logging` | 1.3.0 | BSD-3-Clause | [License](https://pub.dev/packages/logging/versions/1.3.0/license) |
| `matcher` | 0.12.20 | BSD-3-Clause | [License](https://pub.dev/packages/matcher/versions/0.12.20/license) |
| `material_color_utilities` | 0.13.0 | Apache-2.0 | [License](https://pub.dev/packages/material_color_utilities/versions/0.13.0/license) |
| `meta` | 1.19.0 | BSD-3-Clause | [License](https://pub.dev/packages/meta/versions/1.19.0/license) |
| `mime` | 2.0.0 | BSD-3-Clause | [License](https://pub.dev/packages/mime/versions/2.0.0/license) |
| `mock_exceptions` | 0.8.2 | MIT | [License](https://pub.dev/packages/mock_exceptions/versions/0.8.2/license) |
| `more` | 4.7.0 | MIT | [License](https://pub.dev/packages/more/versions/4.7.0/license) |
| `nested` | 1.0.0 | MIT | [License](https://pub.dev/packages/nested/versions/1.0.0/license) |
| `package_config` | 2.2.0 | BSD-3-Clause | [License](https://pub.dev/packages/package_config/versions/2.2.0/license) |
| `path` | 1.9.1 | BSD-3-Clause | [License](https://pub.dev/packages/path/versions/1.9.1/license) |
| `petitparser` | 7.0.2 | MIT | [License](https://pub.dev/packages/petitparser/versions/7.0.2/license) |
| `plugin_platform_interface` | 2.1.8 | BSD-3-Clause | [License](https://pub.dev/packages/plugin_platform_interface/versions/2.1.8/license) |
| `pool` | 1.5.2 | BSD-3-Clause | [License](https://pub.dev/packages/pool/versions/1.5.2/license) |
| `pub_semver` | 2.2.0 | BSD-3-Clause | [License](https://pub.dev/packages/pub_semver/versions/2.2.0/license) |
| `pubspec_parse` | 1.5.0 | BSD-3-Clause | [License](https://pub.dev/packages/pubspec_parse/versions/1.5.0/license) |
| `qr` | 3.0.2 | BSD-3-Clause | [License](https://pub.dev/packages/qr/versions/3.0.2/license) |
| `rx` | 0.5.0 | MIT | [License](https://pub.dev/packages/rx/versions/0.5.0/license) |
| `rxdart` | 0.28.0 | Apache-2.0 | [License](https://pub.dev/packages/rxdart/versions/0.28.0/license) |
| `shelf` | 1.4.2 | BSD-3-Clause | [License](https://pub.dev/packages/shelf/versions/1.4.2/license) |
| `shelf_web_socket` | 3.0.0 | BSD-3-Clause | [License](https://pub.dev/packages/shelf_web_socket/versions/3.0.0/license) |
| `sky_engine` | Flutter SDK 3.47.2 | BSD-3-Clause; component-specific bundled notices (see below) | [License](https://github.com/flutter/flutter/blob/d3b14c876900e553bc736ca19295fc09e3853e8e/LICENSE) |
| `source_gen` | 4.2.4 | BSD-3-Clause | [License](https://pub.dev/packages/source_gen/versions/4.2.4/license) |
| `source_span` | 1.10.2 | BSD-3-Clause | [License](https://pub.dev/packages/source_span/versions/1.10.2/license) |
| `stack_trace` | 1.12.1 | BSD-3-Clause | [License](https://pub.dev/packages/stack_trace/versions/1.12.1/license) |
| `stream_channel` | 2.1.4 | BSD-3-Clause | [License](https://pub.dev/packages/stream_channel/versions/2.1.4/license) |
| `stream_transform` | 2.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/stream_transform/versions/2.1.1/license) |
| `string_scanner` | 1.4.1 | BSD-3-Clause | [License](https://pub.dev/packages/string_scanner/versions/1.4.1/license) |
| `term_glyph` | 1.2.2 | BSD-3-Clause | [License](https://pub.dev/packages/term_glyph/versions/1.2.2/license) |
| `test_api` | 0.7.12 | BSD-3-Clause | [License](https://pub.dev/packages/test_api/versions/0.7.12/license) |
| `typed_data` | 1.4.0 | BSD-3-Clause | [License](https://pub.dev/packages/typed_data/versions/1.4.0/license) |
| `vector_math` | 2.4.2 | BSD-3-Clause | [License](https://pub.dev/packages/vector_math/versions/2.4.2/license) |
| `vm_service` | 15.3.0 | BSD-3-Clause | [License](https://pub.dev/packages/vm_service/versions/15.3.0/license) |
| `watcher` | 1.2.1 | BSD-3-Clause | [License](https://pub.dev/packages/watcher/versions/1.2.1/license) |
| `web` | 1.1.1 | BSD-3-Clause | [License](https://pub.dev/packages/web/versions/1.1.1/license) |
| `web_socket` | 1.0.1 | BSD-3-Clause | [License](https://pub.dev/packages/web_socket/versions/1.0.1/license) |
| `web_socket_channel` | 3.0.3 | BSD-3-Clause | [License](https://pub.dev/packages/web_socket_channel/versions/3.0.3/license) |
| `xml` | 6.6.1 | MIT | [License](https://pub.dev/packages/xml/versions/6.6.1/license) |
| `yaml` | 3.1.3 | MIT | [License](https://pub.dev/packages/yaml/versions/3.1.3/license) |

## Bundled license notices

A package's main license does not replace notices for code bundled inside it:

- **`antlr4` 4.13.2:** BSD-3-Clause, plus MIT notices for the bundled codepoint helpers.
- **`archive` 3.6.1:** MIT. Its `LICENSE-other.md` also identifies MIT code from
  zlib.js and PointyCastle, BSD-3-Clause code from JZLib, and the bzip2 1.0.6 license.
  Both files are included in the
  [versioned package archive](https://pub.dev/api/archives/archive-3.6.1.tar.gz).
- **`image_picker`, `image_picker_android`, and `image_picker_ios`:** their
  package license files contain BSD-3-Clause and Apache-2.0 notices.
- **Flutter / `sky_engine`:** the linked Flutter source license is BSD-3-Clause.
  The installed SDK's `bin/cache/pkg/sky_engine/LICENSE` additionally contains
  a large collection of component-specific notices, including MIT and Apache-2.0.
  Preserve the SDK's full notice file for a distributed build; the table's
  Flutter source link is not a substitute for those bundled notices.

## Python catalog tooling

[requirements-apl.txt](Project3/scripts/requirements-apl.txt) pins `openpyxl`.
[convert_nc_apl.py](Project3/scripts/convert_nc_apl.py) imports it, and the
[CI workflow](.github/workflows/flutter-ci.yml) installs the requirements file.
The installed `openpyxl` 3.1.5 distribution metadata declares `et_xmlfile` as
its dependency. Its local license files and those of `et_xmlfile` were inspected.

| Package | Version evidence | Purpose | License summary | Source |
| --- | --- | --- | --- | --- |
| `openpyxl` | 3.1.5, pinned in requirements | Read the APL spreadsheet | MIT | [Version metadata and license](https://pypi.org/project/openpyxl/3.1.5/) |
| `et_xmlfile` | Required by `openpyxl`; not pinned by this repository. Local inspected version: 2.0.0 | XML support for `openpyxl` | MIT; 2.0.0 also includes a Python license notice in `LICENCE.python` | [Inspected version](https://pypi.org/project/et-xmlfile/2.0.0/) |

The local `et_xmlfile` version is evidence for the inspected license, not a claim
that every installation or CI run resolves that version. Python standard-library
modules used by these scripts and M0 tests are supplied by Python, not additional
third-party package declarations.

## Firebase catalog-import tooling

| Package | Version evidence | Purpose | License | Source |
| --- | --- | --- | --- | --- |
| `firebase-tools` | 15.32.1, documented as tested in the import guide; externally installed | Authentication and REST helpers loaded by the APL importer | MIT | [Published version metadata](https://registry.npmjs.org/firebase-tools/15.32.1) |

Evidence: [import.js](Project3/scripts/import.js) loads Firebase CLI helpers, and
[FIREBASE_UPLOAD.md](Project3/FIREBASE_UPLOAD.md) documents the tested version.
This CLI is not a Flutter application package. Its external npm installation
has no committed lockfile here, so its transitive package versions are not asserted.
Node's `node:*` imports are built-in modules, not separate npm dependencies.

## Explicit Android dependencies and build tools

These entries are present in the Android configuration. Their inclusion does
not establish that a native build was run or that a feature is exercised.

| Dependency / tool | Declared version | License summary | Evidence / license source |
| --- | --- | --- | --- |
| Firebase Android BoM (`com.google.firebase:firebase-bom`) | 34.4.0 | Apache-2.0 | [Application declaration](Project3/android/app/build.gradle.kts); [published POM](https://dl.google.com/dl/android/maven2/com/google/firebase/firebase-bom/34.4.0/firebase-bom-34.4.0.pom) |
| Firebase Analytics (`com.google.firebase:firebase-analytics`) | No explicit version; BoM 34.4.0 specifies 23.0.0 | Android Software Development Kit License, as stated in its POM | [Application declaration](Project3/android/app/build.gradle.kts); [23.0.0 POM](https://dl.google.com/dl/android/maven2/com/google/firebase/firebase-analytics/23.0.0/firebase-analytics-23.0.0.pom) |
| Android Gradle Plugin (`com.android.application`) | 8.9.1 | Apache-2.0 | [Plugin declaration](Project3/android/settings.gradle.kts); [published POM](https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/8.9.1/gradle-8.9.1.pom) |
| Google Services Gradle plugin (`com.google.gms.google-services`) | 4.3.15 | Apache-2.0 | [Plugin declaration](Project3/android/settings.gradle.kts); [published POM](https://dl.google.com/dl/android/maven2/com/google/gms/google-services/4.3.15/google-services-4.3.15.pom) |
| Kotlin Android plugin (`org.jetbrains.kotlin.android`) | 2.1.0 | Apache-2.0; upstream includes third-party notices | [Plugin declaration](Project3/android/settings.gradle.kts); [Kotlin license](https://github.com/JetBrains/kotlin/blob/v2.1.0/license/LICENSE.txt); [notices](https://github.com/JetBrains/kotlin/blob/v2.1.0/license/README.md) |
| Gradle wrapper distribution | 8.12 | Apache-2.0; distribution includes additional notices | [Wrapper configuration](Project3/android/gradle/wrapper/gradle-wrapper.properties); [license and notices](https://github.com/gradle/gradle/blob/v8.12.0/LICENSE) |

The Firebase BoM specifies compatible versions; it is not itself an Analytics
implementation. The 23.0.0 entry above comes from that BoM, not an observed
resolved Android build. Flutter's Gradle plugins come from the Flutter SDK
already identified above. Apple Podfiles delegate plugin installation to Flutter;
no exact CocoaPods resolution is claimed here.

## Keeping this inventory current

When dependencies change, compare this document with `pubspec.yaml`,
`pubspec.lock`, the Python requirements, and the native/tooling declarations.
Update versions and verify the corresponding license files, including bundled
notices. Remove entries only when the underlying dependency is removed from
the project's declarations/resolution. Recheck unpinned dependencies against
the environment used for the submission.

The application's own license is in [Project3/LICENSE.md](Project3/LICENSE.md).
This inventory summarizes dependency licenses and links to their evidence.
