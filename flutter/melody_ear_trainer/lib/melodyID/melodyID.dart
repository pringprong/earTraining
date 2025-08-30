import 'package:flutter/material.dart';
import '../audio/audio_controller.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/chordMelody.dart';

class MelodyID extends StatefulWidget {
  const MelodyID({super.key, required this.audioController});
  final AudioController audioController;
  @override
  State<MelodyID> createState() => _MelodyIDState();
}

class _MelodyIDState extends State<MelodyID> {
  String selectedKey = "";
  String selectedInstrument = "";
  int numberOfNotes = 5;
  bool allowRepeatedNotes = false;
  bool startWithDo = true;
  bool endWithDo = true;

  List<String> melody = [];
  String solfegeText = "";

  // --- Write Melody Section ---
  bool melodiesSame = false;
  ChordMelody generatedChordMelody = ChordMelody();
  ChordMelody userWrittenChordMelody = ChordMelody();

  // Add this to your _MelodyIDState class:
  IconData comparisonIcon = Icons.help_outline;
  Color comparisonIconColor = Colors.grey;
  Color comparisonColor = Colors.grey.shade300;
  Color foregroundColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final mappingProvider = Provider.of<MappingProvider>(context);
    final nestedMapping = mappingProvider.getNestedMapping;
    final noteKeys = mappingProvider.getNoteKeys;
    // Notes grid: group notes by row
    final noteRows = [
      noteKeys.where((n) => n.contains('0')).toList(),
      noteKeys.where((n) => !RegExp(r'\d').hasMatch(n)).toList(),
      noteKeys.where((n) => n.contains('1')).toList(),
      noteKeys.where((n) => n.contains('2')).toList(),
    ];
    final selectedNotes = context.read<MelodyIDSettings>().getSelectedNotes();
    final noteColors = mappingProvider.getNoteColors;
    final noteColorFactor = mappingProvider.getNoteColorFactors;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Melody ID')),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text('Difficulty'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/melodyIDsettings');
                },
              ),
              ListTile(
                title: Text('Hands-free melody ID'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/melodyIDhandsfree');
                },
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  // Update the state of the app
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pop(context);
                  //Navigator.pushNamed(context, '/handsfree');
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
                        newGenerateChordMelody(
                          context.read<MelodyIDSettings>(),
                          mappingProvider,
                        );
                        setState(() {
                          solfegeText = ""; // Clear solfege area
                          comparisonIcon = Icons.help_outline;
                          comparisonIconColor = Colors.grey;
                          comparisonColor = Colors.grey.shade300;
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
                    "Listen to generated melody:",
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed:
                          () => generatedChordMelody.playChordMelody(
                            "Guitar",
                            context.read<MelodyIDSettings>(),
                            mappingProvider,
                            widget,
                          ),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Guitar", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Play Piano Melody Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed:
                          () => generatedChordMelody.playChordMelody(
                            "Piano",
                            context.read<MelodyIDSettings>(),
                            mappingProvider,
                            widget,
                          ),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Piano", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ExpansionTile(
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
                            backgroundColor: getChordButtonColor("blah_H_R"),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            solfegeText = generatedChordMelody
                                .getChordMelody()
                                .join(' ');
                            setState(() {});
                          },
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text("Show", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      // Play Solfege Melody Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getChordButtonColor("blah_M_R"),
                            foregroundColor: Colors.black,
                          ),
                          onPressed:
                              () => generatedChordMelody.playSpoken(
                                context.read<MelodyIDSettings>(),
                                mappingProvider,
                                widget,
                              ),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text("Say", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      // Play Solfege Melody Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getChordButtonColor("blah_L_R"),
                            foregroundColor: Colors.black,
                          ),
                          onPressed:
                              () => generatedChordMelody.playChordMelody(
                                "Solfege",
                                context.read<MelodyIDSettings>(),
                                mappingProvider,
                                widget,
                              ),
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              "Listen",
                              style: TextStyle(fontSize: 20),
                            ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: multiplyHexColor(
                                  noteColors[note].toString(),
                                  noteColorFactor[note] ?? 1.0,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(0.0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () async {
                                final key =
                                    context
                                        .read<MelodyIDSettings>()
                                        .getSelectedKey;
                                final instrument =
                                    context
                                        .read<MelodyIDSettings>()
                                        .getSelectedInstrument;
                                final filename =
                                    nestedMapping[key]?[instrument]?[note] ??
                                    '';
                                comparisonIcon = Icons.help_outline;
                                comparisonIconColor = Colors.grey;
                                comparisonColor = Colors.grey.shade300;
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
              }),
              SizedBox(height: 8),
              // Chord buttons section
              // buildSelectedChordButtons(
              //   context.read<MelodyIDSettings>(),
              //   mappingProvider,
              // ),
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
                    userWrittenChordMelody.getChordMelody().join(' '),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 176, 204, 231),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          userWrittenChordMelody.clear();
                          melodiesSame = false;
                          comparisonIcon = Icons.help_outline;
                          comparisonIconColor = Colors.grey;
                          comparisonColor = Colors.grey.shade400;
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Clear", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 181, 196, 212),
                        foregroundColor: Colors.black,
                      ),

                      onPressed: () {
                        setState(() {
                          if (userWrittenChordMelody
                              .getChordMelody()
                              .isNotEmpty) {
                            userWrittenChordMelody.removeLastNote();
                            melodiesSame = false;
                            comparisonIcon = Icons.help_outline;
                            comparisonIconColor = Colors.grey;
                            comparisonColor = Colors.grey.shade300;
                          }
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Backspace",
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
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(comparisonIcon, color: comparisonIconColor),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          comparisonColor,
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          foregroundColor,
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
                            comparisonIcon = Icons.check_circle;
                            comparisonIconColor = Colors.green;
                            comparisonColor = const Color.fromARGB(
                              255,
                              191,
                              220,
                              158,
                            );
                          } else {
                            comparisonIcon = Icons.cancel;
                            comparisonIconColor = Colors.red;
                            comparisonColor = const Color.fromARGB(
                              255,
                              254,
                              192,
                              192,
                            );
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
                    "Listen to your melody:",
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_2i"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed:
                          () => userWrittenChordMelody.playChordMelody(
                            "Guitar",
                            context.read<MelodyIDSettings>(),
                            mappingProvider,
                            widget,
                          ),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Guitar", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_All"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed:
                          () => userWrittenChordMelody.playChordMelody(
                            "Piano",
                            context.read<MelodyIDSettings>(),
                            mappingProvider,
                            widget,
                          ),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text("Piano", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getChordButtonColor("blah_M_R"),
                        foregroundColor: Colors.black,
                      ),
                      onPressed:
                          () => userWrittenChordMelody.playChordMelody(
                            "Solfege",
                            context.read<MelodyIDSettings>(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void newGenerateChordMelody(
    GeneralProvider generalProvider,
    MappingProvider mappingProvider,
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
    setState(() {});
  }
}
