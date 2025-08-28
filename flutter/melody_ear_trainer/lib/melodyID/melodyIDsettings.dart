import 'package:flutter/material.dart';
import '../providers/general_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mapping_provider.dart';
import '../audio/audio_controller.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';

class melodyIDSettings extends StatefulWidget {
  const melodyIDSettings({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<melodyIDSettings> createState() => _melodyIDSettingsState();
}

class _melodyIDSettingsState extends State<melodyIDSettings> {
  @override
  Widget build(BuildContext context) {
    final mappingKeys = context.watch<MappingProvider>().getMappingKeys;
    final instruments = context.watch<MappingProvider>().getInstruments;
    final generalProvider = Provider.of<MelodyIDSettings>(context);
    final scalesMapping = context.watch<MappingProvider>().getScalesMapping;
    final octavekeys = context.watch<MappingProvider>().getOctaveKeys;
    final scalekeys = context.watch<MappingProvider>().getScaleKeys;
    final nestedMapping = context.watch<MappingProvider>().getNestedMapping;
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    return Scaffold(
      appBar: AppBar(title: Text('Melody ID Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Melody Notes:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Octave:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<MelodyIDSettings>().selectedOctave,
                    hint: Text('Select Octave'),
                    items:
                        octavekeys
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
                            .read<MelodyIDSettings>()
                            .updateSelectedOctave(
                              octave: selectedOctave ?? '',
                            );
                        if (selectedOctave != null &&
                            selectedScale != null) {
                          final notes =
                              scalesMapping[selectedOctave!]![selectedScale!] ??
                              [];
                          generalProvider.setNoteSelection(
                            selectedKeys: notes,
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
                    child: Text('Scale:'),
                  ),
                  DropdownButton<String>(
                    value:
                        context.watch<MelodyIDSettings>().selectedScale,
                    hint: Text('Select Scale'),
                    items:
                        scalekeys
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
                            .read<MelodyIDSettings>()
                            .updateSelectedScale(
                              newscale: selectedScale ?? '',
                            );
                        if (selectedOctave != null &&
                            selectedScale != null) {
                          final notes =
                              scalesMapping[selectedOctave!]![selectedScale!] ??
                              [];
                          generalProvider.setNoteSelection(
                            selectedKeys: notes,
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
              // Notes grid
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                  child: _buildNotesGrid(
                    context.read<MelodyIDSettings>(),
                    context.read<MappingProvider>(),
                  ),
                ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Melody Settings:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Playback Settings:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Select Key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Key'),
                    value: context.watch<MelodyIDSettings>().selectedKey,
                    items:
                        mappingKeys.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                    child: Text('Select Instrument:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Instrument'),
                    value: context.watch<MelodyIDSettings>().selectedInstrument,
                    items:
                        instruments.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                    child: Text('Time between notes in melody (ms):'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<MelodyIDSettings>().timeBetweenNotes,
                    items:
                        [300, 600, 900, 1200].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<MelodyIDSettings>().updateTimeBetweenNotes(
                          time: newValue,
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
                    child: Text('Truncate notes in melody (ms):'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().truncateNotes,
                    items:
                        [
                          "None",
                          "600",
                          "900",
                          "1200",
                          "1500",
                          "1800",
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<MelodyIDSettings>().updateTruncateNotes(
                          time: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Tonic:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
              SizedBox(height: 8),
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
                    child: Text('Tonic Note:'),
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
              SizedBox(height: 8),
              // Ending note "always start with" checkbox
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
              SizedBox(height: 8),
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
                    child: Text('Ending Note:'),
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
              // Play Guitar Tonic Button
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor(
                          "blah_M_2i",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
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
                        child: Text('Play Guitar Tonic', style: TextStyle(fontSize: 20))),
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
                        backgroundColor: getChordButtonColor(
                          "blah_M_All",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
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
                        child: Text('Play Piano Tonic', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ],
              ),
              // Play Solfege Tonic Button
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor(
                          "blah_M_R",
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        String filename =
                            nestedMapping[context
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
                        child: Text('Play Solfege Tonic', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Reset:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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

  Widget _buildNotesGrid(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    final noteKeys = mappingProvider.getNoteKeys;
    final noteColors = mappingProvider.getNoteColors;
    final noteColorFactor = mappingProvider.getNoteColorFactors;
    final noteSelection = generalProvider.getNoteSelection;
    //print(noteSelection);
    List<Widget> rows = [];
    for (int row = 0; row < 4; row++) {
      int start = row * 12;
      int end = (row == 3) ? start + 1 : start + 12;
      if (start >= noteKeys.length) break;
      List<Widget> buttons = [];
      for (int i = start; i < end && i < noteKeys.length; i++) {
        final note = noteKeys[i];
        final selected = noteSelection[note] ?? false;
        final String tempColor = noteColors[note].toString();
        final double tempFactor = noteColorFactor[note] ?? 1.0;
        final buttonColor = multiplyHexColor(tempColor, tempFactor);
        buttons.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //backgroundColor: selected ? buttonColor : Colors.grey,
                  backgroundColor: selected ? buttonColor : Colors.grey,
                  //minimumSize: Size(40, 40),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  generalProvider.toggleNoteSelection(key: note);
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.start, children: buttons),
      );
    }
    return Column(children: rows);
  }
}
