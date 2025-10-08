import 'package:flutter/material.dart';
import 'package:melody_ear_trainer/main.dart';
import '../providers/general_provider.dart';
import '../providers/mapping_provider.dart';
import 'colors.dart';
import 'dart:collection';
import 'package:objectbox/objectbox.dart';
import '../objectbox.g.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';

SizedBox verticalSpacer() {
  return SizedBox(height: 8);
}

SizedBox horizontalSpacer() {
  return SizedBox(width: 8);
}

Row headingRow(String myText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(
          children: [
            Text(
              myText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ],
        ),
      ),
    ],
  );
}

Row TextRow(String myText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(
          children: [
            Text(
              myText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
      ),
    ],
  );
}

Row subHeadingRow(String myText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(
          children: [
            Text(
              myText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    ],
  );
}

Row plainText(String myText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(children: [Text(myText, style: TextStyle(fontSize: 16))]),
      ),
    ],
  );
}

String chordMelodySolfegeToString(List<List<String>> data) {
  return data.map((inner) => inner.join('-')).join(' ');
}

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
  bool tapToSelect, [
  String octave = "All octaves",
  String scaleSet = "Chromatic",
  int numNotesInOctave = 12,
  Set<String> newNotes = const {},
  bool optional = false,
  bool reversedColors = false,
]) {
  if (optional &&
      (generalProvider.getSelectedNotes().isEmpty ||
          generalProvider.chordFrequency == "Every note")) {
    return SizedBox.shrink();
  }
  final noteKeys =
      mappingProvider.getScalesMapping[octave]![scaleSet] ??
      mappingProvider.getNoteKeys;
  final noteColors = mappingProvider.getNoteColors;
  final noteColorFactor = mappingProvider.getNoteColorFactors;
  final noteSelection = generalProvider.getSelectedNotes();
  List<Widget> rows = [];

  void onPressedFunction(GeneralProvider gp, String note) {
    if (tapToSelect) {
      return generalProvider.toggleNoteSelection(key: note);
    }
    return;
  }

  for (int row = 0; row < 4; row++) {
    int start = row * numNotesInOctave;
    int end = (row == 3) ? start + 1 : start + numNotesInOctave;
    if (start >= noteKeys.length) break;
    List<Widget> buttons = [];
    for (int i = start; i < end && i < noteKeys.length; i++) {
      final note = noteKeys[i];
      final selected = noteSelection.contains(note);
      final String tempColor = noteColors[note].toString();
      final double tempFactor = noteColorFactor[note] ?? 1.0;
      Color buttonColor = multiplyHexColor(tempColor, tempFactor);
      Color borderColor = buttonColor;
      Color foregroundColor =
          colorMap["noteButtonForegroundColor"] ?? Colors.white;
      Color selectedForegroundColor = foregroundColor;
      Color unSelectedBackgroundColor = colorMap["borderColor"] ?? Colors.white;
      Color unSelectedBorderColor = unSelectedBackgroundColor;
      if (newNotes.contains(note)) {
        selectedForegroundColor =
            colorMap["newNoteButtonForegroundColor"] ?? Colors.white;
      }
      if (reversedColors) {
        foregroundColor = colorMap["borderColor"] ?? Colors.white;
        selectedForegroundColor =
            colorMap["noteButtonForegroundColor"] ?? Colors.white;
        if (newNotes.contains(note)) {
          selectedForegroundColor = buttonColor;
        }
        buttonColor = colorMap["buttonForegroundColor"] ?? Colors.white;
        unSelectedBackgroundColor =
            colorMap["buttonForegroundColor"] ?? Colors.white;
        unSelectedBorderColor = colorMap["borderColor"] ?? Colors.white;
      }
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selected ? buttonColor : unSelectedBackgroundColor,
                //minimumSize: Size(40, 40),
                padding: EdgeInsets.zero,
                // textStyle: TextStyle(
                //   fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                // ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: selected ? borderColor : unSelectedBorderColor,
                    width: 2.0,
                  ),
                ),
              ),
              onPressed: () {
                onPressedFunction(generalProvider, note);
              },
              child: FittedBox(
                fit: BoxFit.fill,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? selectedForegroundColor : foregroundColor,
                    ),
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
  GeneralProvider generalProvider,
  MappingProvider mappingProvider,
  bool tapToSelect,
) {
  List<Widget> sections = [];
  void onPressedFunction(GeneralProvider gp, String chordName) {
    if (tapToSelect) {
      return gp.toggleSelectedChord(chordName);
    }
    return;
  }

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
                  onPressedFunction(generalProvider, chordName);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? getChordButtonColor2(chordName)
                            : colorMap["yetAnotherGrey"] ?? Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      chordName,
                      style: TextStyle(
                        fontSize: 20,
                        color:
                            colorMap["noteButtonForegroundColor"] ??
                            Colors.white,
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

Widget buildSelectedChordButtonsHelper(
  GeneralProvider generalProvider,
  MappingProvider mappingProvider, {
  bool optional = false,
}) {
  if (optional &&
      (generalProvider.getSelectedNotes().isEmpty ||
          generalProvider.chordFrequency == "Every note")) {
    return SizedBox.shrink();
  }

  final selectedChords = generalProvider.getSelectedChords();
  selectedChords.sort((a, b) => chordNameSort(a, b));
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  chord,
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        colorMap["noteButtonForegroundColor"] ?? Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
  );
}

Widget campaignHeader(CampaignInfo campArgs) {
  return Row(
    children: [
      Expanded(
        child: (Card(
          color: colorMap["buttonForegroundColor"] ?? Colors.white,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: getCampaignColor(campArgs.CampaignID),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Wrap(
                children: [
                  Text(
                    campArgs.CampaignName,
                    style: TextStyle(
                      fontSize: 16,
                      color: getCampaignColor(campArgs.CampaignID),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    ],
  );
}

Widget missionHeader(
  MappingProvider mappingProvider,
  MissionInfo missionInfo, {
  bool max = false,
}) {
  return Row(
    children: [
      Expanded(
        child: (Card(
          color: colorMap["buttonForegroundColor"] ?? Colors.white,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: getModeColor(missionInfo.MissionMode),
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Wrap(
                children: [
                  Column(
                    children: [
                      Text(
                        "Mission: " + missionInfo.MissionName,
                        style: TextStyle(
                          fontSize: 18,
                          color: getModeColor(missionInfo.MissionMode),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (max)
                        Text(
                          missionInfo.MissionMode,
                          style: TextStyle(
                            fontSize: 14,
                            color: getModeColor(missionInfo.MissionMode),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (max) verticalSpacer(),
                      if (max)
                        missionStatusBanner(mappingProvider, missionInfo),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    ],
  );
}

Widget missionStatusBanner(
  MappingProvider mappingProvider,
  MissionInfo missionInfo,
) {
  //String mls = getDeepMissionStatus(mappingProvider, missionInfo.MissionID);
  String mls = objectBox.getSavedMissionStatus(missionInfo.MissionID);
  return Row(
    children: [
      Expanded(
        child: (Card(
          color: colorMap["buttonForegroundColor"] ?? Colors.white,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: missionLevelStatusColor(mls), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Wrap(
                children: [
                  Column(
                    children: [
                      Text(
                        "Status: " + mls,
                        style: TextStyle(
                          fontSize: 18,
                          color: missionLevelStatusColor(mls),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    ],
  );
}

String getDeepMissionStatus(MappingProvider mappingProvider, String missionID) {
  final levels = mappingProvider.getLevelsForMission(missionID);
  LevelInfo lastLevel = levels.last;
  String statusOfLastLevel = objectBox.levelStatus(
    lastLevel.LevelID,
    lastLevel.PassingScore,
    lastLevel.NumTests,
  );
  String thisMissionStatus = statusOfLastLevel;
  if (statusOfLastLevel == "Not started yet") {
    // the last level is not started, so the mission is definitey not passed
    // check all the other levels to see whether any of them are started yet
    // if any are started or passed, then the mission is in progress
    // none of them are started or passed, then the mission is Not Started
    for (var level in levels) {
      String currentLevelStatus = objectBox.levelStatus(
        level.LevelID,
        level.PassingScore,
        level.NumTests,
      );
      if (currentLevelStatus == "In progress" ||
          currentLevelStatus == "Passed!") {
        return "In progress";
      }
    }
  }
  // if the last level is passed or in progress then the whole mission is automatically the same
  return thisMissionStatus;
}

String getLevelStatus(int numPassedTests, LevelInfo levelInfo) {
  return numPassedTests >= levelInfo.NumTests
      ? "Passed!"
      : numPassedTests > 0
      ? "In progress"
      : "Not started yet";
}

String getLevelStatusWithQuery(LevelInfo levelInfo) {
  int numPassedTests = objectBox.numPassedTestsForLevel(
    levelInfo.LevelID,
    levelInfo.PassingScore,
  );
  return getLevelStatus(numPassedTests, levelInfo);
}

Widget levelHeader(LevelInfo levelInfo) {
  int numPassedTests = objectBox.numPassedTestsForLevel(
    levelInfo.LevelID,
    levelInfo.PassingScore,
  );
  String levelStatus = getLevelStatus(numPassedTests, levelInfo);
  return Row(
    children: [
      Expanded(
        child: (
          Card(
          color: colorMap["buttonForegroundColor"] ?? Colors.white,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: missionLevelStatusColor(levelStatus),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Wrap(
                children: [
                  Text(
                    "Level " + levelInfo.LevelName,
                    style: TextStyle(
                      fontSize: 20,
                      color: missionLevelStatusColor(levelStatus),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  horizontalSpacer(),
                  horizontalSpacer(),
                  Column(
                    children: [
                      SizedBox(height: 4),
                      CircularPercentIndicator(
                        radius: 10,
                        lineWidth: 10,
                        percent:
                            min(numPassedTests, levelInfo.NumTests) /
                            levelInfo.NumTests,
                        progressColor:
                            colorMap['correctGuessIconColor'] ?? Colors.white,
                        backgroundColor:
                            colorMap["waitingForGuessIconColor"] ??
                            Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    ],
  );
}

void resetMissionBeforeMissionPage(
  GeneralProvider generalProvider,
  MappingProvider mappingProvider,
  MissionInfo missionInfo,
) {
  MissionSavedSettings? mss = objectBox.getMissionSavedSettingsByMissionID(
    missionInfo.MissionID,
  );
  if (mss != null) {
    generalProvider.setKeyAndInstrument(mss.key, mss.instrument);
  }
  final lastLevel =
      mappingProvider.getLevelsForMission(missionInfo.MissionID).last;
  generalProvider.setNoteSelection(selectedKeys: lastLevel.Notes);
}

const Map<String, String> campaignTreeShapes = {
  "Melody ID": "rectangle",
  "Melody singing": "houseshape",
  "Chord ID": "hexagon",
  "Chord singing": "trapezoid",
  "Chord melody ID": "octagon",
  "Chord melody singing": "diamond",
  "Bonus": "starshape",
  "": "circle",
};

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

class CampaignInfo {
  final String CampaignID;
  final String CampaignName;
  final String CampaignFilename;
  final String CampaignOctave;
  final String CampaignSet;
  final int CampaignNotesInOctave;
  final MissionIDs = LinkedHashSet<String>();

  CampaignInfo(
    this.CampaignID,
    this.CampaignName,
    this.CampaignFilename,
    this.CampaignOctave,
    this.CampaignSet,
    this.CampaignNotesInOctave,
  );

  void addMissionID(String newMissionID) {
    MissionIDs.add(newMissionID);
  }
}

class MissionInfo {
  final String CampaignID;
  final String MissionID;
  final String MissionName;
  final String MissionMode;
  List<String> MissionUnlockedBy = [];
  final String MissionUnlockedByRelationship;
  Set<String> MissionNewNotes = {};
  final LevelIDs = LinkedHashSet<String>();

  MissionInfo(
    this.CampaignID,
    this.MissionID,
    this.MissionName,
    this.MissionMode,
    this.MissionUnlockedByRelationship,
  );

  setMissionUnlockedBy(List<String> unlockedby) {
    MissionUnlockedBy = unlockedby;
  }

  List<String> getMissionUnlockedBy() {
    return MissionUnlockedBy;
  }

  String getMissionUnlockedByRelationship() {
    return MissionUnlockedByRelationship;
  }

  addMissionNewNotes(List<String> noteList) {
    MissionNewNotes.addAll(noteList);
  }

  void addLevelID(String levelid) {
    LevelIDs.add(levelid);
  }

  LinkedHashSet<String> getLevelIDs() {
    return LevelIDs;
  }

  List<String> getLevelIDsList() {
    return LevelIDs.toList();
  }
}

class LevelInfo {
  final String CampaignID;
  final String MissionID;
  final String LevelID;
  final String LevelName;
  List<String> Notes = [];
  Set<String> NewNotes = {};
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
    this.MissionID,
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

  addNewNotes(List<String> noteList) {
    NewNotes.addAll(noteList);
  }
}

@Entity()
class LevelTestResults {
  int id;
  final String CampaignID;
  final String MissionID;
  final String LevelID;
  final int score;
  final String timestamp;

  LevelTestResults({
    this.id = 0,
    required this.CampaignID,
    required this.MissionID,
    required this.LevelID,
    required this.score,
    required this.timestamp,
  });
}

@Entity()
class MissionSavedSettings {
  int id;
  final String MissionID;
  String key;
  String instrument;
  //  bool passedMission;
  String status;
  // enum did not work for this
  // so we set the String to one of 3 values:
  // "Not started yet"
  // "In progress"
  // "Passed!"

  MissionSavedSettings({
    this.id = 0,
    required this.MissionID,
    required this.key,
    required this.instrument,
    //   this.passedMission = false,
    this.status = "Not started yet",
  });
}
