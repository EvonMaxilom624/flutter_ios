import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String _name = "Admin Name";
  final List<String> _descriptions = [];

  void _editName() async {
    final name = await _showEditDialog("Edit Name", _name);
    if (name != null && name.isNotEmpty) {
      setState(() {
        _name = name;
      });
    }
  }

  void _addDescription() async {
    final description = await _showEditDialog("Add Description", "");
    if (description != null && description.isNotEmpty) {
      setState(() {
        _descriptions.add(description);
      });
    }
  }

  Future<String?> _showEditDialog(String title, String initialText) async {
    TextEditingController controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter text"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _uploadPhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadPhotoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Profile',
      ),
      drawer: const CollapsibleSidebarAdmin(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage(
                          'assets/profile_placeholder.png'), //TODO Replace with your image asset or network image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _uploadPhoto,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Text(
                    _name,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _editName,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const Text(
                "Descriptions",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              ..._descriptions.map((description) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(description),
                  )),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addDescription,
                child: const Text("Add Description"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadPhotoPage extends StatelessWidget {
  const UploadPhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select Photo',
      ),
      body: CustomBackground(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              //TODO Implement photo upload functionality here
            },
            child: const Text("Upload Photo"),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AdminProfilePage(),
  ));
}
