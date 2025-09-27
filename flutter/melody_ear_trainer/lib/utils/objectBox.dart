import '../objectbox.g.dart';
import 'helper.dart';

class ObjectBox {
  late final Store _store;
  late final Box<LevelTestResults> _levelTestResultsBox;
  ObjectBox._init(this._store) {
    _levelTestResultsBox = Box<LevelTestResults>(_store);
  }
  static Future<ObjectBox> init() async {
    final store = await openStore();
    return ObjectBox._init(store);
  }

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
}
