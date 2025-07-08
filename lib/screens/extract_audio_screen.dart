import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class ExtractAudioScreen extends StatefulWidget {
  final String videoPath;
  final String projectId;
  const ExtractAudioScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  @override
  State<ExtractAudioScreen> createState() => _ExtractAudioScreenState();
}

class _ExtractAudioScreenState extends State<ExtractAudioScreen> {
  late VideoPlayerController _controller;
  bool _isExporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _extractAudio() async {
    setState(() {
      _isExporting = true;
      _exportResult = null;
    });

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    final output =
        '${downloadsDir!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

    final command =
        '-y -i "${widget.videoPath}" -vn -acodec libmp3lame "$output"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _exportResult = "Audio exported successfully:\n$output";
        });
      } else {
        setState(() {
          _exportResult = "Failed to export audio.\n$logs";
        });
      }
      setState(() {
        _isExporting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extract Audio'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_controller.value.isInitialized)
              FractionallySizedBox(
                widthFactor: 0.8,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: !_controller.value.isPlaying
                            ? Container(
                                color: Colors.black26,
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              )
                            : Container(color: Colors.transparent),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isExporting
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _extractAudio,
                      child: const Text('Export Audio'),
                    ),
            ),
            if (_exportResult != null) ...[
              const SizedBox(height: 16),
              Text(
                _exportResult!,
                style: TextStyle(
                  color: _exportResult!.startsWith('Audio exported')
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
