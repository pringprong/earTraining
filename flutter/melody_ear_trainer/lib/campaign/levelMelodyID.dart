import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../melodyPageAbstract.dart';
import '../utils/helper.dart';
import '../utils/colors.dart';

class LevelMelodyID extends MelodyPageAbstract {
  const LevelMelodyID({super.key, required super.audioController}) : super();

  static const String routeName = '/levelmelodyid';
  @override
  LevelMelodyIDState createState() => LevelMelodyIDState();
}

class LevelMelodyIDState extends MelodyPageAbstractState {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MappingProvider mappingProvider = Provider.of<MappingProvider>(context);
    GeneralProvider generalProvider = Provider.of<missionSettingsProvider>(
      context,
    );
    newGenerateChordMelody(generalProvider, mappingProvider, false);
    generatedChordMelody.playChordMelody(
      generalProvider.getSelectedInstrument,
      generalProvider,
      mappingProvider,
      widget,
    );
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
              plainText("Listen to generated melody again:"),
              verticalSpacer(),
              playMelodyButtons(generalProvider, mappingProvider, false),
              verticalSpacer(),
              plainText("Play the melody back (" +
                    levelInfo.NumNotes.toString() +
                    " notes):"),
              verticalSpacer(),
              buildNoteButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              userWrittenSolfegeArea(),
              verticalSpacer(),
              clearAndBackspaceButtons(),
              verticalSpacer(),
              compareButton2(generalProvider, mappingProvider),
              verticalSpacer(),
              generateMelodyButton(generalProvider, mappingProvider, false),
              verticalSpacer(),
              plainText("Listen to your melody:"),
              verticalSpacer(),
              userWrittenMelodyButtons(generalProvider, mappingProvider),
              verticalSpacer(),
              solfegeExpansionTile(generalProvider, mappingProvider),
              verticalSpacer(),
              returnToLevelButton(levelStatus)
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
              backgroundColor: colorMap["c2f3"] ?? Colors.white,
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              newGenerateChordMelody(
                generalProvider,
                mappingProvider,
                setSolfegeText,
              );
              generatedChordMelody.playChordMelody(
                generalProvider.getSelectedInstrument,
                generalProvider,
                mappingProvider,
                widget,
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

  Widget returnToLevelButton(String levelStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: missionLevelStatusColor(levelStatus),
              foregroundColor:
                  colorMap["buttonForegroundColor"] ?? Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.pop(context); // pop to level page
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Return to level main page",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
