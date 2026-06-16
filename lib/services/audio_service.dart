import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  String? _currentUrl;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _playGeneration = 0;

  final Map<String, Duration> _durationCache = {};
  final Set<String> _loadingDurations = {};

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  String? get currentUrl => _currentUrl;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  AudioService() {
    _durationSub = _player.durationStream.listen((duration) {
      if (duration != null && duration > Duration.zero) {
        _duration = duration;
        final url = _currentUrl;
        if (url != null) {
          _durationCache[url] = duration;
        }
      } else {
        _duration = duration ?? Duration.zero;
      }
      notifyListeners();
    });

    _positionSub = _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processing = state.processingState;

      if (processing == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        _isPlaying = false;
        _position = Duration.zero;
      } else {
        _isPlaying = playing;
      }
      notifyListeners();
    });
  }

  Duration? durationFor(String url) {
    if (_currentUrl == url && _duration > Duration.zero) {
      return _duration;
    }
    return _durationCache[url];
  }

  bool isDurationLoading(String url) => _loadingDurations.contains(url);

  Future<void> preloadDuration(String url) async {
    if (_durationCache.containsKey(url) || _loadingDurations.contains(url)) {
      return;
    }
    if (_isPlaying) return;

    _loadingDurations.add(url);
    notifyListeners();

    try {
      await _player.stop();
      await _setSource(url);
      _currentUrl = url;
      _position = Duration.zero;
      _isPlaying = false;

      var duration = _player.duration;
      if (duration == null || duration <= Duration.zero) {
        duration = await _player.durationStream
            .firstWhere(
              (value) => value != null && value > Duration.zero,
              orElse: () => null,
            )
            .timeout(const Duration(seconds: 10), onTimeout: () => null);
      }

      if (duration != null && duration > Duration.zero) {
        _duration = duration;
        _durationCache[url] = duration;
      }
    } catch (e) {
      debugPrint('Duration preload error: $e');
    } finally {
      _loadingDurations.remove(url);
      notifyListeners();
    }
  }

  Future<void> play(String url) async {
    final generation = ++_playGeneration;

    if (_currentUrl != url) {
      await _haltPlayback(clearUrl: true);
      if (generation != _playGeneration) return;

      await _setSource(url);
      if (generation != _playGeneration) return;

      _currentUrl = url;
      _position = Duration.zero;
      _duration = _durationCache[url] ?? Duration.zero;
      notifyListeners();
    } else if (_isPlaying) {
      return;
    }

    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (_currentUrl == null) return;
    await _player.play();
  }

  Future<void> stop() async {
    _playGeneration++;
    await _haltPlayback(clearUrl: false);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> _haltPlayback({required bool clearUrl}) async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    if (clearUrl) {
      _currentUrl = null;
      _duration = Duration.zero;
    }
    notifyListeners();
  }

  Future<void> _setSource(String url) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      await _player.setUrl(url);
    } else {
      await _player.setFilePath(url);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
