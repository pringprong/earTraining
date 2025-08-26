import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'utils/colors.dart';

class ScalesPage extends StatefulWidget {
  const ScalesPage({super.key});
  @override
  State<ScalesPage> createState() => _ScalesPageState();
}

class _ScalesPageState extends State<ScalesPage> {
  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<MelodyIDSettings>(context);
    final scalesMapping = context.watch<MappingProvider>().getScalesMapping;
    final octavekeys = context.watch<MappingProvider>().getOctaveKeys;
    final scalekeys = context.watch<MappingProvider>().getScaleKeys;
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
                        value: context.watch<MelodyIDSettings>().selectedOctave,
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
                                .read<MelodyIDSettings>()
                                .updateSelectedOctave(
                                  octave: selectedOctave ?? '',
                                );
                            if (selectedOctave != null &&
                                selectedScale != null) {
                              final notes =
                                  scalesMapping[selectedOctave!]![selectedScale!] ??
                                  [];
                              generalProvider.setNoteSelection(
                                selectedKeys: notes,
                              );
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
                        value: context.watch<MelodyIDSettings>().selectedScale,
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
                            context.read<MelodyIDSettings>().updateSelectedScale(
                              newscale: selectedScale ?? '',
                            );
                            if (selectedOctave != null &&
                                selectedScale != null) {
                              final notes =
                                  scalesMapping[selectedOctave!]![selectedScale!] ??
                                  [];
                              generalProvider.setNoteSelection(
                                selectedKeys: notes,
                              );
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
            Expanded(child: _buildNotesGrid(context.read<MelodyIDSettings>(), 
              context.read<MappingProvider>())),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(GeneralProvider generalProvider,
    MappingProvider mappingProvider) {
    final noteKeys = mappingProvider.getNoteKeys;
    final noteColors = mappingProvider.getNoteColors;
    final noteColorFactor = mappingProvider.getNoteColorFactors;
    final noteSelection = generalProvider.getNoteSelection;
    //print(noteSelection);
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
        final buttonColor = multiplyHexColor(
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
                  generalProvider.toggleNoteSelection(key: note);
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
