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
                                  ).toList(),
                          onChanged: (range) {
                            setState(() {
                              selectedRange = range;
                              context
                                  .read<GeneralProvider>()
                                  .updateChordRange(
                                    newChordRange: selectedRange ?? '',
                                  );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                //final notes =
                                //    chordsMapping[selectedRange!]![selectedChordSet!] ??
                                //   [];
                                //generalProvider.setNoteSelection(notes);
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
                                newChordSet:selectedChordSet  ?? '',
                              );
                              if (selectedRange != null &&
                                  selectedChordSet != null) {
                                //final notes =
                                //    chordsMapping[selectedRange!]![selectedChordSet!] ??
                                //    [];
                                //generalProvider.setNoteSelection(notes);
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
            ],
          ),
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
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected ? Colors.blue : Colors.grey,
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
                  generalProvider.toggleNoteSelection(note);
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

      chordsMapping[category] ??= {};
      chordsMapping[category]![degree] ??= {};
      chordsMapping[category]![degree]![chordSet] = notes;
    }
    setState(() {});
  }

Future<void> loadChordSetsJSON() async {
    // Load Chords.json and populate chordsSetMapping
    String jsonData = await DefaultAssetBundle.of(context,
    ).loadString("assets/mapping/ChordSets.json");
    //final jsonResult = jsonDecode(jsonData);
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String rangeValue = item['Range'];
      String set = item['Set'];
      String chordSet = item['Chords'];
      List<String> chordSets = chordSet.split(',').map((s) => s.trim()).toList();

      chordSetsMapping[rangeValue] ??= {};
      chordSetsMapping[rangeValue]![set] = chordSets;

      if (rangeValue.isNotEmpty && !rangesList.contains(rangeValue)) {
        rangesList.add(rangeValue);
      }
      if (set.isNotEmpty && !chordSetsList.contains(set)) {
        chordSetsList.add(set);
      }
    }
    setState(() {});
  }
}