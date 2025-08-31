import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';

class chordMelodySingingSettingsPage extends StatefulWidget {
  const chordMelodySingingSettingsPage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<chordMelodySingingSettingsPage> createState() =>
      _chordMelodySingingSettingsPageState();
}

class _chordMelodySingingSettingsPageState extends State<chordMelodySingingSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<chordMelodySingingSettings>(context);
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
              TextRow("Melody Notes:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Octave:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<chordMelodySingingSettings>().selectedOctave,
                    hint: Text('Select Octave'),
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
                            .read<chordMelodySingingSettings>()
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
                    value: context.watch<chordMelodySingingSettings>().selectedScale,
                    hint: Text('Select Scale'),
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
                            .read<chordMelodySingingSettings>()
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
                      context.read<chordMelodySingingSettings>(),
                      context.read<MappingProvider>(),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Melody Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of notes in melody:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<chordMelodySingingSettings>().numberOfNotes,
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
                            .read<chordMelodySingingSettings>()
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
                    value: context.watch<chordMelodySingingSettings>().maxDistance,
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
                        context.read<chordMelodySingingSettings>().updateMaxDistance(
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
                            .watch<chordMelodySingingSettings>()
                            .allowRepeatedNotes,
                    onChanged: (bool? newValue) {
                      context
                          .read<chordMelodySingingSettings>()
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
                        context.watch<chordMelodySingingSettings>().chordFrequency,
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
                            .read<chordMelodySingingSettings>()
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
                            .watch<chordMelodySingingSettings>()
                            .allowRepeatedChords,
                    onChanged: (bool? newValue) {
                      context
                          .read<chordMelodySingingSettings>()
                          .toggleAllowRepeatedChords();
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Playback Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Playback key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Playback key'),
                    value: context.watch<chordMelodySingingSettings>().selectedKey,
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
                        context.read<chordMelodySingingSettings>().updateSelectedKey(
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
                            .watch<chordMelodySingingSettings>()
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
                            .read<chordMelodySingingSettings>()
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
                    value: context.watch<chordMelodySingingSettings>().playbackSpeed,
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
                            .read<chordMelodySingingSettings>()
                            .updatePlaybackSpeed(speed: newValue);
                        if (newValue == "Very fast") {
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 300);
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTruncateNotes(time: "600");
                        } else if (newValue == "Fast") {
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 600);
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTruncateNotes(time: "900");
                        } else if (newValue == "Normal") {
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 900);
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTruncateNotes(time: "1200");
                        } else if (newValue == "Slow") {
                          context
                              .read<chordMelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 1200);
                          context
                              .read<chordMelodySingingSettings>()
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
                            .watch<chordMelodySingingSettings>()
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
                            .read<chordMelodySingingSettings>()
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
                            .watch<chordMelodySingingSettings>()
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
                            .read<chordMelodySingingSettings>()
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
                      child: Text('Starting note (tonic): Always start with'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<chordMelodySingingSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<chordMelodySingingSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodySingingSettings>().startingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodySingingSettings>().updateStartingDo(
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
                      child: Text('Ending note: Always end with'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: context.watch<chordMelodySingingSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<chordMelodySingingSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending Note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodySingingSettings>().endingDo,
                    items:
                        [
                          "do0",
                          "la0",
                          "do",
                          "la",
                          "do1",
                          "la1",
                          "do2",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<chordMelodySingingSettings>().updateEndingDo(
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
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<chordMelodySingingSettings>()
                                .selectedKey]!['Guitar']![context
                                .read<chordMelodySingingSettings>()
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
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play Guitar Tonic',
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
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<chordMelodySingingSettings>()
                                .selectedKey]!['Piano']![context
                                .read<chordMelodySingingSettings>()
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
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play Piano Tonic',
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
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<chordMelodySingingSettings>()
                                .selectedKey]!['Solfege']![context
                                .read<chordMelodySingingSettings>()
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
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Play Solfege Tonic',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              TextRow("Chord Settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Range:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<chordMelodySingingSettings>().chordSetRange,
                    hint: Text('Select Range'),
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
                        context.read<chordMelodySingingSettings>().updateChordRange(
                          newChordRange: selectedRange ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context
                              .read<chordMelodySingingSettings>()
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
                    value: context.watch<chordMelodySingingSettings>().chordSet,
                    hint: Text('Select Set'),
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
                        context.read<chordMelodySingingSettings>().updateChordSet(
                          newChordSet: selectedChordSet ?? '',
                        );
                        if (selectedRange != null && selectedChordSet != null) {
                          final chords =
                              mappingProvider
                                  .getChordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                              [];
                          context
                              .read<chordMelodySingingSettings>()
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
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        context
                            .read<chordMelodySingingSettings>()
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
