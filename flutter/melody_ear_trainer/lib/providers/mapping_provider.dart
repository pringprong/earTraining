import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/helper.dart';
import 'dart:collection';

class MappingProvider extends ChangeNotifier {
  MappingProvider() {
    loadMappingJSON;
    loadSpokenJSON;
    loadChordSetsJSON;
    loadScalesJSON;
    loadNotesJSON;
    loadMissionsJSON;
  }

  // These are from Mapping.json
  List<String> mappingKeys = [];
  List<String> instruments = [];
  Map<String, Map<String, Map<String, String>>> nestedMapping = {};

  // These are from Spoken.json
  Map<String, String> spokenMapping = {};

  // These are from Chords.json
  Map<String, Map<String, Map<String, List<String>>>> chordsMapping = {};
  Map<String, List<String>> chordMap = {};
  // From ChordSets.json
  List<String> chordList = [];
  Map<String, Map<String, List<String>>> chordSetsMapping = {};
  List<String> rangesList = [];
  List<String> chordSetsList = [];

  // These are from Scales.json
  Map<String, Map<String, List<String>>> scalesMapping = {};
  List<String> octavekeys = [];
  List<String> scalekeys = [];

  // These are from Notes.json
  List<String> noteKeys = [];
  Map<String, String> noteColors = {};
  Map<String, double> noteColorFactors = {};

  // These are from Missions.json
  Map<String, CampaignInfo> campaigns = {};
  Map<String, MissionInfo> missions = {};
  Map<String, LevelInfo> levels = {};

  // Getters
  List<String> get getMappingKeys {
    return mappingKeys;
  }

  List<String> get getInstruments {
    return instruments;
  }

  Map<String, Map<String, Map<String, String>>> get getNestedMapping {
    return nestedMapping;
  }

  Map<String, String> get getSpokenMapping {
    return spokenMapping;
  }

  Map<String, Map<String, Map<String, List<String>>>> get getChordsMapping {
    return chordsMapping;
  }

  Map<String, List<String>> get getChordMap {
    return chordMap;
  }

  List<String> get getChordList {
    return chordList;
  }

  Map<String, Map<String, List<String>>> get getChordSetsMapping {
    return chordSetsMapping;
  }

  List<String> get getRangesList {
    return rangesList;
  }

  List<String> get getChordSetsList {
    return chordSetsList;
  }

  Map<String, Map<String, List<String>>> get getScalesMapping {
    return scalesMapping;
  }

  List<String> get getOctaveKeys {
    return octavekeys;
  }

  List<String> get getScaleKeys {
    return scalekeys;
  }

  List<String> get getNoteKeys {
    return noteKeys;
  }

  Map<String, String> get getNoteColors {
    return noteColors;
  }

  Map<String, double> get getNoteColorFactors {
    return noteColorFactors;
  }

  Map<String, CampaignInfo> get getCampaigns {
    return campaigns;
  }

  String getCampaignName(String campaignID) {
    return campaigns[campaignID]!.CampaignName;
  }

  String getCampaignOctave(String campaignID) {
    return campaigns[campaignID]!.CampaignOctave;
  }

  String getCampaignSet(String campaignID) {
    return campaigns[campaignID]!.CampaignSet;
  }

  int getCampaignNotesInOctave(String campaignID) {
    return campaigns[campaignID]!.CampaignNotesInOctave;
  }

  Map<String, MissionInfo> get getMissions {
    return missions;
  }

  String getMissionName(String missionID) {
    return missions[missionID]!.MissionName;
  }

  String getMissionMode(String missionID) {
    return missions[missionID]!.MissionMode;
  }

  LevelInfo getLevelInfo(String levelID) {
    return levels[levelID]!;
  }

  List<LevelInfo> getLevelsForMission(String missionID) {
    List<LevelInfo> list = [];
    LinkedHashSet<String> levelIDs = missions[missionID]!.LevelIDs;
    levelIDs.forEach((levelid) {
      list.add(levels[levelid]!);
    });
    // get the list of levels based on missionID
    // then extract the levelInfo objects from levels
    return list;
  }

  LevelInfo? getNextLevelForMission(LevelInfo levelInfo) {
    LinkedHashSet<String> levelIDs = missions[levelInfo.MissionID]!.LevelIDs;
    String lastLevelID = levelIDs.last;
    if (levelInfo.LevelID == lastLevelID) {
      return null;
    }
    for (int i = 0; i < levelIDs.length; i++) {
      if (levelIDs.elementAt(i) == levelInfo.LevelID) {
        return levels[levelIDs.elementAt(i + 1)];
      }
    }
    return null;
  }

  LevelInfo? getPrevLevelForMission(LevelInfo levelInfo) {
    LinkedHashSet<String> levelIDs = missions[levelInfo.MissionID]!.LevelIDs;
    String firstLevelID = levelIDs.first;
    if (levelInfo.LevelID == firstLevelID) {
      return null;
    }
    for (int i = 0; i < levelIDs.length; i++) {
      if (levelIDs.elementAt(i) == levelInfo.LevelID) {
        return levels[levelIDs.elementAt(i - 1)];
      }
    }
    return null;
  }

  Future<void> get loadMappingJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Mapping.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String key = item['Key'];
      String instrument = item['Instrument'];
      String note = item['Note'];
      String filename = item['File'];
      nestedMapping[key] ??= {};
      nestedMapping[key]![instrument] ??= {};
      nestedMapping[key]![instrument]![note] = filename;

      if (key.isNotEmpty && !mappingKeys.contains(key)) {
        mappingKeys.add(key);
      }
      if (instrument.length > 1 && !instruments.contains(instrument)) {
        instruments.add(instrument);
      }
    }
    notifyListeners();
  }

  Future<void> get loadSpokenJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Spoken.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String note = item['Note'];
      String filename = item['File'];
      spokenMapping[note] = filename;
    }
    notifyListeners();
  }

  Future<void> get loadChordSetsJSON async {
    // Load Chords.json and populate chordsMapping
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Chords.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String category = item['Category'];
      String degree = item['Degree'];
      String chordSet = item['Chord Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      if (chordSet.isNotEmpty && !chordList.contains(chordSet)) {
        chordList.add(chordSet);
      }
      if (chordSet.isNotEmpty && !chordMap.containsKey(chordSet)) {
        chordMap[chordSet] = notes;
      }
      chordsMapping[category] ??= {};
      chordsMapping[category]![degree] ??= {};
      chordsMapping[category]![degree]![chordSet] = notes;
    }
    // Load Chords.json and populate chordsSetMapping
    final String jsonData2 = await rootBundle.loadString(
      'assets/mapping/ChordSets.json',
    );
    final List<dynamic> items2 = await json.decode(jsonData2);
    for (var item in items2) {
      String rangeValue = item['Range'];
      String set = item['Set'];
      String chordSet = item['Chords'];
      List<String> chordSets =
          chordSet.split(',').map((s) => s.trim()).toList();

      chordSetsMapping[rangeValue] ??= {};
      chordSetsMapping[rangeValue]![set] = chordSets;

      if (rangeValue.isNotEmpty && !rangesList.contains(rangeValue)) {
        rangesList.add(rangeValue);
      }
      if (set.isNotEmpty && !chordSetsList.contains(set)) {
        chordSetsList.add(set);
      }
    }

    // Add "Select all" set for each rangeValue
    for (var rangeValue in rangesList) {
      chordSetsMapping[rangeValue]?["Select all"] = List<String>.from(
        chordList,
      );
    }
    notifyListeners();
  }

  Future<void> get loadScalesJSON async {
    // Load Scales.json and populate scalesMapping
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Scales.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String octave = item['Octave'];
      String set = item['Set'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();

      scalesMapping[octave] ??= {};
      scalesMapping[octave]![set] = notes;

      if (octave.isNotEmpty && !octavekeys.contains(octave)) {
        octavekeys.add(octave);
      }
      if (set.isNotEmpty && !scalekeys.contains(set)) {
        scalekeys.add(set);
      }
    }
    notifyListeners();
  }

  Future<void> get loadNotesJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Notes.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String note = item['Note'];
      String color = item['Color'];
      double factor = double.parse(item['Factor']);
      noteColors[note] = color;
      noteColorFactors[note] = factor;
      if (note.isNotEmpty && !noteKeys.contains(note)) {
        noteKeys.add(note);
      }
    }
    notifyListeners();
  }

  Future<void> get loadMissionsJSON async {
    final String jsonData = await rootBundle.loadString(
      'assets/mapping/Missions.json',
    );
    final List<dynamic> items = await json.decode(jsonData);
    for (var item in items) {
      String campaignID = item['CampaignID'];
      String campaignName = item['CampaignName'];
      String filename = item['CampaignFilename'];
      String octave = item['CampaignOctave'];
      String scaleSet = item['CampaignSet'];
      int numNotesInOctave = int.parse(item['CampaignNotesInOctave']);

      String missionID = item['MissionID'];
      String missionName = item['MissionName'];
      String missionMode = item['MissionMode'];
      String levelID = item['LevelID'];
      String levelName = item['LevelName'];
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).toList();
      String newNotesStr = item['NewNotes'];
      List<String> newNotes =
          newNotesStr.split(',').map((s) => s.trim()).toList();

      int numNotes = int.parse(item['NumNotes']);
      int maxDistance = int.parse(item['MaxDistance']);
      bool allowRepeatedNotes = bool.parse(item['AllowRepeatedNotes']);
      String playbackSpeed = item['PlaybackSpeed'];
      bool startWithDo = bool.parse(item['StartWithDo']);
      bool endWithDo = bool.parse(item['EndWithDo']);
      String startingDo = item['StartingDo'];
      String endingDo = item['EndingDo'];
      String chordFrequency = item['ChordFrequency'];
      int numTests = int.parse(item['NumTests']);
      int numQuestions = int.parse(item['NumQuestions']);
      int passingScore = int.parse(item['PassingScore']);

      if (campaignID.isNotEmpty && !campaigns.containsKey(campaignID)) {
        campaigns[campaignID] = CampaignInfo(
          campaignID,
          campaignName,
          filename,
          octave,
          scaleSet,
          numNotesInOctave,
        );
      }
      if (campaigns.containsKey(campaignID)) {
        campaigns[campaignID]!.addMissionID(missionID);
      } // addMission won't add duplicates because it's a LinkedHashSet

      if (missionID.isNotEmpty && !missions.containsKey(missionID)) {
        MissionInfo mi = MissionInfo(
          campaignID,
          missionID,
          missionName,
          missionMode,
        );
        mi.addMissionNewNotes(newNotes);
        missions[missionID] = mi;
      }
      if (missions.containsKey(missionID)) {
        missions[missionID]!.addLevelID(levelID);
        missions[missionID]!.addMissionNewNotes(newNotes);
      }

      LevelInfo levelInfo = LevelInfo(
        campaignID,
        missionID,
        levelID,
        levelName,
        numNotes,
        maxDistance,
        allowRepeatedNotes,
        playbackSpeed,
        startWithDo,
        endWithDo,
        startingDo,
        endingDo,
        chordFrequency,
        numTests,
        numQuestions,
        passingScore,
      );
      levelInfo.setNotes(notes);
      levelInfo.addNewNotes(newNotes);

      if (levelID.isNotEmpty && !levels.containsKey(levelID)) {
        levels[levelID] = levelInfo;
      }
    }
    notifyListeners();
  }
}
