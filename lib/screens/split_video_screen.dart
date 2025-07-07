import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class SplitVideoScreen extends StatefulWidget {
  const SplitVideoScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  final String videoPath;
  final String projectId;

  @override
  State<SplitVideoScreen> createState() => _SplitVideoScreenState();
}

class _SplitVideoScreenState extends State<SplitVideoScreen> {
  late VideoPlayerController _controller;
  double _start = 0.0;
  double _end = 0.0;
  bool _isExporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _end = _controller.value.duration.inSeconds.toDouble();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportChunk() async {
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
        '${downloadsDir!.path}/split_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command =
        '-y -i "${widget.videoPath}" -ss $_start -to $_end -c copy "$output"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _exportResult = "Exported successfully:\n$output";
        });
      } else {
        setState(() {
          _exportResult = "Failed to export video.\n$logs";
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
      appBar: AppBar(title: const Text('Split Video')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _controller.value.isInitialized
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select start and end time (seconds):',
                    style: const TextStyle(fontSize: 16),
                  ),
                  RangeSlider(
                    min: 0.0,
                    max: _controller.value.duration.inSeconds.toDouble(),
                    values: RangeValues(_start, _end),
                    onChanged: (values) {
                      setState(() {
                        _start = values.start;
                        _end = values.end;
                        _controller.seekTo(Duration(seconds: _start.toInt()));
                      });
                    },
                    divisions: _controller.value.duration.inSeconds,
                    labels: RangeLabels(
                      _start.toStringAsFixed(1),
                      _end.toStringAsFixed(1),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start: ${_start.toStringAsFixed(1)}s'),
                      Text('End: ${_end.toStringAsFixed(1)}s'),
                    ],
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _exportChunk,
                            child: const Text('Export Selected Chunk'),
                          ),
                  ),
                  if (_exportResult != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _exportResult!,
                      style: TextStyle(
                        color: _exportResult!.startsWith('Exported')
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
