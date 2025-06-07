import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  List<String> mappingKeys = [];
  List<String> instruments = [];

  @override
  void initState() {
    super.initState();
    //loadMappingFiles();
    loadMappingJSON();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Select Key:'),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Key'),
                    value: context.watch<GeneralProvider>().selectedKey,
                    items:
                        mappingKeys.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateSelectedKey(
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
                    value: context.watch<GeneralProvider>().selectedInstrument,
                    items:
                        instruments.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateSelectedInstrument(
                          instrument: newValue,
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
                    child: Text('Number of notes in melody:'),
                  ),
                  DropdownButton<int>(
                    value: context.watch<GeneralProvider>().numberOfNotes,
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
                        context.read<GeneralProvider>().updateNumberOfNotes(
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
                    value: context.watch<GeneralProvider>().maxDistance,
                    items:
                        List.generate(7, (i) => i + 1).map<DropdownMenuItem<int>>(
                          (int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          },
                        ).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateMaxDistance(
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
                    value: context.watch<GeneralProvider>().allowRepeatedNotes,
                    onChanged: (bool? newValue) {
                      context.read<GeneralProvider>().toggleAllowRepeatedNotes();
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
                    value: context.watch<GeneralProvider>().timeBetweenNotes,
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
                        context.read<GeneralProvider>().updateTimeBetweenNotes(
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
                    value: context.watch<GeneralProvider>().truncateNotes,
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
                        context.read<GeneralProvider>().updateTruncateNotes(
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
                    child: Text('Chord frequency:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<GeneralProvider>().chordFrequency,
                    items:
                        [
                          "Never",
                          "Every 4 notes",
                          "Every 3 notes",
                          "Every 2 notes",
                          "Every note"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateChordFrequency(
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
                    child: Text('Display chord names:'),
                  ),
                  Checkbox(
                    value: context.watch<GeneralProvider>().displayChordNames,
                    onChanged: (bool? newValue) {
                      context.read<GeneralProvider>().toggleDisplayChordNames();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Arpeggiate chords:'),
                  ),
                  Checkbox(
                    value: context.watch<GeneralProvider>().arpeggiateChords,
                    onChanged: (bool? newValue) {
                      context.read<GeneralProvider>().toggleArpeggiateChords();
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
                    value: context.watch<GeneralProvider>().arpeggiateChordDelay,
                    items:
                        [50, 100, 200, 300, 400, 500].map<DropdownMenuItem<int>>((
                          int value,
                        ) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateArpeggiateChordDelay(
                          delay: newValue,
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
                    child: Text('Arpeggiation order:'),
                  ),
                  DropdownButton<String>(
                    value: context.watch<GeneralProvider>().arpeggiateChordOrder,
                    items:
                        [
                          "Ascending",
                          "Descending",
                          "Random"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<GeneralProvider>().updateArpeggiateChordOrder(
                          order: newValue,
                        );
                      }
                    },
                  ),
                ],
              ),      
            ], // Children of Column
          ),
        ),
      ),
    );
  }

  Future<void> loadMappingFiles() async {
    // Load Mapping.txt and populate mappingKeys and instruments
    String mappingData =
        await File('assets/mapping/Mapping.txt').readAsString();
    List<String> lines = mappingData.split('\n');
    for (String line in lines) {
      List<String> parts = line.split('\t');
      if (parts.isNotEmpty && !mappingKeys.contains(parts[0])) {
        mappingKeys.add(parts[0]);
      }
      if (parts.length > 1 && !instruments.contains(parts[1])) {
        instruments.add(parts[1]);
      }
    }
    setState(() {});
  }

  Future<void> loadMappingJSON() async {
    // Load Scales.json and populate scalesMapping
    // this version only gets the keys and instruments
    // from the Mapping.json file, not the full mapping
    String jsonData = await DefaultAssetBundle.of(
      context,
    ).loadString("assets/mapping/Mapping.json");
    //final jsonResult = jsonDecode(jsonData);
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String key = item['Key'];
      String instrument = item['Instrument'];
      if (key.isNotEmpty && !mappingKeys.contains(key)) {
        mappingKeys.add(key);
      }
      if (instrument.length > 1 && !instruments.contains(instrument)) {
        instruments.add(instrument);
      }
    }
    setState(() {});
  }
}
