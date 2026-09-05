# 2026-09-05 — Fixing provider initialization in the Campaign folder

## The original prompt

> I've made a new branch named "glm53" on the github repo. Can you please switch to that branch and we will commit all changes to that branch from now on.
>
> Can you have a look at my whole Flutter app, especially all of the dart classes that extend `MelodyPageAbstract` and `MelodyPageAbstract` state. I felt like I wasn't loading the providers in the correct place and that it was loading and building objects over and over again. But when I moved the `mappingProvider` and `generalProvider` outside of build, then it didn't update the settings correctly as the user moved from level to level and mission to mission. I started to fix this in `levelMelodyID.dart`, you can see that I have the following code in there:
>
> ```dart
> bool _initialized = false; // Add this flag
> // Add class-level fields to store the providers and info
> late final MappingProvider mappingProvider;
> late final missionSettingsProvider generalProvider;
> late final LevelInfo levelInfo;
> ```
>
> with `didChangeDependencies` and whatnot. You can see that `LevelMelodyIDHandsFree` has a completely different structure. Have a look at these files and the other "level..." dart files in the Campaign folder and give me some recommendations on how to properly set up all the dart files in the campaign folder.

---

## 1. Current state of the app (what I found)

### Provider setup (main.dart)

All providers are created **once** in `main()` as singletons and exposed via `MultiProvider`:

- `ThemeProvider`
- `MappingProvider` — JSON mappings, campaign/mission/level info (loaded with `await loadAll()` **before** `runApp`, good)
- `AudioController` — shared audio engine
- `MelodyIDSettings`, `MelodySingingSettings`, `chordIDSettings`, `chordSingingSettings`, `chordMelodyIDSettings`, `chordMelodySingingSettings`, `missionSettingsProvider`, `missionSingingSettings` — all subclasses of the abstract `GeneralProvider`

### Campaign navigation flow

```
campaignTree → Mission → Level → ┬─ LevelMelodyID          (practice, extends MelodyPageAbstract)
                                  ├─ LevelMelodyIDHandsFree  (practice, plain StatefulWidget)
                                  ├─ LevelMelodyIDTest       (test, extends TestPageAbstract)
                                  ├─ LevelMelodySinging      (practice, extends MelodyPageAbstract)
                                  ├─ LevelMelodySingingHandsFree (plain StatefulWidget)
                                  └─ LevelMelodySingingTest  (test, extends TestPageAbstract)
                                             ↓
                                     LevelTestResultsPage
```

`LevelInfo` / `MissionInfo` / `CampaignInfo` objects travel via route arguments.

### How level settings currently move around

This is the heart of the problem. `missionSettingsProvider` (a global singleton) is used as a **scratch pad for per-level configuration**:

| Call site | What happens |
|---|---|
| `mission.dart:210` (`buildTile.onTap`) | `generalProvider.setLevelDetails(lvl.Notes, lvl.NumNotes, ...)` then push `Level` |
| `level.dart:205 / 255` (prev/next level buttons) | `setLevelDetails(...)` for the other level, then `pushReplacementNamed(Level...)` |
| `levelTestResults.dart:385` (go to next level) | `setLevelDetails(...)` then navigate |
| `level.dart:47` (`PopScope`), `level.dart:431`, `levelTestResults.dart:482`, `campaign.dart:325` | `resetMissionBeforeMissionPage(...)` — reads `MissionSavedSettings` from ObjectBox, restores key/instrument, resets note selection to the mission's last level |

So the "settings" a practice page sees are **whatever was last written into the global provider by whichever navigation button was tapped last**. There are two sources of truth (the `LevelInfo` in the route args, and the mutable global provider), and they can drift.


### Page-by-page patterns (all different!)

| File | Providers read in | Route args read in | One-time side effects | Notes |
|---|---|---|---|---|
| `levelMelodyID.dart` | `didChangeDependencies` once (`_initialized` flag), cached in `late final` fields | `didChangeDependencies` once | generates melody **and autoplays it** in `didChangeDependencies` | Closest to correct, but `late final` + flag means it can never react to changes; autoplay buried in lifecycle callback |
| `levelMelodySinging.dart` | locals in `didChangeDependencies` **and again** in `build` | both places | generates melody + plays first note in `didChangeDependencies` | Double-reading; two patterns mixed in one page |
| `levelMelodyIDtest.dart` / `levelMelodySingingtest.dart` | `build` | **`build`** — assigns a field (`levelInfo = ModalRoute...`) during build | none at init (test is user-started) | Assigning state fields inside `build` is a smell |
| `levelMelodyIDhandsfree.dart` / `levelMelodySinginghandsfree.dart` | `build` (`context.watch` for dropdowns) + `context.read` inside the async play loop | `build` | none (user presses Start) | Don't extend `MelodyPageAbstract` at all; ~500 lines each largely duplicated between the two; **good** patterns: `mounted`-guarded `setState`, `dispose` stops audio and kills the loop |
| `level.dart` | `build` | `build` | **ObjectBox queries on every build** (`getLevelTestResultsByLevelID`, `numPassedTestsForLevel`, next/prev level lookups) | Every provider notification re-runs DB reads |
| `mission.dart` | `build` | `build` | **ObjectBox write on every build** (`createOrUpdateMissionDetails`) | A DB write inside `build` is the worst offender |
| `campaign.dart` | `build` | `didChangeDependencies` + `build` (twice) | JSON graph load once (`_loaded`/`_loading` flags) | Reasonable, but args read twice |

---

## 2. Diagnosis — what's actually going wrong

### 2a. The original fear ("building objects over and over") is a misdiagnosis

Reading providers in `build` does **not** create or rebuild the provider objects. They are singletons created once in `main()`; `Provider.of<T>(context)` in `build` just:

1. grabs the existing reference, and
2. subscribes the widget so it rebuilds when the provider calls `notifyListeners()`.

What you *were* seeing repeatedly was:

- **Whole-page rebuilds on every notification.** Every settings change calls `notifyListeners()` (and `saveSettings()` → a SharedPreferences write + JSON encode), and each page that reads the provider in `build` rebuilds its entire Scaffold.
- **Real heavy work inside `build`/lifecycle paths** — ObjectBox reads on every rebuild in `Level.build`, an ObjectBox **write** on every rebuild in `Mission.build`, plus melody generation and audio playback triggered from `didChangeDependencies`.

So the fix was never "move the providers out of build" — it was "move the *work* out of build".

### 2b. Why moving providers out of build broke level-to-level updates

When you cached `mappingProvider` / `generalProvider` / `levelInfo` as `late final` fields guarded by `_initialized`:

- If the reads happen in `initState` (or with `listen: false`), the widget **never subscribes** to the provider, so later `notifyListeners()` calls (key/instrument changes, `setLevelDetails`, note selection) never reach the page → "settings didn't update".
- If the reads happen in `didChangeDependencies` with the `_initialized` flag (current `levelMelodyID.dart`), the subscription *is* registered and the provider references stay valid (they're singletons) — but any data **derived** at init time (the auto-generated melody, autoplay instrument, etc.) is frozen from the first run. The page keeps showing the first level's derived state if the same State object ever sees new inputs, and `late final` fields make refreshing impossible.

### 2c. The root cause: per-level config stored in a global provider

Because `setLevelDetails()` writes level data (notes, note count, max distance, playback speed, starting/ending do, chord frequency) into the **global** `missionSettingsProvider`, correctness depends on *navigation order*, not on *which level is displayed*:

- Every page that generates a melody must trust that whoever navigated here called `setLevelDetails` with the right level first (temporal coupling).
- That's why `resetMissionBeforeMissionPage()` has to exist as a cleanup hack in four places.
- That's also why caching anything feels dangerous — the global provider genuinely does change under your feet.

If the practice pages instead derive their config from the `LevelInfo` they already receive via route arguments, the global provider only needs to hold *real user preferences* (key, instrument, hands-free rounds/repeats), which are stable while a level page is open. Then caching becomes safe and the whole reset dance disappears.

### 2d. An async race worth knowing about

`GeneralProvider`'s constructor fires `loadSettings()` (async, reads SharedPreferences). If a navigation tap calls `setLevelDetails()` before the load completes, the load can finish later and **overwrite** the level details with stale persisted values. This is another reason per-level data doesn't belong in this provider.

---

## 3. Recommendations

### R1. Keep reading providers where reactivity is needed — just scope it

- In `build`: use `context.watch<T>()` / `context.select()` — do **not** cache into fields.
- In button callbacks and async loops: use `context.read<T>()` (the hands-free pages already do this correctly).
- Never read in `initState`; never assign state fields inside `build`.

You don't need to fear `watch` in `build` — but you should shrink *how much* rebuilds (R5).

### R2. Make `LevelInfo` the single source of truth for level config (root-cause fix)

Create an immutable view model derived from `LevelInfo`, instead of pushing level data into the global provider:

```dart
// utils/level_config.dart
class LevelConfig {
  final List<String> notes;
  final int numberOfNotes;
  final int maxDistance;
  final bool allowRepeatedNotes;
  final String playbackSpeed;
  final int timeBetweenNotes;
  final String truncateNotes;
  final bool startWithDo;
  final bool endWithDo;
  final String startingDo;
  final String endingDo;
  final String chordFrequency;
  final Set<String> newNotes;

  LevelConfig.fromLevelInfo(LevelInfo info)
      : notes = info.Notes,
        numberOfNotes = info.NumNotes,
        maxDistance = info.MaxDistance,
        allowRepeatedNotes = info.AllowRepeatedNotes,
        playbackSpeed = info.PlaybackSpeed,
        timeBetweenNotes = _timeBetween(info.PlaybackSpeed), // 300/600/900 switch
        truncateNotes = _truncate(info.PlaybackSpeed),
        startWithDo = info.StartWithDo,
        endWithDo = info.EndWithDo,
        startingDo = info.StartingDo,
        endingDo = info.EndingDo,
        chordFrequency = info.ChordFrequency,
        newNotes = info.NewNotes;
}
```

Then:

- `ChordMelody.generateChordMelody(...)` takes a `LevelConfig` (+ user-prefs provider) instead of reading `generalProvider.numberOfNotes`, `.maxDistance`, `.startingDo`, etc.
- Delete `setLevelDetails()` and all four call sites (mission.dart, level.dart ×2, levelTestResults.dart).
- `resetMissionBeforeMissionPage()` shrinks to restoring user prefs (key/instrument) only — or disappears entirely once practice/test pages stop mutating them.
- User-pref providers stop persisting level-derived fields to SharedPreferences.

This is the change that makes every other fix easy.

### R3. Adopt one standard lifecycle in `MelodyPageAbstractState` (and document it)

Put the common pattern in the base class so every subclass inherits it:

```dart
abstract class MelodyPageAbstractState extends State<MelodyPageAbstract> {
  // Existing fields...
  LevelInfo? levelInfo; // plain field, NOT late final

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on first build AND whenever an inherited dependency changes.
    // Re-read every time — no _initialized flag for *reads*.
    final args = ModalRoute.of(context)?.settings.arguments;
    final newLevel = args is LevelInfo && args.LevelID != (levelInfo?.LevelID ?? '');
    levelInfo = args is LevelInfo ? args : levelInfo;

### R4. Move all ObjectBox work out of `build`

- `mission.dart` `build()` → move `objectBox.createOrUpdateMissionDetails(...)` into `didChangeDependencies` guarded by `MissionID` (or drop it — `missionSettingsPage` already persists key/instrument changes via `objectBox.updateKey/updateInstrument`; verify what this call still adds).
- `level.dart` `build()` → move `getLevelTestResultsByLevelID`, `numPassedTestsForLevel`, next/prev lookups into `didChangeDependencies` guarded by `LevelID`, store results in plain fields. Same for `levelTestResults.dart`.
- Long-term: pages that need "latest DB state on every pop-back" can call `setState` in a route-aware way, but the current behavior (re-query per rebuild) is the accident you noticed.

### R5. Reduce rebuild scope with `select` / `Selector` and small widgets

Instead of the whole Scaffold rebuilding on every `notifyListeners()`, split the page body into small `Widget`s that each watch only what they use:

```dart
class MissionHeaderRow extends StatelessWidget {
  const MissionHeaderRow({super.key, required this.missionId});
  final String missionId;

  @override
  Widget build(BuildContext context) {
    final mission = context.select<MappingProvider, MissionInfo>(
      (m) => m.missions[missionId]!,
    );
    return missionHeader(context.read<MappingProvider>(), mission);
  }
}
```

This is what actually fixes "it keeps building over and over" without breaking reactivity.

### R6. Unify the hands-free pages under the same hierarchy

`levelMelodyIDhandsfree.dart` and `levelMelodySinginghandsfree.dart` are ~500 lines each, mostly duplicated, and don't extend `MelodyPageAbstract`. Recommended:

- Create `HandsFreePageAbstract` / `HandsFreePageAbstractState` (either extending `MelodyPageAbstractState` or sharing a mixin) that owns: `currentRound`, `notPaused`, `running`, `solfegeText`, `chordMelody`, `startButtonBackgroundColor`, `getInstrument()`, the round loop, the `dispose()` audio stop, the `mounted`-guarded `setState` override, and `returnToLevelButton`.
- **Keep their good patterns**: `dispose()` stopping audio and killing the loop, and `context.read` inside async loops so settings changes apply live mid-session.
- Resolve the `missionSettingsProvider` (ID hands-free) vs `missionSingingSettings` (singing hands-free) split — one hands-free settings provider, or at minimum a documented reason for two.

### R7. Fix the `GeneralProvider` async load race

In `main()`, await the settings load before `runApp`, exactly like `MappingProvider`:

```dart
final missionSettings = missionSettingsProvider();
await missionSettings.loadSettings(); // make loadSettings idempotent/public
runApp(MultiProvider(providers: [ ..., ChangeNotifierProvider.value(value: missionSettings), ... ]));
```

(Only needed for the providers used during the campaign flow; the others can follow.)


    if (newLevel) {
      onLevelEntered(); // subclass hook: generate melody, autoplay, etc.
    }
  }

  /// One-time-per-level side effects (melody generation, autoplay).
  /// Guarded by the LevelID comparison above, NOT by a bool flag.
  void onLevelEntered() {}
}
```

Rules for every subclass:

| Lifecycle | Allowed | Not allowed |
|---|---|---|
| `initState` | create plain objects (`ChordMelody()`), set defaults | anything using `context`/providers/route args |
| `didChangeDependencies` | re-read providers & route args into plain fields; call `onLevelEntered()` when the level changed | unguarded side effects (they'd re-run on *every* provider notification) |
| `build` | pure UI from fields + `context.watch`/`select` | assigning fields, DB access, provider writes, audio |
| `dispose` | `audioController.stopAll()`, cancel async loops, `notPaused=false` | — |

Key insight: **guard side effects by comparing inputs (`LevelID`, a settings fingerprint), not by a boolean.** A bool guards "first time ever"; an input comparison guards "whenever the thing I care about changed" — which is exactly what you wanted when you said settings must update "level to level and mission to mission".


### R8. Test pages: stop assigning fields in `build`

`levelMelodyIDtest.dart:44` and `levelMelodySingingtest.dart:44` do `levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;` inside `build` — with R3 in place this moves to `didChangeDependencies`, and the dummy `LevelInfo("", "", ...)` constructor fallback can go away (make the field nullable until initialized).

### R9. Small hygiene items (optional, do last)

- Rename classes to Dart conventions: `missionSettingsProvider` → `MissionSettingsProvider`, `missionSettingsPage` → `MissionSettingsPage`, etc.
- `LevelMelodySingingState` currently reads providers twice (locals in `didChangeDependencies` **and** in `build`) — collapse to the R3 pattern.
- `updateSelectedKey`/`updateSelectedInstrument` don't need `async` — `saveSettings()` is already fire-and-forget async.
- `newGenerateChordMelody()` calling `setState()` internally is hidden coupling — have it return the melody and let callers `setState` explicitly.

---

## 4. Suggested migration order

1. **R7** — await settings load in `main()` (removes a real race, tiny diff).
2. **R3** — add the base-class lifecycle (`levelInfo` field + `onLevelEntered` hook); convert `levelMelodyID.dart` and `levelMelodySinging.dart` to it. This alone fixes the inconsistency you started fixing.
3. **R8** — test pages stop assigning in `build`.
4. **R4** — move ObjectBox reads/writes out of `build` in `mission.dart`, `level.dart`, `levelTestResults.dart`.
5. **R5** — extract header/settings/note-grid widgets with `select` (biggest perceived-performance win).
6. **R2** — introduce `LevelConfig`, remove `setLevelDetails` and the `resetMissionBeforeMissionPage` note-selection restore. Do this only after 2–4 so you can compare behavior.
7. **R6** — unify hands-free pages under the abstract hierarchy.
8. **R9** — naming/style cleanup.

### How to verify as you go

- Enter a mission → change Key/Instrument in mission settings → open a level → practice page must use the new settings (reactivity preserved).
- Prev/Next level and mission-to-mission jumps must regenerate melodies for the *displayed* level (input-guarded side effects).
- Toggle a hands-free dropdown *mid-session*: current round should keep running, next round should pick up the new value (`context.read` in the loop).
- Android back from Level → Mission must restore mission key/instrument (R2 changes what remains of this).
- No melody should re-play when merely scrolling or toggling an unrelated setting (no unguarded `didChangeDependencies` side effects).

---

## 5. TL;DR

- Reading providers in `build` was never the problem — heavy **work** in `build`/lifecycle was (DB reads/writes, melody generation, autoplay).
- Caching with `late final` + `_initialized` breaks updates because it freezes derived data and (with `listen:false`) drops the subscription. Guard side effects by **comparing inputs** instead of a bool.
- The root cause is per-level config living in the global `missionSettingsProvider` via `setLevelDetails`. Derive a `LevelConfig` from the `LevelInfo` route argument instead; the global provider keeps only real user preferences. The four `resetMissionBeforeMissionPage` call sites then mostly disappear.
- Standardize every campaign page on one lifecycle: `initState` = plain objects, `didChangeDependencies` = re-read providers/args (+ input-guarded side effects), `build` = pure UI with `watch`/`select`, `dispose` = stop audio & loops.
- Bring the two hands-free pages under the same hierarchy and deduplicate them.

