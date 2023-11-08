import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lottie/src/render_cache.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showPerformanceOverlay: true,
      home: Scaffold(
        body: Example(),
      ),
    );
  }
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  //--- example
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CacheInfo(),
        // Lottie.network(
        //   'https://telegram.org/file/464001484/1/bzi7gr7XRGU.10147/815df2ef527132dd23',
        //   decoder: LottieComposition.decodeGZip,
        //   height: 100,
        // ),
        Row(
          children: [
            Lottie.asset(
              'assets/Mobilo/K.json',
              height: 400,
              frameRate: FrameRate(10),
              enableRenderCache: true,
              fit: BoxFit.cover,
            ),
            Lottie.asset(
              'assets/Mobilo/K.json',
              height: 400,
              frameRate: FrameRate(10),
              enableRenderCache: false,
              fit: BoxFit.cover,
            ),
          ],
        ),
        Stack(
          children: [
            for (var i = 0; i < 10; i++)
              Transform.translate(
                offset: Offset((i * 10).toDouble(), 0),
                child: Lottie.asset(
                  'assets/LightningBug_file.tgs',
                  decoder: LottieComposition.decodeGZip,
                  height: 700,
                  enableRenderCache: true,
                  frameRate: FrameRate(10),
                ),
              ),
          ],
        ),

        // Stack(
        //   children: [
        //     for (var i = 0; i < 10; i++)
        //       Transform.translate(
        //         offset: Offset((i * 2).toDouble(), 0),
        //         child: Lottie.asset(
        //           'assets/AndroidWave.json',
        //           decoder: LottieComposition.decodeGZip,
        //           height: 100,
        //           frameRate: FrameRate(10),
        //         ),
        //       ),
        //   ],
        // ),
        // Lottie.asset(
        //   'assets/LightningBug_file.tgs',
        //   decoder: LottieComposition.decodeGZip,
        //   height: 100,
        // ),
      ],
    );
  }
  //---
}

class CacheInfo extends StatefulWidget {
  const CacheInfo({super.key});

  @override
  State<CacheInfo> createState() => _CacheInfoState();
}

class _CacheInfoState extends State<CacheInfo> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cache-: ${globalRenderCache.totalImages}'),
        Text('Cache: ${globalRenderCache.description}'),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
