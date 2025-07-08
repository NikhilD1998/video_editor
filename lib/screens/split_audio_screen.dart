import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class SplitAudioScreen extends StatefulWidget {
  const SplitAudioScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  final String videoPath;
  final String projectId;

  @override
  State<SplitAudioScreen> createState() => _SplitAudioScreenState();
}

class _SplitAudioScreenState extends State<SplitAudioScreen> {
  late AudioPlayer _audioPlayer;
  double _start = 0.0;
  double _end = 0.0;
  Duration _duration = Duration.zero;
  bool _isExporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setFilePath(widget.videoPath).then((_) {
      setState(() {
        _duration = _audioPlayer.duration ?? Duration.zero;
        _end = _duration.inSeconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
        '${downloadsDir!.path}/audio_split_${DateTime.now().millisecondsSinceEpoch}.mp3';

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
          _exportResult = "Failed to export audio.\n$logs";
        });
      }
      setState(() {
        _isExporting = false;
      });
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Audio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _duration == Duration.zero
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select start and end time (seconds):',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  RangeSlider(
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    values: RangeValues(_start, _end),
                    onChanged: (values) {
                      setState(() {
                        _start = values.start;
                        _end = values.end;
                      });
                    },
                    divisions: _duration.inSeconds,
                    labels: RangeLabels(
                      _start.toStringAsFixed(1),
                      _end.toStringAsFixed(1),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start: ${_start.toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'End: ${_end.toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0:00',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
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
              ),
      ),
    );
  }
}
