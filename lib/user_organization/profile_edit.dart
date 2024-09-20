import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrgProfileEditPage extends StatefulWidget {
  final String organizationId;
  final String name;
  final List<Map<String, dynamic>> positions;
  final String? imageUrl;

  const OrgProfileEditPage({
    required this.organizationId,
    required this.name,
    required this.positions,
    this.imageUrl,
    super.key,
  });

  @override
  _OrgProfileEditPageState createState() => _OrgProfileEditPageState();
}

class _OrgProfileEditPageState extends State<OrgProfileEditPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final List<TextEditingController> _positionControllers = [];
  final List<TextEditingController> _valueControllers = [];
  final List<int> _rankSelections = [];
  XFile? _imageFile;
  String? _updatedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var positionData in widget.positions) {
      _positionControllers
          .add(TextEditingController(text: positionData['position']));
      _valueControllers
          .add(TextEditingController(text: positionData['assignedPerson']));
      _rankSelections.add(positionData['rank']);
    }
  }

  void _addNewPosition() {
    setState(() {
      _positionControllers.add(TextEditingController());
      _valueControllers.add(TextEditingController());
      _rankSelections.add(_rankSelections.length + 1);
    });
  }

  Future<void> _savePositions() async {
    List<Map<String, dynamic>> newPositions = [];
    for (int i = 0; i < _positionControllers.length; i++) {
      String position = _positionControllers[i].text;
      String value = _valueControllers[i].text;
      int rank = _rankSelections[i];
      if (position.isNotEmpty && value.isNotEmpty) {
        newPositions.add({
          'position': position,
          'assignedPerson': value,
          'rank': rank,
        });
      }
    }

    try {
      await _firestore
          .collection('organizations')
          .doc(widget.organizationId)
          .update({
        'positions': newPositions,
        'imageUrl': _updatedImageUrl ?? widget.imageUrl,
      });
      log('Saved image URL');
      Navigator.pop(context);
    } catch (e) {
      log('Error saving positions: $e');
    }
  }

  void _removePosition(int index) {
    setState(() {
      _positionControllers.removeAt(index);
      _valueControllers.removeAt(index);
      _rankSelections.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final ref = _storage
          .ref()
          .child('organization_images/${widget.organizationId}.jpg');
      await ref.putFile(File(_imageFile!.path));
      _updatedImageUrl = await ref.getDownloadURL();
      log('Updated image URL: $_updatedImageUrl');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile is updated. Restart to load profile picture.'),
        ),
      );

    } catch (e) {
      log('Error uploading image: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _positionControllers) {
      controller.dispose();
    }
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Organization Profile',
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8.0),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : (widget.imageUrl != null
                                ? AssetImage(widget.imageUrl!)
                                : const AssetImage(
                                    'assets/default_avatar.png'))
                            as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 19.0),
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const Text(
                "Edit Positions",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              ..._buildPositionFields(),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _addNewPosition,
                child: const Text("Add Position"),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _savePositions,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPositionFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _positionControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _positionControllers[i],
                  decoration: InputDecoration(labelText: "Position ${i + 1}"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _valueControllers[i],
                  decoration:
                      const InputDecoration(labelText: "Assigned Person"),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: _rankSelections[i],
                items: List.generate(
                        _positionControllers.length, (index) => index + 1)
                    .map((rank) => DropdownMenuItem<int>(
                          value: rank,
                          child: Text(rank.toString()),
                        ))
                    .toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _rankSelections[i] = newValue;
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removePosition(i),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }
}
