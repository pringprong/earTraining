import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';

class LevelChordMelodySinging extends MelodyPageAbstract {
  const LevelChordMelodySinging({super.key, required super.audioController})
    : super();

  static const String routeName = '/levelchordmelodysinging';
  @override
  LevelChordMelodySingingState createState() => LevelChordMelodySingingState();
}

class LevelChordMelodySingingState extends MelodyPageAbstractState {
  String levelStatus = "";

  @override
  void onLevelEntered() {
    // Runs once per displayed level (guarded by LevelID in the base mixin).
    // Level settings come from LevelConfig (derived from levelInfo), so there
    // is no need to push them into the global settings provider first.
    final info = levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    final generalProvider = context.read<MissionSettingsProvider>();
    newGenerateChordMelody(
      generalProvider,
      mappingProvider,
      true,
      newNotes: info.NewNotes,
    );
    ChordMelody fn = ChordMelody.singleChord(
      generatedChordMelody.getFirstNoteOrChord_Melody(),
      generatedChordMelody.getFirstNoteOrChord_Solfege(),
    );
    fn.playChordMelody(
      generalProvider.getSelectedInstrument,
      generalProvider,
      mappingProvider,
      widget.audioController,
      levelConfig: resolveLevelConfig(generalProvider),
    );
    solfegeText = generatedChordMelody.getChordMelody().join(' ');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the DB-derived status when the page (re)gains visibility,
    // instead of querying ObjectBox on every build.
    if (levelInfo != null) {
      levelStatus = getLevelStatusWithQuery(levelInfo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = this.levelInfo!;
    final mappingProvider = context.read<MappingProvider>();
    final generalProvider = context.read<MissionSettingsProvider>();
    // levelStatus is refreshed in didChangeDependencies (see above).

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Practice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              plainText("Generated melody:"),
              solfegeTextArea(),
              verticalSpacer(),
              sayTheSolfegeButton(generalProvider, mappingProvider),
              verticalSpacer(),
              plainText("Listen to first note:"),
              verticalSpacer(),
              playFirstNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              instructionRow(
                "Now try to sing the melody out loud...",
                small: true,
              ),
              verticalSpacer(),
              plainText("Listen to the melody for comparison:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, true),
              verticalSpacer(),
              instructionRow("Did you sing it correctly?", small: true),
              verticalSpacer(),
              generateMelodyButton(
                generalProvider,
                mappingProvider,
                false,
                newNotes: levelInfo.NewNotes,
              ),
              verticalSpacer(),
              plainText("Notes for reference:"),
              verticalSpacer(),
              plainText(
                "Note: Change the key in Mission settings if not in your singing range",
              ),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              subHeadingRow("Chords for reference"),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              returnToLevelButton(levelStatus),
              verticalSpacer(),
              takeTestButton(
                mappingProvider.missions[levelInfo.MissionID]!.MissionMode,
                levelInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Row generateMelodyButton(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText, {
    Set<String> newNotes = const {},
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'],
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(
                color: colorMap["practiceButtonColor"] ?? Colors.white,
                width: borderWidth,
              ),
            ),
            onPressed: () {
              newGenerateChordMelody(
                generalProvider,
                mappingProvider,
                true,
                newNotes: newNotes,
              );
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget.audioController,
                levelConfig: resolveLevelConfig(generalProvider),
              );
              solfegeText = generatedChordMelody.getChordMelody().join(' ');
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Next melody", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }
}
