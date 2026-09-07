import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/chordMelody.dart';
import '../utils/helper.dart';
import 'handsfreePageAbstract.dart';

class LevelChordSingingHandsFree extends HandsFreePageAbstract {
  const LevelChordSingingHandsFree({super.key, required super.audioController});
  static const String routeName = '/levelchordsinginghandsfree';

  @override
  State<LevelChordSingingHandsFree> createState() =>
      _LevelChordSingingHandsFreeState();
}

class _LevelChordSingingHandsFreeState
    extends HandsFreePageAbstractState<LevelChordSingingHandsFree> {
  // NOTE: melody generation settings (key/instrument/chords) come from the
  // shared MissionSettingsProvider, while the hands-free controls (rounds,
  // repeats, delays, hands-free instrument) use the dedicated
  // MissionSingingSettings provider with its own saved preferences.
  @override
  Future<bool> playRound(
    GeneralProvider melodySettings,
    GeneralProvider roundSettings,
    MappingProvider mappingProvider,
  ) async {
    final info = levelInfo!;
    final config = resolveLevelConfig(melodySettings);
    String result = chordMelody.generateChordMelody(
      melodySettings,
      mappingProvider,
      newNotes: info.NewNotes,
      levelConfig: config,
    );
    if (result.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
      return false;
    }
    solfegeText = chordMelody.getChordMelody().join(' ');
    setState(() {});
    for (
      int n = 0;
      n < roundSettings.getSpokenRepeats && notPaused;
      n++
    ) {
      await chordMelody.playSpoken(
        melodySettings,
        mappingProvider,
        widget.audioController,
        levelConfig: config,
      );
      await Future.delayed(Duration(seconds: 1));
      ChordMelody firstNote = ChordMelody.singleChord(
        chordMelody.getFirstNoteOrChord_Melody(),
        chordMelody.getFirstNoteOrChord_Solfege(),
      );
      await firstNote.playChordMelody(
        "Solfege",
        melodySettings,
        mappingProvider,
        widget.audioController,
        levelConfig: config,
      );
      if (!notPaused) {
        return true; // Exit if paused
      }
      await Future.delayed(
        Duration(seconds: roundSettings.getTimeDelayRepeat),
      );
    }
    await repeatPlay(
      repeats: roundSettings.getSolfegeRepeats,
      play:
          () => chordMelody.playChordMelody(
            "Solfege",
            melodySettings,
            mappingProvider,
            widget.audioController,
            levelConfig: config,
          ),
      delaySeconds: roundSettings.getTimeDelayRepeat,
    );
    if (!notPaused) {
      return true; // Exit if paused
    }
    await repeatPlay(
      repeats: roundSettings.getMelodyRepeats,
      play:
          () => chordMelody.playChordMelody(
            getInstrument(roundSettings.handsfreeInstrument),
            melodySettings,
            mappingProvider,
            widget.audioController,
            levelConfig: config,
          ),
      delaySeconds: roundSettings.getTimeDelayRepeat,
    );
    if (!notPaused) {
      return true; // Exit if paused
    }
    currentRound++;
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = this.levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    final generalProvider = context.read<MissionSettingsProvider>();
    final handsfreeSettings = context.read<MissionSingingSettings>();

    return Scaffold(
      appBar: AppBar(title: Text('Hands-free chord singing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CampaignHeaderRow(campaignId: levelInfo.CampaignID),
              verticalSpacer(),
              MissionHeaderRow(missionId: levelInfo.MissionID),
              verticalSpacer(),
              LevelHeaderRow(levelId: levelInfo.LevelID),
              verticalSpacer(),
              subHeadingRow("Settings:"),
              settingsDropdownRow<int>(
                label: 'Number of rounds:',
                value: context.select<MissionSingingSettings, int>(
                  (s) => s.numberOfRounds,
                ),
                items: [5, 10, 15, 20, 25],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setNumberOfRounds(rounds: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Spoken plus first note repeats:',
                value: context.select<MissionSingingSettings, int>(
                  (s) => s.spokenRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setSpokenRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Solfege repeats:',
                value: context.select<MissionSingingSettings, int>(
                  (s) => s.solfegeRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setSolfegeRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Instrument repeats:',
                value: context.select<MissionSingingSettings, int>(
                  (s) => s.melodyRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setMelodyRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Time between repeats (s):',
                value: context.select<MissionSingingSettings, int>(
                  (s) => s.getTimeDelayRepeat,
                ),
                items: [1, 2, 3, 4, 5, 6, 7, 8],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setTimeDelayRepeat(delay: newValue),
              ),
              settingsDropdownRow<String>(
                label: 'Instrument:',
                value: context.select<MissionSingingSettings, String>(
                  (s) => s.handsfreeInstrument,
                ),
                items: ["Guitar", "Piano", "Alternate"],
                onChanged:
                    (newValue) => context
                        .read<MissionSingingSettings>()
                        .setHandsfreeInstrument(instrument: newValue),
              ),
              verticalSpacer(),
              subHeadingRow("Controls:"),
              verticalSpacer(),
              startStopButtons(
                melodySettings: generalProvider,
                roundSettings: handsfreeSettings,
                mappingProvider: mappingProvider,
              ),
              verticalSpacer(),
              subHeadingRow("Solfege:"),
              verticalSpacer(),
              solfegeArea(),
              verticalSpacer(),
              subHeadingRow("Current round:"),
              verticalSpacer(),
              currentRoundRow(handsfreeSettings),
              verticalSpacer(),
              returnToLevelButton(levelStatus),
            ], // Children of Column
          ),
        ),
      ),
    );
  }
}
