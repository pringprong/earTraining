import 'package:flutter/material.dart';
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
                backgroundColor: selected ? buttonColor : borderColor,
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
                    color: noteButtonForegroundColor,
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

Widget buildChordButtons(
  MappingProvider mappingProvider,
  GeneralProvider generalProvider,
) {
  List<Widget> sections = [];
  mappingProvider.getChordsMapping.forEach((category, degreesMap) {
    // Section title
    sections.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          category,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
    degreesMap.forEach((degree, chordSetMap) {
      // Row for each degree
      List<Widget> chordButtons = [];
      chordSetMap.forEach((chordName, notes) {
        final selected = generalProvider.selectedChords[chordName] == true;
        chordButtons.add(
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Tooltip(
              message: notes.join(' '),
              child: GestureDetector(
                onTap: () {
                  generalProvider.toggleSelectedChord(chordName);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? getChordButtonColor2(chordName)
                            : yetAnotherGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      chordName,
                      style: TextStyle(
                        fontSize: 20,
                        color: noteButtonForegroundColor,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
      sections.add(subHeadingRow(degree));
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Wrap(spacing: 4, runSpacing: 4, children: chordButtons),
        ),
      );
    });
  });
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: sections,
  );
}

RegExp pattern = RegExp(r'([IViv7]{1,3})([01]{0,2})_(Rt|Fir|Sec|Thr|All)');

int chordNameSort(String? a, String? b) {
  String propertyA = a ?? "";
  String propertyB = b ?? "";
  final matchA = pattern.firstMatch(propertyA);
  final matchB = pattern.firstMatch(propertyB);
  if (matchA != null && matchB != null) {
    final romanA = matchA.group(1) ?? "";
    final romanB = matchB.group(1) ?? "";
    final numberA = matchA.group(2) ?? "";
    final numberB = matchB.group(2) ?? "";
    final suffixA = matchA.group(3) ?? "";
    final suffixB = matchB.group(3) ?? "";

    const romanOrder = {
      'I': 1,
      'i': 2,
      'I7': 3,
      'II': 4,
      'ii': 5,
      'III': 6,
      'iii': 7,
      'IV': 8,
      'iv': 9,
      'IV7': 10,
      'V': 11,
      'v': 12,
      'V7': 13,
      'VI': 14,
      'vi': 15,
      'VII': 16,
      'vii': 17,
    };

    const numOrder = {'00': 1, '0': 2, '': 3, '1': 4};

    const suffixOrder = {'Rt': 1, 'Fir': 2, 'Sec': 3, 'Thr': 4, 'All': 5};

    int romanComparison = (romanOrder[romanA] ?? 0).compareTo(
      romanOrder[romanB] ?? 0,
    );
    if (romanComparison != 0) return romanComparison;

    int numberComparison = (numOrder[numberA] ?? 0).compareTo(
      (numOrder[numberB] ?? 0),
    );
    if (numberComparison != 0) return numberComparison;

    return (suffixOrder[suffixA] ?? 0).compareTo(suffixOrder[suffixB] ?? 0);
  }
  int comparison = propertyA.compareTo(propertyB);
  if (comparison < 0) {
    return -1;
  } else if (comparison > 0) {
    return 1;
  } else {
    return 0;
  }
}
