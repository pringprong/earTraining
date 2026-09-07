# 20260907 — Ear Training Types Upgrade: Campaign support for the 4 chord-based MissionModes

## Original prompt

> the next thing we want to do is add support for the other 4 modes (or MissionModes) of ear training (namely chordID, chord singing, chord melody ID, and chord melody singing) to the campaign code. These are already supported in the "custom" part of the app, so we can look there to see how the interface should work. Each one of these MissionModes will get a different shape in the campaign tree. We need to make 3 files for each mode: the main dart page, the test page and the handsfree page. we will need to update Campaign, Mission, and the other files in lib/campaign to support the 4 new modes. I also need to generate the contents of the missions and levels for each type, but I will do that separately once the code is written and add them into the JSON files in the assets/mapping folder. Generate a plan to upgrade the app to support the other 4 types of ear training and save the plan together with this prompt in 20260907_ear_training_types_upgrade.md

---

## 1. Goal

Extend the campaign flow so missions with `MissionMode` = **"Chord ID"**, **"Chord singing"**, **"Chord melody ID"**, and **"Chord melody singing"** are fully playable, exactly like the existing **"Melody ID"** and **"Melody singing"** missions:

- a **practice page** (main dart page),
- a **test page** (writes `LevelTestResults`, drives mission unlock status),
- a **hands-free page** (looped listening/singing drills),

with routing from the campaign tree → mission → level → practice/test/hands-free, and per-mode shapes in the campaign tree. Mission/level *content* (JSON) is authored separately afterwards; this plan covers code only.

All paths below are relative to `flutter/melody_ear_trainer/`.

---

## 2. Current state (verified against the code)

### Campaign flow

```
campaignTree (lib/campaign/campaign.dart)
   └─ node per mission, shape = campaignTreeShapes[MissionMode]        (utils/helper.dart:623)
   └─ tap → resetMissionBeforeMissionPage() → Mission page
Mission (lib/campaign/mission.dart)
   └─ lists levels (tiles) → Level page
Level (lib/campaign/level.dart)
   ├─ practiceButton(missionMode, levelInfo)     → LevelMelodyID | LevelMelodySinging          (level.dart:267)
   ├─ handsFreeButton(missionMode, levelInfo)    → LevelMelodyIDHandsFree | ...SingingHandsFree (level.dart:308)
   ├─ takeTestButton(missionMode, levelInfo)     → LevelMelodyIDTest | LevelMelodySingingTest  (level.dart:352)
   └─ returnToMissionPage(...)
Practice/test/hands-free pages
   ├─ extend MelodyPageAbstract / TestPageAbstract (lib/melodyPageAbstract.dart, lib/testPageAbstract.dart)
   │   └─ CampaignLevelArgs mixin: route args (LevelInfo) → levelInfo → LevelConfig.fromLevelInfo
   ├─ hands-free pages extend HandsFreePageAbstract (lib/campaign/handsfreePageAbstract.dart)
   │   └─ abstract playRound() implemented per page; repeatPlay(), startStopButtons(), solfegeArea()
   └─ practice pages call takeTestButton(missionMode, levelInfo)          (melodyPageAbstract.dart:916)
Test results (lib/campaign/levelTestResults.dart)
   └─ optionalRedoTestButton() re-dispatches on missionMode               (levelTestResults.dart:343)
```


### Shared engine (already mode-agnostic — no changes needed)

- `utils/chordMelody.dart` — `ChordMelody.generateChordMelody()` builds note melodies **and inserts chords** whenever `LevelConfig.chordFrequency != "Never"`, using `generalProvider.getSelectedChords()`. `playChordMelody()`/`playSpoken()` arpeggiate multi-note entries. So *all four new modes* run on the same melody engine — only the UI differs per mode.
- `utils/level_config.dart` — `LevelConfig.fromLevelInfo(LevelInfo)` is the single source of level-fixed settings (notes, numNotes, maxDistance, playbackSpeed, start/end do, chordFrequency, newNotes).
- `providers/mapping_provider.dart` — `MissionMode` is parsed as a free string from `Missions.json` (`item['MissionMode']`, mapping_provider.dart:346) and stored on `MissionInfo`. No enum to extend.
- `providers/general_provider.dart` — `MissionSettingsProvider` (campaign melody settings + hands-free controls for ID modes) and `MissionSingingSettings` (hands-free controls for singing modes); both persist `selectedChords` etc. via SharedPreferences.
- ObjectBox: `LevelTestResults`, `MissionSavedSettings`, status helpers (`getDeepMissionStatus`, `numPassedTestsForLevel`, `updateMissionStatus`) — all mode-agnostic.

### Already wired for the 4 new modes (no changes needed)

| Concern | Where | Status |
|---|---|---|
| Tree node shape per mode | `campaignTreeShapes` (helper.dart:623): `"Chord ID": hexagon`, `"Chord singing": trapezoid`, `"Chord melody ID": octagon`, `"Chord melody singing": diamond` (+ width/height maps) | ✅ done |
| Mode colors (headers/buttons) | `getModeColor` (utils/colors.dart:213) covers all 6 modes | ✅ done |
| Campaign tree rendering | `campaign.dart` `myClipWidget()` looks up `campaignTreeShapes[MissionMode]` (campaign.dart:270) | ✅ done |
| Mission page display (notes grid + chord reference + level tiles) | `mission.dart` — mode-agnostic | ✅ done |
| Mission settings (key/instrument) | `missionSettings.dart` — mode-agnostic | ✅ done |

### Gap — the exact places that only know the 2 existing modes

1. **`lib/campaign/level.dart`** — `practiceButton()` (:284), `handsFreeButton()` (:325), `takeTestButton()` (:369): `if/else` chains handle only `"Melody ID"` / `"Melody singing"`.
2. **`lib/melodyPageAbstract.dart`** — `takeTestButton()` (:933): same problem (used by the practice pages' "Take a test" button).
3. **`lib/campaign/levelTestResults.dart`** — `optionalRedoTestButton()` (:343): "Repeat test" only knows the 2 existing test routes.
4. **`lib/main.dart`** — routes registered only for the 6 existing campaign pages (:205-219).
5. **12 missing page files** (3 per new mode).

---

## 3. Design

### 3.1 Page compositions per mode (mirroring the "custom" pages)

The custom (`lib/chordID/chordID.dart`, `lib/chordSinging/chordSinging.dart`, `lib/chordMelodyID/chordMelody.dart`, `lib/chordMelodySinging/chordMelodySinging.dart`) pages define each mode's UX; the campaign pages reuse the **same widgets from the abstracts** but with `MissionSettingsProvider` + route-arg `LevelInfo` (via `CampaignLevelArgs` / `LevelConfig`), plus the standard campaign headers and `returnToLevelButton` / `takeTestButton` — exactly like `LevelMelodyID` / `LevelMelodySinging` do today.

Widget cheat-sheet from the abstracts (all take `generalProvider, mappingProvider` unless noted):

- Answer/input: `buildNoteButtons()` (uses `levelInfo?.Notes` on campaign pages), `buildSelectedChordButtons()` (uses `MissionSettingsProvider.getSelectedChords()`, gated by `levelInfo?.ChordFrequency != "Never"`), `userWrittenSolfegeArea()`, `clearAndBackspaceButtons()`
- Playback: `playMelodyButtons(g, m, includeSolfege)`, `playFirstNoteButtons()`, `userWrittenMelodyButtons()`
- Singing: `solfegeTextArea()`, `sayTheSolfegeButton()`, `instructionRow(text)`
- Reveal: `solfegeExpansionTile()`, `compareButton()` / `compareButton2()` (campaign pages use `compareButton2`, which replays solfege on correct)
- Test: `startTestButton(g, m, setSolfegeText, levelInfo)`, `startTestButtonSinging(...)`, `enterGuessbutton(g, m, setSolfegeText, levelInfo)`, `reportWhetherCorrect(g, m, levelInfo)`, `previousQuestionResult()`, `finishTest()` hook
- Hands-free: `playRound(melodySettings, roundSettings, mappingProvider)` + `repeatPlay(...)`, `startStopButtons(...)`, `solfegeArea()`, `currentRoundRow()`, `settingsDropdownRow(...)`, `returnToLevelButton(levelStatus)`

#### Practice pages (extend `MelodyPageAbstract`)

Common skeleton (copy of `LevelMelodyID`/`LevelMelodySinging`): headers (`CampaignHeaderRow`, `MissionHeaderRow`, `LevelHeaderRow`), `onLevelEntered()` generating the first melody + autoplay/first-note, `didChangeDependencies()` refreshing `levelStatus`, and a `generateMelodyButton` override + `takeTestButton(missionMode, levelInfo)` + `returnToLevelButton(levelStatus)` tail.

| Page | Mode | Body (after headers) | Mode-specific `onLevelEntered` |
|---|---|---|---|
| `LevelChordID` | Chord ID | `generateMelodyButton` → "Listen to generated melody": `playMelodyButtons(false)` → `solfegeExpansionTile` → "Play the melody back": **`buildSelectedChordButtons`** (tap to answer) → `userWrittenSolfegeArea` → `clearAndBackspaceButtons` → **`compareButton2`** → "Listen to your melody": `userWrittenMelodyButtons` | generate with `setSolfegeText=false`, autoplay full melody (same as `LevelMelodyID`) |
| `LevelChordSinging` | Chord singing | "Generated melody": `solfegeTextArea` → `sayTheSolfegeButton` → "Listen to first note": `playFirstNoteButtons` → `instructionRow("Now try to sing the melody out loud...")` → "Listen to the melody for comparison": `playMelodyButtons(true)` → `instructionRow("Did you sing it correctly?")` → chord reference: `buildSelectedChordButtonsHelper(g, m, optional: true, selectedNotes: levelInfo.Notes.toSet(), chordFrequencyOverride: levelInfo.ChordFrequency)` (display-only, same as level/mission pages) | generate with `setSolfegeText=true`, play first note only, `solfegeText = generated melody` (same as `LevelMelodySinging`) |
| `LevelChordMelodyID` | Chord melody ID | `generateMelodyButton` → `playMelodyButtons(false)` → `solfegeExpansionTile` → "Play the melody back": **`buildNoteButtons`** → "Long press to see the solfege": **`buildSelectedChordButtons`** → `userWrittenSolfegeArea` → `clearAndBackspaceButtons` → `compareButton2` → `userWrittenMelodyButtons` | same as `LevelMelodyID` |
| `LevelChordMelodySinging` | Chord melody singing | same as `LevelChordSinging` plus **notes reference `buildNoteButtons`** before the chord reference ("Notes for reference" / "Chords for reference") | same as `LevelMelodySinging` |


#### Test pages (extend `TestPageAbstract`)

Common skeleton (copy of `LevelMelodyIDTest`/`LevelMelodySingingTest`): headers, score row, start button, `previousQuestionResult()`, question widgets, and the standard `finishTest()` override (insert `LevelTestResults` → `updateMissionStatus(getDeepMissionStatus(...))` → pushReplacementNamed `LevelTestResultsPage`). `onLevelEntered()` sets `numberOfQuestions = levelInfo!.NumQuestions`.

| Page | Start button | Question widgets | Answer mechanism |
|---|---|---|---|
| `LevelChordIDTest` | `startTestButton(g, m, false, levelInfo)` | `playMelodyButtons(false)`; "Enter the chords (N notes):" | **`buildSelectedChordButtons`** + `userWrittenSolfegeArea` + **`enterGuessbutton(g, m, false, levelInfo)`** |
| `LevelChordSingingTest` | `startTestButtonSinging(g, m, true, levelInfo)` | "Sing melody based on first note": `solfegeTextArea` → `sayTheSolfegeButton(compact: true)` → `playFirstNoteButtons` → "Listen to melody to check": `playMelodyButtons(true)` → chord reference | **`reportWhetherCorrect(g, m, levelInfo)`** (Yes/No) |
| `LevelChordMelodyIDTest` | `startTestButton(g, m, false, levelInfo)` | as `LevelChordIDTest` plus **`buildNoteButtons`** above the chord buttons | note + chord buttons + `enterGuessbutton` |
| `LevelChordMelodySingingTest` | `startTestButtonSinging(g, m, true, levelInfo)` | as `LevelChordSingingTest` plus notes reference | `reportWhetherCorrect` |

#### Hands-free pages (extend `HandsFreePageAbstract`)

Common skeleton (copy of `LevelMelodyIDHandsFree`/`LevelMelodySingingHandsFree`): headers, "Settings:" dropdown rows, `startStopButtons(...)`, `solfegeArea()`, `currentRoundRow(...)`, `returnToLevelButton(levelStatus)`; only `playRound()` differs. Round-control providers follow the existing campaign convention:

- **ID modes** (`LevelChordIDHandsFree`, `LevelChordMelodyIDHandsFree`): `melodySettings` = `roundSettings` = `MissionSettingsProvider` — `playRound` body identical to `LevelMelodyIDHandsFree.playRound` (generate → instrument repeats → reveal solfege → solfege repeats → spoken repeats).
- **Singing modes** (`LevelChordSingingHandsFree`, `LevelChordMelodySingingHandsFree`): `melodySettings` = `MissionSettingsProvider`, `roundSettings` = `MissionSingingSettings` — `playRound` body identical to `LevelMelodySingingHandsFree.playRound` (spoken + first-note repeats → solfege repeats → instrument repeats).

No chord-specific logic is required here: chord insertion/arpeggiation happens inside `ChordMelody` from `LevelConfig.chordFrequency` + `MissionSettingsProvider.getSelectedChords()`.


### 3.2 New files (12) — names, classes, routes

All in `lib/campaign/`, following the existing `LevelMelodyID` naming/route style:

| File | Widget class | State class | `routeName` | Extends |
|---|---|---|---|---|
| `levelChordID.dart` | `LevelChordID` | `LevelChordIDState` | `/levelchordid` | `MelodyPageAbstract` |
| `levelChordIDtest.dart` | `LevelChordIDTest` | `LevelChordIDTestState` | `/levelchordidtest` | `TestPageAbstract` |
| `levelChordIDhandsfree.dart` | `LevelChordIDHandsFree` | `_LevelChordIDHandsFreeState` | `/levelchordidhandsfree` | `HandsFreePageAbstract` |
| `levelChordSinging.dart` | `LevelChordSinging` | `LevelChordSingingState` | `/levelchordsinging` | `MelodyPageAbstract` |
| `levelChordSingingtest.dart` | `LevelChordSingingTest` | `LevelChordSingingTestState` | `/levelchordsingingtest` | `TestPageAbstract` |
| `levelChordSinginghandsfree.dart` | `LevelChordSingingHandsFree` | `_LevelChordSingingHandsFreeState` | `/levelchordsinginghandsfree` | `HandsFreePageAbstract` |
| `levelChordMelodyID.dart` | `LevelChordMelodyID` | `LevelChordMelodyIDState` | `/levelchordmelodyid` | `MelodyPageAbstract` |
| `levelChordMelodyIDtest.dart` | `LevelChordMelodyIDTest` | `LevelChordMelodyIDTestState` | `/levelchordmelodyidtest` | `TestPageAbstract` |
| `levelChordMelodyIDhandsfree.dart` | `LevelChordMelodyIDHandsFree` | `_LevelChordMelodyIDHandsFreeState` | `/levelchordmelodyidhandsfree` | `HandsFreePageAbstract` |
| `levelChordMelodySinging.dart` | `LevelChordMelodySinging` | `LevelChordMelodySingingState` | `/levelchordmelodysinging` | `MelodyPageAbstract` |
| `levelChordMelodySingingtest.dart` | `LevelChordMelodySingingTest` | `LevelChordMelodySingingTestState` | `/levelchordmelodysingingtest` | `TestPageAbstract` |
| `levelChordMelodySinginghandsfree.dart` | `LevelChordMelodySingingHandsFree` | `_LevelChordMelodySingingHandsFreeState` | `/levelchordmelodysinginghandsfree` | `HandsFreePageAbstract` |

### 3.3 Centralised mode→route dispatch (refactor)

Today the mode dispatch is duplicated as `if/else` chains in 5 places (level.dart ×3, melodyPageAbstract.dart ×1, levelTestResults.dart ×1). To avoid drift as we go from 2 → 6 modes, add one resolver per navigation kind in `lib/utils/helper.dart` (next to `campaignTreeShapes`):

```dart
// helpers in utils/helper.dart — single source of truth for mode → page routes
String? levelPracticeRoute(String missionMode) {
  switch (missionMode) {
    case "Melody ID":            return '/levelmelodyid';
    case "Melody singing":       return '/levelmelodysinging';
    case "Chord ID":             return '/levelchordid';
    case "Chord singing":        return '/levelchordsinging';
    case "Chord melody ID":      return '/levelchordmelodyid';
    case "Chord melody singing": return '/levelchordmelodysinging';
  }
  return null; // unknown mode (e.g. "Bonus") → caller hides/disables the button
}
// levelTestRoute(...) and levelHandsFreeRoute(...) analogous
```

The call sites then become `Navigator.pushNamed(context, levelPracticeRoute(missionMode)!, arguments: levelInfo)` with a null guard, so unknown future modes fail visibly instead of silently doing nothing.

Call sites to update:

1. `level.dart` `practiceButton` / `handsFreeButton` / `takeTestButton` — use the resolvers.
2. `melodyPageAbstract.dart` `takeTestButton` — use `levelTestRoute`.
3. `levelTestResults.dart` `optionalRedoTestButton` — use `levelTestRoute`.


### 3.4 `main.dart` changes

- Add 12 imports for the new page files.
- Register 12 routes in the `routes:` map following the existing pattern, e.g.:

```dart
LevelChordID.routeName:          (context) => LevelChordID(audioController: audioController),
LevelChordIDTest.routeName:      (context) => LevelChordIDTest(audioController: audioController),
LevelChordIDHandsFree.routeName: (context) => LevelChordIDHandsFree(audioController: audioController),
// ... and the singing / chordMelodyID / chordMelodySinging triplets
```

### 3.5 Files that need NO changes (verified)

- `campaign.dart` — shapes/widths/heights already resolve for the 4 new modes.
- `mission.dart` — level tiles, notes grid, chord reference are mode-agnostic.
- `missionSettings.dart` — key/instrument only, mode-agnostic.
- `testPageAbstract.dart`, `handsfreePageAbstract.dart` — all needed widgets exist.
- `melodyPageAbstract.dart` — apart from `takeTestButton`, every widget used by the new practice pages already exists (including `buildSelectedChordButtons`, which already respects `levelInfo?.ChordFrequency`).
- `mapping_provider.dart`, `objectBox.dart`, `utils/chordMelody.dart`, `utils/level_config.dart`, `utils/colors.dart` — mode-agnostic already.

---

## 4. Campaign settings & chord selection semantics (important design note)

- **Which chords are used**: `ChordMelody.generateChordMelody` and `buildSelectedChordButtons` take chords from `MissionSettingsProvider.getSelectedChords()`. Defaults are `I_Rt, IV0_Sec, V0_Fir` (`defaultChordKeys` in general_provider.dart) and the value persists in the `minimal_settings` SharedPreferences. There is currently **no campaign UI to change chords per mission/level** — chord content for the new modes will therefore come from these persisted defaults unless we extend the app. Out-of-scope options for later: (a) add a chord picker to `missionSettings.dart` shown per MissionMode, or (b) add a per-level chord list to `Missions.json` + `LevelInfo`. The plan keeps current behaviour (provider-level chord selection) so the JSON format doesn't change.
- **Whether chords are used at all**: `LevelInfo.ChordFrequency` (`"Never"` | `"Every 3 notes"` | `"Every 4 notes"`) gates generation and button visibility — chord missions should never author `"Never"` levels, and `buildSelectedChordButtons`/`buildSelectedChordButtonsHelper` will hide themselves if they do (safe fallback).
- **Notes still matter**: even chord missions generate a *melody of notes* with chords inserted every N notes, so `Notes`, `NumNotes`, `MaxDistance`, `StartWithDo/EndWithDo`, `StartingDo/EndingDo`, `PlaybackSpeed` remain meaningful in the JSON for all 4 new modes.


---

## 5. JSON content authoring (for the follow-up content task)

Once the code lands, new content goes into `assets/mapping/Missions.json` (one row per campaign-mission-level triplet) and the per-campaign tree file referenced by `CampaignFilename` (`{"nodes": [...], "edges": [{"from": id, "to": id}, ...]}`, loaded by `campaign.dart`). Row schema (parsed in `mapping_provider.dart` `loadMissionsJSON`):

| Field | Notes for the 4 new modes |
|---|---|
| `MissionMode` | Must match exactly: `Chord ID`, `Chord singing`, `Chord melody ID`, `Chord melody singing` (drives tree shape, colors, routing) |
| `Notes` / `NewNotes` | Comma-separated solfege names (e.g. `do,re,mi,fa,so`); melody pool + highlighting; still required for chord modes |
| `NumNotes`, `MaxDistance`, `AllowRepeatedNotes`, `PlaybackSpeed`, `StartWithDo`, `EndWithDo`, `StartingDo`, `EndingDo` | Melody difficulty knobs, same semantics as melody missions |
| `ChordFrequency` | `Every 4 notes` / `Every 3 notes` for chord modes; `Never` hides all chord UI |
| `NumTests`, `NumQuestions`, `PassingScore` | Test gating — identical for all modes |
| `MissionUnlockedBy`, `MissionUnlockedByRelationship` | `AND`/`OR` over mission IDs — unchanged |

Suggested IDs follow the existing convention (`c<campaign#>m<mission#>`, levels with `LevelID` per row). Tree shapes that will render: hexagon (Chord ID), trapezoid (Chord singing), octagon (Chord melody ID), diamond (Chord melody singing) — sizes come from `campaignTreeWidth`/`campaignTreeHeight` (trapezoid is 200×200, notably taller; adjust those maps if the tree gets cramped).

---

## 6. Implementation order

1. **Add the 3 dispatch resolvers** to `utils/helper.dart` and rewire `level.dart` (3 buttons), `melodyPageAbstract.takeTestButton`, `levelTestResults.optionalRedoTestButton` — behaviour unchanged for the existing 2 modes (safe refactor, verified by `flutter analyze` + smoke test of a Melody mission).
2. **Chord ID triplet** (`levelChordID.dart`, `levelChordIDtest.dart`, `levelChordIDhandsfree.dart`) — closest to the existing `LevelMelodyID` pages; register routes in `main.dart`.
3. **Chord melody ID triplet** — Chord ID pages + note buttons.
4. **Chord singing triplet** — mirrors `LevelMelodySinging` pages.
5. **Chord melody singing triplet** — Chord singing pages + note buttons.
6. **Full validation pass** (below).

Steps 2-5 each include: create 3 files, register 3 routes, `flutter analyze`, and a manual run-through with a temporary JSON row.

## 7. Validation plan

- `flutter analyze` (from `flutter/melody_ear_trainer/`) — zero new errors.
- `flutter run -d windows` smoke tests with temporary missions added to `Missions.json` + the campaign tree file (one per mode, 2 levels each):
  1. Campaign tree renders each new mode with its shape; locked/unlocked behaviour intact.
  2. Mission → Level → Practice: first melody autoplays (ID) / first note plays + solfege shown (singing); answering with chord/note buttons; compare shows ✓/✗; "Next melody" regenerates.
  3. Take a test: start → N questions → results page → mission status updates; "Repeat test" from results works for all 6 modes.
  4. Hands-free: start/stop mid-round safely, rounds counter, live dropdown changes apply, dispose stops audio.
  5. Regression: existing Melody ID / Melody singing missions behave identically (practice, test, hands-free, tree).
- `test/` currently has no unit tests (empty `widget_test.dart`), so no unit-test gate is added by this plan; the pure-logic pieces (`ChordMelody`, `LevelConfig`) are unchanged.

## 8. Risks / open questions / small cleanups

1. **Chord selection has no campaign UI** (see §4). If chord missions need curated chord sets per mission, we should add either a mission-settings chord picker or per-level chord lists in JSON — decide before authoring content.
2. **Trapezoid size** (200×200) may crowd the tree once many missions exist — tune `campaignTreeWidth`/`campaignTreeHeight` after seeing real content.
3. **Existing minor bug** in `LevelMelodySingingTest.finishTest`: timestamp format `HH:MM` (months, not minutes) — `LevelMelodyIDTest` uses `HH:mm`. Copy the correct format into the new singing test pages and fix the existing one opportunistically.
4. `startTestButtonSinging`/`reportWhetherCorrect` already handle `setSolfegeText`/regeneration correctly for chord melodies (they use `generatedChordMelody` + `LevelConfig`), so no abstract changes are expected; if a widget turns out to assume single-note melodies during implementation, fix it in the abstract, not per page.
5. Unknown future modes (e.g. `Bonus`) resolve to `null` routes → buttons disabled with the resolver guard instead of silently doing nothing (current behaviour).

The build succeeded — `√ Built build\windows\x64\runner\Debug\melody_ear_trainer.exe` (the odd exit code is just a PowerShell pipeline quirk; the executable was produced). Implementation is complete and validated.

## Summary

I implemented the full plan from `20260907_ear_training_types_upgrade.md`. **Validation: `flutter analyze` → "No issues found!" and `flutter build windows --debug` → executable built successfully.**

### 13 new files (in `flutter/melody_ear_trainer/lib/campaign/`)

| Mode | Practice | Test | Hands-free |
|---|---|---|---|
| Chord ID | `levelChordID.dart` (`/levelchordid`) | `levelChordIDtest.dart` | `levelChordIDhandsfree.dart` |
| Chord singing | `levelChordSinging.dart` | `levelChordSingingtest.dart` | `levelChordSinginghandsfree.dart` |
| Chord melody ID | `levelChordMelodyID.dart` | `levelChordMelodyIDtest.dart` | `levelChordMelodyIDhandsfree.dart` |
| Chord melody singing | `levelChordMelodySinging.dart` | `levelChordMelodySingingtest.dart` | `levelChordMelodySinginghandsfree.dart` |

Plus **`levelRoutes.dart`** — the centralized `levelPracticeRoute()` / `levelHandsFreeRoute()` / `levelTestRoute()` resolvers. One improvement over the plan: they return the pages' own `routeName` constants rather than duplicated string literals, so routes can't drift; unknown modes (e.g. "Bonus") return `null` and the buttons do nothing instead of crashing.

- **Practice pages** extend `MelodyPageAbstract` — ID modes answer with `buildSelectedChordButtons` (+ `buildNoteButtons` for chord-melody ID) and `compareButton2`; singing modes show the solfege, play the first note, and include "Notes/Chords for reference" sections.
- **Test pages** extend `TestPageAbstract` — ID modes use `startTestButton` + `enterGuessbutton`; singing modes use `startTestButtonSinging` + `reportWhetherCorrect`; all write `LevelTestResults` and update mission status via the standard `finishTest()`.
- **Hands-free pages** extend `HandsFreePageAbstract` — ID modes use `MissionSettingsProvider` for rounds; singing modes use `MissionSingingSettings` (matching the existing melody pages' convention).

### 5 existing files updated

- **`level.dart`** — 6 page imports → 1 `levelRoutes.dart` import; `practiceButton`/`handsFreeButton`/`takeTestButton` now resolve via the resolvers (all 6 modes work).
- **`melodyPageAbstract.dart`** — `takeTestButton` rewired via `levelTestRoute`.
- **`levelTestResults.dart`** — "Repeat test" rewired via `levelTestRoute`.
- **`main.dart`** — 12 imports + 12 routes registered.
- **`levelMelodySingingtest.dart`** — opportunistic fix: timestamp format `HH:MM` (months!) → `HH:mm`.

### Notes for your content authoring next step

- `MissionMode` strings must match exactly: `Chord ID`, `Chord singing`, `Chord melody ID`, `Chord melody singing` (shapes/colors/tree routing key off these).
- Use `ChordFrequency` = `Every 3 notes` or `Every 4 notes` on chord levels (`Never` auto-hides all chord buttons). Chords used come from `MissionSettingsProvider`'s persisted selection (defaults `I_Rt, IV0_Sec, V0_Fir`) — there's still no campaign UI to change chords, as flagged in the plan.
- Manual smoke-testing with real mission JSON (tree shapes, unlocking, audio) is the remaining step from the plan's validation section.