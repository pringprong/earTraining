import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';
import 'dart:math';
import '../utils/helper.dart';

class LevelMelodySingingHandsFree extends StatefulWidget {
  const LevelMelodySingingHandsFree({super.key, required this.audioController});
  final AudioController audioController;
  static const String routeName = '/levelmelodysinginghandsfree';

  @override
  State<LevelMelodySingingHandsFree> createState() =>
      _LevelMelodySingingHandsFreeState();
}

class _LevelMelodySingingHandsFreeState
    extends State<LevelMelodySingingHandsFree> {
  int currentRound = 0;
  bool notPaused = true;
  bool running = false;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";

  @override
  Widget build(BuildContext context) {
    final levelInfo = ModalRoute.of(context)!.settings.arguments as LevelInfo;
    final mappingProvider = Provider.of<MappingProvider>(context);
    final nestedMapping = mappingProvider.getNestedMapping;
    String levelStatus = getLevelStatusWithQuery(levelInfo);

    return Scaffold(
      appBar: AppBar(title: Text('Hands-free singing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              subHeadingRow("Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of rounds:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<missionSingingSettings>().numberOfRounds,
                    items:
                        [5, 10, 15, 20, 25].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<missionSingingSettings>()
                            .setNumberOfRounds(rounds: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Spoken plus first note repeats:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<missionSingingSettings>().spokenRepeats,
                    items:
                        [0, 1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<missionSingingSettings>().setSpokenRepeats(
                          repeats: newValue,
                        );
                      }
                    },
                    //               },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Solfege repeats:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<missionSingingSettings>().solfegeRepeats,
                    items:
                        [0, 1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<missionSingingSettings>()
                            .setSolfegeRepeats(repeats: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Instrument repeats:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<missionSingingSettings>().melodyRepeats,
                    items:
                        [0, 1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<missionSingingSettings>().setMelodyRepeats(
                          repeats: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Time between repeats (s):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<missionSingingSettings>()
                            .getTimeDelayRepeat,
                    items:
                        [1, 2, 3, 4, 5, 6, 7, 8].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<missionSingingSettings>()
                            .setTimeDelayRepeat(delay: newValue);
                      }
                    },
                    //               },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select instrument'),
                    value:
                        context
                            .watch<missionSingingSettings>()
                            .handsfreeInstrument,
                    items:
                        [
                          "Guitar",
                          "Piano",
                          "Alternate",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<missionSingingSettings>()
                            .setHandsfreeInstrument(instrument: newValue);
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Controls:"),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMap["c3f3"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () {
                        print("start singing");
                        if (!running) {
                          setState(() {
                            solfegeText = "";
                            notPaused = true;
                          });
                          running = true;
                          currentRound = 0;
                          chordMelody = ChordMelody();
                          playFunction(
                            context.read<missionSettingsProvider>(),
                            context.read<missionSingingSettings>(),
                            context.read<MappingProvider>(),
                            nestedMapping,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text('Start', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMap["c5f2"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          notPaused = false;
                          running = false;
                          solfegeText = "";
                          currentRound = 0;
                          widget.audioController.refresh();
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text('Stop', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Solfege:"),
              verticalSpacer(),
              Row(
                // Solfege Text Area
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorMap["borderColor"] ?? Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(solfegeText, style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Current round:"),
              verticalSpacer(),
              Row(
                // Current Round Display
                children: [
                  Text(
                    (min(
                          currentRound + 1,
                          context
                              .read<missionSingingSettings>()
                              .getNumberOfRounds,
                        )).toString() +
                        " / " +
                        context
                            .read<missionSingingSettings>()
                            .getNumberOfRounds
                            .toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              verticalSpacer(),
              returnToLevelButton(levelStatus),
            ], // Children of Column
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    notPaused = false;
    running = false;
    widget.audioController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  String getInstrument(String userChoice) {
    if (userChoice == "Alternate") {
      if (currentInstrument == "Guitar") {
        currentInstrument = "Piano"; // Alternate to Piano
        return "Piano"; // Alternate to Piano
      } else if (currentInstrument == "Piano") {
        currentInstrument = "Guitar"; // Alternate to Guitar
        return "Guitar"; // Alternate to Guitar
      }
    } else if (userChoice.isNotEmpty) {
      return userChoice;
    }
    return "Guitar"; // Default to Guitar if no valid choice
  }

  playFunction(
    GeneralProvider generalProvider,
    // generalProvider is for the melody settings
    GeneralProvider missionSingingSettings,
    // missionSingingSettings is only used for the handsfree settings
    // number of {rounds, spoken, solfege, instrument}, timebetween, and getInstrument
    MappingProvider mappingProvider,
    Map<String, Map<String, Map<String, String>>> nestedMapping,
  ) async {
    // while currentRound < numberOfRounds and notPaused = true
    // carry out the following steps:
    // generate a melody
    // for i in numberOfMelodyRepeats play the melody using the selected Instrument
    // wait for timeDelayRepeat seconds in between playing the melody
    // for j in numberOfSolfegeRepeats play the melody using solfege
    // wait for timeDelayRepeat seconds in between playing the melody
    // wait for timeDelay seconds before starting the next round
    // increment currentRound by 1
    // keep checking if paused is true, if so, exit the function
    while (currentRound < missionSingingSettings.getNumberOfRounds && notPaused) {
      solfegeText = "";
      setState(() {});
      String result = chordMelody.generateChordMelody(
        generalProvider,
        mappingProvider,
      );
      if (result.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
        return;
      }
      solfegeText = chordMelody.getChordMelody().join(' ');
      setState(() {});
      for (int n = 0; n < missionSingingSettings.getSpokenRepeats && notPaused; n++) {
        print("playing the spoken");
        await chordMelody.playSpoken(generalProvider, mappingProvider, widget);
        await Future.delayed(Duration(seconds: 1));
        ChordMelody firstNote = ChordMelody.singleChord(
          chordMelody.getFirstNoteOrChord_Melody(),
          chordMelody.getFirstNoteOrChord_Solfege(),
        );
        await firstNote.playChordMelody(
          "Solfege",
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(seconds: missionSingingSettings.getTimeDelayRepeat),
        );
      }
      for (int j = 0; j < missionSingingSettings.getSolfegeRepeats && notPaused; j++) {
        await chordMelody.playChordMelody(
          "Solfege",
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(seconds: missionSingingSettings.getTimeDelayRepeat),
        );
      }
      for (int i = 0; i < missionSingingSettings.getMelodyRepeats && notPaused; i++) {
        await chordMelody.playChordMelody(
          getInstrument(missionSingingSettings.handsfreeInstrument),
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(seconds: missionSingingSettings.getTimeDelayRepeat),
        );
      }
      if (!notPaused) {
        return; // Exit if paused
      }
      currentRound++;
      setState(() {});
    }
    running = false;
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
                  colorMap["noteButtonForegroundColor"] ?? Colors.white,
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
