import 'package:flutter/material.dart';
import 'audio/audio_controller.dart';
import 'dart:io';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
  Map<String, Map<String, Map<String, String>>> nestedMapping = {};
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

  @override
  void initState() {
    super.initState();
    //loadMappingFiles();
    loadMappingJSON();
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
              // Notes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              //minimumSize: Size(80, 36),
                              //maximumSize: Size(80, 36),
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(0.0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: TextStyle(
                                fontSize: 14,
                                //padding: EdgeInsets.zero,
                              ),
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
                                  nestedMapping[key]?[instrument]?[note] ?? '';
                              if (filename.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No audio file for $note'),
                                  ),
                                );
                                return;
                              }
                              await widget.audioController.playSound(
                                "assets/audio/$filename",
                              );
                              // Add to writtenMelody
                              setState(() {
                                writtenMelody.add(note);
                              });
                            },
                            child: Text(note),
                          ),
                        );
                      }).toList(),
                );
              }),
              SizedBox(height: 16),
              // Generate Melody Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      generateMelody(generalProvider);
                      setState(() {
                        solfegeText = ""; // Clear solfege area
                      });
                    },
                    child: Text("Generate melody"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Play Melody:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => playMelody("Guitar", generalProvider),
                    child: Text("Guitar"),
                  ),
                  // Play Piano Melody Button
                  ElevatedButton(
                    onPressed: () => playMelody("Piano", generalProvider),
                    child: Text("Piano"),
                  ),
                  // Play Solfege Melody Button
                  ElevatedButton(
                    onPressed: () => playMelody("Solfege", generalProvider),
                    child: Text("Solfege"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Solfege:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Show Solfege Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showSolfege();
                      setState(() {});
                    },
                    child: Text("Show Solfege"),
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
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Write and play your own melody:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
                    writtenMelody.join(' '),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        writtenMelody.clear();
                        comparisonResult = "";
                      });
                    },
                    child: Text("Clear"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
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
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed:
                        () => playWrittenMelody("Guitar", generalProvider),
                    child: Text("Guitar"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        () => playWrittenMelody("Piano", generalProvider),
                    child: Text("Piano"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        () => playWrittenMelody("Solfege", generalProvider),
                    child: Text("Solfege"),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Comparison Result: $comparisonResult",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
