import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody_ear_trainer/providers/general_provider.dart';
import 'package:melody_ear_trainer/providers/mapping_provider.dart';
import 'package:melody_ear_trainer/utils/chordMelody.dart';
import 'package:melody_ear_trainer/utils/helper.dart';
import 'package:melody_ear_trainer/utils/level_config.dart';

/// MappingProvider's constructor fires a fire-and-forget [loadAll] that loads
/// every mapping asset via rootBundle. Mock the asset channel with empty JSON
/// arrays so those loads succeed without real assets; the engine test then
/// populates the pieces it needs (chordMap) directly.
void mockAssetChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        return ByteData.sublistView(
          Uint8List.fromList(utf8.encode('[]')),
        );
      });
}

/// Builds a 3-item "Every note" chord level: StartingDo -> one free slot ->
/// EndingDo. With chord start/end anchors the single free slot is always the
/// second item, which makes assertions on the chord pool deterministic.
LevelInfo buildChordLevelInfo({
  List<String> chords = const [],
  String startingDo = "I_Rt",
  String endingDo = "I_Rt",
}) {
  final info = LevelInfo(
    "c1",
    "c1m08",
    "c1m08L900",
    "Test",
    3, // NumNotes
    5, // MaxDistance
    true, // AllowRepeatedNotes
    "Normal", // PlaybackSpeed
    true, // StartWithDo
    true, // EndWithDo
    startingDo,
    endingDo,
    "Every note", // ChordFrequency
    2, // NumTests
    10, // NumQuestions
    9, // PassingScore
  );
  info.setNotes(["do", "re", "mi", "do1"]);
  info.setChords(chords);
  return info;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(mockAssetChannel);

  group('Missions.json "Chords" data contract', () {
    test('every "Chords" entry is a valid Chords.json "Chord Set" key', () {
      final missionsPath = File('assets/mapping/Missions.json');
      final chordsPath = File('assets/mapping/Chords.json');
      expect(
        missionsPath.existsSync(),
        isTrue,
        reason: 'flutter test must run from flutter/melody_ear_trainer',
      );
      final missions =
          jsonDecode(missionsPath.readAsStringSync()) as List<dynamic>;
      final chordsJson =
          jsonDecode(chordsPath.readAsStringSync()) as List<dynamic>;
      final validChordKeys =
          chordsJson.map((c) => c['Chord Set'] as String).toSet();
      expect(validChordKeys, isNotEmpty);

      for (final row in missions) {
        final chordsStr = (row['Chords'] ?? '') as String;
        final chords =
            chordsStr
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
        for (final chord in chords) {
          expect(
            validChordKeys,
            contains(chord),
            reason: 'Level ${row['LevelID']} lists unknown chord "$chord"',
          );
        }
      }
    });

    test('chord-mode levels define a non-empty "Chords" pool', () {
      final missions =
          jsonDecode(File('assets/mapping/Missions.json').readAsStringSync())
              as List<dynamic>;
      final chordRows =
          missions
              .where(
                (row) => (row['MissionMode'] as String).startsWith('Chord'),
              )
              .toList();
      expect(chordRows, isNotEmpty);
      for (final row in chordRows) {
        final chordsStr = (row['Chords'] ?? '') as String;
        final chords =
            chordsStr
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
        expect(
          chords,
          isNotEmpty,
          reason: 'Chord-mode level ${row['LevelID']} should define "Chords"',
        );
        expect(
          row['ChordFrequency'],
          isNot('Never'),
          reason:
              'Chord-mode level ${row['LevelID']} uses "Never": no chords '
              'would ever be inserted or displayed',
        );
      }
    });
  });

  group('per-level chord pool override', () {
    late MappingProvider mappingProvider;
    late MissionSettingsProvider generalProvider;
    late ChordMelody chordMelody;

    setUp(() async {
      // Seed the persisted MissionSettingsProvider settings so its
      // constructor's loadSettings() resolves deterministically to a
      // single-chord provider pool (no SharedPreferences plugin in tests).
      SharedPreferences.setMockInitialValues({
        'minimal_settings': jsonEncode({
          'selectedChords': jsonEncode({"IV0_Sec": true}),
        }),
      });
      mappingProvider = MappingProvider();
      // Drain the constructor's fire-and-forget loadAll (empty mocked assets)
      // before manually populating the chord map.
      await mappingProvider.loadAll();
      mappingProvider.chordMap.addAll({
        "I_Rt": ["do", "mi", "so"],
        "IV0_Sec": ["so0", "do", "mi"],
        "V0_Fir": ["mi", "so", "do1"],
      });
      generalProvider = MissionSettingsProvider();
      // Await loadSettings() so the constructor's identical (mocked) load has
      // settled; both reads produce the same seeded state.
      await generalProvider.loadSettings();
      chordMelody = ChordMelody();
    });

    String generate(LevelInfo info) {
      chordMelody.clear();
      return chordMelody.generateChordMelody(
        generalProvider,
        mappingProvider,
        levelConfig: LevelConfig.fromLevelInfo(info),
      );
    }

    test('level "Chords" overrides the provider selection', () {
      for (int i = 0; i < 30; i++) {
        final result = generate(
          buildChordLevelInfo(chords: ["I_Rt", "V0_Fir"]),
        );
        expect(result, isEmpty);
        final melody = chordMelody.getChordMelody();
        expect(melody.length, 3);
        expect(melody.first, "I_Rt"); // StartingDo (a chord)
        expect(melody.last, "I_Rt"); // EndingDo (a chord)
        // The one free slot must come from the level's pool only.
        expect(const ["I_Rt", "V0_Fir"], contains(melody[1]));
        expect(melody, isNot(contains("IV0_Sec")));
      }
    });

    test('empty level "Chords" falls back to the provider selection', () {
      for (int i = 0; i < 10; i++) {
        final result = generate(buildChordLevelInfo());
        expect(result, isEmpty);
        final melody = chordMelody.getChordMelody();
        expect(melody.length, 3);
        // Free slot drawn from the provider's pool: only IV0_Sec selected.
        expect(melody[1], "IV0_Sec");
      }
    });

    test('unknown chord keys are dropped and fall back to the provider', () {
      final result = generate(
        buildChordLevelInfo(chords: ["not_a_chord"]),
      );
      expect(result, isEmpty);
      final melody = chordMelody.getChordMelody();
      expect(melody.length, 3);
      expect(melody[1], "IV0_Sec");
    });
  });
}
