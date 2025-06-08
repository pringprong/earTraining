import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
//import 'dart:io';
import 'dart:convert';

class ChordsPage extends StatefulWidget {
  const ChordsPage({super.key});

  @override
  State<ChordsPage> createState() => _ChordsPageState();
}

class _ChordsPageState extends State<ChordsPage> {
  Map<String, Map<String, Map<String, List<String>>>> chordsMapping = {};
  List<String> chordList = [];
  Map<String, Map<String, List<String>>> chordSetsMapping = {};
  List<String> rangesList = [];
  List<String> chordSetsList = [];

  @override
  void initState() {
    super.initState();
    //loadChords();
    loadChordsJSON();
    loadChordSetsJSON();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);
    String? selectedRange =
        generalProvider.chordSetRange; // Default range selection
    String? selectedChordSet =
        generalProvider.chordSet; // Default set selection

    return Scaffold(
      appBar: AppBar(title: Text('Chord Selection')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Octave dropdown
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Range:'),
                        ),
                        DropdownButton<String>(
                          value: context.watch<GeneralProvider>().chordSetRange,
                          hint: Text('Select Range'),
                          items:
                              rangesList
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
                              context.read<GeneralProvider>().updateChordRange(
                                newChordRange: selectedRange ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<GeneralProvider>()
                                    .setSelectedChords(chords);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Set:'),
                        ),
                        DropdownButton<String>(
                          value: context.watch<GeneralProvider>().chordSet,
                          hint: Text('Select Set'),
                          items:
                              chordSetsList
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
                              context.read<GeneralProvider>().updateChordSet(
                                newChordSet: selectedChordSet ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                final chords =
                                    chordSetsMapping[selectedRange!]?[selectedChordSet!] ??
                                    [];
                                context
                                    .read<GeneralProvider>()
                                    .setSelectedChords(chords);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Notes grid
              //Expanded(child: _buildNotesGrid(generalProvider)),
              buildChordButtons(chordsMapping, generalProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildNotesGrid(GeneralProvider generalProvider) {
  //   const noteKeys = GeneralProvider.noteKeys;
  //   List<Widget> rows = [];
  //   for (int row = 0; row < 4; row++) {
  //     int start = row * 12;
  //     int end = (row == 3) ? start + 1 : start + 12;
  //     if (start >= noteKeys.length) break;
  //     List<Widget> buttons = [];
  //     for (int i = start; i < end && i < noteKeys.length; i++) {
  //       final note = noteKeys[i];
  //       final selected = generalProvider.noteSelection[note] ?? false;
  //       buttons.add(
  //         Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.all(1.0),
  //             child: ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: selected ? Colors.blue : Colors.grey,
  //                 //minimumSize: Size(40, 40),
  //                 padding: EdgeInsets.zero,
  //                 textStyle: TextStyle(
  //                   fontWeight: selected ? FontWeight.bold : FontWeight.normal,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 generalProvider.toggleNoteSelection(note);
  //               },
  //               child: FittedBox(
  //                 fit: BoxFit.fill,
  //                 child: Text(
  //                   note,
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight:
  //                         selected ? FontWeight.bold : FontWeight.normal,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //     rows.add(
  //       Row(mainAxisAlignment: MainAxisAlignment.start, children: buttons),
  //     );
  //   }
  //   return Column(children: rows);
  // }

  // a. Multiply hex color by factor
  Color multiplyHexColor(String hexColor, double factor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      int r = int.parse(hexColor.substring(0, 2), radix: 16);
      int g = int.parse(hexColor.substring(2, 4), radix: 16);
      int b = int.parse(hexColor.substring(4, 6), radix: 16);

      r = (r * factor).clamp(0, 255).toInt();
      g = (g * factor).clamp(0, 255).toInt();
      b = (b * factor).clamp(0, 255).toInt();

      return Color.fromARGB(255, r, g, b);
    }
    return Colors.grey;
  }

  // b. Get chord button color
  Color getChordButtonColor(String chordName) {
    const color1 = "#8189d3";
    const color2 = "#89afaa";
    const color3 = "#bcae9a";
    const color4 = "#c3b2b7";
    const color5 = "#d0a89b";
    const buttonColor = "#84b6d4";
    const factor1 = 0.85;
    const factor2 = 1.0;
    const factor3 = 1.15;
    const factor4 = 1.3;
    //const FACTOR5 = 1.45;

    String c = chordName;
    if (c.endsWith("_VL_R")) return multiplyHexColor(color1, factor1);
    if (c.endsWith("_L_R")) return multiplyHexColor(color1, factor2);
    if (c.endsWith("_M_R")) return multiplyHexColor(color1, factor3);
    if (c.endsWith("_H_R")) return multiplyHexColor(color1, factor4);

    if (c.endsWith("_VL_1i")) return multiplyHexColor(color2, factor1);
    if (c.endsWith("_L_1i")) return multiplyHexColor(color2, factor2);
    if (c.endsWith("_M_1i")) return multiplyHexColor(color2, factor3);
    if (c.endsWith("_H_1i")) return multiplyHexColor(color2, factor4);

    if (c.endsWith("_VL_2i")) return multiplyHexColor(color3, factor1);
    if (c.endsWith("_L_2i")) return multiplyHexColor(color3, factor2);
    if (c.endsWith("_M_2i")) return multiplyHexColor(color3, factor3);
    if (c.endsWith("_H_2i")) return multiplyHexColor(color3, factor4);

    if (c.endsWith("_VL_3i")) return multiplyHexColor(color4, factor1);
    if (c.endsWith("_L_3i")) return multiplyHexColor(color4, factor2);
    if (c.endsWith("_M_3i")) return multiplyHexColor(color4, factor3);
    if (c.endsWith("_H_3i")) return multiplyHexColor(color4, factor4);

    if (c.endsWith("_All")) return multiplyHexColor(color5, factor2);

    return multiplyHexColor(buttonColor, 1.0);
  }

  // c. Draw dynamic chord buttons
  Widget buildChordButtons(
    Map<String, Map<String, Map<String, List<String>>>> chordsMapping,
    GeneralProvider generalProvider,
  ) {
    List<Widget> sections = [];
    chordsMapping.forEach((category, degreesMap) {
      // Section title
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            category,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );
      degreesMap.forEach((degree, chordSetMap) {
        // Row for each degree
        List<Widget> chordButtons = [];
        chordSetMap.forEach((chordName, notes) {
          final selected = generalProvider.selectedChords[chordName] == true;
          chordButtons.add(
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Tooltip(
                message: notes.join(' '),
                child: GestureDetector(
                  onTap: () {
                    generalProvider.toggleSelectedChord(chordName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? generalProvider.getChordButtonColor(chordName)
                              : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Text(
                        chordName,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
        sections.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Wrap(spacing: 4, runSpacing: 4, children: chordButtons),
          ),
        );
      });
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Future<void> loadChordsJSON() async {
    // Load Chords.json and populate chordsMapping
    String jsonData = await DefaultAssetBundle.of(
      context,
    ).loadString("assets/mapping/Chords.json");
    //final jsonResult = jsonDecode(jsonData);
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String category = item['Category'];
      String degree = item['Degree'];
      String chordSet = item['Chord Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      if (chordSet.isNotEmpty && !chordList.contains(chordSet)) {
        chordList.add(chordSet);
      }
      chordsMapping[category] ??= {};
      chordsMapping[category]![degree] ??= {};
      chordsMapping[category]![degree]![chordSet] = notes;
    }
    setState(() {});
  }

  Future<void> loadChordSetsJSON() async {
    // Load Chords.json and populate chordsSetMapping
    String jsonData = await DefaultAssetBundle.of(
      context,
    ).loadString("assets/mapping/ChordSets.json");
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String rangeValue = item['Range'];
      String set = item['Set'];
      String chordSet = item['Chords'];
      List<String> chordSets =
          chordSet.split(',').map((s) => s.trim()).toList();

      chordSetsMapping[rangeValue] ??= {};
      chordSetsMapping[rangeValue]![set] = chordSets;

      if (rangeValue.isNotEmpty && !rangesList.contains(rangeValue)) {
        rangesList.add(rangeValue);
      }
      if (set.isNotEmpty && !chordSetsList.contains(set)) {
        chordSetsList.add(set);
      }
    }

    // Add "Select all" set for each rangeValue
    for (var rangeValue in rangesList) {
      chordSetsMapping[rangeValue]?["Select all"] = List<String>.from(
        chordList,
      );
    }

    setState(() {});
  }
}
