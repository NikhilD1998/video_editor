import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

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

    final dir = await getTemporaryDirectory();
    final output =
        '${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Create a file list for ffmpeg
    final fileList = widget.videoPaths.map((path) => "file '$path'").join('\n');
    final fileListPath = '${dir.path}/filelist.txt';
    await File(fileListPath).writeAsString(fileList);

    // FFmpeg command to merge videos
    final command =
        "-f concat -safe 0 -i \"$fileListPath\" -c copy \"$output\"";

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          outputPath = output;
          mergeResult = "Merge Successful!\nSaved at:\n$output";
        });
      } else {
        setState(() {
          mergeResult = "Merge Failed!";
        });
      }
      setState(() {
        isMerging = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  if (controller.value.isInitialized) {
                    return AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isMerging ? null : mergeVideos,
              child: isMerging
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Merge Videos'),
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
          ],
        ),
      ),
    );
  }
}
