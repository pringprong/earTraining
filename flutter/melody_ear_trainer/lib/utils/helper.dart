import 'package:flutter/material.dart';
//import 'chordMelody.dart';
//import 'package:provider/provider.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'colors.dart';

// Add this utility function to your file (e.g., below the listEquals function or anywhere in your class/file):
String chordMelodySolfegeToString(List<List<String>> data) {
  return data.map((inner) => inner.join('-')).join(' ');
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

Widget buildNotesGrid(
  GeneralProvider generalProvider,
  MappingProvider mappingProvider,
) {
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
      final buttonColor = multiplyHexColor(tempColor, tempFactor);
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
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
