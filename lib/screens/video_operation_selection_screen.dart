import 'package:flutter/material.dart';

class VideoOperationSelectionScreen extends StatelessWidget {
  const VideoOperationSelectionScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'Navigated to VideoOperationSelectionScreen with id: $projectId',
    );

    final List<String> operations = [
      'Timeline Reordering',
      'Merge Videos',
      'Split Videos',
      'Overlay Audio and Videos',
      'Change Video Speed',
      'Transitions',
      'Filters',
      'Add Watermark',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select Operation'),
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
              operations[index],
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
            onTap: () {
              // TODO: Handle navigation to the selected operation
              debugPrint(
                'Selected: ${operations[index]} for project $projectId',
              );
            },
          ),
        ),
      ),
    );
  }
}
