import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_transition.dart';
import 'package:video_editor/screens/add_watermark_screen.dart';
import 'package:video_editor/screens/change_video_speed_screen.dart';
import 'package:video_editor/screens/merge_videos_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_editor/screens/split_video_screen.dart';

class AudioOperationSelectionScreen extends StatelessWidget {
  const AudioOperationSelectionScreen({super.key, required this.projectId});

  final String projectId;

  Future<void> _pickAndNavigateToMerge(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final List<String> paths = result.paths.whereType<String>().toList();
      Navigator.of(context).push(
        screenTransition(
          MergeVideosScreen(videoPaths: paths, projectId: projectId),
        ),
      );
    }
  }

  Future<void> _pickAndNavigateToSpeed(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            ChangeVideoSpeedScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  Future<void> _pickAndNavigateToWatermark(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            AddWatermarkScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  Future<void> _pickAndNavigateToSplit(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            SplitVideoScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'Navigated to AudioOperationSelectionScreen with id: $projectId',
    );

    final List<Map<String, dynamic>> operations = [
      {
        'title': 'Extract Audio',
        'screen': PlaceholderScreen(
          title: 'Extract Audio',
          projectId: projectId,
        ),
        'onTap': null,
      },
      {
        'title': 'Add Background Music',
        'screen': PlaceholderScreen(
          title: 'Add Background Music',
          projectId: projectId,
        ),
        'onTap': null,
      },
      {
        'title': 'Audio Fade In/Out, Volume, Mute',
        'screen': PlaceholderScreen(
          title: 'Audio Fade/Volume/Mute',
          projectId: projectId,
        ),
        'onTap': null,
      },
      {
        'title': 'Audio Waveform Visualization',
        'screen': PlaceholderScreen(
          title: 'Audio Waveform Visualization',
          projectId: projectId,
        ),
        'onTap': null,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select Audio Operation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        itemCount: operations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Card(
          color: Colors.grey[900],
          child: ListTile(
            title: Text(
              operations[index]['title'],
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {
              if (operations[index]['onTap'] != null) {
                operations[index]['onTap']!(context);
              } else {
                Navigator.of(
                  context,
                ).push(screenTransition(operations[index]['screen']));
              }
            },
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String projectId;
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '$title\nProject ID: $projectId',
          style: const TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
