import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';

class ScalesPage extends StatefulWidget {
  const ScalesPage({super.key});
  @override
  State<ScalesPage> createState() => _ScalesPageState();
}

class _ScalesPageState extends State<ScalesPage> {
  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context);
    final scalesMapping = context.watch<GeneralProvider>().getScalesMapping;
    final octavekeys = context.watch<GeneralProvider>().getOctaveKeys;
    final scalekeys = context.watch<GeneralProvider>().getScaleKeys;
    String? selectedOctave =
        generalProvider.selectedOctave; // Default octave selection
    String? selectedScale =
        generalProvider.selectedScale; // Default scale selection
    return Scaffold(
      appBar: AppBar(title: Text('Scales Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                            context
                                .read<GeneralProvider>()
                                .updateSelectedOctave(
                                  octave: selectedOctave ?? '',
                                );
                            if (selectedOctave != null &&
                                selectedScale != null) {
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

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            if (selectedOctave != null &&
                                selectedScale != null) {
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
                ],
              ),
            ),
            // Notes grid
            Expanded(child: _buildNotesGrid(generalProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(GeneralProvider generalProvider) {
    final noteKeys = generalProvider.getNoteKeys;
    final noteColors = generalProvider.getNoteColors;
    final noteColorFactor = generalProvider.getNoteColorFactors;
    final noteSelection = generalProvider.getNoteSelection;
    List<Widget> rows = [];
    for (int row = 0; row < 4; row++) {
      int start = row * 12;
      int end = (row == 3) ? start + 1 : start + 12;
      if (start >= noteKeys.length) break;
      List<Widget> buttons = [];
      for (int i = start; i < end && i < noteKeys.length; i++) {
        final note = noteKeys[i];
        final selected = noteSelection[note] ?? false;
        final String tempColor = noteColors[note].toString();
        final double tempFactor = noteColorFactor[note] ?? 1.0;
        final buttonColor = generalProvider.multiplyHexColor(
          tempColor,
          tempFactor,
        );
        buttons.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //backgroundColor: selected ? buttonColor : Colors.grey,
                  backgroundColor: selected ? buttonColor : Colors.grey,
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
}
