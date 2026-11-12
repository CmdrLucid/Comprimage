# HANDOFF.md

Session date: 2026-11-12

## State

- App implemented on `dev` (English and German).
- `flutter analyze` is clean.
- 26 tests pass.
- CI build-only check on `dev` is added. Pushes to `dev` run analyze, test and
  the release APK build, and publish nothing.
- CI APK build verified green on `dev` (first build ~11 min).
- `v0.1.0` released from `main` (debug-signed APK on GitHub Releases).
- Not yet tested on a real device.
- Fixed (2026-11-12): newly taken photos did not appear in the picker. Cause:
  photo_manager's default `createTimeCond` caps at the time the albums were
  loaded. Now ignored; the picker also refreshes on resume, gallery changes
  and pull-to-refresh, keeping album and selection. Needs device check.

## Next steps

0. **CI will likely fail at `flutter analyze`.** The current Flutter stable
   (Dart 3.14, released 2026-11-09) deprecates `package:flutter/material.dart`
   in favour of `package:material_ui` (and `GlobalCupertinoLocalizations` in
   favour of `package:cupertino_ui`). That yields 16 `deprecated_member_use`
   infos across the codebase, and `flutter analyze` exits non-zero on infos.
   Options: migrate imports to `material_ui`/`cupertino_ui`, or pin
   `flutter-version` in the workflow. Not caused by the picker fix.

1. Test on a real device: gallery permission (including Android 14 partial
   access), both save modes, the replace confirmation, JPEG and WebP output,
   target size, cancel, and before/after compare.
2. Switch to a real release keystore:
   - Add repository secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
     `KEY_ALIAS` and `KEY_PASSWORD`.
   - Uncomment the "Decode keystore and create key.properties" step in the
     workflow.
   - Make `android/app/build.gradle.kts` read `android/key.properties` for the
     release `signingConfig`. It still uses the debug config.
3. Persist compression settings between launches. Only the language is saved
   today.

## Notes

- Licensed under GPL-3.0-only (`LICENSE`); repo is intended to be public.

- To release: bump `version` in `pubspec.yaml`, merge `dev` into `main`,
  then push a `vX.Y.Z` tag (locally) or run the workflow manually on `main`
  with `version=vX.Y.Z` (agent sessions cannot push tags, see LESSONS.md).
- Release URL: https://github.com/CmdrLucid/Comprimage/releases/tag/v0.1.0
- Optional: split APKs per ABI to shrink the 54 MB universal APK.

- `selectAllLoaded` and `newRun` exist in the ARB files but are not used in
  `lib/`. Remove them or wire them up.
- Manual workflow runs with an empty version field publish a pre-release named
  `dev-<run number>`.
