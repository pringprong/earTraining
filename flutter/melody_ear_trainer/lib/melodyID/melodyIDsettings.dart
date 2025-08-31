import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';

class MelodyIDSettingsPage extends StatefulWidget {
  const MelodyIDSettingsPage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<MelodyIDSettingsPage> createState() => _MelodyIDSettingsPageState();
}

class _MelodyIDSettingsPageState extends State<MelodyIDSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<MelodyIDSettings>(context);
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    return Scaffold(
      appBar: AppBar(title: Text('Melody ID settings')),
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
                    value: context.watch<MelodyIDSettings>().selectedOctave,
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
                        context.read<MelodyIDSettings>().updateSelectedOctave(
                          octave: selectedOctave ?? '',
                        );
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
                    value: context.watch<MelodyIDSettings>().selectedScale,
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
                        context.read<MelodyIDSettings>().updateSelectedScale(
                          newscale: selectedScale ?? '',
                        );
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
                      context.read<MelodyIDSettings>(),
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
                    value: context.watch<MelodyIDSettings>().numberOfNotes,
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
                        context.read<MelodyIDSettings>().updateNumberOfNotes(
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
                    child: Text('Max distance between adjacent notes:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().maxDistance,
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
                        context.read<MelodyIDSettings>().updateMaxDistance(
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
                    value: context.watch<MelodyIDSettings>().allowRepeatedNotes,
                    onChanged: (bool? newValue) {
                      context
                          .read<MelodyIDSettings>()
                          .toggleAllowRepeatedNotes();
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
                    value: context.watch<MelodyIDSettings>().selectedKey,
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
                        context.read<MelodyIDSettings>().updateSelectedKey(
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
                    value: context.watch<MelodyIDSettings>().selectedInstrument,
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
                            .read<MelodyIDSettings>()
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
                    value: context.watch<MelodyIDSettings>().playbackSpeed,
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
                        context.read<MelodyIDSettings>().updatePlaybackSpeed(
                          speed: newValue,
                        );
                        if (newValue == "Very fast") {
                          context
                              .read<MelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 300);
                          context.read<MelodyIDSettings>().updateTruncateNotes(
                            time: "600",
                          );
                        } else if (newValue == "Fast") {
                          context
                              .read<MelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 600);
                          context.read<MelodyIDSettings>().updateTruncateNotes(
                            time: "900",
                          );
                        } else if (newValue == "Normal") {
                          context
                              .read<MelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 900);
                          context.read<MelodyIDSettings>().updateTruncateNotes(
                            time: "1200",
                          );
                        } else if (newValue == "Slow") {
                          context
                              .read<MelodyIDSettings>()
                              .updateTimeBetweenNotes(time: 1200);
                          context.read<MelodyIDSettings>().updateTruncateNotes(
                            time: "1500",
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text('Time between notes in melody (ms):'),
              //     ),
              //     DropdownButton<int>(
              //       value: context.watch<MelodyIDSettings>().timeBetweenNotes,
              //       items:
              //           [300, 600, 900, 1200].map<DropdownMenuItem<int>>((
              //             int value,
              //           ) {
              //             return DropdownMenuItem<int>(
              //               value: value,
              //               child: Text(value.toString()),
              //             );
              //           }).toList(),
              //       onChanged: (int? newValue) {
              //         if (newValue != null) {
              //           context.read<MelodyIDSettings>().updateTimeBetweenNotes(
              //             time: newValue,
              //           );
              //         }
              //       },
              //     ),
              //   ],
              // ),
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text('Truncate notes in melody (ms):'),
              //     ),
              //     DropdownButton<String>(
              //       value: context.watch<MelodyIDSettings>().truncateNotes,
              //       items:
              //           [
              //             "None",
              //             "600",
              //             "900",
              //             "1200",
              //             "1500",
              //             "1800",
              //           ].map<DropdownMenuItem<String>>((String value) {
              //             return DropdownMenuItem<String>(
              //               value: value,
              //               child: Text(value),
              //             );
              //           }).toList(),
              //       onChanged: (String? newValue) {
              //         if (newValue != null) {
              //           context.read<MelodyIDSettings>().updateTruncateNotes(
              //             time: newValue,
              //           );
              //         }
              //       },
              //     ),
              //   ],
              // ),
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
                    value: context.watch<MelodyIDSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodyIDSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().startingDo,
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
                        context.read<MelodyIDSettings>().updateStartingDo(
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
                    value: context.watch<MelodyIDSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodyIDSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().endingDo,
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
                        context.read<MelodyIDSettings>().updateEndingDo(
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
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Guitar']![context
                                .read<MelodyIDSettings>()
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
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Piano']![context
                                .read<MelodyIDSettings>()
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
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<MelodyIDSettings>()
                                .selectedKey]!['Solfege']![context
                                .read<MelodyIDSettings>()
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
                          'Play solfege tonic',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
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
                        context.read<MelodyIDSettings>().resetAllSettings();
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
