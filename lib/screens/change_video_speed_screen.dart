import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/widgets/custom_button.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChangeVideoSpeedScreen extends StatefulWidget {
  const ChangeVideoSpeedScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  final String videoPath;
  final String projectId;

  @override
  State<ChangeVideoSpeedScreen> createState() => _ChangeVideoSpeedScreenState();
}

class _ChangeVideoSpeedScreenState extends State<ChangeVideoSpeedScreen> {
  late VideoPlayerController _controller;
  double _speed = 1.0;
  bool _isSaving = false;
  String? _saveResult;

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

  Future<void> _saveVideo() async {
    setState(() {
      _isSaving = true;
      _saveResult = null;
    });

    // Save to Downloads folder
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    final output =
        '${downloadsDir!.path}/speed_${_speed}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // FFmpeg command to change speed
    // For video: setpts=PTS/<speed>
    // For audio: atempo=<speed> (but only supports 0.5-2.0, so chain if needed)
    String atempoFilter;
    double remaining = _speed;
    List<String> atempoFilters = [];
    while (remaining > 2.0) {
      atempoFilters.add('atempo=2.0');
      remaining /= 2.0;
    }
    while (remaining < 0.5) {
      atempoFilters.add('atempo=0.5');
      remaining /= 0.5;
    }
    atempoFilters.add('atempo=${remaining.toStringAsFixed(2)}');
    atempoFilter = atempoFilters.join(',');

    final command =
        '-y -i "${widget.videoPath}" -filter_complex "[0:v]setpts=${1 / _speed}*PTS[v];[0:a]$atempoFilter[a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac "$output"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _saveResult = "Saved successfully:\n$output";
        });
      } else {
        final logs = await session.getAllLogsAsString();
        setState(() {
          _saveResult = "Failed to save video.\n$logs";
        });
      }
      setState(() {
        _isSaving = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final videoHeight = mediaQuery.size.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: videoHeight,
              child: _controller.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (!_controller.value.isPlaying)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.play();
                              });
                            },
                            child: Container(
                              color: Colors.black26,
                              child: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                        if (_controller.value.isPlaying)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.pause();
                              });
                            },
                            child: Container(color: Colors.transparent),
                          ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
            Text(
              'Speed: ${_speed.toStringAsFixed(2)}x',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            Slider(
              value: _speed,
              min: 0.25,
              max: 2.0,
              divisions: 7,
              label: '${_speed.toStringAsFixed(2)}x',
              onChanged: (value) {
                setState(() {
                  _speed = value;
                  _controller.setPlaybackSpeed(_speed);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _speed > 0.25
                      ? () {
                          setState(() {
                            _speed = (_speed - 0.25).clamp(0.25, 2.0);
                            _controller.setPlaybackSpeed(_speed);
                          });
                        }
                      : null,
                  child: const Text('Slower'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _speed < 2.0
                      ? () {
                          setState(() {
                            _speed = (_speed + 0.25).clamp(0.25, 2.0);
                            _controller.setPlaybackSpeed(_speed);
                          });
                        }
                      : null,
                  child: const Text('Faster'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isSaving
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
                  : (_saveResult != null && _saveResult!.startsWith('Saved'))
                  ? CustomButton(
                      onPressed: () {
                        final outputPath =
                            RegExp(
                              r'Saved successfully:\n(.+)',
                            ).firstMatch(_saveResult!)?.group(1) ??
                            '';
                        if (outputPath.isNotEmpty) {
                          Share.shareXFiles([
                            XFile(outputPath),
                          ], text: 'Check out my speed-edited video!');
                        }
                      },
                      text: 'Share Video',
                    )
                  : CustomButton(onPressed: _saveVideo, text: 'Save Video'),
            ),
            if (_saveResult != null) ...[
              const SizedBox(height: 16),
              Text(
                _saveResult!,
                style: TextStyle(
                  color: _saveResult!.startsWith('Saved')
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
