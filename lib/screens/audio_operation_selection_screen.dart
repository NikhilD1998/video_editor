import 'package:flutter/material.dart';
import 'package:video_editor/helpers/screen_transition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_editor/screens/add_music_screen.dart';
import 'package:video_editor/screens/extract_audio_screen.dart';
import 'package:video_editor/screens/split_audio_screen.dart';

class AudioOperationSelectionScreen extends StatelessWidget {
  const AudioOperationSelectionScreen({super.key, required this.projectId});

  final String projectId;

  Future<void> _pickAndNavigateToExtract(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            ExtractAudioScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  Future<void> _pickAndNavigateToAddMusic(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            AddMusicScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  Future<void> _pickAndNavigateToSplitAudio(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final String? path = result.paths.first;
      if (path != null) {
        Navigator.of(context).push(
          screenTransition(
            SplitAudioScreen(videoPath: path, projectId: projectId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> operations = [
      {
        'title': 'Extract Audio',
        'screen': null,
        'onTap': (BuildContext context) => _pickAndNavigateToExtract(context),
      },
      {
        'title': 'Add Music',
        'screen': null,
        'onTap': (BuildContext context) => _pickAndNavigateToAddMusic(context),
      },
      {
        'title': 'Split Audio',
        'screen': null,
        'onTap': (BuildContext context) =>
            _pickAndNavigateToSplitAudio(context),
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
