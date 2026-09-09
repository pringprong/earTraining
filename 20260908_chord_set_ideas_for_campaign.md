# 20260908 — Chord set ideas for the campaign (Chord ID / Chord singing scoping)

## Original prompt

> I can see that the problem is that we don't have a set of chords that goes together with the campaign. The campaign name is associated with a set of notes, but it's not associated with a set of chords. And the total number of chords is just too great. We cannot do all of the chords in one campaign. I could just select the root chords from the middle octave and focus on those for the major scale. What do you suggest we do to make the new chord ID and chord singing mission modes make more sense? Place your answer together with this prompt in the following file: 20260908_chord_set_ideas_for_campaign.md

---

## 1. TL;DR — the recommendation

**Give campaigns the same chord scoping the custom modes already have, then narrow per level — mirroring exactly how notes already work.**

1. **Campaign level**: add two optional columns to `Missions.json` — `CampaignChordRange` (`Lower` / `Middle` / `All_Root`) and `CampaignChordSet` (e.g. `I_IV_V`). These reuse the **existing** `ChordSets.json` data, which already curates small, register-bounded chord groups. Your instinct ("root chords, middle octave, major scale") is literally the existing set **`I_IV_V` @ Range `Middle`** = `I_Rt, IV0_Sec, V0_Fir` (the inversions are pre-chosen to keep all three chords inside one singable register).
2. **Level level**: add optional `Chords` and `NewChords` columns per level row (parallel to `Notes` / `NewNotes`) so each mission/level drills a small subset (2–4 chords) and highlights newly introduced chords — same pedagogy, same UI treatment as new notes.
3. **Resolution chain** in code: level `Chords` → campaign Range+Set → provider selection. Custom (non-campaign) modes keep using their own provider settings, so nothing there changes.

This keeps JSON authoring light (a campaign is one Range+Set pair; levels just list the chords they use), keeps every chord-mission's answer-button row to 2–4 options (the actual difficulty knob), and needs only small, backward-compatible code changes.

---

## 2. What already exists (verified — more than you might think)

### The chord vocabulary: `assets/mapping/Chords.json` (~112 variants)

Every chord is named `<Degree><Octave?>_<Inversion>` and maps to solfege notes, e.g.:

| Chord Set (name) | Notes | Meaning |
|---|---|---|
| `I_Rt` | do,mi,so | tonic triad, middle octave, root position |
| `I0_Rt` | do0,mi0,so0 | same, lower octave (`0` = one octave below middle do) |
| `I_Fir` / `I_Sec` | mi,so,do1 / so,do1,mi1 | first / second inversion |
| `IV0_Sec` | — | IV, lower octave, second inversion |
| `V70_Fir` | — | dominant 7th, first inversion |
| `vi0_Fir`, `i_Rt`, ... | — | minor degrees are lowercase Roman numerals |

Because chords are **solfege-based**, they automatically transpose with the campaign key (`nestedMapping[key][instrument][note]`) — a chord set defined once works for every key, like the note sets.

### The curated groups: `assets/mapping/ChordSets.json`

This file already solves the "too many chords" problem with named sets per **register**:

| Range | Set | Chords |
|---|---|---|
| `Middle` | `I_IV_V` | `I_Rt, IV0_Sec, V0_Fir` |
| `Middle` | `I_IV_V_vi` | `I_Rt, IV0_Sec, V0_Fir, vi0_Fir` |
| `Middle` | `I_IV_V_V7_vi` | `I_Rt, IV0_Sec, V0_Fir, vi0_Fir, V70_Fir` |
| `Middle` | `I` | `I_Rt, I_Fir, I_Sec` (inversions of one chord) |
| `Middle` | `i` | `i_Rt, i_Fir, i_Sec` |
| `All_Root` | `I_IV_V` | root positions across both octaves |
| `Lower` | `I_IV_V` | low-register variants |
| any | `Select all` / `Select none` | sentinels (loader fills/clears the full list) |

Note what `Middle` does: it doesn't just take root positions — it picks the **inversion of IV and V that keeps the chords clustered around middle do** (`IV0_Sec`, `V0_Fir`). That's what makes it right for **chord singing** (everything sits in a voice range) and good for chord ID (register no longer a giveaway cue).

### The custom modes already work this way

`GeneralProvider` already has `chordSetRange` (default `"Middle"`) and `chordSet` (default `"I_IV_V"`), persisted in settings, with `updateChordRange`/`updateChordSet` and dropdowns on the custom settings pages. `MappingProvider.chordSetsMapping[range][set]` → chord list. **The campaign side simply never got hooked up to this** — campaign modes fall back to `MissionSettingsProvider.getSelectedChords()` (defaults `I_Rt, IV0_Sec, V0_Fir`, silently persisted, no campaign awareness).

### How campaigns scope notes today (the pattern to copy)

`CampaignOctave` + `CampaignSet` + `CampaignNotesInOctave` define the note universe; each level row's `Notes` narrows the pool and `NewNotes` flags what's new (colored highlighting on the mission/level pages). Chords should follow the identical two-stage design.

---

## 3. Options considered

| Option | Idea | Verdict |
|---|---|---|
| A — status quo | Campaign chord modes keep using `MissionSettingsProvider` chord selection | ❌ campaign content depends on hidden user prefs; no progression; mission page shows the same 3 default chords regardless of level |
| B — campaign-level only | One Range+Set per campaign, used by all its chord missions | ✅ simple authoring, ❌ no per-level progression or "new chord" highlighting; a 5-chord set from mission 1 is steep |
| C — per-level only | Every level row lists its exact `Chords` | ✅ max flexibility, ❌ lots of authoring, easy to drift, no campaign-wide identity |
| **D — hybrid (recommended)** | Campaign Range+Set defines the universe; level `Chords`/`NewChords` narrow it and flag novelty | ✅ mirrors the note pipeline 1:1, cheap authoring, per-level progression, consistent identity per campaign |

## 4. The resolution chain (code side)

One rule, applied everywhere chords are consumed:

```
level.Chords (if non-empty)
  → else campaign Range+Set via chordSetsMapping[range][set] (if campaign declares one)
    → else provider.getSelectedChords()   (custom modes + campaigns without a chord scope)
```

Places that consume it:

- `ChordMelody.generateChordMelody()` — chord pool for melody generation.
- `MelodyPageAbstractState.buildSelectedChordButtons()` — the answer buttons on practice/test pages (and long-press reference). Since the campaign pages already hold `levelInfo`, the widget can resolve the chain internally and every call site stays unchanged.
- `helper.buildSelectedChordButtonsHelper()` — mission page / singing-test reference display; add an optional `chordsOverride` (the mission page passes the last level's chords, exactly like it already passes `selectedNotes: lastLevel?.Notes`).
- Hands-free pages need **no changes** (they generate via `generateChordMelody` with `LevelConfig`).

## 5. Concrete code changes (all backward-compatible)

1. **`providers/mapping_provider.dart`** — parse 4 optional keys in `loadMissionsJSON`: `CampaignChordRange`, `CampaignChordSet` (store on `CampaignInfo`; empty string = no scope) and per-row `Chords`, `NewChords` (store on `LevelInfo`; empty = inherit). Add getters `getCampaignChordRange/Set`.
2. **`utils/helper.dart`** — `CampaignInfo` + `LevelInfo` gain the new fields; `buildSelectedChordButtonsHelper` gains an optional `chordsOverride`.
3. **`utils/level_config.dart`** — `LevelConfig` gains `chords`; filled from the resolved level list (empty → `null` → consumer falls back to the provider).
4. **`utils/chordMelody.dart`** — in `generateChordMelody`, prefer `cfg.chords` when non-null, else keep using `generalProvider.getSelectedChords()`. The campaign scope is resolved *before* building the `LevelConfig`: the abstract page states (`MelodyPageAbstractState`, `HandsFreePageAbstractState`) already hold `levelInfo` + `mappingProvider`, so they can compute "level Chords → campaign Range+Set → provider" once and hand the final list to `LevelConfig.chords`. `ChordMelody` itself stays simple.
5. **`melodyPageAbstract.dart`** — `buildSelectedChordButtons` resolves the same chain internally (uses `levelInfo.Chords` when present, else campaign scope, else provider) so the 12 new pages need no edits.
6. **`campaign/mission.dart` / `campaign/missionSettings.dart`** — optional: a read-only "Chords: I_IV_V (Middle)" line from the campaign scope; the chord button row will then automatically show exactly the level's chords.
7. **No changes** needed to the 12 new chord-mode pages, `testPageAbstract`, `handsfreePageAbstract`, or ObjectBox.


## 6. JSON examples

Campaign-level fields (repeated on every row of that campaign, like the other `Campaign*` fields):

```json
{
  "CampaignID": "c0",
  "CampaignName": "Campaign 1: Pentatonic",
  "CampaignFilename": "pentatonic.json",
  "CampaignOctave": "All octaves",
  "CampaignSet": "Pentatonic major",
  "CampaignNotesInOctave": "5",
  "CampaignChordRange": "Middle",
  "CampaignChordSet": "I_IV_V",
  ...
}
```

Level-level narrowing (chord campaign rows only; empty/missing = inherit campaign scope):

```json
{
  "MissionID": "c0m07",
  "MissionName": "Two chords: I and V",
  "MissionMode": "Chord ID",
  "LevelID": "c0m07L100",
  "Chords": "I_Rt,V0_Fir",
  "NewChords": "I_Rt,V0_Fir",
  "ChordFrequency": "Every 4 notes",
  "NumNotes": "4",
  ...
}
```

## 7. Suggested content ladder (major-scale campaign)

**Chord ID** — the answer-button row *is* the difficulty knob, so grow it slowly (2 → 3 → 4):

| Mission | Level chords | Learns |
|---|---|---|
| 1. "Tonic & Dominant" | `I_Rt, V0_Fir` | function contrast, 2-way choice |
| 2. "Primary triads" | `I_Rt, IV0_Sec, V0_Fir` | = the classic `I_IV_V` Middle set |
| 3. "Adding vi" | `+ vi0_Fir` | deceptive color (set `I_IV_V_vi`) |
| 4. "Dominant seventh" | `+ V70_Fir` | tension chord (set `I_IV_V_V7_vi`) |
| 5. "Inversions of I" | `I_Rt, I_Fir, I_Sec` | same chord, different bass (set `I`) |
| 6+. Review / speed | full campaign set, faster `PlaybackSpeed` | fluency |

**Chord singing** — same ladder, but:

- keep `NumNotes` low (3–5) and `ChordFrequency` at `Every 3/4 notes` so sung stretches stay short;
- stay in the `Middle` range — the pre-picked inversions keep every chord inside voice range (the mission page already warns "make sure all of these are in your range...");
- the hands-free page's spoken-plus-first-note loop is the main practice vehicle, so set spoken/solfege repeats generously.

Later campaigns need **zero new code**: an `All_Root` campaign (octave-transposition recognition), a minor campaign using set `i` / `i_IV_V...`, and a "seventh chords" campaign — all just different `CampaignChordRange` / `CampaignChordSet` values.

## 8. Why not "all chords in one campaign"

- `Chords.json` holds ~112 variants; even a single register holds ~40. A chord-ID discrimination set beyond ~4 buttons stops measuring hearing and starts measuring elimination strategy.
- Chord singing needs register-bounded chords, which only the curated inversions in `ChordSets.json` guarantee.
- Small sets per level + a campaign-wide chord identity give natural unlock pacing (`MissionUnlockedBy`), review missions, and "new chord" moments that match the existing notes UX.

## 9. Open questions

1. Should the campaign tree show the chord scope anywhere (e.g. a subtitle on chord-mission nodes), or keep it inside the mission page only?
2. Should `NewChords` also gate completion (a level can't pass until each new chord was answered correctly N times), or stay cosmetic like `NewNotes`?
3. Do we ever want a scope *smaller* than a set (e.g. only `I_Rt` vs `V0_Fir` in mission 1)? — already covered by per-level `Chords`, so no new mechanism needed.
4. Naming: keep the `ChordSets.json` "Set" names (`I_IV_V`) as the public campaign vocabulary, or add friendlier display names in a future column?

The document is complete at `c:\Users\pring\Github\earTraining\20260908_chord_set_ideas_for_campaign.md` (169 lines, prompt + full answer).

## My recommendation, in short

**Your instinct is already 90% built into the app — it just was never wired to campaigns.** While researching the answer I found:

1. **`ChordSets.json` already defines exactly the "campaign-sized" chord universes you described.** It has named sets (`I_IV_V`, `I_IV_V_vi`, `I_IV_V_V7_vi`, `I`, `i`) per register (`Lower` / `Middle` / `All_Root`). "Root chords from the middle octave" is literally the existing **`I_IV_V` @ `Middle`** set = `I_Rt, IV0_Sec, V0_Fir` — and note it uses *pre-picked inversions* (IV second inversion, V first inversion) so all three chords sit inside one singable register, which matters a lot for chord singing.

2. **The custom modes already use this mechanism** — `chordSetRange` (default `Middle`) + `chordSet` (default `I_IV_V`) are existing provider fields with settings dropdowns. The campaign modes just fall back to the hidden provider chord selection instead.

So the suggested design (a hybrid, mirroring exactly how notes work today):

- **Campaign level**: add optional `CampaignChordRange` + `CampaignChordSet` columns to `Missions.json` → one Range+Set pair defines the campaign's chord universe.
- **Level level**: add optional `Chords` + `NewChords` columns per level row (parallel to `Notes`/`NewNotes`) — mission 1 drills just `I_Rt, V0_Fir`, later missions add `IV0_Sec`, then `vi0_Fir`, then `V70_Fir`, then inversions of I. `NewChords` drives the same colored "new" highlighting notes already have.
- **Resolution chain** in code: level `Chords` → campaign Range+Set → provider selection. Custom modes keep their current behavior; the 12 new campaign pages need **zero changes** (the widgets resolve the chain internally via `levelInfo`).

The doc also includes a concrete mission ladder for a major-scale campaign (chord ID grows the answer buttons 2→3→4, which *is* the difficulty knob; chord singing stays in `Middle` with short melodies), JSON examples, the ~7 small backward-compatible code changes needed, why one campaign can't hold all ~112 chord variants, and 4 open questions (e.g. whether `NewChords` should gate completion or stay cosmetic).

When you're ready, say the word and I'll implement the §5 code changes.