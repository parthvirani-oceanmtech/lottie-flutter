import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../lottie.dart';
import 'composition.dart';
import 'frame_rate.dart';

final globalRenderCache = RenderCache();

class RenderCache {
  final _entries = <CacheKey, RenderCacheEntry>{};
  final _handles = <Object, RenderCacheHandle>{};

  Stream get onLog => throw UnimplementedError();
  Stream get onUpdate => throw UnimplementedError();

  int get totalImages =>
      _entries.values.map((e) => e.images.length).fold<int>(0, (a, b) => a + b);

  Map<String, dynamic> get description => {
        '_handles': _handles.length,
        '_entries': {
          'length': _entries.length,
          'e': [
            for (var e in _entries.entries) e.value.handles.length,
          ]
        },
      };

  void _clearUnused() {
    print("Will clear");
    for (var entry in _entries.entries.toList()) {
      var key = entry.key;
      var cache = entry.value;

      if (cache.handles.isEmpty) {
        print("Clear unsuded");
        cache.dispose();
        var found = _entries.remove(key);
        assert(found == cache);
      }
    }
  }

  RenderCacheHandle acquire(Object user) {
    return _handles[user] ??= RenderCacheHandle(this);
  }

  void release(Object user) {
    var handle = _handles.remove(user);
    if (handle?._currentEntry case var currentEntry?) {
      currentEntry.handles.remove(handle);
      _clearUnused();
    }
  }
}

class RenderCacheHandle {
  final RenderCache _cache;
  RenderCacheEntry? _currentEntry;

  RenderCacheHandle(this._cache);

  RenderCacheEntry withKey(CacheKey key) {
    if (_currentEntry case var currentEntry? when currentEntry.key != key) {
      _currentEntry = null;
      currentEntry.handles.remove(this);
      _cache._clearUnused();
    }
    var entry = _cache._entries[key] ??= RenderCacheEntry(key);
    entry.handles.add(this);
    _currentEntry = entry;
    return entry;
  }
}

class RenderCacheEntry {
  final CacheKey key;
  final handles = <RenderCacheHandle>{};
  final images = <double, Image>{};
  bool _isDisposed = false;

  RenderCacheEntry(this.key);

  ui.Image imageForProgress(double progress, void Function(Canvas) draw) {
    assert(!_isDisposed);
    // Implement 2 strategies:
    //  - Draw the complete animation on a big image on one time (measure the cost).
    //    It is totally possible that this is a bad idea because it will be very slow
    //    and the advantages in term of efficienty can be totally false
    //  - Create lot of small pictures

    var existing = images[progress];
    if (existing != null) {
      return existing;
    }

    var size = key.size;
    print("Create image ${images.length}");
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    draw(canvas);
    var picture = recorder.endRecording();
    var image = picture.toImageSync(size.width.round(), size.height.round());
    images[progress] = image;
    "??";
    picture.dispose();
    return image;

    throw UnimplementedError();
  }

  Image _takeImage(double progress) {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);

    var size = key.size;

    "Use a callback directly ";
    LottieDrawable(key.composition, frameRate: key.frameRate)
      ..setProgress(progress)
      ..draw(canvas, Offset.zero & size);
    var picture = recorder.endRecording();
    var image = picture.toImageSync(size.width.round(), size.height.round());
    "??";
    picture.dispose();
    return image;
  }

  void dispose() {
    _isDisposed = true;
    for (var image in images.values) {
      image.dispose();
    }
    images.clear();
  }
}

var a = "";

@immutable
class CacheKey {
  // Missing ValueDelegate & everything that have an effect on the animation?
  // => better to create a key from LottieDrawable with all the parameters
  final LottieComposition composition;
  final Size size;
  final FrameRate frameRate;

  const CacheKey({
    required this.composition,
    required this.size,
    required this.frameRate,
  });

  @override
  int get hashCode => Object.hash(composition, size, frameRate);

  @override
  bool operator ==(other) =>
      other is CacheKey &&
      other.composition == composition &&
      other.size == size &&
      other.frameRate == frameRate;
}

/*
class CachedLottie {
  final Size size;
  final LottieComposition composition;
  final List<Image?> images;
  late final _drawable = LottieDrawable(composition);

  CachedLottie(this.size, this.composition)
      : images = List.filled(composition.durationFrames.ceil(), null);

  Duration get duration => composition.duration;

  Image imageAt(BuildContext context, double progress) {
    var index = (images.length * progress).round() % images.length;
    return images[index] ??= _takeImage(context, progress);
  }

  Image _takeImage(BuildContext context, double progress) {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);

    var devicePixelRatio = View.of(context).devicePixelRatio;

    _drawable
      ..setProgress(progress)
      ..draw(canvas, Offset.zero & (size * devicePixelRatio));
    var picture = recorder.endRecording();
    var image = picture.toImageSync((size.width * devicePixelRatio).round(),
        (size.height * devicePixelRatio).round());
    image.dispose();
    picture.dispose();
    "";
    return image;
  }
}
*/
