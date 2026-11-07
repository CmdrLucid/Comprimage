# HANDOFF.md

Session date: 2026-11-07

## State

- App implemented on `dev` (English and German).
- `flutter analyze` is clean.
- 26 tests pass.
- CI build-only check on `dev` is added. Pushes to `dev` run analyze, test and
  the release APK build, and publish nothing.
- First release is pending.
- Not yet tested on a real device.

## Next steps

1. Verify the CI APK build on `dev`.
2. Merge `dev` into `main`.
3. Tag `v0.1.0` on `main` to publish the first release.
4. Test on a real device: gallery permission (including Android 14 partial
   access), both save modes, the replace confirmation, JPEG and WebP output,
   target size, cancel, and before/after compare.
5. Switch to a real release keystore:
   - Add repository secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
     `KEY_ALIAS` and `KEY_PASSWORD`.
   - Uncomment the "Decode keystore and create key.properties" step in the
     workflow.
   - Make `android/app/build.gradle.kts` read `android/key.properties` for the
     release `signingConfig`. It still uses the debug config.
6. Persist compression settings between launches. Only the language is saved
   today.

## Notes

- `selectAllLoaded` and `newRun` exist in the ARB files but are not used in
  `lib/`. Remove them or wire them up.
- Manual workflow runs with an empty version field publish a pre-release named
  `dev-<run number>`.
