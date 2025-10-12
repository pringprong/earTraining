import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';

class LevelMelodySinging extends MelodyPageAbstract {
  const LevelMelodySinging({super.key, required super.audioController})
    : super();

  static const String routeName = '/levelmelodysinging';
  @override
  LevelMelodySingingState createState() => LevelMelodySingingState();
}

class LevelMelodySingingState extends MelodyPageAbstractState {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MappingProvider mappingProvider = Provider.of<MappingProvider>(context);
    GeneralProvider generalProvider = Provider.of<missionSettingsProvider>(
      context,
    );
    newGenerateChordMelody(generalProvider, mappingProvider, true);
    ChordMelody fn = ChordMelody.singleChord(
      generatedChordMelody.getFirstNoteOrChord_Melody(),
      generatedChordMelody.getFirstNoteOrChord_Solfege(),
    );
    fn.playChordMelody(
      generalProvider.getSelectedInstrument,
      generalProvider,
      mappingProvider,
      widget,
    );
    solfegeText = generatedChordMelody.getChordMelody().join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<missionSettingsProvider>(context);
    String levelStatus = getLevelStatusWithQuery(levelInfo);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Practice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              campaignHeader(mappingProvider.campaigns[levelInfo.CampaignID]!),
              verticalSpacer(),
              missionHeader(
                mappingProvider,
                mappingProvider.missions[levelInfo.MissionID]!,
              ),
              verticalSpacer(),
              levelHeader(levelInfo),
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
              instructionRow("Now try to sing the melody out loud...", small:true),
              verticalSpacer(),
              plainText("Listen to the melody for comparison:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, true),
              verticalSpacer(),
              instructionRow("Did you sing it correctly?", small:true),
              verticalSpacer(),
              generateMelodyButton(generalProvider, mappingProvider, false),
              verticalSpacer(),
              plainText("Notes for reference:"),
              verticalSpacer(),
              plainText("Note: Change the key in Mission settings if not in your singing range"),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              buildSelectedChordButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              returnToLevelButton(levelStatus),
              verticalSpacer(),
              takeTestButton(mappingProvider.missions[levelInfo.MissionID]!.MissionMode, levelInfo),
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
    bool setSolfegeText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMap["practiceButtonColor"] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              newGenerateChordMelody(generalProvider, mappingProvider, true);
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget,
              );
              solfegeText = generatedChordMelody.getChordMelody().join(' ');
              // setState(() {
              //   //solfegeText = ""; // Clear solfege area
              //   setToWaitingForGuess();
              // });
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(comparisonColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                colorMap["buttonForegroundColor"] ?? Colors.white,
              ),
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
                    widget,
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
