import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/widgets/custom_button.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class MergeVideosScreen extends StatefulWidget {
  const MergeVideosScreen({
    super.key,
    required this.videoPaths,
    required this.projectId,
  });

  final List<String> videoPaths;
  final String projectId;

  @override
  State<MergeVideosScreen> createState() => _MergeVideosScreenState();
}

class _MergeVideosScreenState extends State<MergeVideosScreen> {
  String? outputPath;
  bool isMerging = false;
  String? mergeResult;
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (final path in widget.videoPaths) {
      final controller = VideoPlayerController.file(File(path));
      controller.initialize().then((_) {
        setState(() {});
      });
      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> mergeVideos() async {
    setState(() {
      isMerging = true;
      mergeResult = null;
    });

    // Get the Downloads directory
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    final output =
        '${downloadsDir!.path}/merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Preprocess all videos to ensure they have audio
    List<String> processedPaths = [];
    for (final path in widget.videoPaths) {
      final processed = await ensureAudio(path);
      processedPaths.add(processed);
    }

    // Build input arguments and filter_complex for normalization
    final inputs = processedPaths.map((path) => '-i "$path"').join(' ');
    final n = processedPaths.length;
    final filterInputs = List.generate(
      n,
      (i) => '[${i}:v]scale=1280:720,setsar=1,fps=30[v$i];',
    ).join();
    final filterStreams = List.generate(n, (i) => '[v$i][${i}:a]').join();
    final filter = '$filterInputs$filterStreams concat=n=$n:v=1:a=1 [v][a]';

    final command =
        '$inputs -filter_complex "$filter" -map "[v]" -map "[a]" -c:v libx264 -c:a aac -strict experimental -b:a 192k "$output"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();
      final failStackTrace = await session.getFailStackTrace();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          outputPath = output;
          mergeResult = "Merge Successful!\nSaved at:\n$output";
        });
      } else {
        debugPrint('FFmpeg error log:\n$logs');
        debugPrint('FFmpeg fail stack trace:\n$failStackTrace');
        setState(() {
          mergeResult = "Merge Failed!\n\n$logs";
        });
      }
      setState(() {
        isMerging = false;
      });
    });
  }

  Future<String> ensureAudio(String inputPath) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_audio.mp4';

    // Get duration using ffprobe
    final probeSession = await FFmpegKit.execute(
      '-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$inputPath"',
    );
    final probeLogs = await probeSession.getAllLogsAsString();
    final durationString = probeLogs!.trim().split('\n').last;
    final duration = double.tryParse(durationString) ?? 1.0;

    // Add silent audio if missing, otherwise copy as is
    final command =
        '-y -i "$inputPath" -f lavfi -t $duration -i anullsrc=channel_layout=stereo:sample_rate=44100 -shortest -c:v copy -c:a aac "$outputPath"';
    await FFmpegKit.execute(command);
    return outputPath;
  }

  @override
  Widget build(BuildContext context) {
    // If all videos are removed, go back
    if (_controllers.isEmpty) {
      Future.microtask(() {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Merge Videos'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid at the top
            SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _controllers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final controller = _controllers[index];
                  final duration = controller.value.isInitialized
                      ? controller.value.duration
                      : Duration.zero;
                  return Stack(
                    children: [
                      controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            )
                          : const Center(child: CircularProgressIndicator()),
                      // Duration at bottom left
                      if (controller.value.isInitialized)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      // Remove button at top right
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              controller.dispose();
                              _controllers.removeAt(index);
                              widget.videoPaths.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (mergeResult != null)
              Text(
                mergeResult!,
                style: TextStyle(
                  color: mergeResult!.contains('Successful')
                      ? Colors.green
                      : Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            // Spacer to push the button to the bottom
            const Spacer(),
            (_controllers.isEmpty)
                ? const SizedBox.shrink()
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: (outputPath != null)
                        ? CustomButton(
                            onPressed: () {
                              if (outputPath != null) {
                                Share.shareXFiles([
                                  XFile(outputPath!),
                                ], text: 'Check out my merged video!');
                              }
                            },
                            text: 'Share Merged Video',
                          )
                        : isMerging
                        ? Container(
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
                        : CustomButton(
                            onPressed: mergeVideos,
                            text: 'Merge Videos',
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours) != '00' ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }
}
