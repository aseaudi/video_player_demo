import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player_demo/video_controller_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Video Player Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? _newVideoPlayerController;
  VideoPlayerController? _nextVideoPlayerController;
  VideoPlayerController? _newNextVideoPlayerController;
  VideoPlayerController? _previousVideoPlayerController;
  VideoPlayerController? _newPreviousVideoPlayerController;

  CachedVideoControllerService cachedSvc = CachedVideoControllerService(DefaultCacheManager());

  int lastIndex = 0;
  List<String> srcs = [
    "https://www.treefe.in/video_1725979416530825_0_dKbGnV7wCPCqbWB4.mp4",
    "https://www.treefe.in/video_1725519289224798_0_JTf8Q5ovZDqgSCcJ.mp4",
    "https://www.treefe.in/video_1728390696278373_0_mkCfbAEsvF6SvWGe.mp4",
    "https://www.treefe.in/video_1726913543848460_0_tqz9k7ujIekqSUwj.mp4",
    "https://www.treefe.in/video_1727962702007024_0_nUSat8Wn5OwQDlEq.mp4",
    "https://www.treefe.in/video_1727081419590442_0_mdt6U5bTRihjEkED.mp4",
    "https://www.treefe.in/video_1725961307474236_0_5uYPFkA9ER7M64ae.mp4",
    "https://www.treefe.in/video_1728132075819621_0_3Nz1m7y8qoVgvB2U.mp4",
    "https://www.treefe.in/video_1726922612182235_0_vrfykzRTP4c43M7G.mp4",
    "https://www.treefe.in/video_1727965216635177_0_dYHg8JkndfKB1Qcj.mp4",
    'https://www.treefe.in/video_1728053218511292_0_40jAv6nHnHgupECs.mp4',
    "https://www.treefe.in/video_1725966235451248_0_CCMZAjizu8TsaUsl.mp4",
    "https://www.treefe.in/video_1727080353303273_0_cYMRgRKyxNwIB1X0.mp4",
    "https://www.treefe.in/video_1726652000566755_0_buAq5AomTRKclAqb.mp4",
    "https://www.treefe.in/video_1725446629120499_0_k3pS8qeOcEII3o01.mp4",
    "https://www.treefe.in/video_1728124071571171_0_PDTwgK5SlbOZIz7u.mp4",
    "https://www.treefe.in/video_1726671468883984_0_V4dlc5j0EtJ6rioE.mp4",
    "https://www.treefe.in/video_1725979591893362_0_jc9aUftTgdnyfgHK.mp4",
    "https://www.treefe.in/video_1726667766414573_0_WTRTOGkiJWC30Rlu.mp4",
    "https://www.treefe.in/video_1726918827098260_0_wbgsDoFNumLxyMU2.mp4",
    // "https://treefeappassest.s3.ap-south-1.amazonaws.com/large_video6ffb3f69-d464-46d6-bb3f-461833e65fb8.mp4",
    // "https://treefeappassest.s3.ap-south-1.amazonaws.com/large_video15ec57a5-3be6-43bc-8a31-6606cb2be587.mp4",
    // "https://treefeappassest.s3.ap-south-1.amazonaws.com/large_videoe6ad1f7b-18f2-4649-becf-4d203146257c.mp4",
    // "https://treefeappassest.s3.ap-south-1.amazonaws.com/large_video24ae8f3e-dcaf-4881-b7d2-1e447fa0ef6c.mp4",
    // "https://treefeappassest.s3.ap-south-1.amazonaws.com/large_video3cc0334c-be1b-45e2-8d28-cd1f5a5afb62.mp4",
  ];

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  void initializePlayer()  {
    // cachedSvc.getControllerForVideo(srcs[0]).then((VideoPlayerController cachedVideoController)  {
    //   _videoPlayerController = cachedVideoController;
    // });
    // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(srcs[0]));
    _videoPlayerController = getCachedVideoController(srcs[0]);
    _videoPlayerController?.initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController?.play();
    // cachedSvc.getControllerForVideo(srcs[1]).then((VideoPlayerController cachedVideoController)  {
    //   _videoPlayerController = cachedVideoController;
    // });
    // _nextVideoPlayerController = VideoPlayerController.networkUrl(Uri.parse(srcs[1]));
    _nextVideoPlayerController = getCachedVideoController(srcs[1]);
    _nextVideoPlayerController?.initialize().then((_){});
    // cachedSvc.getControllerForVideo(srcs[srcs.length-1]).then((VideoPlayerController cachedVideoController)  {
    //   _videoPlayerController = cachedVideoController;
    // });
    // _previousVideoPlayerController = VideoPlayerController.networkUrl(Uri.parse(srcs[srcs.length-1]));
    _previousVideoPlayerController = getCachedVideoController(srcs[srcs.length-1]);
    _previousVideoPlayerController?.initialize().then((_){});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _nextVideoPlayerController?.dispose();
    _previousVideoPlayerController?.dispose();
    super.dispose();
  }

    VideoPlayerController getCachedVideoController(String videoUrl) {
    CacheManager _cacheManager = DefaultCacheManager();
     _cacheManager.getFileFromCache(videoUrl).then((fileInfo) {

    if (fileInfo == null || fileInfo.file == null) {
      print('[VideoControllerService]: No video in cache');
      print('[VideoControllerService]: Saving video to cache');
      unawaited(_cacheManager.downloadFile(videoUrl));
      return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    } else {
      print('[VideoControllerService]: Loading video from cache');
      return VideoPlayerController.file(fileInfo.file);
    }
     });
     return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }

  void _nextVideo(index) {
    // VideoPlayerController? newPreviousVideoPlayerController;
    // VideoPlayerController? videoController;
    // VideoPlayerController? newNextVideoPlayerController;
    if (index > lastIndex) {
      _newPreviousVideoPlayerController = _videoPlayerController;
      _newPreviousVideoPlayerController?.pause();
      _newVideoPlayerController = _nextVideoPlayerController;
      VideoPlayerController? oldPreviousVideoPlayerController =
          _previousVideoPlayerController;
      oldPreviousVideoPlayerController?.dispose();
      // cachedSvc.getControllerForVideo(srcs[(index + 1) % srcs.length]).then((VideoPlayerController cachedVideoController)  {
      //   _newNextVideoPlayerController = cachedVideoController;
      // });
      // _newNextVideoPlayerController = VideoPlayerController?.networkUrl(
          // Uri.parse(srcs[(index + 1) % srcs.length]));
      _newNextVideoPlayerController = getCachedVideoController(srcs[(index + 1) % srcs.length]);
      _newNextVideoPlayerController?.initialize().then((_){
        setState(() {});
      });
    } else {
      _newNextVideoPlayerController = _videoPlayerController;
      _newNextVideoPlayerController?.pause();
      _newVideoPlayerController = _previousVideoPlayerController;
      VideoPlayerController? oldNextVideoPlayerController =
          _nextVideoPlayerController;
      oldNextVideoPlayerController?.dispose();
    //   cachedSvc.getControllerForVideo(srcs[(index - 1) % srcs.length]).then((VideoPlayerController cachedVideoController)  {
    //   _newPreviousVideoPlayerController = cachedVideoController;
    // });
      // _newPreviousVideoPlayerController = VideoPlayerController?.networkUrl(
          // Uri.parse(srcs[(index - 1) % srcs.length]));
                _newPreviousVideoPlayerController = getCachedVideoController(srcs[(index - 1) % srcs.length]);
      _newPreviousVideoPlayerController?.initialize().then((_){
        setState(() {});
      });
    }
    _videoPlayerController = _newVideoPlayerController;
    setState(() {});
    _newVideoPlayerController?.play();
    _previousVideoPlayerController = _newPreviousVideoPlayerController;
    _nextVideoPlayerController = _newNextVideoPlayerController;
    lastIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: PageView.builder(
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              _nextVideo(index);
            },
            itemBuilder: (context, index) {
              return _videoPlayerController!.value.isInitialized
                  ?
              VideoPlayer(_videoPlayerController!)
                  :
              const Center(
                  child: SizedBox(
                      width: 100,
                      height:100,
                      child: CircularProgressIndicator()
                  )
              );
            }),
      ),
    );
  }
}

