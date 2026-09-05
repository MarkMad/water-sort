# Water Sort

A relaxing and addictive color-sorting puzzle game built with Flutter.

---


| Google Play | F-Droid |
| :---: | :---: |
| <a href="https://play.google.com/store/apps/details?id=com.sidhant.watersort"><img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Get it on Google Play" height="40" /></a> | <a href="https://f-droid.org/packages/com.sidhant.watersort"><img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid" height="60" /></a> |

---

<a href="https://ko-fi.com/M4M01C1R6J" target="_blank">
  <img src="https://storage.ko-fi.com/cdn/kofi2.png?v=6" alt="Buy Me a Coffee at ko-fi.com" height="36" />
</a>

## About

Sort the colored water in the tubes until each tube contains only one color. Simple to learn, challenging to master.

## Features

- **Infinite Levels** — Endless procedurally generated puzzles. No level cap, no waiting, no energy system. Play as long as you want.
- **100% Offline** — Works entirely offline. No internet required, no data collected.
- **Zero Tracking** — No analytics, no trackers, no fingerprints. Your gameplay stays on your device.
- **Ad-Free** — No banner ads, no interstitials, no rewarded videos. Just pure gameplay.
- **Privacy First** — No permissions required beyond basic storage. No network access. Your data never leaves your phone.
- **Clean UI** — Minimalist design with smooth animations and a relaxing color palette.


## Automated Android builds

Every push to `main` runs the regression tests and builds signed Android binaries with GitHub Actions. Open [Build and Release](https://github.com/MarkMad/water-sort/actions/workflows/build.yml), select a successful run, and download its artifact (retained for 30 days).

The download contains a universal APK, APKs for ARMv7/ARM64/x86-64, an Android App Bundle, a separate **Water Sort Test** APK, and SHA-256 checksums. The test APK installs alongside F-Droid or store copies with independent progress.

To publish a release, run the workflow manually and enter the tag matching `pubspec.yaml` (for example, `v1.0.15`). Leave the tag blank to generate artifacts only. Signing uses the repository's existing `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEY_PASSWORD`, and `KEY_ALIAS` secrets.

## Local testing on Android

To install alongside a store or F-Droid copy, build with a separate application ID:

```powershell
flutter build apk --release --android-project-arg=testBuild=true
```

This creates **Water Sort Test** (`com.sidhant.watersort.testing`) with its own progress. Normal builds retain the original application ID and name.

## License

GPL v3
