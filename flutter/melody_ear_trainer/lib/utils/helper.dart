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

RegExp chordNameParse = RegExp(
  r'([IVivd7]{1,4})([01]{0,2})_(Rt|Fir|Sec|Thr|All)',
);

const romanOrder = {
  'I': 100,
  'i': 200,
  'I7': 300,
  'II': 400,
  'ii': 500,
  'iid': 550,
  'III': 600,
  'iii': 700,
  'IV': 800,
  'iv': 900,
  'IV7': 1000,
  'V': 1100,
  'v': 1200,
  'V7': 1300,
  'VI': 1400,
  'vi': 1500,
  'VII': 1600,
  'vii': 1700,
  'viid': 1800,
};

const numOrder = {'00': 100, '0': 200, '': 300, '1': 400};

const suffixOrder = {'Rt': 100, 'Fir': 200, 'Sec': 300, 'Thr': 400, 'All': 500};

int chordNameSort(String? a, String? b) {
  final matchA = chordNameParse.firstMatch(a ?? "");
  final matchB = chordNameParse.firstMatch(b ?? "");

  if (matchA != null && matchB != null) {
    final romanA = matchA.group(1) ?? "";
    final romanB = matchB.group(1) ?? "";
    final numberA = matchA.group(2) ?? "";
    final numberB = matchB.group(2) ?? "";
    final suffixA = matchA.group(3) ?? "";
    final suffixB = matchB.group(3) ?? "";

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
  return 0;
}

class CampaignArguments {
  final String CampaignID;
  final String CampaignName;
  final String CampaignFilename;

  CampaignArguments(this.CampaignID, this.CampaignName, this.CampaignFilename);
}

class MissionInfo {
  final String CampaignID;
  final String CampaignName;
  final String MissionID;
  final String MissionName;
  final String MissionMode;
  Map<String, LevelInfo> levels = {};

  MissionInfo(
    this.CampaignID,
    this.CampaignName,
    this.MissionID,
    this.MissionName,
    this.MissionMode,
  );

  void addLevel(String levelid, LevelInfo level) {
    if (levels.isNotEmpty && !levels.containsKey(levelid)) {
      levels[levelid] = level;
    }
  }

  LevelInfo getLevel(String levelID) {
    return levels[levelID]!;
  }
}

class LevelInfo {
  final String CampaignID;
  final String CampaignName;
  final String MissionID;
  final String MissionName;
  final String MissionMode;
  final String LevelID;
  final String LevelName;
  List<String> Notes = [];
  final int NumNotes;
  final int MaxDistance;
  final bool AllowRepeatedNotes;
  final String PlaybackSpeed;
  final bool StartWithDo;
  final bool EndWithDo;
  final String StartingDo;
  final String EndingDo;
  final String ChordFrequency;
  final int NumTests;
  final int NumQuestions;
  final int PassingScore;
  //GeneralProvider? settings;

  LevelInfo(
    this.CampaignID,
    this.CampaignName,
    this.MissionID,
    this.MissionName,
    this.MissionMode,
    this.LevelID,
    this.LevelName,
    this.NumNotes,
    this.MaxDistance,
    this.AllowRepeatedNotes,
    this.PlaybackSpeed,
    this.StartWithDo,
    this.EndWithDo,
    this.StartingDo,
    this.EndingDo,
    this.ChordFrequency,
    this.NumTests,
    this.NumQuestions,
    this.PassingScore,
  );

  setNotes(List<String> noteList) {
    Notes = noteList;
  }
}

class LevelTestResults {
  final String CampaignID;
  final String MissionID;
  final String LevelID;
  final int score;
  final String timestamp;

  LevelTestResults(
    this.CampaignID,
    this.MissionID,
    this.LevelID,
    this.score,
    this.timestamp,
  );
}
