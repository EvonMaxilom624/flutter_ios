import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_general.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class GeneralUserProfilePage extends StatefulWidget {
  const GeneralUserProfilePage({super.key});

  @override
  State<GeneralUserProfilePage> createState() => _GeneralUserProfilePageState();
}

class _GeneralUserProfilePageState extends State<GeneralUserProfilePage> {
  String _name = "General User Name";
  final List<String> _descriptions = [];
  String? _selectedCollege;
  String? _selectedProgram;
  String? _selectedYearLevel;

  final Map<String, List<String>> _collegePrograms = {
    'College of Engineering and Technology': [
      'Bachelor of Science in Information Technology',
      'Bachelor of Science in Hospitality Management',
      'Bachelor of Science in Agricultural and Biosystems Engineering',
      'Bachelor of Science in Environmental Engineering',
      'Bachelor of Food Processing and Technology'
    ],
    'College of Agriculture': [
      'STC-Dairy',
      'Bachelor of Technology and Livelihood Education',
      'DAT-BAT',
      'Bachelor of Science in Agriculture'
    ],
    'College of Arts and Sciences': [
      'Bachelor of Science in Social Work'
    ],
  };

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

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
        title: 'User Profile',
      ),
      drawer: const CollapsibleSidebarGeneral(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Stack(
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage(
                            'assets/profile_placeholder.png'), // TODO Replace with your image asset or network image
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
                const Divider(),
                const Text(
                  "Courses",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCollege,
                  hint: const Text('Select College'),
                  items: _collegePrograms.keys.map((String college) {
                    return DropdownMenuItem<String>(
                      value: college,
                      child: Text(college),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCollege = newValue;
                      _selectedProgram = null;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'College',
                  ),
                ),
                if (_selectedCollege != null)
                  DropdownButtonFormField<String>(
                    value: _selectedProgram,
                    hint: const Text('Select Program'),
                    items: _collegePrograms[_selectedCollege!]!.map((String program) {
                      return DropdownMenuItem<String>(
                        value: program,
                        child: Text(program),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProgram = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Program',
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: _selectedYearLevel,
                  hint: const Text('Select Year Level'),
                  items: _yearLevels.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedYearLevel = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Year Level',
                  ),
                ),
              ],
            ),
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
    home: GeneralUserProfilePage(),
  ));
}
