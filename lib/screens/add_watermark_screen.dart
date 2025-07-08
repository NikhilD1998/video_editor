import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class AddWatermarkScreen extends StatefulWidget {
  const AddWatermarkScreen({
    super.key,
    required this.videoPath,
    required this.projectId,
  });

  final String videoPath;
  final String projectId;

  @override
  State<AddWatermarkScreen> createState() => _AddWatermarkScreenState();
}

class _AddWatermarkScreenState extends State<AddWatermarkScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _watermark;
  VideoPlayerController? _videoController;
  bool _isExporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWatermarkDialog();
    });
  }

  void _showWatermarkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Watermark Text'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Type your watermark...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                setState(() {
                  _watermark = _controller.text.trim();
                  _videoController =
                      VideoPlayerController.file(File(widget.videoPath))
                        ..initialize().then((_) {
                          setState(() {});
                        });
                });
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportWithWatermark() async {
    if (_watermark == null || _watermark!.isEmpty) return;

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
        '${downloadsDir!.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final watermarkText = _watermark!.replaceAll("'", "\\'");
    final fontPath = await ensureFontFile();

    final command =
        '-y -i "${widget.videoPath}" -vf "drawtext=fontfile=\'$fontPath\':text=\'$watermarkText\':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:x=(w-text_w)/2:y=(h-text_h)/2" -codec:a copy "$output"';

    debugPrint('Starting export with watermark...');
    debugPrint('FFmpeg command: $command');
    debugPrint('Input video: ${widget.videoPath}');
    debugPrint('Output video: $output');
    debugPrint('Watermark text: $_watermark');

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();
      final failStackTrace = await session.getFailStackTrace();

      debugPrint('FFmpeg return code: $returnCode');
      debugPrint('FFmpeg logs:\n$logs');
      debugPrint('FFmpeg fail stack trace:\n$failStackTrace');

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _exportResult = "Exported successfully:\n$output";
        });
        debugPrint('Export successful: $output');
      } else {
        setState(() {
          _exportResult = "Failed to export video.\n$logs";
        });
        debugPrint('Export failed.');
      }
      setState(() {
        _isExporting = false;
      });
    });
  }

  Future<String> ensureFontFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final fontFile = File('${dir.path}/Roboto-Regular.ttf');
    if (!await fontFile.exists()) {
      final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      await fontFile.writeAsBytes(data.buffer.asUint8List());
    }
    return fontFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Watermark'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _watermark == null
            ? const Center(child: Text('Please enter a watermark to continue.'))
            : Column(
                children: [
                  if (_videoController != null &&
                      _videoController!.value.isInitialized)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        IgnorePointer(
                          child: Text(
                            _watermark!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          },
                          child: !_videoController!.value.isPlaying
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _exportWithWatermark,
                            child: const Text('Export Video'),
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
