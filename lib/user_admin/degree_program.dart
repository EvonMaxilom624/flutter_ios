import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_admin.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class DegreeProgramPage extends StatefulWidget {
  const DegreeProgramPage({super.key});

  @override
  State<DegreeProgramPage> createState() => _DegreeProgramPageState();
}

class _DegreeProgramPageState extends State<DegreeProgramPage> {
  final TextEditingController _programController = TextEditingController();
  final CollectionReference _degreeProgramsCollection =
  FirebaseFirestore.instance.collection('degree_programs');

  @override
  void dispose() {
    _programController.dispose();
    super.dispose();
  }

  // Function to add a new degree program to Firestore
  Future<void> _addProgram() async {
    String programName = _programController.text.trim();

    if (programName.isEmpty) {
      _showErrorDialog('Program name cannot be empty.');
      return;
    }

    // Check if the degree program already exists
    QuerySnapshot existingPrograms = await _degreeProgramsCollection
        .where('name', isEqualTo: programName)
        .get();

    if (existingPrograms.docs.isNotEmpty) {
      _showErrorDialog('This degree program already exists.');
      return;
    }

    // Add the new degree program
    await _degreeProgramsCollection.add({'name': programName});
    _programController.clear();
  }

  // Function to update a degree program
  Future<void> _updateProgram(String id, String newName) async {
    String programName = newName.trim();

    if (programName.isEmpty) {
      _showErrorDialog('Program name cannot be empty.');
      return;
    }

    // Check if the new name already exists
    QuerySnapshot existingPrograms = await _degreeProgramsCollection
        .where('name', isEqualTo: programName)
        .get();

    if (existingPrograms.docs.isNotEmpty) {
      _showErrorDialog('This degree program already exists.');
      return;
    }

    await _degreeProgramsCollection.doc(id).update({'name': programName});
  }

  // Function to delete a degree program
  Future<void> _deleteProgram(String id) async {
    await _degreeProgramsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Degree Programs',
      ),
      drawer: const CollapsibleSidebarAdmin(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _programController,
                decoration: const InputDecoration(
                  labelText: 'Add Degree Program Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addProgram,
                child: const Text('Add Degree Program'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _degreeProgramsCollection
                      .orderBy('name') // Sort alphabetically
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching programs'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final programs = snapshot.data?.docs ?? [];

                    return ListView.builder(
                      itemCount: programs.length,
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        final programName = program['name'];
                        final programId = program.id;

                        return Card(
                          child: ListTile(
                            title: Text(programName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _editProgramDialog(
                                        context, programId, programName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProgram(programId),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog to edit a degree program
  void _editProgramDialog(BuildContext context, String id, String currentName) {
    final TextEditingController editController =
    TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Degree Program'),
          content: TextFormField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Program Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProgram(id, editController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
