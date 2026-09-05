# Recommendations for Melody Ear Trainer

Based on a close read of the actual code, here are concrete suggestions — grouped by impact, with real bugs first.

## 1. Actual bugs worth fixing first

- **Settings save/load mismatch** (`general_provider.dart`): `saveSettings()` persists `startingDoDefault` / `endingDoDefault` / `chordFrequencyDefault` instead of the current `startingDo` / `endingDo` / `chordFrequency` — so user-chosen values for those aren't actually persisted.
- **Typo bug in `mapping_provider.dart`**: `if (instrument.length > 1 && !instruments.contains(instrument))` — checks *string length*, not list membership; the instruments list gets polluted/deduped incorrectly. Also, all `loadXxxJSON` getters are fired from the constructor without `await`, so `MappingProvider` consumers can render before data is ready (the homepage "No campaigns available" flash).
- **Shared audio engine disposed by one page**: `melodyIDhandsfree.dart`'s `dispose()` calls `audioController.dispose()` on the *global* SoLoud instance — leaving that page kills audio for everything else until some other code calls `refresh()`. Only the app root should own that lifecycle.
- **Typo method `voidSetChordDetails`** in `general_provider.dart` — the return type got merged into the method name. Works, but hides intent.
- **Suspicious import** in `lib/custom.dart`: `import '../utils/helper.dart'` from inside `lib/` — should be `utils/helper.dart` (works only by accident of path resolution).
- **Filename typo risk**: default `selectedChords` uses `"I_Rt,IV0_Sec,V0_Fir"` in one place and `"I_Rt,IV_Rt,V_Rt"` in `loadSettings` fallback — inconsistent chord IDs.

## 2. Architecture / code quality

- **Stop passing `dynamic widget` into playback** (`chordMelody.playChordMelody(..., widget)` calls `widget.audioController`). Provide `AudioController` via `Provider`/`get_it` instead — enables testing and removes the leaky abstraction.
- **Split `ChordMelody`** into `MelodyGenerator` (pure logic — trivially unit-testable) and `MelodyPlayer` (audio sequencing). Right now generation, model, and timing live together.
- **`GeneralProvider` is a 900-line god class** with every setting for all six modes; subclasses only override defaults. Split per-mode settings classes, or hold a frozen `LevelConfig` object for campaign play.
- **Replace magic strings with enums** ("Every 4 notes", "Normal", "Guitar", "Passed!") — these are compared/dropped into switch statements all over; a typo fails silently.
- **Naming conventions**: `chordIDSettings`, `chordSinging`, `missionSettingsProvider` violate Dart's `UpperCamelCase` class rule; `analyzer` is presumably warning constantly — run `flutter analyze` and clean up.
- **Version hard-coded** as `"3.0"` in `main.dart` — use `package_info_plus` or `--dart-define` so it stays in sync with pubspec.
- **Routing**: 25+ stringly-typed routes; `go_router` would give typed arguments, deep links (nice for campaign share links), and less boilerplate.
- **Hands-free pages duplicate ~450 lines each** with only the loop body differing — parameterize one `HandsFreeSessionPage` with a strategy callback.
- **Unused dependency**: `flame` is declared but never imported — removing it shrinks the build. Check `intl`, `flutter_screenutil`, `auto_size_text`, `percent_indicator` usage too.

## 3. Audio engine improvements

- **Cache loaded sounds.** `playSound()` calls `loadAsset()` on *every note*, then plays — creating a new source each time (leaked unless disposed; you currently band-aid with `refresh()` deinit/init and `i % 7` resets). Preload per key/instrument into a `Map` at startup or on settings change; latency drops and leaks disappear.
- **Tempo-based playback**: replace `Future.delayed(timeBetweenNotes)` with a BPM + note-duration model so melodies sound musical; optionally use SoLoud's `scheduleStop`/voice timing instead of `Future`s for drift-free sequences.
- **Pause audio when app is backgrounded** (`AppLifecycleListener`) — currently a melody keeps playing if the user switches away mid-drill.
- **APK size**: hundreds of per-key MP3s are bundled. Consider OGG/Opus conversion (SoLoud supports it) or synthesizing tones at runtime — could cut asset size substantially.

## 4. UX / feature wins

- **Note-by-note grading**: the "Compare" button is all-or-nothing. You already have both melody lists — render a colored diff (green/red per syllable). Cheap to build, big learning benefit.
- **Pitch detection for singing modes** — the biggest feature gap. "Melody singing" is currently self-graded; mic pitch detection (e.g., `pitch_detector_dart` + record package) would let the app *verify* the sung melody and make singing drills genuinely hands-free.
- **Statistics screen**: ObjectBox already stores every test result — surface accuracy over time, a per-syllable error heatmap, and "weakest notes" that feed the existing `newNotes` bias in generation. Right now that data is collected but invisible.
- **Adaptive difficulty**: use pass-rate history to auto-adjust `numNotes`/`maxDistance`/`playbackSpeed` between levels.
- **Add a Pause button** to hands-free mode (currently only Start/Stop; pausing mid-round kills the round).
- **Metronome or tonic drone option** during playback, and a "same melody in 12 keys" transposition drill mode.
- **Progress affordances on the campaign tree**: % complete per campaign, stars per level (you store `score` already), and a "continue where you left off" button on the home screen.
- **Onboarding**: a first-run tutorial overlay; the help page is dense.
- **Localization**: strings are hardcoded English while `intl` is already a dependency.
- **Accessibility**: add `Semantics` labels to note buttons (screen readers currently hear "button"), and ensure minimum tap targets on the dense note grid.

## 5. Testing & CI

- `test/widget_test.dart` is empty — zero tests for a fairly logic-heavy app. Highest-value targets:
  - `generateChordMelody()` property tests: respect `maxDistance`, no-repeats, start/end-do, chord cadence invariants;
  - `ObjectBox` repository CRUD + `levelPassed` logic;
  - settings save/load round-trip (which would have caught the `*Default` bug above);
  - `MappingProvider` JSON consistency (every note×key×instrument has a file).
- Add GitHub Actions: `flutter analyze && flutter test && flutter build apk` on PRs.

## Suggested priority order

1. Fix the persistence bug, mapping typo, and audio-dispose bug (quick, user-visible).
2. Add note-by-note diff feedback + statistics screen (cheap, high learning value).
3. Audio source caching + lifecycle handling (robustness/perf).
4. MelodyGenerator/Player refactor + unit tests (unlocks faster iteration).
5. Mic pitch detection for singing modes (flagship differentiator).

Happy to start implementing any of these — the bug fixes in group 1 are each small, targeted `replace_in_file` changes.