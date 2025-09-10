import 'package:flutter/material.dart';
import '../audio/audio_controller.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';

abstract class MelodyPageAbstract extends StatefulWidget {
  const MelodyPageAbstract({super.key, required this.audioController});
  final AudioController audioController;
}

abstract class MelodyPageAbstractState extends State<MelodyPageAbstract> {
  String solfegeText = "";
  bool melodiesSame = false;
  ChordMelody generatedChordMelody = ChordMelody();
  ChordMelody userWrittenChordMelody = ChordMelody();

  IconData comparisonIcon = waitingForGuessIcon;
  Color comparisonIconColor = waitingForGuessIconColor;
  Color comparisonColor = waitingForGuessButtonColor;

  void setToWaitingForGuess() {
    setState(() {
      comparisonIcon = waitingForGuessIcon;
      comparisonIconColor = waitingForGuessIconColor;
      comparisonColor = waitingForGuessButtonColor;
    });
  }

  void setToCorrectGuess() {
    setState(() {
      comparisonIcon = correctGuessIcon;
      comparisonIconColor = correctGuessIconColor;
      comparisonColor = correctGuessButtonColor;
    });
  }

  void setToIncorrectGuess() {
    setState(() {
      comparisonIcon = incorrectGuessIcon;
      comparisonIconColor = incorrectGuessIconColor;
      comparisonColor = incorrectGuessButtonColor;
    });
  }

  Row generateMelodyButton(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c2f3,
              foregroundColor: buttonForegroundColor,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              newGenerateChordMelody(
                generalProvider,
                mappingProvider,
                setSolfegeText,
              );
              setState(() {
                //solfegeText = ""; // Clear solfege area
                setToWaitingForGuess();
              });
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Generate melody", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Row playMelodyButtons(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool includeSolfege,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c3f4,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed:
                () => generatedChordMelody.playChordMelody(
                  "Guitar",
                  generalProvider,
                  mappingProvider,
                  widget,
                ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Guitar", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        // Play Piano Melody Button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c5f4,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed:
                () => generatedChordMelody.playChordMelody(
                  "Piano",
                  generalProvider,
                  mappingProvider,
                  widget,
                ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Piano", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        if (includeSolfege) ...[
          horizontalSpacer(),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: c1f4,
                foregroundColor: buttonForegroundColor,
              ),
              onPressed:
                  () => generatedChordMelody.playChordMelody(
                    "Solfege",
                    generalProvider,
                    mappingProvider,
                    widget,
                  ),
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text("Solfege", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Row playFirstNoteButtons(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c3f1,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed: () {
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                "Guitar",
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Guitar", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        // Play Piano Melody Button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c5f1,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed: () {
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                "Piano",
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Piano", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c1f1,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed: () {
              ChordMelody fn = ChordMelody.singleChord(
                generatedChordMelody.getFirstNoteOrChord_Melody(),
                generatedChordMelody.getFirstNoteOrChord_Solfege(),
              );
              fn.playChordMelody(
                "Solfege",
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Solfege", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  ExpansionTile solfegeExpansionTile(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    return ExpansionTile(
      title: Text(
        "Solfege for generated melody",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: false,
      children: [
        // Show Solfege Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c1f4,
                  foregroundColor: buttonForegroundColor,
                ),
                onPressed: () {
                  solfegeText = generatedChordMelody.getChordMelody().join(' ');
                  setState(() {});
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text("Show", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            horizontalSpacer(),
            // Play Solfege Melody Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c1f3,
                  foregroundColor: buttonForegroundColor,
                ),
                onPressed:
                    () => generatedChordMelody.playSpoken(
                      generalProvider,
                      mappingProvider,
                      widget,
                    ),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text("Say", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            horizontalSpacer(),
            // Play Solfege Melody Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c1f2,
                  foregroundColor: buttonForegroundColor,
                ),
                onPressed:
                    () => generatedChordMelody.playChordMelody(
                      "Solfege",
                      generalProvider,
                      mappingProvider,
                      widget,
                    ),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text("Listen", style: TextStyle(fontSize: 20)),
                ),
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
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(solfegeText, style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Row solfegeTextArea() {
    return Row(
      // Solfege Text Area
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(solfegeText, style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Row sayTheSolfegeButton(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c1f3,
              foregroundColor: buttonForegroundColor,
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              generatedChordMelody.playSpoken(
                generalProvider,
                mappingProvider,
                widget,
              );
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Say the solfege", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Padding userWrittenSolfegeArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          userWrittenChordMelody.getChordMelody().join(' '),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Row clearAndBackspaceButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: clearButtonColor,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed: () {
              setState(() {
                userWrittenChordMelody.clear();
                melodiesSame = false;
                setToWaitingForGuess();
              });
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Clear", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: yetAnotherGrey,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed: () {
              setState(() {
                if (userWrittenChordMelody.getChordMelody().isNotEmpty) {
                  userWrittenChordMelody.removeLastNote();
                  melodiesSame = false;
                  setToWaitingForGuess();
                }
              });
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Backspace", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Row compareButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(comparisonIcon, color: comparisonIconColor),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(comparisonColor),
              foregroundColor: WidgetStateProperty.all<Color>(
                buttonForegroundColor,
              ),
            ),
            label: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "Compare with generated melody",
                style: TextStyle(fontSize: 20),
              ),
            ),
            onPressed: () {
              setState(() {
                // Compare writtenChordMelody with generated melody
                melodiesSame = generatedChordMelody.sameAs(
                  userWrittenChordMelody,
                );
                if (melodiesSame) {
                  setToCorrectGuess();
                } else {
                  setToIncorrectGuess();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Row userWrittenMelodyButtons(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c3f3,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed:
                () => userWrittenChordMelody.playChordMelody(
                  "Guitar",
                  generalProvider,
                  mappingProvider,
                  widget,
                ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Guitar", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c5f3,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed:
                () => userWrittenChordMelody.playChordMelody(
                  "Piano",
                  generalProvider,
                  mappingProvider,
                  widget,
                ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Piano", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
        horizontalSpacer(),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c1f3,
              foregroundColor: buttonForegroundColor,
            ),
            onPressed:
                () => userWrittenChordMelody.playChordMelody(
                  "Solfege",
                  generalProvider,
                  mappingProvider,
                  widget,
                ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("Solfege", style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNoteButtons(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    final nestedMapping = mappingProvider.getNestedMapping;
    final noteKeys = mappingProvider.getNoteKeys;
    // Notes grid: group notes by row
    final noteRows = [
      noteKeys.where((n) => n.contains('0')).toList(),
      noteKeys.where((n) => !RegExp(r'\d').hasMatch(n)).toList(),
      noteKeys.where((n) => n.contains('1')).toList(),
      noteKeys.where((n) => n.contains('2')).toList(),
    ];
    final selectedNotes = generalProvider.getSelectedNotes();
    final noteColors = mappingProvider.getNoteColors;
    final noteColorFactor = mappingProvider.getNoteColorFactors;

    return Column(
      children: [
        for (int rowIdx = 0; rowIdx < noteRows.length; rowIdx++)
          Builder(
            builder: (context) {
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
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: multiplyHexColor(
                                noteColors[note].toString(),
                                noteColorFactor[note] ?? 1.0,
                              ),
                              foregroundColor: noteButtonForegroundColor,
                              padding: const EdgeInsets.all(0.0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () async {
                              final key = generalProvider.getSelectedKey;
                              final instrument =
                                  generalProvider.getSelectedInstrument;
                              final filename =
                                  nestedMapping[key]?[instrument]?[note] ?? '';
                              setToWaitingForGuess();
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
                                userWrittenChordMelody.addNote(note);
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
            },
          ),
      ],
    );
  }

  void newGenerateChordMelody(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
    bool setSolfegeText,
  ) {
    userWrittenChordMelody.clear();
    melodiesSame = false;

    String result = generatedChordMelody.generateChordMelody(
      generalProvider,
      mappingProvider,
    );
    if (result.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    if (setSolfegeText) {
      solfegeText = generatedChordMelody.getChordMelody().join(' ');
    } else {
      solfegeText = "";
    }
    setState(() {});
  }

  Row instructionRow(String myText) {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          color: c6f3,
          width: double.infinity,
          padding: EdgeInsets.all(12),
          child: Text(
            myText,
            style: TextStyle(fontSize: 22, color: buttonForegroundColor),
          ),
        ),
      ],
    );
  }

  Widget buildSelectedChordButtons(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
  ) {
    final selectedChords = generalProvider.getSelectedChords();
    final chordFrequency = generalProvider.chordFrequency;
    final chordMap = mappingProvider.getChordMap;
    if (chordFrequency == "Never") {
      return Padding(padding: const EdgeInsets.all(0.0));
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children:
          selectedChords.map((chord) {
            final color = getChordButtonColor2(chord);
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
                    userWrittenChordMelody.addChord(chord, notes);
                    setToWaitingForGuess();
                    ChordMelody cm = ChordMelody.singleChord(chord, notes);
                    cm.playChordMelody(
                      generalProvider.getSelectedInstrument,
                      generalProvider,
                      mappingProvider,
                      widget,
                    );
                  });
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    chord,
                    style: TextStyle(
                      fontSize: 20,
                      color: noteButtonForegroundColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
