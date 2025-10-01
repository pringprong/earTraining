import '../objectbox.g.dart';
import 'helper.dart';

class ObjectBox {
  late final Store _store;
  late final Box<LevelTestResults> _levelTestResultsBox;
  late final Box<MissionSavedSettings> _missionSavedSettingsBox;

  ObjectBox._init(this._store) {
    _levelTestResultsBox = Box<LevelTestResults>(_store);
    _missionSavedSettingsBox = Box<MissionSavedSettings>(_store);
  }
  static Future<ObjectBox> init() async {
    final store = await openStore();
    return ObjectBox._init(store);
  }

  //#region	 <LEVEL> methods START */
  LevelTestResults? getLevelTestResult(int id) => _levelTestResultsBox.get(id);

  Stream<List<LevelTestResults>> getLevelTestResults() => _levelTestResultsBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  int insertLevelTestResult(LevelTestResults ltr) =>
      _levelTestResultsBox.put(ltr);

  bool deleteLevelTestResult(int id) => _levelTestResultsBox.remove(id);

  List<LevelTestResults> getLevelTestResultsByLevelID(String levelid) {
    Query<LevelTestResults> ltrq =
        _levelTestResultsBox
            .query(LevelTestResults_.LevelID.equals(levelid))
            .build();
    List<LevelTestResults> queryResults = ltrq.find();
    ltrq.close();
    return queryResults;
  }

  int numPassedTestsForLevel(String levelid, int passingScore) {
    int ltrq =
        _levelTestResultsBox
            .query(
              LevelTestResults_.LevelID.equals(
                levelid,
              ).and(LevelTestResults_.score.greaterOrEqual(passingScore)),
            )
            .build()
            .count();
    return ltrq;
  }

  bool levelPassed(String levelid, int passingScore, int numTests) {
    int ltrq =
        _levelTestResultsBox
            .query(
              LevelTestResults_.LevelID.equals(
                levelid,
              ).and(LevelTestResults_.score.greaterOrEqual(passingScore)),
            )
            .build()
            .count();
    return ltrq >= numTests;
  }

  String levelStatus(
    String levelid,
    int passingScore,
    int numTests,
  ) {
    int attempted =
        _levelTestResultsBox
            .query(LevelTestResults_.LevelID.equals(levelid))
            .build()
            .count();
    if (attempted == 0) {
      return "Not started yet";
    }
    if (attempted < passingScore) {
      return "In progress";
    }
    int ltrq =
        _levelTestResultsBox
            .query(
              LevelTestResults_.LevelID.equals(
                levelid,
              ).and(LevelTestResults_.score.greaterOrEqual(passingScore)),
            )
            .build()
            .count();
    if (ltrq >= numTests) {
      return "Passed!";
    }
    return "In progress";
  }

  void removeAllLevelTestResults() {
    _levelTestResultsBox.removeAll();
  }
  //#endregion ****Level Test Results methods END */

  MissionSavedSettings? getMissionSavedSettings(int id) =>
      _missionSavedSettingsBox.get(id);

  Stream<List<MissionSavedSettings>> getAllMissionSavedSettings() =>
      _missionSavedSettingsBox
          .query()
          .watch(triggerImmediately: true)
          .map((query) => query.find());

  int insertMissionSavedSettings(MissionSavedSettings mss) =>
      _missionSavedSettingsBox.put(mss);

  bool deleteMissionSavedSettings(int id) =>
      _missionSavedSettingsBox.remove(id);

  MissionSavedSettings? getMissionSavedSettingsByMissionID(String mid) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(mid))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isEmpty) {
      return null;
    }
    return queryResults.first;
  }

  void updateKey(String mid, String newkey) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(mid))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      MissionSavedSettings mss = queryResults.first;
      mss.key = newkey;
      _missionSavedSettingsBox.put(mss);
    }
  }

  void updateInstrument(String mid, String newInstrument) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(mid))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      MissionSavedSettings mss = queryResults.first;
      mss.instrument = newInstrument;
      _missionSavedSettingsBox.put(mss);
    }
  }

  void updateKeyAndInstrument(String mid, String newkey, String newInstrument) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(mid))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      MissionSavedSettings mss = queryResults.first;
      mss.key = newkey;
      mss.instrument = newInstrument;
      _missionSavedSettingsBox.put(mss);
    } else {
      _missionSavedSettingsBox.put(
        MissionSavedSettings(
          MissionID: mid,
          key: newkey,
          instrument: newInstrument,
        ),
      );
    }
  }

  void removeAllMissionSavedSettings() {
    _missionSavedSettingsBox.removeAll();
  }

  bool isMissionPassed(String missionID) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(missionID))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      return queryResults.first.status == "Passed!";
    }
    return false;
  }

  String missionStatus(String missionID) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(missionID))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      return queryResults.first.status;
    }
    return "Not started yet";
  }

  void updateMissionPassed(
    String mid,
    String newkey,
    String newInstrument,
    String newStatus,
  ) {
    Query<MissionSavedSettings> qmms =
        _missionSavedSettingsBox
            .query(MissionSavedSettings_.MissionID.equals(mid))
            .build();
    List<MissionSavedSettings> queryResults = qmms.find();
    if (queryResults.isNotEmpty) {
      MissionSavedSettings mss = queryResults.first;
      mss.key = newkey;
      mss.instrument = newInstrument;
      mss.status = newStatus;
      _missionSavedSettingsBox.put(mss);
    } else {
      _missionSavedSettingsBox.put(
        MissionSavedSettings(
          MissionID: mid,
          key: newkey,
          instrument: newInstrument,
          status: newStatus,
        ),
      );
    }
  }
}
