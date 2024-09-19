import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_general.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
//TODO check google ai studio to update this page
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

  // One flag to rule them all
  bool _isEditingProfile = false;

  List<String> _programList = [];

  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  // Fetch programs from Firebase Firestore
  Future<void> _fetchPrograms() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('degree_programs').get();
      List<String> programs =
      querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _programList = programs;
      });
    } catch (e) {
      debugPrint("Error fetching programs: $e");
    }
  }

  // Function to toggle the editing state for the entire profile
  void _toggleEditProfile() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
    });
  }

  // Common function to show the dialog for editing text fields
  Future<String?> _showEditDialog(
      String title, String initialText) async {
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
    // TODO: Implement photo upload functionality here
    if (kDebugMode) {
      print('Upload Photo button pressed!');
    }
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
                        backgroundImage:
                        AssetImage('assets/profile_placeholder.png'),
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

                // Name Display and Edit (now controlled by _isEditingProfile)
                Row(
                  children: <Widget>[
                    Text(
                      _name,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    IconButton(
                      icon: Icon(_isEditingProfile ? Icons.close : Icons.edit),
                      onPressed: () async {
                        if (_isEditingProfile) {
                          final name = await _showEditDialog("Edit Name", _name);
                          if (name != null && name.isNotEmpty) {
                            setState(() {
                              _name = name;
                            });
                          }
                        }
                        _toggleEditProfile(); // Toggle edit mode for all fields
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10.0),
                const Divider(),

                // Descriptions Section (Add/Edit controlled by _isEditingProfile)
                const Text(
                  "Descriptions",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                ..._descriptions.map((description) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(description),
                )),
                const SizedBox(height: 16.0),

                // Add Description Button (only enabled when in edit mode)
                ElevatedButton(
                  onPressed: _isEditingProfile
                      ? () async {
                    final description =
                    await _showEditDialog("Add Description", "");
                    if (description != null && description.isNotEmpty) {
                      setState(() {
                        _descriptions.add(description);
                      });
                    }
                  }
                      : null,
                  child: const Text("Add Description"),
                ),

                const Divider(),

                // Courses Section
                const Text(
                  "Courses",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),

                // College Dropdown (enabled/disabled based on _isEditingProfile)
                DropdownButtonFormField<String>(
                  value: _selectedCollege,
                  hint: const Text('Select College'),
                  items: _programList.map((String program) {
                    return DropdownMenuItem<String>(
                      value: program,
                      child: Text(program),
                    );
                  }).toList(),
                  onChanged: _isEditingProfile
                      ? (newValue) {
                    setState(() {
                      _selectedCollege = newValue;
                      _selectedProgram =
                      null; // Reset program when college changes
                    });
                  }
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'College',
                  ),
                ),
                const SizedBox(height: 16.0),

                // Program Dropdown (similarly controlled)
                if (_selectedCollege != null)
                  DropdownButtonFormField<String>(
                    value: _selectedProgram,
                    hint: const Text('Select Program'),
                    items: _programList.map((String program) {
                      return DropdownMenuItem<String>(
                        value: program,
                        child: Text(program),
                      );
                    }).toList(),
                    onChanged: _isEditingProfile
                        ? (newValue) {
                      setState(() {
                        _selectedProgram = newValue;
                      });
                    }
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Program',
                    ),
                  ),
                const SizedBox(height: 16.0),

                // Year Level Dropdown (controlled by _isEditingProfile)
                DropdownButtonFormField<String>(
                  value: _selectedYearLevel,
                  hint: const Text('Select Year Level'),
                  items: const [
                    DropdownMenuItem(value: '1st Year', child: Text('1st Year')),
                    DropdownMenuItem(value: '2nd Year', child: Text('2nd Year')),
                    DropdownMenuItem(value: '3rd Year', child: Text('3rd Year')),
                    DropdownMenuItem(value: '4th Year', child: Text('4th Year')),
                  ],
                  onChanged: _isEditingProfile
                      ? (newValue) {
                    setState(() {
                      _selectedYearLevel = newValue;
                    });
                  }
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Year Level',
                  ),
                ),

                const SizedBox(height: 32.0),

                // Save Changes Button (always enabled; handles save logic)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement data saving logic here - send data to backend
                      //  (e.g., Firebase).
                      //  This function will be called when the "Save Changes"
                      //  button is pressed, whether or not _isEditingProfile is true.

                      if (kDebugMode) {
                        print('Saving user data...');
                      }
                      if (kDebugMode) {
                        print('Name: $_name');
                      }
                      if (kDebugMode) {
                        print('Descriptions: $_descriptions');
                      }
                      if (kDebugMode) {
                        print('College: $_selectedCollege');
                      }
                      if (kDebugMode) {
                        print('Program: $_selectedProgram');
                      }
                      if (kDebugMode) {
                        print('Year Level: $_selectedYearLevel');
                      }

                      _toggleEditProfile(); // Automatically exit edit mode after saving
                    },
                    child: const Text("Save Changes"),
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