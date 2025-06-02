import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
//import 'dart:io';
import 'dart:convert';

class ScalesPage extends StatefulWidget {
  const ScalesPage({super.key});

  @override
  State<ScalesPage> createState() => _ScalesPageState();
}

class _ScalesPageState extends State<ScalesPage> {
  Map<String, Map<String, List<String>>> scalesMapping = {};

  List<String> octavekeys = [];
  List<String> scalekeys = [];

  @override
  void initState() {
    super.initState();
    //loadScales();
    loadScalesJSON();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);
    //String? selectedOctave = "All octaves"; // Default octave selection
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    // Get octave and scale dropdown values
    //final octaveKeys = scalesMapping.keys.toList();
    //final scaleKeys =
    //    <String>{for (var v in scalesMapping.values) ...v.keys}.toList();

    // Get notes for current selection
    // List<String> selectedNotes = [];
    // if (selectedOctave != null &&
    //     selectedScale != null &&
    //     scalesMapping[selectedOctave!] != null &&
    //     scalesMapping[selectedOctave!]![selectedScale!] != null) {
    //   selectedNotes = scalesMapping[selectedOctave!]![selectedScale!]!;
    // }

    return Scaffold(
      appBar: AppBar(title: Text('Scales Settings')),
      body: Center(
        child: Column(
          children: [
            // Octave dropdown
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Octave:'),
                ),
                DropdownButton<String>(
                  value: context.watch<GeneralProvider>().selectedOctave,
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
                      context.read<GeneralProvider>().updateSelectedOctave(
                        octave: selectedOctave ?? '',
                      );
                      if (selectedOctave != null && selectedScale != null) {
                        final notes =
                            scalesMapping[selectedOctave!]![selectedScale!] ??
                            [];
                        generalProvider.setNoteSelection(notes);
                      }
                    });
                  },
                ),
              ],
            ),
            // Scale dropdown
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Scale:'),
                ),
                DropdownButton<String>(
                  value: context.watch<GeneralProvider>().selectedScale,
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
                      context.read<GeneralProvider>().updateSelectedScale(
                        newscale: selectedScale ?? '',
                      );
                      if (selectedOctave != null && selectedScale != null) {
                        final notes =
                            scalesMapping[selectedOctave!]![selectedScale!] ??
                            [];
                        generalProvider.setNoteSelection(notes);
                      }
                    });
                  },
                ),
              ],
            ),
            // Notes grid
            Expanded(
              //padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildNotesGrid(generalProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(GeneralProvider generalProvider) {
    const noteKeys = GeneralProvider.noteKeys;
    List<Widget> rows = [];
    for (int row = 0; row < 4; row++) {
      int start = row * 12;
      int end = (row == 3) ? start + 1 : start + 12;
      if (start >= noteKeys.length) break;
      List<Widget> buttons = [];
      for (int i = start; i < end && i < noteKeys.length; i++) {
        final note = noteKeys[i];
        final selected = generalProvider.noteSelection[note] ?? false;
        buttons.add(
          Expanded(
            //padding: const EdgeInsets.all(2.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected ? Colors.blue : Colors.grey,
                //minimumSize: Size(40, 40),
                padding: EdgeInsets.zero,
                textStyle: TextStyle(fontSize: selected ? 16 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                generalProvider.toggleNoteSelection(note);
              },
              child: Text(
                note,
                style: TextStyle(
                  fontSize: selected ? 16 : 12,
                  color: Colors.white,
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

  // Future<void> loadScales() async {
  //   // Load Scales.txt and populate mappingKeys and instruments
  //   String mappingData = await File('assets/mapping/Scales.txt').readAsString();
  //   List<String> lines = mappingData.split('\n');
  //   for (String line in lines) {
  //     List<String> parts = line.split('\t');
  //     if (parts.length >= 3) {
  //       String key1 = parts[0];
  //       String key2 = parts[1];
  //       String value = parts[2].trim();
  //       List<String> values = value.split(',');
  //       scalesMapping[key1] ??= {};
  //       scalesMapping[key1]![key2] = values;
  //     }
  //   }
  //   // Set defaults
  //   if (scalesMapping.isNotEmpty) {
  //     selectedOctave = scalesMapping.keys.first;
  //     selectedScale = scalesMapping[selectedOctave!]!.keys.first;
  //   }
  //   setState(() {});
  // }

  Future<void> loadScalesJSON() async {
    // Load Scales.json and populate scalesMapping
    String jsonData = await DefaultAssetBundle.of(
      context,
    ).loadString("assets/mapping/Scales.json");
    //final jsonResult = jsonDecode(jsonData);
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String octave = item['Octave'];
      String set = item['Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      scalesMapping[octave] ??= {};
      scalesMapping[octave]![set] = notes;

      if (octave.isNotEmpty && !octavekeys.contains(octave)) {
        octavekeys.add(octave);
      }
      if (set.isNotEmpty && !scalekeys.contains(set)) {
        scalekeys.add(set);
      }
    }
    setState(() {});
  }
}
