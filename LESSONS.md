# LESSONS.md

Things learned while building Comprimage. Add new entries at the top of their
section, or at the end if no section fits.

## CI and releases

- **`workflow_dispatch` needs the workflow on `main`.** GitHub only offers
  "Run workflow" for a workflow file that exists on the default branch. Until
  `build-release.yml` is merged to `main`, release it by pushing a tag.
- **Releases are only published from tags or manual runs.** Pushes to `dev` run
  the build check and publish nothing.
- **The local container has no Android SDK.** APK builds cannot be verified
  locally, so check them in CI before tagging.
- **No workflow artifacts.** APKs go to GitHub Releases only.

## Build

- **AGP 9 / Gradle 9 is a build risk.** The project uses AGP 9.1.0, Kotlin 2.4.0
  and Gradle 9.3.1 (from the Flutter template). Older Groovy-based plugins such
  as `photo_manager` and `flutter_image_compress_common` may not work with it.
  If a CI build fails inside Gradle or AGP, check plugin versions first.

## Compression

- **`keepExif` only works for JPEG.** `flutter_image_compress` ignores it for
  WebP, which never carries EXIF data. The settings UI states this.
- **`minWidth` / `minHeight` are minimums, not a size cap.** The library scales
  the image so it is at least that size while keeping the aspect ratio. To cap
  the longest edge, compute the exact target dimensions with
  `targetDimensions` and pass those values.

## Gallery listing (photo_manager)

- **`FilterOptionGroup` freezes "now".** Its default `createTimeCond` is
  `DateTimeCond.def()`, which caps results at `DateTime.now()` *when the
  filter is built*. An `AssetPathEntity` keeps that filter, so photos taken
  after the albums were loaded never appear (nor do photos whose creation date
  is slightly in the future due to clock or time zone skew). Use
  `DateTimeCond.def().copyWith(ignore: true)` and reload albums on refresh.
- **The picker must refresh itself.** It reloads on app resume, on
  `PhotoManager` change notifications (debounced) and on pull-to-refresh.

## Saving and deleting originals

- **Replace mode deletes in one batch.** Originals are deleted with a single
  `deleteWithIds` call at the end of the run. On Android 11 and newer this
  shows one system confirmation dialog. On Android 10 the confirmation is per
  file.

## Releasing from agent sessions

- **Tag pushes are blocked in cloud agent sessions.** `git push origin vX.Y.Z`
  fails with HTTP 403 from the session's git proxy, while branch pushes work.
  Release with `workflow_dispatch` on `main` and the `version` input instead;
  `softprops/action-gh-release` creates the tag. Humans can still push tags
  locally.
- **The universal APK is ~54 MB** because it bundles all ABIs (arm, arm64,
  x86_64). `flutter build apk --split-per-abi` would cut that to roughly a
  third per APK if size matters.
