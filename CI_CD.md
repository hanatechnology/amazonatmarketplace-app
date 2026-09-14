# CI/CD — GitHub Actions + fastlane

`.github/workflows/cd.yml` runs two independent jobs:

| Job | Runner | Output |
|---|---|---|
| `ios` | `macos-26` | signed IPA → **TestFlight** |
| `android` | `ubuntu-latest` | signed APK → **Firebase App Distribution** |

Triggers: every push to `main`, or **Actions → CD → Run workflow** where you pick
the platform (`both` / `ios` / `android`) and the environment (`staging` / `prod`).

The runner is `macos-26` rather than `macos-15` on purpose: since 28 April 2026
App Store Connect rejects any upload not built with Xcode 26 / the iOS 26 SDK,
and the `macos-15` image tops out at Xcode 16.

---

## Versioning

The version **name** comes from `pubspec.yaml` (`version: 1.0.0+1` → `1.0.0`).

The build **number** comes from `GITHUB_RUN_NUMBER`, not from pubspec. TestFlight
and Play both reject a build number that was uploaded before, so tying it to the
run counter means every pipeline run is accepted with no manual bump. Local
`fastlane` runs fall back to the pubspec value.

This is what the account-page version footer shows — `1.0.0 (147) · staging` tells
you the exact CI run a tester is on.

---

## Environment

Both lanes compile with `--dart-define-from-file=env/<APP_ENV>.json`, default
`staging`. See `env/README.md`. `env/prod.json` still holds a `REPLACE-ME`
placeholder — fill it before running the workflow with `app_env: prod`.

---

## Required GitHub secrets

Settings → Secrets and variables → Actions.

### iOS

| Secret | What it is |
|---|---|
| `APPLE_ID` | Apple ID email on the developer account |
| `APPLE_TEAM_ID` | 10-char team ID, from developer.apple.com → Membership |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | Issuer ID shown above the key list |
| `ASC_KEY_CONTENT` | The `.p8` file, base64: `base64 -i AuthKey_XXX.p8 \| pbcopy` |
| `MATCH_GIT_URL` | HTTPS URL of the private certificates repo |
| `MATCH_GIT_TOKEN` | GitHub PAT with read access to that repo |
| `MATCH_PASSWORD` | Passphrase that encrypts the match repo |
| `MAPS_API_KEY_IOS` | Maps SDK key restricted to bundle ID `com.hanatech.marketplace` |

Create the API key at App Store Connect → Users and Access → Integrations → App
Store Connect API, role **App Manager**. The `.p8` downloads once — keep a copy.

### Android

| Secret | What it is |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_STORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias, e.g. `upload` |
| `ANDROID_KEY_PASSWORD` | key password |
| `FIREBASE_APP_ID_ANDROID` | `1:373526715379:android:49b88bc1587d738f7b9086` |
| `FIREBASE_SERVICE_ACCOUNT` | service account JSON, base64 |
| `MAPS_API_KEY_ANDROID` | Maps SDK key restricted to package + release SHA-1 |

Optional repository **variable** `FIREBASE_TESTER_GROUPS` overrides the default
tester group alias (`testers`).

Service account: Firebase console → Project settings → Service accounts →
Generate new private key, then grant it **Firebase App Distribution Admin** in
Google Cloud IAM.

---

## One-time setup before the first green run

1. **Apple Developer Program** membership, and bundle ID
   `com.hanatech.marketplace` registered with the Push Notifications capability.
2. **Certificates repo** — create a private repo, then once from your Mac:
   ```bash
   bundle exec fastlane match appstore
   ```
   This generates the distribution certificate and profile and pushes them
   encrypted. CI runs `readonly: true` and never creates anything.
3. **Upload keystore** for Android:
   ```bash
   keytool -genkey -v -keystore ~/amazonat-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Back it up. Losing it means you can never update the Play listing.
4. **Release SHA-1** from that keystore added to (a) the Android Maps key
   restrictions and (b) the Firebase Android app, then re-download
   `google-services.json`. Skip this and maps go grey and push breaks in the
   signed build while working fine in debug.
5. **TestFlight internal testing group** and a **Firebase tester group** named
   `testers` (or set `FIREBASE_TESTER_GROUPS`).

---

## Running a lane locally

```bash
bundle install
APP_ENV=staging APPLE_TEAM_ID=XXXXXXXXXX bundle exec fastlane ios beta
APP_ENV=staging bundle exec fastlane android beta
```

The Android lane refuses to run without `android/key.properties` — otherwise
Gradle silently falls back to debug signing and testers get an APK that cannot be
upgraded in place later.

---

## Notes on the two awkward bits

**`env -u RUBYOPT …` around `flutter build ipa`.** The lane runs under
`bundle exec`, so `RUBYOPT=-rbundler/setup` and `GEM_HOME`/`GEM_PATH` restrict gem
lookup to the bundle. `flutter build ipa` spawns `pod` to validate CocoaPods;
`pod` is a Ruby script, inherits those variables, and then cannot find the
cocoapods gem → *"CocoaPods broken"*. Unsetting them for that one subprocess
restores normal lookup. `flutter` itself is a Dart binary and is unaffected.

**`flutter build ipa` instead of `gym`/`build_app`.** `gym` calls `xcodebuild`
without Flutter's xcargs (`FLUTTER_ROOT`, `FLUTTER_BUILD_MODE`, …). Xcode 26
changed how xcconfig variables propagate into build-phase scripts during archive,
so the Thin Binary phase receives an empty `FLUTTER_ROOT` and exits → *ARCHIVE
FAILED*. `flutter build ipa` passes every xcarg explicitly.
