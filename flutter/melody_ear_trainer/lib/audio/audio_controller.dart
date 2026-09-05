import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');
  SoLoud? _soloud;
  SoundHandle? _musicHandle;
  // Handles of one-shot sounds started by this controller, so they can be
  // stopped without deinitialising the shared audio engine.
  final List<SoundHandle> _activeHandles = [];

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _soloud?.deinit();
  }

  Future<void> refresh() async {
    //_log.info('Refreshing audio controller');
    _soloud?.deinit();
    _soloud?.init();
  }

  Future<void> playSound(String assetKey) async {
    try {
      final source = await _soloud!.loadAsset(assetKey);
      final handle = await _soloud!.play(source);
      _trackHandle(handle);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  Future<void> playSoundFade(String assetKey, int dur, int fadeDur) async {
    try {
      final source = await _soloud!.loadAsset(assetKey);
      final myhandle = await _soloud!.play(source);
      _trackHandle(myhandle);
      await Future.delayed(Duration(milliseconds: dur));
      _soloud!.fadeVolume(
        myhandle,
        0.0,
        Duration(milliseconds: fadeDur),
      );
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }


  Future<void> startMusic() async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }
    _log.info('Loading music');
    final musicSource = await _soloud!.loadAsset(
      'assets/audio/C-do.mp3',
      mode: LoadMode.disk,
    );
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
    });

    _log.info('Playing music');
    _musicHandle = await _soloud!.play(
      musicSource,
      volume: 0.6,
      looping: true,
      loopingStartAt: const Duration(seconds: 25, milliseconds: 43),
    );
  }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void _trackHandle(SoundHandle handle) {
    // Prune handles whose voices have already finished naturally.
    _activeHandles.removeWhere((h) => !_soloud!.getIsValidVoiceHandle(h));
    _activeHandles.add(handle);
  }

  /// Stops every one-shot sound currently playing without deinitialising the
  /// engine. Safe to call when leaving a page that may still be playing
  /// audio; the shared engine stays usable for other pages.
  Future<void> stopAll() async {
    final soloud = _soloud;
    if (soloud == null) return;
    for (final handle in List<SoundHandle>.from(_activeHandles)) {
      if (soloud.getIsValidVoiceHandle(handle)) {
        await soloud.stop(handle);
      }
    }
    _activeHandles.clear();
  }

  void applyFilter() {
    _soloud!.filters.freeverbFilter.activate();
    _soloud!.filters.freeverbFilter.wet.value = 0.2;
    _soloud!.filters.freeverbFilter.roomSize.value = 0.9;
  }

  void removeFilter() {
    _soloud!.filters.freeverbFilter.deactivate();
  }
}