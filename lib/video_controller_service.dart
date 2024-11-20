import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';
// import '../models/models.dart';

abstract class VideoControllerService {
  Future<VideoPlayerController> getControllerForVideo(String videoUrl);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager) : assert(_cacheManager != null);

  @override
  Future<VideoPlayerController> getControllerForVideo(String videoUrl) async {
    final fileInfo = await _cacheManager.getFileFromCache(videoUrl);

    if (fileInfo == null || fileInfo.file == null) {
      print('[VideoControllerService]: No video in cache');
      print('[VideoControllerService]: Saving video to cache');
      unawaited(_cacheManager.downloadFile(videoUrl));
      return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    } else {
      print('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(fileInfo.file);
    }
  }
}