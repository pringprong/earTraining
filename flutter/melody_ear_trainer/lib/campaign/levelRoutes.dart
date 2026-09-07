import 'levelChordID.dart';
import 'levelChordIDhandsfree.dart';
import 'levelChordIDtest.dart';
import 'levelChordMelodyID.dart';
import 'levelChordMelodyIDhandsfree.dart';
import 'levelChordMelodyIDtest.dart';
import 'levelChordMelodySinging.dart';
import 'levelChordMelodySinginghandsfree.dart';
import 'levelChordMelodySingingtest.dart';
import 'levelChordSinging.dart';
import 'levelChordSinginghandsfree.dart';
import 'levelChordSingingtest.dart';
import 'levelMelodyID.dart';
import 'levelMelodyIDhandsfree.dart';
import 'levelMelodyIDtest.dart';
import 'levelMelodySinging.dart';
import 'levelMelodySinginghandsfree.dart';
import 'levelMelodySingingtest.dart';

/// MissionMode → campaign level page route resolution.
///
/// Single source of truth used by `level.dart` (practice/hands-free/test
/// buttons), `melodyPageAbstract.takeTestButton` and
/// `levelTestResults.optionalRedoTestButton`, so new modes cannot drift out
/// of sync across call sites. The returned values are the pages' own
/// `routeName` constants.
///
/// Returns null for modes without level pages (e.g. "Bonus") — callers
/// should hide/disable the corresponding button in that case.

String? levelPracticeRoute(String missionMode) {
  switch (missionMode) {
    case "Melody ID":
      return LevelMelodyID.routeName;
    case "Melody singing":
      return LevelMelodySinging.routeName;
    case "Chord ID":
      return LevelChordID.routeName;
    case "Chord singing":
      return LevelChordSinging.routeName;
    case "Chord melody ID":
      return LevelChordMelodyID.routeName;
    case "Chord melody singing":
      return LevelChordMelodySinging.routeName;
  }
  return null;
}

String? levelHandsFreeRoute(String missionMode) {
  switch (missionMode) {
    case "Melody ID":
      return LevelMelodyIDHandsFree.routeName;
    case "Melody singing":
      return LevelMelodySingingHandsFree.routeName;
    case "Chord ID":
      return LevelChordIDHandsFree.routeName;
    case "Chord singing":
      return LevelChordSingingHandsFree.routeName;
    case "Chord melody ID":
      return LevelChordMelodyIDHandsFree.routeName;
    case "Chord melody singing":
      return LevelChordMelodySingingHandsFree.routeName;
  }
  return null;
}

String? levelTestRoute(String missionMode) {
  switch (missionMode) {
    case "Melody ID":
      return LevelMelodyIDTest.routeName;
    case "Melody singing":
      return LevelMelodySingingTest.routeName;
    case "Chord ID":
      return LevelChordIDTest.routeName;
    case "Chord singing":
      return LevelChordSingingTest.routeName;
    case "Chord melody ID":
      return LevelChordMelodyIDTest.routeName;
    case "Chord melody singing":
      return LevelChordMelodySingingTest.routeName;
  }
  return null;
}
