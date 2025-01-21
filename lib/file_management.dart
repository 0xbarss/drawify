import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'draw_input.dart';
import 'app_strings.dart';

class FileManagementPage extends StatefulWidget {
  final List<DrawInput> inputs;
  final bool is3D;

  const FileManagementPage({super.key, required this.inputs, required this.is3D});

  @override
  State<FileManagementPage> createState() => _FileManagementPageState();
}

class _FileManagementPageState extends State<FileManagementPage> {
  List<Map<String, dynamic>> files = [];
  final String language = 'TR';

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> saveFile(String fileName, List<Map<String, String>> fileContent) async {
    if (!fileName.endsWith('.json')) {fileName += '.json';}
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(fileContent));
    setState(() {files.add({'name': fileName, 'path': filePath, 'content': fileContent});});
    showSnackBar(context, AppStrings.get("savedSuccessfully", language));
  }

  Future<void> loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final filesInDir = Directory(directory.path).listSync();
    setState(() {
      files = filesInDir
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map((file) {
        final content = jsonDecode(file.readAsStringSync());
        return {
          'name': file.uri.pathSegments.last,
          'path': file.path,
          'content': content
        };
      }).toList();
    });
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {await file.delete();}
    setState(() {files.removeWhere((file) => file['path'] == filePath);});
    showSnackBar(context, AppStrings.get('deletedSuccessfully', language));
  }

  Future<void> uploadFile(Map<String, dynamic> file) async {
    List<DrawInput> newInputs = (file['content'] as List).map((entry) => DrawInput.fromMap(entry)).toList();
    setState(() {
      if (widget.is3D && newInputs.last.crossAngleController != null) {
        widget.inputs.clear();
        widget.inputs.addAll(newInputs);
      } else if (!widget.is3D && newInputs.last.crossAngleController == null) {
        widget.inputs.clear();
        widget.inputs.addAll(newInputs);
      }
    });
  }

  Future<void> promptForFilenameAndSave() async {
    TextEditingController filenameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('filename', language)),
        content: TextField(
          controller: filenameController,
          decoration: InputDecoration(
            hintText: AppStrings.get('enterFilename', language),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', language)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (filenameController.text.isNotEmpty) {
                saveFile(
                    filenameController.text,
                    widget.inputs.map((entry) => entry.toMap()).toList());
              }
            },
            child: Text(AppStrings.get('save', language)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: files.isEmpty
                ? Center(
                child: Text(AppStrings.get('viewFiles', language)))
                : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(file['name']),
                    subtitle: Text(file['path']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.upload),
                          onPressed: () => uploadFile(file),
                        ),
                        IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteFile(file['path']),
                        ),
                        Text(file['content']
                            .toString()
                            .contains('crossAngle')
                            ? '3D'
                            : '2D')
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: promptForFilenameAndSave,
            icon: const Icon(Icons.save),
            label: Text(AppStrings.get('saveJsonFile', language)),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}
