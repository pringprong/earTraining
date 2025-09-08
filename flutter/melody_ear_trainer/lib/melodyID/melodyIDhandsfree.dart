import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';
import 'dart:math';

class MelodyIDHandsFree extends StatefulWidget {
  const MelodyIDHandsFree({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<MelodyIDHandsFree> createState() => _MelodyIDHandsFreeState();
}

class _MelodyIDHandsFreeState extends State<MelodyIDHandsFree> {
  int currentRound = 0;
  bool notPaused = true;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";
  @override
  Widget build(BuildContext context) {
    final nestedMapping = context.read<MappingProvider>().getNestedMapping;
    return Scaffold(
      appBar: AppBar(title: Text('Hands-free melody ID')),
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
                    value: context.watch<MelodyIDSettings>().numberOfRounds,
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
                        context.read<MelodyIDSettings>().setNumberOfRounds(
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
                    child: Text('Instrument repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().melodyRepeats,
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
                        context.read<MelodyIDSettings>().setMelodyRepeats(
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
                    child: Text('Solfege repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().solfegeRepeats,
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
                        context.read<MelodyIDSettings>().setSolfegeRepeats(
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
                    child: Text('Spoken repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().spokenRepeats,
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
                        context.read<MelodyIDSettings>().setSpokenRepeats(
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
                    child: Text('Time between repeats (s):'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().getTimeDelayRepeat,
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
                        context.read<MelodyIDSettings>().setTimeDelayRepeat(
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
                    hint: Text('Select Instrument'),
                    value:
                        context.watch<MelodyIDSettings>().handsfreeInstrument,
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
                        context.read<MelodyIDSettings>().setHandsfreeInstrument(
                          instrument: newValue,
                        );
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
                        backgroundColor: c3f3,
                        foregroundColor: buttonForegroundColor,
                      ),
                      onPressed: () {
                        setState(() {
                          solfegeText = "";
                          notPaused = true;
                        });

                        currentRound = 0;
                        chordMelody = ChordMelody();
                        //playFunction(MelodyIDSettings, nestedMapping);
                        playFunction(
                          context.read<MelodyIDSettings>(),
                          context.read<MappingProvider>(),
                          nestedMapping,
                        );
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
                        backgroundColor: c5f2,
                        foregroundColor: buttonForegroundColor,
                      ),
                      onPressed: () {
                        setState(() {
                          notPaused = false;
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
                      border: Border.all(color: borderColor),
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
                          context.read<MelodyIDSettings>().getNumberOfRounds,
                        )).toString() +
                        " / " +
                        context
                            .read<MelodyIDSettings>()
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
    while (currentRound < context.read<MelodyIDSettings>().getNumberOfRounds &&
        notPaused) {
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
      for (
        int i = 0;
        i < context.read<MelodyIDSettings>().getMelodyRepeats && notPaused;
        i++
      ) {
        await chordMelody.playChordMelody(
          getInstrument(context.read<MelodyIDSettings>().handsfreeInstrument),
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(
            seconds: context.read<MelodyIDSettings>().getTimeDelayRepeat,
          ),
        );
      }
      solfegeText = chordMelody.getChordMelody().join(' ');
      setState(() {});
      for (
        int j = 0;
        j < context.read<MelodyIDSettings>().getSolfegeRepeats && notPaused;
        j++
      ) {
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
          Duration(
            seconds: context.read<MelodyIDSettings>().getTimeDelayRepeat,
          ),
        );
      }
      for (
        int k = 0;
        k < context.read<MelodyIDSettings>().getSpokenRepeats && notPaused;
        k++
      ) {
        await chordMelody.playSpoken(generalProvider, mappingProvider, widget);
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(
            seconds: context.read<MelodyIDSettings>().getTimeDelayRepeat,
          ),
        );
      }
      if (!notPaused) {
        return; // Exit if paused
      }
      currentRound++;
      setState(() {});
    }
  }
}
