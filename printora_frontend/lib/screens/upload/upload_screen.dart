import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../../state/app_state.dart';
import '../print_settings/print_settings_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<File> selectedFiles = [];

  Future<void> pickFile() async {
    final List<XFile> files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'documents',
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ],
    );

    if (files.isNotEmpty) {
      setState(() {
        selectedFiles = files.map((f) => File(f.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kioskId = AppState.kioskId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Printora"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.print,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 15),
              const Text(
                "Ready to Print",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 35,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Connected Kiosk",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kioskId ?? "No Kiosk Selected",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Choose Files"),
                ),
              ),
              const SizedBox(height: 25),
              if (selectedFiles.isNotEmpty)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: selectedFiles.map((file) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(
                            file.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (selectedFiles.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrintSettingsScreen(
                            files: selectedFiles,
                          ),
                        ),
                      ); // TODO:
                      // Upload selectedFiles + kioskId to backend
                    },
                    child: const Text(
                      "Continue to Upload",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
