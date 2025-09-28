import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';
import '../utils/chordMelody.dart';

class chordIDSettingsPage extends StatefulWidget {
  const chordIDSettingsPage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<chordIDSettingsPage> createState() => _chordIDSettingsPageState();
}

class _chordIDSettingsPageState extends State<chordIDSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordIDSettings>(context);
    String? selectedRange =
        generalProvider.chordSetRange; // Default range selection
    String? selectedChordSet =
        generalProvider.chordSet; // Default set selection
    return Scaffold(
      appBar: AppBar(title: Text('Chord ID settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              subHeadingRow("Melody settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of notes in melody:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordIDSettings>().numberOfNotes,
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
                        context.read<chordIDSettings>().updateNumberOfNotes(
                          count: newValue,
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
                    child: Text('Allow repeated chords:'),
                  ),
                  Checkbox(
                    value: context.watch<chordIDSettings>().allowRepeatedChords,
                    onChanged: (bool? newValue) {
                      context
                          .read<chordIDSettings>()
                          .toggleAllowRepeatedChords();
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Playback settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Playback key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback key'),
                    value: context.watch<chordIDSettings>().selectedKey,
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
                        context.read<chordIDSettings>().updateSelectedKey(
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
                    value: context.watch<chordIDSettings>().selectedInstrument,
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
                            .read<chordIDSettings>()
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
                    value: context.watch<chordIDSettings>().playbackSpeed,
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
                        context.read<chordIDSettings>().updatePlaybackSpeed(
                          speed: newValue,
                        );
                        if (newValue == "Very fast") {
                          context
                              .read<chordIDSettings>()
                              .updateTimeBetweenNotes(time: 300);
                          context.read<chordIDSettings>().updateTruncateNotes(
                            time: "600",
                          );
                        } else if (newValue == "Fast") {
                          context
                              .read<chordIDSettings>()
                              .updateTimeBetweenNotes(time: 600);
                          context.read<chordIDSettings>().updateTruncateNotes(
                            time: "900",
                          );
                        } else if (newValue == "Normal") {
                          context
                              .read<chordIDSettings>()
                              .updateTimeBetweenNotes(time: 900);
                          context.read<chordIDSettings>().updateTruncateNotes(
                            time: "1200",
                          );
                        } else if (newValue == "Slow") {
                          context
                              .read<chordIDSettings>()
                              .updateTimeBetweenNotes(time: 1200);
                          context.read<chordIDSettings>().updateTruncateNotes(
                            time: "1500",
                          );
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
                    child: Text('Arpeggiate chord delay - Guitar (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<chordIDSettings>()
                            .arpeggiateChordDelayGuitar,
                    items:
                        [
                          0,
                          50,
                          100,
                          200,
                          300,
                          400,
                          500,
                          600,
                        ].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordIDSettings>()
                            .updateArpeggiateChordDelayGuitar(delay: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chord delay - Piano (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<chordIDSettings>()
                            .arpeggiateChordDelayPiano,
                    items:
                        [
                          0,
                          50,
                          100,
                          200,
                          300,
                          400,
                          500,
                          600,
                        ].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordIDSettings>()
                            .updateArpeggiateChordDelayPiano(delay: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chord delay - Solfege (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<chordIDSettings>()
                            .arpeggiateChordDelaySolfege,
                    items:
                        [
                          0,
                          50,
                          100,
                          200,
                          300,
                          400,
                          500,
                          600,
                        ].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordIDSettings>()
                            .updateArpeggiateChordDelaySolfege(delay: newValue);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chord delay - Spoken (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context
                            .watch<chordIDSettings>()
                            .arpeggiateChordDelaySpoken,
                    items:
                        [
                          0,
                          50,
                          100,
                          200,
                          300,
                          400,
                          500,
                          600,
                        ].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context
                            .read<chordIDSettings>()
                            .updateArpeggiateChordDelaySpoken(delay: newValue);
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
                        context.watch<chordIDSettings>().arpeggiateChordOrder,
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
                            .read<chordIDSettings>()
                            .updateArpeggiateChordOrder(order: newValue);
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Tonic:"),
              verticalSpacer(),
              plainText(
                "Note: Make sure these are selected in the chords below",
              ),
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
                    value: context.watch<chordIDSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<chordIDSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordIDSettings>().startingDo,
                    items:
                        [
                          "I0_Rt",
                          "I_Rt",
                          "I1_Rt",
                          "i0_Rt",
                          "i_Rt",
                          "i1_Rt",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordIDSettings>().updateStartingDo(
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
                    value: context.watch<chordIDSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<chordIDSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordIDSettings>().endingDo,
                    items:
                        [
                          "I0_Rt",
                          "I_Rt",
                          "I1_Rt",
                          "i0_Rt",
                          "i_Rt",
                          "i1_Rt",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordIDSettings>().updateEndingDo(
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
                        backgroundColor: colorMap["c3f3"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordIDSettings>()
                                  .selectedKey]!['Guitar']![context
                                  .read<chordIDSettings>()
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
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordIDSettings>()
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
                        backgroundColor: colorMap["c5f2"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordIDSettings>()
                                  .selectedKey]!['Piano']![context
                                  .read<chordIDSettings>()
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
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordIDSettings>()
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
                        backgroundColor: colorMap["c1f3"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () async {
                        // startingDo is a note
                        if (mappingProvider.getNoteKeys.contains(
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          String filename =
                              mappingProvider.getNestedMapping[context
                                  .read<chordIDSettings>()
                                  .selectedKey]!['Solfege']![context
                                  .read<chordIDSettings>()
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
                          context.read<chordIDSettings>().startingDo,
                        )) {
                          ChordMelody cm = ChordMelody.singleChord(
                            context.read<chordIDSettings>().startingDo,
                            mappingProvider.getChordMap[context
                                    .read<chordIDSettings>()
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
              subHeadingRow("Chord settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Range:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordIDSettings>().chordSetRange,
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
                        context.read<chordIDSettings>().updateChordRange(
                          newChordRange: selectedRange ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context.read<chordIDSettings>().setSelectedChords(
                            chords,
                          );
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
                    value: context.watch<chordIDSettings>().chordSet,
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
                        context.read<chordIDSettings>().updateChordSet(
                          newChordSet: selectedChordSet ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context.read<chordIDSettings>().setSelectedChords(
                            chords,
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Select chords to include in melody:"),
              verticalSpacer(),
              plainText("Long press to see the solfege"),
              verticalSpacer(),
              plainText(
                "Note: Make sure to include starting and ending chords if selected above",
              ),
              verticalSpacer(),
              buildChordButtons(mappingProvider, generalProvider),
              subHeadingRow("Reset:"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMap["c1f3"] ?? Colors.white,
                        foregroundColor: colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () {
                        context.read<chordIDSettings>().resetAllSettings();
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
