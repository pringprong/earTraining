import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';
import '../utils/colors.dart';

class LevelChordMelodyID extends MelodyPageAbstract {
  const LevelChordMelodyID({super.key, required super.audioController}) : super();

  static const String routeName = '/levelchordmelodyid';
  @override
  LevelChordMelodyIDState createState() => LevelChordMelodyIDState();
}

class LevelChordMelodyIDState extends MelodyPageAbstractState {
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
      false,
      newNotes: info.NewNotes,
    );
    generatedChordMelody.playChordMelody(
      generalProvider.getSelectedInstrument,
      generalProvider,
      mappingProvider,
      widget.audioController,
      levelConfig: resolveLevelConfig(generalProvider),
    );
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
              plainText("Listen to generated melody again:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              solfegeExpansionTile(generalProvider, mappingProvider),
              verticalSpacer(),
              plainText(
                "Play the melody back (" +
                    levelInfo.NumNotes.toString() +
                    " notes):",
              ),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              verticalSpacer(),
              clearAndBackspaceButtons(),
              verticalSpacer(),
              compareButton2(generalProvider, mappingProvider),
              verticalSpacer(),
              generateMelodyButton(
                generalProvider,
                mappingProvider,
                false,
                newNotes: levelInfo.NewNotes,
              ),
              verticalSpacer(),
              plainText("Listen to your melody:"),
              verticalSpacer(),
              userWrittenMelodyButtons(generalProvider, mappingProvider),
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
                setSolfegeText,
                newNotes: newNotes,
              );
              generatedChordMelody.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget.audioController,
                levelConfig: resolveLevelConfig(generalProvider),
              );
              setState(() {
                //solfegeText = ""; // Clear solfege area
                setToWaitingForGuess();
              });
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

  Row compareButton2(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(comparisonIcon, color: comparisonIconColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap['brightBackground'],
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
              side: BorderSide(color: comparisonIconColor, width: borderWidth),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Compare with generated melody",
                style: TextStyle(fontSize: 20),
              ),
            ),
            onPressed: () {
              setState(() {
                // Compare writtenChordMelody with generated melody
                melodiesSame = generatedChordMelody.sameAs(
                  userWrittenChordMelody,
                );
                if (melodiesSame) {
                  setToCorrectGuess();
                  generatedChordMelody.playChordMelody(
                    "Solfege",
                    generalProvider,
                    mappingProvider,
                    widget.audioController,
                    levelConfig: resolveLevelConfig(generalProvider),
                  );
                } else {
                  setToIncorrectGuess();
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
