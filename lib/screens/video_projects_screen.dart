import 'package:flutter/material.dart';
import 'package:video_editor/widgets/custom_button.dart';
import 'package:video_editor/helpers/screen_sizes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  List<String> projectList = [];

  Future<void> _createProject(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Project Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Project Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        projectList.add(result);
      });
      await prefs.setStringList('project_list', projectList);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      projectList = prefs.getStringList('project_list') ?? [];
    });
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
                            projectList[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                projectList.removeAt(index);
                              });
                              await prefs.setStringList(
                                'project_list',
                                projectList,
                              );
                            },
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
