import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'audio/audio_controller.dart';
import 'utils/colors.dart';
import 'utils/chordMelody.dart';

class Singing extends StatefulWidget {
  const Singing({super.key, required this.audioController});
  final AudioController audioController;

  @override
  State<Singing> createState() => _SingingState();
}

class _SingingState extends State<Singing> {
  ChordMelody generatedChordMelody = ChordMelody();
  String solfegeText = "";

  @override
  Widget build(BuildContext context) {
    // Get the nestedMapping from the provider (auto-updates on notifyListeners)
    return Scaffold(
      appBar: AppBar(title: Text('Singing')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_1i"),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(12.0),
                      ),
                      onPressed: () {
                        //generateMelody(generalProvider);
                        newGenerateChordMelody(context.read<GeneralProvider>());
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
                    "Generated melody:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                // Solfege Text Area
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(solfegeText, style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(12.0),
                      ),
                      onPressed: () {
                        playSpoken(
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getChordMelodySolfege(),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Say the solfege",
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
                    "Listen to the first note:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Guitar",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getFirstNoteOrChord(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'First note: Guitar',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Piano",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getFirstNoteOrChord(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'First note: Piano',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Solfege",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getFirstNoteOrChord(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'First note: Solfege',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                // Solfege Text Area
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Now try to sing the melody out loud...",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Listen to the melody:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Guitar",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getChordMelodySolfege(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Guitar',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Piano",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getChordMelodySolfege(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Piano',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        playChordMelody(
                          "Solfege",
                          context.read<GeneralProvider>(),
                          generatedChordMelody.getChordMelodySolfege(),                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          'Solfege',
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
                    "Did you sing it correctly?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ], // Children of Column
          ),
        ),
      ),
    );
  }

  void newGenerateChordMelody(GeneralProvider generalProvider) {
    String result = generatedChordMelody.generateChordMelody(generalProvider);
    if (result.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    solfegeText = generatedChordMelody.getChordMelody().join(' ');
    setState(() {});
  }

  Future<void> playSpoken(
    GeneralProvider generalProvider,
    List<List<String>> melodyList,
  ) async {
    await widget.audioController.refresh();
    final timeBetween = generalProvider.timeBetweenNotes;
    final arpeggiate = generalProvider.arpeggiateChordDelay > 0;
    final arpeggiateDelay = generalProvider.arpeggiateChordDelay;
    final spokenMapping = generalProvider.getSpokenMapping;
    int i = 0;
    for (var notes in melodyList) {
      if (notes.length == 1) {
        final note = notes[0];
        final filename = spokenMapping[note] ?? '';
        if (filename.isNotEmpty) {
          widget.audioController.playSound("assets/audio/$filename");
        }
      } else if (notes.length > 1) {
        if (i % 7 == 0) {
          await widget.audioController.refresh();
        }
        List<String> chordNotes = List<String>.from(notes);
        for (var note in chordNotes) {
          final filename = spokenMapping[note] ?? '';
          if (filename.isNotEmpty) {
            widget.audioController.playSound("assets/audio/$filename");
          }
          if (arpeggiate) {
            await Future.delayed(Duration(milliseconds: arpeggiateDelay));
          }
        }
      }
      await Future.delayed(Duration(milliseconds: timeBetween));
      i++;
    }
  }

  Future<void> playChordMelody(
    String instrument,
    GeneralProvider generalProvider,
    List<List<String>> melodyList,
  ) async {
    await widget.audioController.refresh();
    final key = generalProvider.selectedKey;
    final timeBetween = generalProvider.timeBetweenNotes;
    final truncate = generalProvider.truncateNotes;
    final arpeggiate = generalProvider.arpeggiateChordDelay > 0;
    final arpeggiateDelay = generalProvider.arpeggiateChordDelay;
    final arpeggiateOrder = generalProvider.arpeggiateChordOrder;
    final nestedMapping = generalProvider.getNestedMapping;
    int i = 0;
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
        if (i % 7 == 0) {
          await widget.audioController.refresh();
        }
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
      i++;
    }
  }
}
