import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/theme_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});
  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    final mappingKeys = context.watch<MappingProvider>().getMappingKeys;
    final instruments = context.watch<MappingProvider>().getInstruments;
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Chord frequency:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<MelodyIDSettings>().chordFrequency,
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
                        context.read<MelodyIDSettings>().updateChordFrequency(
                          frequency: newValue,
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
                    value: context.watch<MelodyIDSettings>().allowRepeatedChords,
                    onChanged: (bool? newValue) {
                      context
                          .read<MelodyIDSettings>()
                          .toggleAllowRepeatedChords();
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chord delay (ms):'),
                  ),
                  DropdownButton<int>(
                    value:
                        context.watch<MelodyIDSettings>().arpeggiateChordDelay,
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
                            .read<MelodyIDSettings>()
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
                        context.watch<MelodyIDSettings>().arpeggiateChordOrder,
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
                            .read<MelodyIDSettings>()
                            .updateArpeggiateChordOrder(order: newValue);
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
                    "Display Settings:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Light mode:'),
                  ),
                  Checkbox(
                    value: context.watch<ThemeProvider>().darkModeBool,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        context.read<ThemeProvider>().setDarkMode(newValue);
                      }
                    },
                  ),
                ],
              ),
              //  Row(
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Text('Display chord names:'),
              //       ),
              //       Checkbox(
              //         value: context.watch<MelodyIDSettings>().displayChordNames,
              //         onChanged: (bool? newValue) {
              //           context.read<MelodyIDSettings>().toggleDisplayChordNames();
              //         },
              //       ),
              //     ],
              //   ),
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
                        child: Text("Reset all settings", style: TextStyle(fontSize: 20))),
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
