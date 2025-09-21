import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/helper.dart';

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
  Map<String, String> campaigns = {};
  // the first key is the campaign
  // the second key is the mission name
  // the value is a list of keys: Mode and Level
  Map<String, Map<String, MissionInfo>> missions = {};


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

  Map<String, String> get getCampaigns {
    return campaigns;
  }

  Map<String, Map<String, MissionInfo>> get getMissions {
    return missions;
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
      String campaign = item['Campaign'];
      String filename = item['Filename'];
      if (campaign.isNotEmpty && !campaigns.containsKey(campaign)) {
        campaigns[campaign] = filename;
      }

      // for each item:
      // add the campaign as a key to missions if it is not already present

      // extract the notes from item['Notes'] to a List<String> by parsing on comma
      // create a LevelInfo object from [item['Level'], item['NumNotes'], 
      // item['NumTests'], item['NumQuestions'], item['PassingScore']]
      // add the notes to the LevelInfo object using setNotes()

      // create a MissionInfo object if one does not exist
      // using [item['Mission'], item['Mode']]
      // add the LevelInfo object to the MissionInfo object using addLevel()

      // add the MissionInfo object to the missions map
      // using the campaign and mission as keys
      String mission = item['Mission'];
      String mode = item['Mode'];
      String level = item['Level'];
      int numNotes = int.parse(item['NumNotes']);
      int numTests = int.parse(item['NumTests']);  
      int numQuestions = int.parse(item['NumQuestions']);
      int passingScore = int.parse(item['PassingScore']);
      String notesStr = item['Notes'];
      List<String> notes = notesStr.split(',').map((s) => s.trim()).
      toList();
      LevelInfo levelInfo = LevelInfo(campaign, mission, level, numNotes, numTests, 
        numQuestions, passingScore);
      levelInfo.setNotes(notes);
      missions[campaign] ??= {};
      missions[campaign]![mission] ??= MissionInfo(campaign, mission, mode);
      missions[campaign]![mission]!.addLevel(levelInfo);

    }


    notifyListeners();
  }
}
