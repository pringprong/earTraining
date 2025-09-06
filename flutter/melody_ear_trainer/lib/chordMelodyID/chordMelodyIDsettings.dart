import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import '../utils/chordMelody.dart';

class chordMelodyIDSettingsPage extends StatefulWidget {
  const chordMelodyIDSettingsPage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<chordMelodyIDSettingsPage> createState() =>
      _chordMelodyIDSettingsPageState();
}

class _chordMelodyIDSettingsPageState extends State<chordMelodyIDSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordMelodyIDSettings>(context);
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    String? selectedRange =
        generalProvider.chordSetRange; // Default range selection
    String? selectedChordSet =
        generalProvider.chordSet; // Default set selection
    return Scaffold(
      appBar: AppBar(title: Text('Chord melody ID settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextRow("Melody notes:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Octave:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<chordMelodyIDSettings>().selectedOctave,
                    hint: Text('Select octave'),
                    items:
                        mappingProvider.getOctaveKeys
                            .map(
                              (octave) => DropdownMenuItem(
                                value: octave,
                                child: Text(octave),
                              ),
                            )
                            .toList(),
                    onChanged: (octave) {
                      setState(() {
                        selectedOctave = octave;
                        context
                            .read<chordMelodyIDSettings>()
                            .updateSelectedOctave(octave: selectedOctave ?? '');
                        if (selectedOctave != null && selectedScale != null) {
                          final notes =
                              mappingProvider
                                  .getScalesMapping[selectedOctave!]![selectedScale!] ??
                              [];
                          generalProvider.setNoteSelection(selectedKeys: notes);
                        }
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Scale:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().selectedScale,
                    hint: Text('Select scale'),
                    items:
                        mappingProvider.getScaleKeys
                            .map(
                              (scale) => DropdownMenuItem(
                                value: scale,
                                child: Text(scale),
                              ),
                            )
                            .toList(),
                    onChanged: (scale) {
                      setState(() {
                        selectedScale = scale;
                        context
                            .read<chordMelodyIDSettings>()
                            .updateSelectedScale(newscale: selectedScale ?? '');
                        if (selectedOctave != null && selectedScale != null) {
                          final notes =
                              mappingProvider
                                  .getScalesMapping[selectedOctave!]![selectedScale!] ??
                              [];
                          generalProvider.setNoteSelection(selectedKeys: notes);
                        }
                      });
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: buildNotesGrid(
                      context.read<chordMelodyIDSettings>(),
                      context.read<MappingProvider>(),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Melody settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of notes in melody:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordMelodyIDSettings>().numberOfNotes,
                    items:
                        List.generate(
                          18,
                          (i) => i + 1,
                        ).map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updateNumberOfNotes(count: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Max distance between adjacent notes:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordMelodyIDSettings>().maxDistance,
                    items:
                        List.generate(
                          9,
                          (i) => i + 1,
                        ).map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodyIDSettings>().updateMaxDistance(
                          distance: newValue,
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
                    child: Text('Allow repeated notes:'),
                  ),
                  Checkbox(
                    value:
                        context
                            .watch<chordMelodyIDSettings>()
                            .allowRepeatedNotes,
                    onChanged: (bool? newValue) {
                      context
                          .read<chordMelodyIDSettings>()
                          .toggleAllowRepeatedNotes();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Chord frequency:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<chordMelodyIDSettings>().chordFrequency,
                    items:
                        [
                          "Never",
                          "Every 4 notes",
                          "Every 3 notes",
                          "Every 2 notes",
                          "Every note",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updateChordFrequency(frequency: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Allow repeated chords:'),
                  ),
                  Checkbox(
                    value:
                        context
                            .watch<chordMelodyIDSettings>()
                            .allowRepeatedChords,
                    onChanged: (bool? newValue) {
                      context
                          .read<chordMelodyIDSettings>()
                          .toggleAllowRepeatedChords();
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Playback settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Playback key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback key'),
                    value: context.watch<chordMelodyIDSettings>().selectedKey,
                    items:
                        mappingProvider.getMappingKeys
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodyIDSettings>().updateSelectedKey(
                          newkey: newValue,
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
                    child: Text('Playback instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback instrument'),
                    value:
                        context
                            .watch<chordMelodyIDSettings>()
                            .selectedInstrument,
                    items:
                        mappingProvider.getInstruments
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updateSelectedInstrument(instrument: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Playback speed:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().playbackSpeed,
                    items:
                        [
                          "Very fast",
                          "Fast",
                          "Normal",
                          "Slow",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updatePlaybackSpeed(speed: newValue);
                        if (newValue == "Very fast") {
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 300);
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTruncateNotes(time: "600");
                        } else if (newValue == "Fast") {
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 600);
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTruncateNotes(time: "900");
                        } else if (newValue == "Normal") {
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 900);
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTruncateNotes(time: "1200");
                        } else if (newValue == "Slow") {
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 1200);
                          context
                              .read<chordMelodyIDSettings>()
                              .updateTruncateNotes(time: "1500");
                        }
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chord delay (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<chordMelodyIDSettings>()
                            .arpeggiateChordDelay,
                    items:
                        [
                          0,
                          50,
                          100,
                          200,
                          300,
                          400,
                          500,
                        ].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updateArpeggiateChordDelay(delay: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiation order:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context
                            .watch<chordMelodyIDSettings>()
                            .arpeggiateChordOrder,
                    items:
                        [
                          "Ascending",
                          "Descending",
                          "Random",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordMelodyIDSettings>()
                            .updateArpeggiateChordOrder(order: newValue);
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Tonic:"),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Starting note (tonic): always start with'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<chordMelodyIDSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<chordMelodyIDSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().startingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                          "I_M_R",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodyIDSettings>().updateStartingDo(
                          newStartingDo: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Ending note: always end with'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<chordMelodyIDSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<chordMelodyIDSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().endingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                          "I_M_R",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodyIDSettings>().updateEndingDo(
                          newEndingDo: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c3f3,
                        foregroundColor: buttonForegroundColor,
                      ),
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordMelodyIDSettings>()
                                  .selectedKey]!['Guitar']![context
                                  .read<chordMelodyIDSettings>()
                                  .startingDo] ??
                              '';
                          filename = "assets/audio/$filename";
                          if (filename.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No tonic found')),
                            );
                            return;
                          }
                          await widget.audioController.refresh();
                          widget.audioController.playSound(filename);
                        }
                        // startingDo is a chord
                        else if (mappingProvider.getChordMap.keys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordMelodyIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordMelodyIDSettings>()
                                    .startingDo] ??
                                [],
                          );
                          cm.playChordMelody(
                            "Guitar",
                            generalProvider,
                            mappingProvider,
                            widget,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play guitar tonic',
                          style: TextStyle(fontSize: 20),
                        ),
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
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordMelodyIDSettings>()
                                  .selectedKey]!['Piano']![context
                                  .read<chordMelodyIDSettings>()
                                  .startingDo] ??
                              '';
                          filename = "assets/audio/$filename";
                          if (filename.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No tonic found')),
                            );
                            return;
                          }
                          await widget.audioController.refresh();
                          widget.audioController.playSound(filename);
                        }
                        // startingDo is a chord
                        else if (mappingProvider.getChordMap.keys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordMelodyIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordMelodyIDSettings>()
                                    .startingDo] ??
                                [],
                          );
                          cm.playChordMelody(
                            "Piano",
                            generalProvider,
                            mappingProvider,
                            widget,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play piano tonic',
                          style: TextStyle(fontSize: 20),
                        ),
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
                        backgroundColor: c1f3,
                        foregroundColor: buttonForegroundColor,
                      ),
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordMelodyIDSettings>()
                                  .selectedKey]!['Solfege']![context
                                  .read<chordMelodyIDSettings>()
                                  .startingDo] ??
                              '';
                          filename = "assets/audio/$filename";
                          if (filename.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No tonic found')),
                            );
                            return;
                          }
                          await widget.audioController.refresh();
                          widget.audioController.playSound(filename);
                        }
                        // startingDo is a chord
                        else if (mappingProvider.getChordMap.keys.contains(
                          context.read<chordMelodyIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordMelodyIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordMelodyIDSettings>()
                                    .startingDo] ??
                                [],
                          );
                          cm.playChordMelody(
                            "Solfege",
                            generalProvider,
                            mappingProvider,
                            widget,
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play solfege tonic',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Chord settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Range:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().chordSetRange,
                    hint: Text('Select range'),
                    items:
                        mappingProvider.getRangesList
                            .map(
                              (range) => DropdownMenuItem(
                                value: range,
                                child: Text(range),
                              ),
                            )
                            .toList(),
                    onChanged: (range) {
                      setState(() {
                        selectedRange = range;
                        context.read<chordMelodyIDSettings>().updateChordRange(
                          newChordRange: selectedRange ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context
                              .read<chordMelodyIDSettings>()
                              .setSelectedChords(chords);
                        }
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Set:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodyIDSettings>().chordSet,
                    hint: Text('Select set'),
                    items:
                        mappingProvider.getChordSetsList
                            .map(
                              (set) => DropdownMenuItem(
                                value: set,
                                child: Text(set),
                              ),
                            )
                            .toList(),
                    onChanged: (set) {
                      setState(() {
                        selectedChordSet = set;
                        context.read<chordMelodyIDSettings>().updateChordSet(
                          newChordSet: selectedChordSet ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context
                              .read<chordMelodyIDSettings>()
                              .setSelectedChords(chords);
                        }
                      });
                    },
                  ),
                ],
              ),
              buildChordButtons(mappingProvider, generalProvider),
              TextRow("Reset:"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c1f3,
                        foregroundColor: buttonForegroundColor,
                      ),
                      onPressed: () {
                        context
                            .read<chordMelodyIDSettings>()
                            .resetAllSettings();
                        context.read<ThemeProvider>().resetAllSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('All settings reset to default!'),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Reset all settings",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ], // Children of Column
          ),
        ),
      ),
    );
  }
}
