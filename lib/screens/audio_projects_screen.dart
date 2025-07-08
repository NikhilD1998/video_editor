import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_editor/helpers/screen_sizes.dart';
import 'package:video_editor/helpers/screen_transition.dart';
import 'package:video_editor/screens/audio_operation_selection_screen.dart';
import 'package:video_editor/screens/video_operation_selection_screen.dart';
import 'package:video_editor/widgets/custom_button.dart';

class AudioProjectsScreen extends StatefulWidget {
  const AudioProjectsScreen({super.key});

  @override
  State<AudioProjectsScreen> createState() => _AudioProjectsScreenState();
}

class _AudioProjectsScreenState extends State<AudioProjectsScreen> {
  List<Map<String, dynamic>> projectList = [];
  final uuid = const Uuid();

  Future<void> _createProject(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Enter Project Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Project Name'),
          autofocus: true,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          CustomButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            text: 'Create',
            fontSize: 0.035,
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final newProject = {'id': uuid.v4(), 'name': result};
      setState(() {
        projectList.add(newProject);
      });
      await prefs.setStringList(
        'audio_project_list',
        projectList.map((p) => jsonEncode(p)).toList(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('audio_project_list') ?? [];
    setState(() {
      projectList = stored
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _deleteProject(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      projectList.removeAt(index);
    });
    await prefs.setStringList(
      'audio_project_list',
      projectList.map((p) => jsonEncode(p)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = ScreenSizes.width(context) * 0.5;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenSizes.width(context) * 0.06,
          vertical: ScreenSizes.height(context) * 0.06,
        ),
        child: projectList.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No project yet.\nCreate a new project to\nget started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenSizes.width(context) * 0.05,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ScreenSizes.height(context) * 0.04),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: CustomButton(
                        onPressed: () => _createProject(context),
                        text: 'Create a Project',
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenSizes.width(context) * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ScreenSizes.height(context) * 0.02),
                  Expanded(
                    child: ListView.builder(
                      itemCount: projectList.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.only(
                          bottom: ScreenSizes.height(context) * 0.015,
                        ),
                        child: ListTile(
                          title: Text(
                            projectList[index]['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              screenTransition(
                                AudioOperationSelectionScreen(
                                  projectId: projectList[index]['id'],
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteProject(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      backgroundColor: Colors.black,
      floatingActionButton: projectList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _createProject(context),
              label: const Icon(Icons.add),
              backgroundColor: Colors.deepPurple,
            )
          : null,
    );
  }
}
