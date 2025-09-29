import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/helper.dart';

class MelodySingingSettingsPage extends StatefulWidget {
  const MelodySingingSettingsPage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<MelodySingingSettingsPage> createState() =>
      _MelodySingingSettingsPageState();
}

class _MelodySingingSettingsPageState extends State<MelodySingingSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final generalProvider = Provider.of<MelodySingingSettings>(context);
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    return Scaffold(
      appBar: AppBar(title: Text('Melody singing settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              subHeadingRow("Melody notes:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Octave:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<MelodySingingSettings>().selectedOctave,
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
                            .read<MelodySingingSettings>()
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
                    value: context.watch<MelodySingingSettings>().selectedScale,
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
                            .read<MelodySingingSettings>()
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
              subHeadingRow("Select notes to include in melody:"),
              verticalSpacer(),
              plainText(
                "Note: Make sure to include starting and ending notes if selected below",
              ),
              verticalSpacer(),
              Row(
                children: [
                  Expanded(
                    child: buildNotesGrid(
                      context.read<MelodySingingSettings>(),
                      context.read<MappingProvider>(),
                      true
                    ),
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Melody settings:"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Number of notes in melody:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodySingingSettings>().numberOfNotes,
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
                            .read<MelodySingingSettings>()
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
                    value: context.watch<MelodySingingSettings>().maxDistance,
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
                        context.read<MelodySingingSettings>().updateMaxDistance(
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
                            .watch<MelodySingingSettings>()
                            .allowRepeatedNotes,
                    onChanged: (bool? newValue) {
                      context
                          .read<MelodySingingSettings>()
                          .toggleAllowRepeatedNotes();
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
                    value: context.watch<MelodySingingSettings>().selectedKey,
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
                        context.read<MelodySingingSettings>().updateSelectedKey(
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
                            .watch<MelodySingingSettings>()
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
                            .read<MelodySingingSettings>()
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
                    value: context.watch<MelodySingingSettings>().playbackSpeed,
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
                            .read<MelodySingingSettings>()
                            .updatePlaybackSpeed(speed: newValue);
                        if (newValue == "Very fast") {
                          context
                              .read<MelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 300);
                          context
                              .read<MelodySingingSettings>()
                              .updateTruncateNotes(time: "600");
                        } else if (newValue == "Fast") {
                          context
                              .read<MelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 600);
                          context
                              .read<MelodySingingSettings>()
                              .updateTruncateNotes(time: "900");
                        } else if (newValue == "Normal") {
                          context
                              .read<MelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 900);
                          context
                              .read<MelodySingingSettings>()
                              .updateTruncateNotes(time: "1200");
                        } else if (newValue == "Slow") {
                          context
                              .read<MelodySingingSettings>()
                              .updateTimeBetweenNotes(time: 1200);
                          context
                              .read<MelodySingingSettings>()
                              .updateTruncateNotes(time: "1500");
                        }
                      }
                    },
                  ),
                ],
              ),
              verticalSpacer(),
              subHeadingRow("Tonic:"),
              verticalSpacer(),
              plainText(
                "Note: Make sure these are selected in the melody notes above",
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
                    value: context.watch<MelodySingingSettings>().startWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodySingingSettings>().toggleStartWithDo();
                    },
                  ),
                  // Starting note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tonic note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodySingingSettings>().startingDo,
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
                        context.read<MelodySingingSettings>().updateStartingDo(
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
                    value: context.watch<MelodySingingSettings>().endWithDo,
                    onChanged: (bool? value) {
                      context.read<MelodySingingSettings>().toggleEndWithDo();
                    },
                  ),
                  // Ending note dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ending note:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodySingingSettings>().endingDo,
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
                        context.read<MelodySingingSettings>().updateEndingDo(
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
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<MelodySingingSettings>()
                                .selectedKey]!['Guitar']![context
                                .read<MelodySingingSettings>()
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
                        backgroundColor: colorMap["c5f2"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<MelodySingingSettings>()
                                .selectedKey]!['Piano']![context
                                .read<MelodySingingSettings>()
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
                        backgroundColor: colorMap["c1f3"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () async {
                        String filename =
                            mappingProvider.getNestedMapping[context
                                .read<MelodySingingSettings>()
                                .selectedKey]!['Solfege']![context
                                .read<MelodySingingSettings>()
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
              subHeadingRow("Reset:"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMap["c1f3"] ?? Colors.white,
                        foregroundColor:
                            colorMap["buttonForegroundColor"] ?? Colors.white,
                      ),
                      onPressed: () {
                        context
                            .read<MelodySingingSettings>()
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
