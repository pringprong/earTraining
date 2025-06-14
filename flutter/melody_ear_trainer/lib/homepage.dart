import 'package:flutter/material.dart';
import 'audio/audio_controller.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';
//import 'package:expandable/expandable.dart';
//import 'package:auto_size_text/auto_size_text.dart';

class MelodyHomePage extends StatefulWidget {
  const MelodyHomePage({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<MelodyHomePage> createState() => _MelodyHomePageState();
}

class _MelodyHomePageState extends State<MelodyHomePage> {
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
  bool melodiesSame = false;

  List<String> chordMelody = [];
  List<List<String>> chordMelodySolfege = [];
  List<String> writtenChordMelody = [];
  List<List<String>> writtenChordMelodySolfege = [];

  // Add this to your _MelodyHomePageState class:
  IconData comparisonIcon = Icons.help_outline;
  Color comparisonIconColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);
    context.read<GeneralProvider>().loadMappingJSON;
    context.read<GeneralProvider>().loadChordSetsJSON;
    context.read<GeneralProvider>().loadScalesJSON; 
    final nestedMapping = generalProvider.getNestedMapping;
    final noteKeys = generalProvider.getNoteKeys; 
    // Notes grid: group notes by row
    final noteRows = [
      noteKeys.where((n) => n.contains('0')).toList(),
      noteKeys.where((n) => !RegExp(r'\d').hasMatch(n))
          .toList(),
      noteKeys.where((n) => n.contains('1')).toList(),
      noteKeys.where((n) => n.contains('2')).toList(),
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
                  Text(
                    "Generate melody:",
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
                      onPressed: () {
                        //generateMelody(generalProvider);
                        generateChordMelody(generalProvider);
                        setState(() {
                          solfegeText = ""; // Clear solfege area
                          comparisonIcon = Icons.help_outline;
                          comparisonIconColor = Colors.grey;
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
                      onPressed:
                          () => playChordMelody(
                            "Guitar",
                            generalProvider,
                            chordMelodySolfege,
                          ),
                      child: Text("Guitar"),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Play Piano Melody Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Piano",
                            generalProvider,
                            chordMelodySolfege,
                          ),
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
                              () => playChordMelody(
                                "Solfege",
                                generalProvider,
                                chordMelodySolfege,
                              ),
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
                                  writtenChordMelody.add(note);
                                  writtenChordMelodySolfege.add([note]);
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
                    //chordMelodySolfegeToString(writtenChordMelodySolfege),
                    writtenChordMelody.join(' '),
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
                          writtenChordMelody.clear();
                          writtenChordMelodySolfege.clear();
                          melodiesSame = false;
                          comparisonIcon = Icons.help_outline;
                          comparisonIconColor = Colors.grey;
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
                          if (writtenChordMelody.isNotEmpty) {
                            writtenChordMelody.removeLast();
                            writtenChordMelodySolfege.removeLast();
                            melodiesSame = false;
                            comparisonIcon = Icons.help_outline;
                            comparisonIconColor = Colors.grey;
                          }
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
                    child: ElevatedButton.icon(
                      icon: Icon(comparisonIcon, color: comparisonIconColor),
                      label: Text("Compare with generated melody"),
                      onPressed: () {
                        setState(() {
                          // Compare writtenChordMelody with generated melody
                          melodiesSame = listEquals(
                            chordMelody,
                            writtenChordMelody,
                          );
                          if (melodiesSame) {
                            comparisonIcon = Icons.check_circle;
                            comparisonIconColor = Colors.green;
                          } else {
                            comparisonIcon = Icons.cancel;
                            comparisonIconColor = Colors.red;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Play back your melody:",
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
                            writtenChordMelodySolfege,
                          ),
                      child: Text("Guitar"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Piano",
                            generalProvider,
                            writtenChordMelodySolfege,
                          ),
                      child: Text("Piano"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => playChordMelody(
                            "Solfege",
                            generalProvider,
                            writtenChordMelodySolfege,
                          ),
                      child: Text("Solfege"),
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

  void showSolfege() {
    solfegeText = chordMelody.join(' ');
    setState(() {});
  }

  // 1. Add chord buttons below notes section
  Widget buildSelectedChordButtons(GeneralProvider generalProvider) {
    final selectedChords = generalProvider.getSelectedChords();
    final chordMap = generalProvider.getChordMap;
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
                    writtenChordMelody.add(chord);
                    writtenChordMelodySolfege.add(List<String>.from(notes));
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
    final nestedMapping = generalProvider.getNestedMapping;
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

  void generateChordMelody(GeneralProvider generalProvider) {
    final chordMap = generalProvider.getChordMap;
    chordMelody.clear();
    chordMelodySolfege.clear();
    writtenChordMelody.clear();
    writtenChordMelodySolfege.clear();
    melodiesSame = false;

    final numNotes = generalProvider.numberOfNotes;
    final maxDist = generalProvider.maxDistance;
    final allowRepeats = generalProvider.allowRepeatedNotes;
    final startWithDo = generalProvider.startWithDo;
    final endWithDo = generalProvider.endWithDo;
    final startingDo = generalProvider.startingDo;
    final endingDo = generalProvider.endingDo;
    final notes = generalProvider.getSelectedNotes();
    final chordFrequency = generalProvider.chordFrequency;
    final chords = generalProvider.getSelectedChords();
    final allowRepeatedChords = generalProvider.allowRepeatedChords;

    int chordStartOffset = 2;
    if (chordFrequency == "Every 3 notes") {
      chordStartOffset = 1;
    }

    List<String> availableNotes = List<String>.from(notes);
    List<String> availableChords = List<String>.from(chords);

    // Calculate minimums
    int minNumberOfNotes = !allowRepeats ? 2 : 1;
    minNumberOfNotes = chordFrequency == "Every note" ? 0 : minNumberOfNotes;

    int minNumberOfChords = !allowRepeatedChords ? 2 : 1;
    minNumberOfChords = chordFrequency == "Never" ? 0 : minNumberOfChords;

    int effectiveLength =
        numNotes - (startWithDo ? 1 : 0) - (endWithDo ? 1 : 0);
    minNumberOfNotes = min(minNumberOfNotes, effectiveLength);
    minNumberOfChords = min(minNumberOfChords, effectiveLength);

    if (availableNotes.length < minNumberOfNotes ||
        availableChords.length < minNumberOfChords) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Not enough notes or chords selected! Please select at least $minNumberOfNotes notes and $minNumberOfChords chords.",
          ),
        ),
      );
      return;
    }

    Random random = Random();

    for (int i = 1; i <= numNotes; i++) {
      if (i == 1 && startWithDo) {
        chordMelody.add(startingDo);
        chordMelodySolfege.add([startingDo]);
      } else if (i == numNotes && endWithDo) {
        chordMelody.add(endingDo);
        chordMelodySolfege.add([endingDo]);
      } else if (chordFrequency != "Never" &&
          ((i + chordStartOffset) %
                  {
                    "Every 4 notes": 4,
                    "Every 3 notes": 3,
                    "Every 2 notes": 2,
                    "Every note": 1,
                  }[chordFrequency]! ==
              0)) {
        // Add a chord
        String selectedChord;
        if (allowRepeatedChords) {
          selectedChord =
              availableChords[random.nextInt(availableChords.length)];
        } else {
          List<String> unusedChords =
              availableChords
                  .where((chord) => !chordMelody.contains(chord))
                  .toList();
          if (unusedChords.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Not enough unique chords available! Please select more chords.",
                ),
              ),
            );
            return;
          }
          selectedChord = unusedChords[random.nextInt(unusedChords.length)];
        }
        chordMelody.add(selectedChord);
        chordMelodySolfege.add(
          List<String>.from(chordMap[selectedChord] ?? []),
        );
      } else {
        // Add a note
        List<String> candidates = [];
        if (i == 2 && startWithDo) {
          if (allowRepeats) {
            candidates = List<String>.from(availableNotes);
          } else {
            candidates =
                availableNotes.where((note) => note != startingDo).toList();
          }
        } else {
          // third or later note of melody: need to check distance from previous note
          var currentNote = chordMelody.isNotEmpty ? chordMelody.last : null;
          if (currentNote is! String && chordMelody.length >= 2) {
            currentNote = chordMelody[chordMelody.length - 2];
          }
          if (allowRepeats) {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return (availableNotes.indexOf(note) -
                              availableNotes.indexOf(currentNote))
                          .abs() <=
                      maxDist;
                }).toList();
          } else if (i == numNotes - 1 && endWithDo) {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return note != currentNote &&
                      note != endingDo &&
                      (availableNotes.indexOf(note) -
                                  availableNotes.indexOf(currentNote))
                              .abs() <=
                          maxDist;
                }).toList();
          } else {
            candidates =
                availableNotes.where((note) {
                  if (currentNote == null) return true;
                  return note != currentNote &&
                      (availableNotes.indexOf(note) -
                                  availableNotes.indexOf(currentNote))
                              .abs() <=
                          maxDist;
                }).toList();
          }
        }
        if (candidates.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Not enough unique notes available! Please enable repeated notes or select more notes.",
              ),
            ),
          );
          return;
        }
        String nextNote = candidates[random.nextInt(candidates.length)];
        chordMelody.add(nextNote);
        chordMelodySolfege.add([nextNote]);
      }
    }
    setState(() {});
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
String chordMelodySolfegeToString(List<List<String>> data) {
  return data.map((inner) => inner.join('-')).join(' ');
}
