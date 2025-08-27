import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import 'audio/audio_controller.dart';
import 'utils/colors.dart';
import 'utils/chordMelody.dart';
import 'dart:math';

class HandsFreeSinging extends StatefulWidget {
  const HandsFreeSinging({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<HandsFreeSinging> createState() => _HandsFreeSingingState();
}

class _HandsFreeSingingState extends State<HandsFreeSinging> {
  int currentRound = 0;
  bool notPaused = true;
  String solfegeText = "";
  ChordMelody chordMelody = ChordMelody();
  String currentInstrument = "Piano";
  @override
  Widget build(BuildContext context) {
    // Get the nestedMapping from the provider (auto-updates on notifyListeners)
    final nestedMapping = context.watch<MappingProvider>().getNestedMapping;
    return Scaffold(
      appBar: AppBar(title: Text('Hands-free singing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of rounds:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<MelodySingingSettings>().numberOfRounds,
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
                        context.read<MelodySingingSettings>().setNumberOfRounds(
                          rounds: newValue,
                        );
                      }
                    },
                    //               },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Spoken plus first note repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodySingingSettings>().spokenRepeats,
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
                        context.read<MelodySingingSettings>().setSpokenRepeats(
                          repeats: newValue,
                        );
                      }
                    },
                    //               },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Solfege repeats:'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<MelodySingingSettings>().solfegeRepeats,
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
                        context.read<MelodySingingSettings>().setSolfegeRepeats(
                          repeats: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Instrument repeats:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodySingingSettings>().melodyRepeats,
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
                        context.read<MelodySingingSettings>().setMelodyRepeats(
                          repeats: newValue,
                        );
                      }
                    },
                    //               },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Time between repeats (s):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<MelodySingingSettings>()
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
                            .read<MelodySingingSettings>()
                            .setTimeDelayRepeat(delay: newValue);
                      }
                    },
                    //               },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Instrument'),
                    value:
                        context
                            .watch<MelodySingingSettings>()
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
                            .read<MelodySingingSettings>()
                            .setHandsfreeInstrument(instrument: newValue);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
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
              // Play Piano Tonic Button
              SizedBox(height: 8),
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
              SizedBox(height: 8),
              // Row(
              //   children: [
              //     Expanded(
              //       child: ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: getChordButtonColor("blah_M_R"),
              //           foregroundColor: Colors.black,
              //         ),
              //         onPressed: () {
              //           //resumeFunction(
              //           //  context.read<MelodySingingSettings>(),
              //           //  nestedMapping,
              //           //);
              //         },
              //         child: FittedBox(
              //           fit: BoxFit.fill,
              //           child: Text('Resume', style: TextStyle(fontSize: 20)),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 8),
              Row(
                // Solfege Text Area
                children: [Text("Solfege:", style: TextStyle(fontSize: 18))],
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 8),
              Row(
                // Solfege Text Area
                children: [
                  Text("Current round: ", style: TextStyle(fontSize: 18)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                // Current Round Display
                children: [
                  Text(
                    (min(
                          currentRound + 1,
                          context
                              .read<MelodySingingSettings>()
                              .getNumberOfRounds,
                        )).toString() +
                        " / " +
                        context
                            .read<MelodySingingSettings>()
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
            context.read<MelodySingingSettings>().getNumberOfRounds &&
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
      solfegeText = chordMelody.getChordMelody().join(' ');
      setState(() {});
      for (
        int n = 0;
        n < context.read<MelodySingingSettings>().getSpokenRepeats && notPaused;
        n++
      ) {
        // await playSpoken(generalProvider,
        //     mappingProvider,
        // chordMelody.getChordMelodySolfege());
        await chordMelody.playSpoken(generalProvider, mappingProvider, widget);
        await Future.delayed(Duration(seconds: 1));
        // await playChordMelody(
        //   "Solfege",
        //   generalProvider,
        //   mappingProvider,
        //   chordMelody.getFirstNoteOrChord(),
        // );
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
          Duration(
            seconds: context.read<MelodySingingSettings>().getTimeDelayRepeat,
          ),
        );
      }
      for (
        int j = 0;
        j < context.read<MelodySingingSettings>().getSolfegeRepeats &&
            notPaused;
        j++
      ) {
        // await playChordMelody(
        //   "Solfege",
        //   generalProvider,
        //   mappingProvider,
        //   chordMelody.getChordMelodySolfege(),
        // );
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
            seconds: context.read<MelodySingingSettings>().getTimeDelayRepeat,
          ),
        );
      }
      for (
        int i = 0;
        i < context.read<MelodySingingSettings>().getMelodyRepeats && notPaused;
        i++
      ) {
        // await playChordMelody(
        //   getInstrument(context.read<MelodySingingSettings>().handsfreeInstrument),
        //   generalProvider,
        //   mappingProvider,
        //   chordMelody.getChordMelodySolfege(),
        // );
        await chordMelody.playChordMelody(
          getInstrument(
            context.read<MelodySingingSettings>().handsfreeInstrument,
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
            seconds: context.read<MelodySingingSettings>().getTimeDelayRepeat,
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

  // Future<void> playSpoken(
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   List<List<String>> melodyList,
  // ) async {
  //   await widget.audioController.refresh();
  //   final timeBetween = generalProvider.timeBetweenNotes;
  //   final arpeggiate = generalProvider.arpeggiateChordDelay > 0;
  //   final arpeggiateDelay = generalProvider.arpeggiateChordDelay;
  //   final spokenMapping = mappingProvider.getSpokenMapping;
  //   int i = 0;
  //   for (var notes in melodyList) {
  //     if (!notPaused) {
  //       return; // Exit if paused
  //     }
  //     if (notes.length == 1) {
  //       final note = notes[0];
  //       final filename = spokenMapping[note] ?? '';
  //       if (filename.isNotEmpty) {
  //         widget.audioController.playSound("assets/audio/$filename");
  //       }
  //     } else if (notes.length > 1) {
  //       if (i % 7 == 0) {
  //         await widget.audioController.refresh();
  //       }
  //       List<String> chordNotes = List<String>.from(notes);
  //       for (var note in chordNotes) {
  //         if (!notPaused) {
  //           return; // Exit if paused
  //         }
  //         final filename = spokenMapping[note] ?? '';
  //         if (filename.isNotEmpty) {
  //           widget.audioController.playSound("assets/audio/$filename");
  //         }
  //         if (arpeggiate) {
  //           await Future.delayed(Duration(milliseconds: arpeggiateDelay));
  //         }
  //       }
  //     }
  //     await Future.delayed(Duration(milliseconds: timeBetween));
  //     i++;
  //   }
  // }

  // Future<void> playChordMelody(
  //   String instrument,
  //   GeneralProvider generalProvider,
  //   MappingProvider mappingProvider,
  //   List<List<String>> chordMelodySolfege,
  // ) async {
  //   await widget.audioController.refresh();
  //   final key = generalProvider.selectedKey;
  //   final timeBetween = generalProvider.timeBetweenNotes;
  //   final truncate = generalProvider.truncateNotes;
  //   final arpeggiate = generalProvider.arpeggiateChordDelay > 0;
  //   final arpeggiateDelay = generalProvider.arpeggiateChordDelay;
  //   final arpeggiateOrder = generalProvider.arpeggiateChordOrder;
  //   final nestedMapping = mappingProvider.getNestedMapping;
  //   int i = 0;
  //   for (var notes in chordMelodySolfege) {
  //     if (!notPaused) {
  //       return; // Exit if paused
  //     }
  //     if (notes.length == 1) {
  //       final note = notes[0];
  //       final filename = nestedMapping[key]?[instrument]?[note] ?? '';
  //       if (filename.isNotEmpty) {
  //         if (truncate == "None" || truncate == "Never") {
  //           widget.audioController.playSound("assets/audio/$filename");
  //         } else {
  //           widget.audioController.playSoundFade(
  //             "assets/audio/$filename",
  //             int.parse(truncate),
  //             500,
  //           );
  //         }
  //       }
  //     } else if (notes.length > 1) {
  //       if (i % 7 == 0) {
  //         await widget.audioController.refresh();
  //       }
  //       List<String> chordNotes = List<String>.from(notes);
  //       if (arpeggiateOrder == "Descending") {
  //         chordNotes = chordNotes.reversed.toList();
  //       } else if (arpeggiateOrder == "Random") {
  //         chordNotes.shuffle();
  //       }
  //       for (var note in chordNotes) {
  //         if (!notPaused) {
  //           return; // Exit if paused
  //         }
  //         final filename = nestedMapping[key]?[instrument]?[note] ?? '';
  //         if (filename.isNotEmpty) {
  //           if (truncate == "None" || truncate == "Never") {
  //             widget.audioController.playSound("assets/audio/$filename");
  //           } else {
  //             widget.audioController.playSoundFade(
  //               "assets/audio/$filename",
  //               int.parse(truncate),
  //               500,
  //             );
  //           }
  //         }
  //         if (arpeggiate) {
  //           await Future.delayed(Duration(milliseconds: arpeggiateDelay));
  //         }
  //       }
  //     }
  //     await Future.delayed(Duration(milliseconds: timeBetween));
  //     i++;
  //   }
  // }
}
