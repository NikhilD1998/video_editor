import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class AddMusicScreen extends StatefulWidget {
  const AddMusicScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  final String videoPath;
  final String projectId;

  @override
  State<AddMusicScreen> createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  late VideoPlayerController _videoController;
  String? _audioPath;
  bool _isExporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _audioPath = result.paths.first;
      });
    }
  }

  Future<void> _exportWithAudio() async {
    if (_audioPath == null) return;

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
        '${downloadsDir!.path}/with_music_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Replace original audio with selected audio
    final command =
        '-y -i "${widget.videoPath}" -i "$_audioPath" -c:v copy -map 0:v:0 -map 1:a:0 -shortest "$output"';

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
      appBar: AppBar(title: const Text('Add Background Music')),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_videoController.value.isInitialized)
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoController.value.isPlaying) {
                                _videoController.pause();
                              } else {
                                _videoController.play();
                              }
                            });
                          },
                          child: !_videoController.value.isPlaying
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _pickAudio,
                child: const Text('Pick Audio File'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_audioPath != null && !_isExporting)
                    ? _exportWithAudio
                    : null,
                child: _isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Export Video with Audio'),
              ),
              if (_audioPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Selected audio: ${_audioPath!.split('/').last}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_exportResult != null) ...[
                const SizedBox(height: 24),
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
      ),
    );
  }
}
