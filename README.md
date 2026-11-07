# Comprimage

Comprimage is an Android app that makes your photos smaller. Pick photos from
your gallery, choose how they should be compressed, and save the smaller
versions, either as new copies or by replacing the originals. All processing
happens on the device.

## Features

- **Gallery multi-select**: browse all photos or a single album, select as many
  as you like, then continue. With Android 14 partial access, a banner lets you
  change the selection.
- **Output formats**: JPEG or WebP.
- **Quality slider**: 10 to 100.
- **Maximum edge length**: original size, 3840, 2560, 1920 or 1280 px. Images
  are never upscaled.
- **Presets**: Small (quality 55, 1280 px), Medium (quality 75, 1920 px) and
  High (quality 90, 2560 px).
- **Target size**: optionally set a maximum size per photo in KB or MB. The app
  searches for the highest quality that fits and lowers the resolution if
  needed. Photos that cannot reach the target are marked as such.
- **Metadata removal**: EXIF data, including GPS location, is removed by
  default. This applies to JPEG output. Turning the option off keeps EXIF in JPEG
  output. WebP output never contains EXIF data.
- **Save modes**:
  - *Save as copy* (default): saves to `Pictures/Comprimage` as
    `<name>_comprimage.jpg` or `.webp`. Originals stay untouched.
  - *Replace originals*: saves the compressed file next to the original and
    deletes the original. Android asks you to confirm the deletion.
- **Skip if not smaller**: if the compressed file is not smaller than the
  original, nothing is saved and the photo is reported as skipped.
- **Batch progress with cancel**: photos are processed one at a time. Cancelling
  asks for confirmation; photos that were already processed are kept.
- **Results and comparison**: a summary of total savings, a line per photo, and a
  before/after slider to compare the original with the compressed image.
- **Languages**: English and German. The app follows the system language and
  falls back to English. The language can be changed from the app bar.

Compression settings are chosen for each run. Only the language is remembered
between launches.

## Install

1. Download `comprimage-vX.Y.Z.apk` from the
   [GitHub Releases](../../releases) page on your Android device.
2. Open the file and allow installation from this source if Android asks.

Release APKs are currently signed with the Android debug key. That is fine for
testing, but the signing will change once a real release keystore is in place.

### Permissions

The app asks for access to your photos (`READ_MEDIA_IMAGES` on Android 13+,
`READ_MEDIA_VISUAL_USER_SELECTED` for partial access, and the external storage
permissions on Android 12 and older). `ACCESS_MEDIA_LOCATION` is used to read
GPS data of the originals. The manifest does not request internet access.

## Development

Requirements: a Flutter SDK matching the Dart constraint in `pubspec.yaml`
(`^3.13.7`), and the Android SDK for building APKs. CI uses Java 17.

```sh
flutter pub get        # install dependencies
flutter analyze        # static analysis, must report no issues
flutter test           # unit and widget tests
flutter gen-l10n       # regenerate localization code after editing lib/l10n/*.arb
flutter run            # run on a connected device
flutter build apk --release
```

Strings live in `lib/l10n/app_en.arb` (template) and `lib/l10n/app_de.arb`.
Generated localization code in `lib/l10n/app_localizations*.dart` must not be
edited by hand.

See [CODEMAP.md](CODEMAP.md) for the project layout and
[CLAUDE.md](CLAUDE.md) for contribution conventions.

## Releasing

The workflow is `.github/workflows/build-release.yml`. It runs analysis, tests
and a release APK build, then publishes a GitHub Release with the APK attached.

- **Tag release**: push a tag `vX.Y.Z` (for example `v0.1.0`). This creates a
  regular release with `comprimage-vX.Y.Z.apk`.
- **Manual release**: open Actions, choose *Build & Release APK*, and run it
  from `main`. Enter a tag such as `v0.1.0` in the version field. If the field
  is empty, the run publishes a pre-release named `dev-<run number>`.
- **Push to `dev`**: runs analysis, tests and the release build only. Nothing
  is published.

Workflow runs do not upload artifacts. APKs are only available through Releases.

## Branch model

- Develop on `dev`.
- Release from `main`: merge `dev` into `main`, then tag or run the workflow
  from `main`.

## License

Copyright (C) 2026 CmdrLucid

Comprimage is free software: you can redistribute it and/or modify it under
the terms of the [GNU General Public License v3.0](LICENSE) as published by the
Free Software Foundation. Modified versions must be released under the same
license. It is distributed WITHOUT ANY WARRANTY.

Third-party packages keep their own licenses (e.g. `photo_manager`:
Apache-2.0, `flutter_image_compress`: MIT), both compatible with GPL-3.0.
