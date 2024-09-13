import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:file_picker/file_picker.dart';

class ReportEventPage extends StatefulWidget {
  const ReportEventPage({super.key});

  @override
  State<ReportEventPage> createState() => ReportEventPageState();
}

class ReportEventPageState extends State<ReportEventPage> {
  final List<String> activities = [
    'IT Panagmaya',
    'Wellness Week 2024 Bazaar ',
    'General Assembly',
  ];

  String? selectedActivity;
  PlatformFile? narrativeReport;
  PlatformFile? attendance;
  PlatformFile? financialReport;
  List<PlatformFile> documentation = [];

  void _pickFile(Function(PlatformFile?) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      onFilePicked(result.files.first);
    }
  }

  void _pickMultipleFiles(Function(List<PlatformFile>) onFilesPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      onFilesPicked(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Submit Report'),
      drawer: const CollapsibleSidebarOrganization(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Activity',
                  border: OutlineInputBorder(),
                ),
                items: activities.map((activity) {
                  return DropdownMenuItem(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value;
                  });
                },
                value: selectedActivity,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Upload Narrative Report'),
                onPressed: () {
                  _pickFile((file) {
                    setState(() {
                      narrativeReport = file;
                    });
                  });
                },
              ),
              if (narrativeReport != null) Text('Uploaded: ${narrativeReport!.name}'),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Upload Attendance'),
                onPressed: () {
                  _pickFile((file) {
                    setState(() {
                      attendance = file;
                    });
                  });
                },
              ),
              if (attendance != null) Text('Uploaded: ${attendance!.name}'),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Upload Financial Report'),
                onPressed: () {
                  _pickFile((file) {
                    setState(() {
                      financialReport = file;
                    });
                  });
                },
              ),
              if (financialReport != null) Text('Uploaded: ${financialReport!.name}'),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Upload Documentation'),
                onPressed: () {
                  _pickMultipleFiles((files) {
                    setState(() {
                      documentation = files;
                    });
                  });
                },
              ),
              if (documentation.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: documentation.map((file) => Text('Uploaded: ${file.name}')).toList(),
                ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement the logic to submit the report
                },
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
