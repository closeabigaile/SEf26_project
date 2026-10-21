"""Check Firebase configuration consistency locally, without contacting Firebase."""

import json
from pathlib import Path
import plistlib
import re


ROOT = Path(__file__).resolve().parents[1]
PROJECT = "wolfbyte-proj1"
NUMBER = "108724297221"
BUNDLE = "com.example.wolfbite"


def read_json(relative_path):
    return json.loads((ROOT / relative_path).read_text())


def require(condition, message):
    if not condition:
        raise SystemExit(f"FAIL: {message}")


def main():
    require(read_json(".firebaserc")["projects"]["default"] == PROJECT,
            "Firebase CLI default project differs")
    source = (ROOT / "lib/firebase_options.dart").read_text()
    options = {
        platform: dict(re.findall(r"(\w+):\s*'([^']*)'", body))
        for platform, body in re.findall(
            r"static const FirebaseOptions (\w+) = FirebaseOptions\((.*?)\);",
            source, re.S,
        )
    }
    platforms = {"web", "android", "ios", "macos", "windows"}
    require(set(options) == platforms, "Expected all five configured platforms")
    metadata = read_json("firebase.json")["flutter"]["platforms"]
    dart = metadata["dart"]["lib/firebase_options.dart"]
    require(dart["projectId"] == PROJECT, "FlutterFire project differs")
    for platform, config in options.items():
        require(config["projectId"] == PROJECT, f"{platform}: wrong project")
        require(config["messagingSenderId"] == NUMBER, f"{platform}: wrong sender")
        kind = "android" if platform == "android" else (
            "ios" if platform in {"ios", "macos"} else "web")
        require(config["appId"].startswith(f"1:{NUMBER}:{kind}:"),
                f"{platform}: app registration belongs to another project/type")
        require(config["appId"] == dart["configurations"][platform],
                f"{platform}: FlutterFire app ID differs")
        require(config.get("apiKey", "").startswith("AIza"),
                f"{platform}: missing client API key")
        require(config["storageBucket"] == f"{PROJECT}.firebasestorage.app",
                f"{platform}: wrong storage bucket")
        if kind == "web":
            require(config["authDomain"] == f"{PROJECT}.firebaseapp.com",
                    f"{platform}: wrong auth domain")

    android = read_json("android/app/google-services.json")
    require(android == read_json("google-services.json"),
            "Root Android configuration copy differs from the build configuration")
    require(android["project_info"]["project_id"] == PROJECT,
            "Android native project differs")
    require(android["project_info"]["project_number"] == NUMBER,
            "Android native project number differs")
    clients = [client for client in android["client"] if
               client["client_info"]["android_client_info"]["package_name"] == BUNDLE]
    require(len(clients) == 1, "Android package does not match the app")
    client = clients[0]
    require(client["client_info"]["mobilesdk_app_id"] == options["android"]["appId"],
            "Android native/Dart app IDs differ")
    require(options["android"]["apiKey"] in [key["current_key"] for key in client["api_key"]],
            "Android native/Dart API keys differ")
    require(metadata["android"]["default"]["projectId"] == PROJECT and
            metadata["android"]["default"]["appId"] == options["android"]["appId"],
            "Android FlutterFire metadata differs")
    for platform in ("ios", "macos"):
        with (ROOT / platform / "Runner/GoogleService-Info.plist").open("rb") as handle:
            native = plistlib.load(handle)
        for native_key, dart_key in {
            "PROJECT_ID": "projectId", "GOOGLE_APP_ID": "appId",
            "GCM_SENDER_ID": "messagingSenderId", "API_KEY": "apiKey",
            "STORAGE_BUCKET": "storageBucket", "BUNDLE_ID": "iosBundleId",
        }.items():
            require(native[native_key] == options[platform][dart_key],
                    f"{platform}: native/Dart {native_key} differs")
        require(native["BUNDLE_ID"] == BUNDLE, f"{platform}: wrong bundle ID")
    print(f"PASS: CLI, FlutterFire metadata, and five platform configurations agree on {PROJECT}.")


if __name__ == "__main__":
    main()
