import '../providers/general_provider.dart';
import 'helper.dart';

/// Immutable per-level melody settings.
///
/// Campaign levels pass their fixed settings via the [LevelInfo] route
/// argument; this view model derives them once so pages never need to write
/// level data into the global `missionSettingsProvider` (the old
/// `setLevelDetails` mechanism).
class LevelConfig {
  final List<String> notes;
  final int numberOfNotes;
  final int maxDistance;
  final bool allowRepeatedNotes;
  final String playbackSpeed;
  final int timeBetweenNotes;
  final String truncateNotes;
  final bool startWithDo;
  final bool endWithDo;
  final String startingDo;
  final String endingDo;
  final String chordFrequency;
  final Set<String> newNotes;

  const LevelConfig({
    required this.notes,
    required this.numberOfNotes,
    required this.maxDistance,
    required this.allowRepeatedNotes,
    required this.playbackSpeed,
    required this.timeBetweenNotes,
    required this.truncateNotes,
    required this.startWithDo,
    required this.endWithDo,
    required this.startingDo,
    required this.endingDo,
    required this.chordFrequency,
    required this.newNotes,
  });

  /// Campaign flow: derive the fixed settings from the level definition.
  factory LevelConfig.fromLevelInfo(LevelInfo info) {
    int timeBetweenNotes;
    String truncateNotes;
    switch (info.PlaybackSpeed) {
      case 'Very fast':
        timeBetweenNotes = 300;
        truncateNotes = '600';
      case 'Fast':
        timeBetweenNotes = 600;
        truncateNotes = '900';
      case 'Slow':
        timeBetweenNotes = 1200;
        truncateNotes = '1500';
      case 'Normal':
      default:
        timeBetweenNotes = 900;
        truncateNotes = '1200';
    }
    return LevelConfig(
      notes: List<String>.from(info.Notes),
      numberOfNotes: info.NumNotes,
      maxDistance: info.MaxDistance,
      allowRepeatedNotes: info.AllowRepeatedNotes,
      playbackSpeed: info.PlaybackSpeed,
      timeBetweenNotes: timeBetweenNotes,
      truncateNotes: truncateNotes,
      startWithDo: info.StartWithDo,
      endWithDo: info.EndWithDo,
      startingDo: info.StartingDo,
      endingDo: info.EndingDo,
      chordFrequency: info.ChordFrequency,
      newNotes: Set<String>.from(info.NewNotes),
    );
  }

  /// Non-campaign pages (Melody ID, Chord ID, ...) keep deriving their
  /// settings from their own provider, so their behavior is unchanged.
  factory LevelConfig.fromProvider(GeneralProvider generalProvider) {
    return LevelConfig(
      notes: generalProvider.getSelectedNotes(),
      numberOfNotes: generalProvider.numberOfNotes,
      maxDistance: generalProvider.maxDistance,
      allowRepeatedNotes: generalProvider.allowRepeatedNotes,
      playbackSpeed: generalProvider.playbackSpeed,
      timeBetweenNotes: generalProvider.timeBetweenNotes,
      truncateNotes: generalProvider.truncateNotes,
      startWithDo: generalProvider.startWithDo,
      endWithDo: generalProvider.endWithDo,
      startingDo: generalProvider.startingDo,
      endingDo: generalProvider.endingDo,
      chordFrequency: generalProvider.chordFrequency,
      newNotes: const {},
    );
  }
}
