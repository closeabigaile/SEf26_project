# WolfBite 🐺

<p align="center">
    <!-- Working-branch preview. Before final submission, change all nine badge
         image/report paths to ci-evidence/main/ and both workflow branch
         filters to main, then verify the published main reports. -->
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/build.svg"
             alt="Web build">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/tests.svg"
             alt="Flutter test count and results">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/coverage.svg"
             alt="Dart line coverage">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/style.svg"
             alt="Style: Dart analyzer result">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/formatter.svg"
             alt="Dart formatter">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/syntax.svg"
             alt="Syntax: Dart analyzer result">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/firebase.svg"
             alt="Firebase configuration consistency">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/python.svg"
             alt="Python checks">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/docs/ReadMe_Update/README.md">
        <img src="https://raw.githubusercontent.com/closeabigaile/SEf26_project/ci-evidence/docs/ReadMe_Update/javascript.svg"
             alt="JavaScript tests">
    </a>
    <a href="Project2/LICENSE.md">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg"
             alt="License: MIT">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project/issues">
        <img src="https://img.shields.io/github/issues/closeabigaile/SEf26_project"
             alt="GitHub Issues">
    </a>
    <!-- UPDATE IF TOOLCHAIN CHANGES: Match the Flutter CI configuration.-->
    <a href=".github/workflows/flutter-ci.yml">
        <img src="https://img.shields.io/badge/Flutter%20%28CI%29-3.47.2-02569B?logo=flutter&amp;logoColor=white"
             alt="Flutter configured for CI: 3.47.2">
    </a>
    <!-- Combined workflow status: web build, tests, Dart lint/static analysis,
         formatting, and documentation deployment. Not a coverage percentage. -->
    <a href="https://github.com/closeabigaile/SEf26_project/actions/workflows/flutter-ci.yml?query=branch%3Adocs%2FReadMe_Update">
        <img src="https://github.com/closeabigaile/SEf26_project/actions/workflows/flutter-ci.yml/badge.svg?branch=docs%2FReadMe_Update&amp;event=push"
             alt="Flutter CI">
    </a>
    <a href="https://github.com/closeabigaile/SEf26_project">
        <img src="https://img.shields.io/github/stars/closeabigaile/SEf26_project?style=social"
             alt="GitHub Stars">
    </a>
</p>

**🎬 Project 2 teaser — 18 seconds**

https://github.com/user-attachments/assets/b2ab8bb9-fdce-4d43-b549-b2f909a34a38

[Feature walkthrough — 3 minutes, 26 seconds](Project2/docs/videos/WolfBite%20Walkthrough.mov)

The [original teaser](Project2/docs/videos/Wolfbite%20Teaser%20Video.mov) and
walkthrough are also available in the repository. To watch a repository video,
select **View raw** or **Download raw file** and open the `.mov` file in a video player.

These badges show the latest published CI evidence for **`docs/ReadMe_Update`**.
For the final submission, switch the badge URLs and workflow filters to `main`
and verify its published reports. Style and syntax
share the strict Dart analyzer result; tests and coverage cover the Flutter
suite. Each generated badge links to the report, source commit, and CI run.
See [badge reporting](.github/scripts/README.md) for scope and publication details.

<p align="center">
    <strong>A WIC shopping assistant for product lookup, basket management, and checkout guidance</strong>
</p>

<p align="center">
    Extended by Team 7 for CSC 510 Project 2 at NC State University,
    building on the previous teams’ WolfBite implementation.
</p>

<p align="center">
    <a href="#-features">Features</a> •
    <a href="#-quick-start">Quick Start</a> •
    <a href="#-documentation">Documentation</a> •
    <a href="#-contributing">Contributing</a> •
    <a href="#-license">License</a>
</p>

---

## 📖 About

**WolfBite** is a WIC shopping-assistance prototype developed for
CSC 510 Software Engineering at NC State University. It is intended
to help people shopping with WIC benefits find product information,
manage their shopping basket, and understand checkout guidance.

Team 7 is extending the previous teams’ Flutter/Firebase application
for Project 2, including an imported North Carolina WIC Authorized
Product List (APL) and item-level checkout help.

The application is in `Project2/` (formerly `Project3/`). Historical reports
and saved test logs retain the folder name used when they were recorded.

### Key Highlights

- 🔍 **Product Lookup:** Scan or enter a barcode to look up products
  in the imported NC WIC APL.
- 🛒 **Basket Management:** Add products, adjust quantities, and
  review the application's saved allowance information.
- 🥗 **Nutrition and Basket Balance:** Read nutrient values with units and
  missing-data labels, compare alternatives, and preview optional basket swaps.
- 💬 **Checkout Help:** View guidance about items in
  your basket. Checkout-rejection explanations currently use
  synthetic sample scenarios for demonstration.
- 🔐 **User Accounts:** Sign up and sign in using Firebase Authentication.

**Prototype limitations:** The APL identifies products listed in the
imported catalog version. WolfBite's demo allowances are not connected
to a participant's official WIC benefit account, and checkout guidance
does not guarantee acceptance at the register.

---

## 🎬 Demo Videos

### Project 2

- [Teaser — 18 seconds](https://github.com/user-attachments/assets/b2ab8bb9-fdce-4d43-b549-b2f909a34a38)
- [Feature walkthrough — 3 minutes, 26 seconds](Project2/docs/videos/WolfBite%20Walkthrough.mov)

The walkthrough shows product lookup, alternatives, nutrition details, basket
quantities, benefits, and QR checkout. See the [User Guide](USER_GUIDE.md) for
instructions and the [testing record](Project2/docs/TESTING.md) for the scope
of automated checks and remaining demonstration verification.

### Previous - Team Demo

[View previous-team demo materials](https://drive.google.com/drive/folders/1f9GWDyXS6KWoICaTHnpUJQOfn6ZkmLgA?usp=sharing)


---

## ✨ Features

### Team 7 - Project 2 Updates

- **North Carolina APL Integration:** Look up products in the imported
  NC WIC catalog; catalog listing does not confirm remaining benefits.

- **Checkout-Help Evaluation (M0):** Scenarios, tests, and scoring tools
  evaluate whether a shopper identifies the expected next step within
  60 seconds. The scorer and CI exercise explicitly synthetic passing and
  failing examples; a real-participant study has not been conducted.
  See the [evaluation results and limitations](Project2_Work/M0/m0_evaluation_results.md).

- **Clearer Nutrition Information (M1):**
  Displays nutrient values with units, serving-basis labels, explanations,
  and alternative-product tradeoffs. Missing values appear as **Unknown**
  and do not earn favorable nutrition badges. Available nutrition comes from
  product records or the separate nutrition collection; it is not available
  for every APL product.

- **Basket-Aware Suggestions (M2):**
  **Check basket balance** summarizes the basket's nutrition with quantities
  included and previews same-category swaps using available catalog and
  nutrition data. A swap requires the shopper's confirmation. Suggestions
  respect application-managed allowances and can be withheld when data is
  insufficient. Comparison targets are illustrative, not personal dietary goals.

- **Shopping Interface Improvements (M3):**
  Updated scan, basket, benefits, and receipt screens provide product details,
  quantity controls, and loading or empty states. Tests cover lookup errors,
  allowance limits, small-screen scan layouts, basket-control tooltips, and
  long product names.

- **Item-Level Checkout Help (M4):**
  Opens guidance for basket items and provides **Try sample checkout help**
  scenarios for checkout-rejection explanations. Sample scenarios are
  synthetic; saved allowances are not official participant benefits, and
  the app does not receive live retailer rejection data.

These descriptions reflect the merged implementation and automated tests.
See [Testing WolfBite](Project2/docs/TESTING.md) for commit-specific results,
manual checks, and remaining gaps; automated checks are not real-user outcomes.

### Inherited Features

- **Barcode and Manual Lookup:** Scan a barcode or enter a product code to search the catalog.
- **User Authentication:** Sign up and log in with Firebase Authentication.
- **Shopping Basket:** Add items, change quantities, and save your basket.
- **Demo Allowance Tracking:** Track application-managed category limits and usage.
- **Nutrition and Alternatives:** Explore nutrition displays and alternative products, extended by the M1 and M2 improvements above; comparisons depend on available data.
- **QR Basket Summary:** Generate a QR code containing your basket data; retailer checkout support is unverified.
- **Receipt OCR Import:** Sends a selected or captured receipt image to OCR.space, extracts product codes, and looks up catalog matches for the basket. A successful live receipt scan has not been verified in the recorded checks.

---

## 🚀 Quick Start

For step-by-step setup and troubleshooting, see [INSTALL.md](INSTALL.md).

### Prerequisites

Before you begin, ensure you have the following installed:

- **[Flutter SDK](https://docs.flutter.dev/install) 3.47.2:**
  Matches the project's CI configuration. Specific versions are
  available in the [SDK archive](https://docs.flutter.dev/install/archive).
- **[Dart SDK](https://dart.dev/get-dart)** Included with Flutter; no separate installation required.
- **[Git](https://git-scm.com/downloads/)** 
- **[Google Chrome](https://www.google.com/chrome/)** 
- **Code editor (optional):** Android Studio, IntelliJ IDEA or [Visual Studio Code](https://code.visualstudio.com/) recommended.

Firebase client configuration is included in the repository.
Review [Firebase setup](Project2/FIREBASE_SETUP.md) before running the app.


### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/closeabigaile/SEf26_project.git
   cd SEf26_project/Project2
   ```

   Run the remaining commands from this directory.

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

   This uses the dependency versions recorded in the repository.

3. **Review Firebase configuration**

   The repository includes client configuration for the team's shared
   Firebase project. An internet connection is required for authentication
   and catalog access.

   See [Firebase setup](Project2/FIREBASE_SETUP.md) for configuration details.

4. **Run the application**

   ```bash
   # For web
   flutter run -d chrome

   # For mobile (with device connected)
   flutter run

   # For specific platform
   flutter run -d <device_id>
   ```

   Android and iOS require their respective development tools and a
   configured device or emulator. Native builds and device behavior
   have not yet been verified for this version.

5. **Build for production**

   ```bash
   # Android APK
   flutter build apk --release

   # iOS
   flutter build ios --release

   # Web
   flutter build web --release
   ```

---

## 📦 Dependencies

This table covers packages referenced by the application, tests, or development
configuration. For all declared dependencies, see
[pubspec.yaml](Project2/pubspec.yaml). Versions below are the exact versions
recorded in [pubspec.lock](Project2/pubspec.lock), rather than the allowed
version ranges. SDK packages are supplied by Flutter; see Prerequisites for
the configured SDK version. Transitive dependencies are listed in the lockfile.

| Package | Version | Purpose | License | Documentation | Mandatory/Optional |
| ------- | ------- | ------- | ------- | ------------- | ------------------ |
| `flutter` | Flutter SDK | Application framework and UI widgets | BSD 3-Clause | [Docs](https://api.flutter.dev/flutter/) | Mandatory |
| `firebase_core` | 4.13.0 | Firebase initialization | BSD 3-Clause | [Docs](https://pub.dev/packages/firebase_core/versions/4.13.0) | Mandatory |
| `firebase_auth` | 6.5.7 | User authentication | BSD 3-Clause | [Docs](https://pub.dev/packages/firebase_auth/versions/6.5.7) | Mandatory |
| `cloud_firestore` | 6.7.1 | Product catalog, profiles, and saved basket state | BSD 3-Clause | [Docs](https://pub.dev/packages/cloud_firestore/versions/6.7.1) | Mandatory |
| `go_router` | 16.3.0 | Screen navigation and routing | BSD 3-Clause | [Docs](https://pub.dev/packages/go_router/versions/16.3.0) | Mandatory |
| `provider` | 6.1.5+1 | Shared application state | MIT | [Docs](https://pub.dev/packages/provider/versions/6.1.5%2B1) | Mandatory |
| `mobile_scanner` | 7.4.0 | Camera barcode scanning | BSD 3-Clause | [Docs](https://pub.dev/packages/mobile_scanner/versions/7.4.0) | Mandatory |
| `qr_flutter` | 4.1.0 | Basket QR code generation | BSD 3-Clause | [Docs](https://pub.dev/packages/qr_flutter/versions/4.1.0) | Mandatory |
| `image_picker` | 1.2.2 | Receipt image selection and capture | BSD 3-Clause; bundled Apache 2.0 notice | [Docs](https://pub.dev/packages/image_picker/versions/1.2.2) | Mandatory |
| `http` | 1.6.0 | Receipt OCR requests | BSD 3-Clause | [Docs](https://pub.dev/packages/http/versions/1.6.0) | Mandatory |
| `flutter_test` | Flutter SDK | Flutter unit and widget testing | BSD 3-Clause | [Docs](https://api.flutter.dev/flutter/flutter_test/) | Development/testing |
| `mockito` | 5.6.4 | Test mocks | Apache 2.0 | [Docs](https://pub.dev/packages/mockito/versions/5.6.4) | Development/testing |
| `fake_cloud_firestore` | 4.2.0 | In-memory Firestore for tests | BSD 2-Clause | [Docs](https://pub.dev/packages/fake_cloud_firestore/versions/4.2.0) | Development/testing |
| `build_runner` | 2.15.1 | Code generation for test mocks | BSD 3-Clause | [Docs](https://pub.dev/packages/build_runner/versions/2.15.1) | Development/testing |
| `flutter_lints` | 5.0.0 | Dart lint rules | BSD 3-Clause | [Docs](https://pub.dev/packages/flutter_lints/versions/5.0.0) | Development/testing |

**Licenses:** Entries summarize the package license files for the recorded
versions. Refer to the linked package pages for full license text and notices.

See [Third-Party Libraries](THIRD_PARTY_LIBRARIES.md)
for the dependency and license inventory, its evidence, and its scope limits.

> **Note:** Run `flutter pub get` from `Project2` to resolve and download
> dependencies. Flutter SDK packages are supplied by the installed SDK.


## 🧪 Testing

Run the test suite to ensure code quality:

```bash
# Run all Flutter tests
flutter test

# Run all Flutter tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/screens/signup_page_test.dart
```

Coverage is saved to `coverage/lcov.info`.
See [CI checks](.github/workflows/flutter-ci.yml) for additional
Python, JavaScript, formatting, analysis, and build checks.

---

## 📚 Documentation


- [User Guide](USER_GUIDE.md) — Product lookup, basket management, nutrition comparisons, checkout help, receipt import, and troubleshooting.
- [Previous-team documentation](https://suyeshjadhav.github.io/CSC510_G19/) — Historical reference; use the guide above for the current application.

- [Installation Guide](INSTALL.md) — Local setup, launch instructions, and troubleshooting.
- [Firebase Setup](Project2/FIREBASE_SETUP.md) — Application configuration.
- [APL Import Guide](Project2/FIREBASE_UPLOAD.md) — Catalog import instructions and results.
- [Contributing Guidelines](Project2/CONTRIBUTING.md) — Development and contribution process.
- [Code of Conduct](Project2/CODE_OF_CONDUCT.md) — Community guidelines.
- [AI Usage and Human Review](AI_USAGE.md) — Recorded AI assistance and human review status.

---

## 🤝 Contributing

We welcome contributions! Our contribution process builds on the
previous team’s guidelines, updated for Team 7’s Project 2 work.
See our [Contributing Guidelines](Project2/CONTRIBUTING.md) for details on:

- Setting up the development environment
- Code style and standards
- Submitting pull requests
- Reporting issues

### Development Workflow

1. Fork the repository
2. Create a descriptively named branch (`git checkout -b your-branch-name`).
3. Make your changes and run the relevant tests and checks.
4. Stage and commit your changes.
5. Push your branch (`git push -u origin your-branch-name`).
6. Open a pull request describing your changes and test results.

---

## 👥 Team

### Group 7 - CSC 510, Fall 2026

| Name                     | Role
| ------------------------ | ----------
| Abigail Close            | Developer
| Aditya Mahajan           | Developer
| Satwi Shah               | Developer
| Supreme Constantine      | Developer

### Previous Contributors

WolfBite builds on the work of previous CSC 510 teams.

The inherited README credits these Group 19 developers:

- Jacob Phillips
- Aarya Rajoju
- Aadya Maurya
- Galav Sharma
- Janelle Correia

It also acknowledges Group 1.

---

## 📄 License

This project is licensed under the MIT License.
See [LICENSE.md](Project2/LICENSE.md), which retains the original
authors’ copyright notice.

---


## 📞 Support

- **Questions and bug reports**: [GitHub Issues](https://github.com/closeabigaile/SEf26_project/issues)
- **Email**: Coming soon.

---

<p align="center">
    Made with ❤️ by CSC510 Group 19, Group 1 and Group 7!
</p>

<p align="center">
    <sub>Built with Flutter • Powered by Firebase</sub>
</p>
