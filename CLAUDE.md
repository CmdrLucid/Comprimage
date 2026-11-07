# CLAUDE.md

Guidance for AI agents working in this repository.

## Project overview

Comprimage is a Flutter app for Android (package `de.comprimage.comprimage`,
Dart SDK `^3.13.7`). It compresses gallery photos to JPEG or WebP entirely on
the device. Languages: English (template) and German.

Key dependencies: `photo_manager` (gallery access and saving),
`flutter_image_compress` (encoding), `shared_preferences` (saved language).

Layout and data flow: see `CODEMAP.md`. Project history and open work:
`HANDOFF.md` and `LESSONS.md`.

## Commands

```sh
flutter pub get
flutter analyze        # must report 0 issues
flutter test
flutter gen-l10n       # after editing lib/l10n/*.arb
flutter build apk --release
```

The local container has no Android SDK, so APK builds cannot be verified here.
Verify them in CI (see below).

## Branch model

- Develop on `dev`. Pushes to `dev` run a build check only.
- Release from `main`: merge `dev` into `main`, then push a `vX.Y.Z` tag or run
  the workflow manually from `main`.

## Conventions

- **No hardcoded UI strings.** Add every user-visible string to both
  `lib/l10n/app_en.arb` and `lib/l10n/app_de.arb`, run `flutter gen-l10n`, and
  read it with `context.l10n` (`lib/l10n/l10n_ext.dart`).
- **Code comments are in English.**
- **Pure logic goes in `lib/models/` or `lib/services/`** and gets unit tests in
  `test/`. Examples: `searchTargetSize`, `targetDimensions`, `formatBytes`.
  Keep platform calls (`photo_manager`, `flutter_image_compress`) out of pure
  functions so they can be tested without a device.
- **Keep `flutter analyze` at 0 issues** and keep all tests passing.

## CI notes

- Workflow: `.github/workflows/build-release.yml`. It runs analyze, test and
  the release APK build on pushes to `dev`, on `v*` tags, and on manual runs.
- The workflow uses no workflow artifacts. APKs are published only to GitHub
  Releases.
- `workflow_dispatch` works only once the workflow file is on `main`
  (see `LESSONS.md`).
- Release signing uses the debug key for now. The keystore steps in the
  workflow are commented out.

## Documentation rules

- Always update `HANDOFF.md` at the end of every session.
- Record learnings in `LESSONS.md`.
- Keep `CODEMAP.md` in sync when files are added, moved or removed.
