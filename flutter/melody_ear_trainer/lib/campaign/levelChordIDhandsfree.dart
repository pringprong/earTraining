import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/helper.dart';
import 'handsfreePageAbstract.dart';

class LevelChordIDHandsFree extends HandsFreePageAbstract {
  const LevelChordIDHandsFree({super.key, required super.audioController});
  static const String routeName = '/levelchordidhandsfree';

  @override
  State<LevelChordIDHandsFree> createState() => _LevelChordIDHandsFreeState();
}

class _LevelChordIDHandsFreeState
    extends HandsFreePageAbstractState<LevelChordIDHandsFree> {
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
    if (!notPaused) return true;
    solfegeText = chordMelody.getChordMelody().join(' ');
    setState(() {});
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
    if (!notPaused) return true;
    await repeatPlay(
      repeats: roundSettings.getSpokenRepeats,
      play:
          () => chordMelody.playSpoken(
            melodySettings,
            mappingProvider,
            widget.audioController,
            levelConfig: config,
          ),
      delaySeconds: roundSettings.getTimeDelayRepeat,
    );
    if (!notPaused) return true;
    currentRound++;
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = this.levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    final generalProvider = context.read<MissionSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Hands-free chord ID')),
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
                value: context.select<MissionSettingsProvider, int>(
                  (s) => s.numberOfRounds,
                ),
                items: [5, 10, 15, 20, 25],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setNumberOfRounds(rounds: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Instrument repeats:',
                value: context.select<MissionSettingsProvider, int>(
                  (s) => s.melodyRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setMelodyRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Solfege repeats:',
                value: context.select<MissionSettingsProvider, int>(
                  (s) => s.solfegeRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setSolfegeRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Spoken repeats:',
                value: context.select<MissionSettingsProvider, int>(
                  (s) => s.spokenRepeats,
                ),
                items: [0, 1, 2, 3, 4, 5],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setSpokenRepeats(repeats: newValue),
              ),
              settingsDropdownRow<int>(
                label: 'Time between repeats (s):',
                value: context.select<MissionSettingsProvider, int>(
                  (s) => s.getTimeDelayRepeat,
                ),
                items: [1, 2, 3, 4, 5, 6, 7, 8],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setTimeDelayRepeat(delay: newValue),
              ),
              settingsDropdownRow<String>(
                label: 'Instrument:',
                value: context.select<MissionSettingsProvider, String>(
                  (s) => s.handsfreeInstrument,
                ),
                items: ["Guitar", "Piano", "Alternate"],
                onChanged:
                    (newValue) => context
                        .read<MissionSettingsProvider>()
                        .setHandsfreeInstrument(instrument: newValue),
              ),
              verticalSpacer(),
              subHeadingRow("Controls:"),
              verticalSpacer(),
              startStopButtons(
                melodySettings: generalProvider,
                roundSettings: generalProvider,
                mappingProvider: mappingProvider,
              ),
              verticalSpacer(),
              subHeadingRow("Solfege:"),
              verticalSpacer(),
              solfegeArea(),
              verticalSpacer(),
              subHeadingRow("Current round:"),
              verticalSpacer(),
              currentRoundRow(generalProvider),
              verticalSpacer(),
              returnToLevelButton(levelStatus),
            ], // Children of Column
          ),
        ),
      ),
    );
  }
}
