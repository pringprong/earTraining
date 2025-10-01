import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import '../utils/chordMelody.dart';
import 'dart:math';

class chordSingingHandsFree extends StatefulWidget {
  const chordSingingHandsFree({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<chordSingingHandsFree> createState() => _chordSingingHandsFreeState();
}

class _chordSingingHandsFreeState extends State<chordSingingHandsFree> {
  int currentRound = 0;
  bool notPaused = true;
  bool running = false;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";
  @override
  Widget build(BuildContext context) {
    final nestedMapping = context.read<MappingProvider>().getNestedMapping;
    return Scaffold(
      appBar: AppBar(title: Text('Hands-free chord singing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              subHeadingRow("Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of rounds:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordSingingSettings>().numberOfRounds,
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
                        context.read<chordSingingSettings>().setNumberOfRounds(
                          rounds: newValue,
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
                    child: Text('Spoken plus first note repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordSingingSettings>().spokenRepeats,
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
                        context.read<chordSingingSettings>().setSpokenRepeats(
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
                    value: context.watch<chordSingingSettings>().solfegeRepeats,
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
                        context.read<chordSingingSettings>().setSolfegeRepeats(
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
                    child: Text('Instrument repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordSingingSettings>().melodyRepeats,
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
                        context.read<chordSingingSettings>().setMelodyRepeats(
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
                            .watch<chordSingingSettings>()
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
                        context.read<chordSingingSettings>().setTimeDelayRepeat(
                          delay: newValue,
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
                    child: Text('Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select instrument'),
                    value:
                        context
                            .watch<chordSingingSettings>()
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
                            .read<chordSingingSettings>()
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
                        if (!running) {
                          setState(() {
                            solfegeText = "";
                            notPaused = true;
                          });
                          running = true;
                          currentRound = 0;
                          chordMelody = ChordMelody();
                          playFunction(
                            context.read<chordSingingSettings>(),
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
                              .read<chordSingingSettings>()
                              .getNumberOfRounds,
                        )).toString() +
                        " / " +
                        context
                            .read<chordSingingSettings>()
                            .getNumberOfRounds
                            .toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
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
    while (currentRound < generalProvider.getNumberOfRounds && notPaused) {
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
      for (int n = 0; n < generalProvider.getSpokenRepeats && notPaused; n++) {
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
          Duration(seconds: generalProvider.getTimeDelayRepeat),
        );
      }
      for (int j = 0; j < generalProvider.getSolfegeRepeats && notPaused; j++) {
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
          Duration(seconds: generalProvider.getTimeDelayRepeat),
        );
      }
      for (int i = 0; i < generalProvider.getMelodyRepeats && notPaused; i++) {
        await chordMelody.playChordMelody(
          getInstrument(generalProvider.handsfreeInstrument),
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(seconds: generalProvider.getTimeDelayRepeat),
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
}
