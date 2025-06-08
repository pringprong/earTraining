import 'package:flutter/material.dart';
import 'audio/audio_controller.dart';
import 'dart:io';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
//import 'package:expandable/expandable.dart';
//import 'dart:math' as math;
//import 'package:auto_size_text/auto_size_text.dart';

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  Map<String, Map<String, Map<String, String>>> nestedMapping = {};
  Map<String, Map<String, Map<String, List<String>>>> chordsMapping = {};
  List<String> chordList = [];
  Map<String, List<String>> chordMap = {};

  String selectedKey = "";
  String selectedInstrument = "";
  int numberOfNotes = 5;
  bool allowRepeatedNotes = false;
  bool startWithDo = true;
  bool endWithDo = true;

  List<String> melody = [];
  String solfegeText = "";

  // --- Write Melody Section ---
  List<String> writtenMelody = [];
  String comparisonResult = "";

  List<List<String>> chordMelody = [];
  List<List<String>> writtenChordMelody = [];

  @override
  void initState() {
    super.initState();
    //loadMappingFiles();
    loadMappingJSON();
    loadChordsJSON();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);

    // Notes grid: group notes by row
    final noteRows = [
      GeneralProvider.noteKeys.where((n) => n.contains('0')).toList(),
      GeneralProvider.noteKeys
          .where((n) => !RegExp(r'\d').hasMatch(n))
          .toList(),
      GeneralProvider.noteKeys.where((n) => n.contains('1')).toList(),
      GeneralProvider.noteKeys.where((n) => n.contains('2')).toList(),
    ];

    final selectedNotes = generalProvider.getSelectedNotes();

    return Scaffold(
      appBar: AppBar(title: Text('Melody Ear Trainer')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('General'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/general');
                },
              ),
              ListTile(
                title: Text('Tonic'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/tonic');
                },
              ),
              ListTile(
                title: Text('Scales'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/scales');
                },
              ),
              ListTile(
                title: Text('Chords'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chords');
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Generate Melody Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        generateMelody(generalProvider);
                        setState(() {
                          solfegeText = ""; // Clear solfege area
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Generate melody",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Play Melody:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => playMelody("Guitar", generalProvider),
                      child: Text("Guitar"),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Play Piano Melody Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => playMelody("Piano", generalProvider),
                      child: Text("Piano"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  "Solfege",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: [
                  // Show Solfege Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showSolfege();
                            setState(() {});
                          },
                          child: Text("Show Solfege"),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Play Solfege Melody Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () => playMelody("Solfege", generalProvider),
                          child: Text("Play Solfege"),
                        ),
                      ),
                    ],
                  ),
                  // Solfege Text Area
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(solfegeText, style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Notes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "Play the melody back:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...List.generate(noteRows.length, (rowIdx) {
                final rowNotes =
                    noteRows[rowIdx]
                        .where((n) => selectedNotes.contains(n))
                        .toList();
                if (rowNotes.isEmpty) return SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:
                      rowNotes.map((note) {
                        return Expanded(
                          //padding: const EdgeInsets.all(2.0),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                //minimumSize: Size(80, 36),
                                //maximumSize: Size(80, 36),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(0.0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                //textStyle: TextStyle(
                                //fontSize: 14,
                                ///color: Colors.white,
                                //padding: EdgeInsets.zero,
                                //),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () async {
                                // Play note using AudioController and nestedMapping
                                final key = generalProvider.selectedKey;
                                final instrument =
                                    generalProvider.selectedInstrument;
                                final filename =
                                    nestedMapping[key]?[instrument]?[note] ??
                                    '';
                                if (filename.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No audio file for $note'),
                                    ),
                                  );
                                  return;
                                }
                                widget.audioController.playSound(
                                  "assets/audio/$filename",
                                );
                                // Add to writtenMelody
                                setState(() {
                                  writtenMelody.add(note);
                                  writtenChordMelody.add([note]);
                                });
                              },
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              }),
              SizedBox(height: 8),
              // Chord buttons section
              buildSelectedChordButtons(generalProvider),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    chordMelodyToString(writtenChordMelody),
                    //dMelody.expand((e) => e).toList().join(' '),
                    //writtenChordMelody.join(' '),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          writtenMelody.clear();
                          comparisonResult = "";
                        });
                      },
                      child: Text("Clear"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (writtenMelody.isNotEmpty) {
                            writtenMelody.removeLast();
                          }
                          comparisonResult = "";
                        });
                      },
                      child: Text("Backspace"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          comparisonResult =
                              listEquals(writtenMelody, melody)
                                  ? "Same"
                                  : "not the same";
                        });
                      },
                      child: Text("Compare with generated melody"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Comparison Result: $comparisonResult",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playWrittenMelody("Guitar", generalProvider),
                      child: Text("Guitar"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playWrittenMelody("Piano", generalProvider),
                      child: Text("Piano"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playWrittenMelody("Solfege", generalProvider),
                      child: Text("Solfege"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          writtenChordMelody.clear();
                        });
                      },
                      child: Text("Clear Chords"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (writtenChordMelody.isNotEmpty) {
                            writtenChordMelody.removeLast();
                          }
                        });
                      },
                      child: Text("Backspace Chord"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Compare writtenChordMelody with generated melody
                          // Flatten the writtenChordMelody for comparison
                          List<String> flatWrittenChordMelody =
                              writtenChordMelody.expand((e) => e).toList();
                          comparisonResult =
                              listEquals(flatWrittenChordMelody, melody)
                                  ? "Same"
                                  : "not the same";
                        });
                      },
                      child: Text("Compare Chords with generated melody"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Chord Comparison Result: $comparisonResult",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Guitar",
                            generalProvider,
                            writtenChordMelody,
                          ),
                      child: Text("Play Chord Melody (Guitar)"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Piano",
                            generalProvider,
                            writtenChordMelody,
                          ),
                      child: Text("Play Chord Melody (Piano)"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Solfege",
                            generalProvider,
                            writtenChordMelody,
                          ),
                      child: Text("Play Chord Melody (Solfege)"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void generateMelody(GeneralProvider generalProvider) {
    melody = [];
    writtenMelody = [];
    comparisonResult = "";
    final numNotes = generalProvider.numberOfNotes;
    final maxDist = generalProvider.maxDistance;
    final allowRepeats = generalProvider.allowRepeatedNotes;
    final startWithDo = generalProvider.startWithDo;
    final endWithDo = generalProvider.endWithDo;
    final startingDo = generalProvider.startingDo;
    final endingDo = generalProvider.endingDo;
    final notes = generalProvider.getSelectedNotes();

    if (notes.isEmpty || numNotes < 1) return;

    String? lastNote;
    for (int i = 0; i < numNotes; i++) {
      if (i == 0 && startWithDo) {
        melody.add(startingDo);
        lastNote = startingDo;
      } else if (i == numNotes - 1 && endWithDo) {
        melody.add(endingDo);
        lastNote = endingDo;
      } else {
        // Allowed notes: within maxDist of lastNote, and not repeated if not allowed
        List<String> allowed = notes;
        if (lastNote != null) {
          int lastIdx = notes.indexOf(lastNote);
          allowed =
              notes.where((n) {
                int idx = notes.indexOf(n);
                bool withinDist = (lastIdx - idx).abs() <= maxDist;
                bool notRepeat = allowRepeats || n != lastNote;
                return withinDist && notRepeat;
              }).toList();
        }
        if (allowed.isEmpty) allowed = notes;
        final next = (allowed..shuffle()).first;
        //final next = allowed[(allowed.length * (i + 1) * 37) % allowed.length];
        melody.add(next);
        lastNote = next;
      }
    }
    setState(() {});
  }

  Future<void> playMelody(
    String instrument,
    GeneralProvider generalProvider,
  ) async {
    final key = generalProvider.selectedKey;
    final timeBetween = generalProvider.timeBetweenNotes;
    final truncate = generalProvider.truncateNotes;
    if (melody.isEmpty) return;
    for (var note in melody) {
      final filename = nestedMapping[key]?[instrument]?[note] ?? '';
      if (filename.isNotEmpty) {
        if (truncate == "None") {
          widget.audioController.playSound("assets/audio/$filename");
        } else {
          // Truncate the sound if specified
          widget.audioController.playSoundFade(
            "assets/audio/$filename",
            int.parse(truncate),
            500,
          );
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
    }
  }

  void showSolfege() {
    solfegeText = melody.join(' ');
    setState(() {});
  }

  Future<void> loadMappingFiles() async {
    // Load Mapping.txt and populate nestedMapping
    String mappingData =
        await File('assets/mapping/Mapping.txt').readAsString();
    List<String> lines = mappingData.split('\n');
    for (String line in lines) {
      List<String> parts = line.split('\t');
      if (parts.length >= 4) {
        String key1 = parts[0];
        String key2 = parts[1];
        String key3 = parts[2];
        String value = parts[3];
        nestedMapping[key1] ??= {};
        nestedMapping[key1]![key2] ??= {};
        nestedMapping[key1]![key2]![key3] = value.trim();
      }
    }
    setState(() {});
  }

  Future<void> loadMappingJSON() async {
    // Load Scales.json and populate scalesMapping
    String jsonData = await DefaultAssetBundle.of(
      context,
    ).loadString("assets/mapping/Mapping.json");
    //final jsonResult = jsonDecode(jsonData);
    final List<dynamic> items = json.decode(jsonData);

    for (var item in items) {
      String key = item['Key'];
      String instrument = item['Instrument'];
      String note = item['Note'];
      String filename = item['File'];
      //List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();
      nestedMapping[key] ??= {};
      nestedMapping[key]![instrument] ??= {};
      nestedMapping[key]![instrument]![note] = filename;
    }
    setState(() {});
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

      if (chordSet.isNotEmpty && !chordMap.containsKey(chordSet)) {
        // Add to chordMap if not already present
        chordMap[chordSet] = notes;
      }
      chordsMapping[category] ??= {};
      chordsMapping[category]![degree] ??= {};
      chordsMapping[category]![degree]![chordSet] = notes;
    }
    setState(() {});
  }

  Future<void> playWrittenMelody(
    String instrument,
    GeneralProvider generalProvider,
  ) async {
    final key = generalProvider.selectedKey;
    final timeBetween = generalProvider.timeBetweenNotes;
    final truncate = generalProvider.truncateNotes;
    if (writtenMelody.isEmpty) return;
    for (var note in writtenMelody) {
      final filename = nestedMapping[key]?[instrument]?[note] ?? '';
      if (filename.isNotEmpty) {
        if (truncate == "None") {
          widget.audioController.playSound("assets/audio/$filename");
        } else {
          widget.audioController.playSoundFade(
            "assets/audio/$filename",
            int.parse(truncate),
            500,
          );
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
    }
  }

  // 1. Add chord buttons below notes section
  Widget buildSelectedChordButtons(GeneralProvider generalProvider) {
    final selectedChords = generalProvider.getSelectedChords();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children:
          selectedChords.map((chord) {
            final color = generalProvider.getChordButtonColor(chord);
            final notes = chordMap[chord] ?? [];
            return Tooltip(
              message: notes.join(' '),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    // 2b. Append chord as a list of notes to writtenChordMelody
                    writtenChordMelody.add(List<String>.from(notes));
                    playChordMelody(
                      generalProvider.selectedInstrument,
                      generalProvider,
                      [notes],
                    );
                  });
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    chord,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // 3. Add playChordMelody function
  Future<void> playChordMelody(
    String instrument,
    GeneralProvider generalProvider,
    List<List<String>> melodyList,
  ) async {
    final key = generalProvider.selectedKey;
    final timeBetween = generalProvider.timeBetweenNotes;
    final truncate = generalProvider.truncateNotes;
    final arpeggiate = generalProvider.arpeggiateChordDelay > 0;
    final arpeggiateDelay = generalProvider.arpeggiateChordDelay;
    final arpeggiateOrder = generalProvider.arpeggiateChordOrder;
    for (var notes in melodyList) {
      if (notes.length == 1) {
        final note = notes[0];
        final filename = nestedMapping[key]?[instrument]?[note] ?? '';
        if (filename.isNotEmpty) {
          if (truncate == "None" || truncate == "Never") {
            widget.audioController.playSound("assets/audio/$filename");
          } else {
            widget.audioController.playSoundFade(
              "assets/audio/$filename",
              int.parse(truncate),
              500,
            );
          }
        }
      } else if (notes.length > 1) {
        List<String> chordNotes = List<String>.from(notes);
        if (arpeggiateOrder == "Descending") {
          chordNotes = chordNotes.reversed.toList();
        } else if (arpeggiateOrder == "Random") {
          chordNotes.shuffle();
        }
        for (var note in chordNotes) {
          final filename = nestedMapping[key]?[instrument]?[note] ?? '';
          if (filename.isNotEmpty) {
            if (truncate == "None" || truncate == "Never") {
              widget.audioController.playSound("assets/audio/$filename");
            } else {
              widget.audioController.playSoundFade(
                "assets/audio/$filename",
                int.parse(truncate),
                500,
              );
            }
          }
          if (arpeggiate) {
            await Future.delayed(Duration(milliseconds: arpeggiateDelay));
          }
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
    }
  }
}

// Helper for list comparison
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Add this utility function to your file (e.g., below the listEquals function or anywhere in your class/file):

String chordMelodyToString(List<List<String>> data) {
  return data.map((inner) => inner.join('-')).join(' ');
}
