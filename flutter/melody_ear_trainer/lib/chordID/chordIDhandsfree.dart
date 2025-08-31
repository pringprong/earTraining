import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../audio/audio_controller.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';
import 'dart:math';

class chordIDHandsFree extends StatefulWidget {
  const chordIDHandsFree({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<chordIDHandsFree> createState() => _chordIDHandsFreeState();
}

class _chordIDHandsFreeState extends State<chordIDHandsFree> {
  int currentRound = 0;
  bool notPaused = true;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";
  @override
  Widget build(BuildContext context) {
    final nestedMapping = context.read<MappingProvider>().getNestedMapping;
    return Scaffold(
      appBar: AppBar(title: Text('Hands-free chord ID')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextRow("Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of rounds:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<chordIDSettings>().numberOfRounds,
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
                        context.read<chordIDSettings>().setNumberOfRounds(
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
                    value: context.watch<chordIDSettings>().melodyRepeats,
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
                        context.read<chordIDSettings>().setMelodyRepeats(
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
                    value:
                        context.watch<chordIDSettings>().solfegeRepeats,
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
                        context.read<chordIDSettings>().setSolfegeRepeats(
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
                    value: context.watch<chordIDSettings>().spokenRepeats,
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
                        context.read<chordIDSettings>().setSpokenRepeats(
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
                    value:
                        context
                            .watch<chordIDSettings>()
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
                            .read<chordIDSettings>()
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
                            .watch<chordIDSettings>()
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
                            .read<chordIDSettings>()
                            .setHandsfreeInstrument(instrument: newValue);
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Controls:"),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          solfegeText = "";
                          notPaused = true;
                        });

                        currentRound = 0;
                        chordMelody = ChordMelody();
                        playFunction(
                          context.read<chordIDSettings>(),
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
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
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
              TextRow("Solfege:"),
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
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(solfegeText, style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Current round:"),
              verticalSpacer(),
              Row(
                // Current Round Display
                children: [
                  Text(
                    (min(
                          currentRound + 1,
                          context
                              .read<chordIDSettings>()
                              .getNumberOfRounds,
                        )).toString() +
                        " / " +
                        context
                            .read<chordIDSettings>()
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
    while (currentRound <
            context.read<chordIDSettings>().getNumberOfRounds &&
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
        i < context.read<chordIDSettings>().getMelodyRepeats && notPaused;
        i++
      ) {
        await chordMelody.playChordMelody(
          getInstrument(
            context.read<chordIDSettings>().handsfreeInstrument,
          ),
          generalProvider,
          mappingProvider,
          widget,
        );
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(
            seconds: context.read<chordIDSettings>().getTimeDelayRepeat,
          ),
        );
      }
      solfegeText = chordMelody.getChordMelody().join(' ');
      setState(() {});
      for (
        int j = 0;
        j < context.read<chordIDSettings>().getSolfegeRepeats &&
            notPaused;
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
            seconds: context.read<chordIDSettings>().getTimeDelayRepeat,
          ),
        );
      }
      for (
        int k = 0;
        k < context.read<chordIDSettings>().getSpokenRepeats && notPaused;
        k++
      ) {
        await chordMelody.playSpoken(generalProvider, mappingProvider, widget);
        if (!notPaused) {
          return; // Exit if paused
        }
        await Future.delayed(
          Duration(
            seconds: context.read<chordIDSettings>().getTimeDelayRepeat,
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
