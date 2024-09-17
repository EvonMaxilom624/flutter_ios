import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => CreateEventPageState();
}

class CreateEventPageState extends State<CreateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  File? _imageFile;
  String? _filePath; // Used to store file path for desktop platforms
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'], // Specify allowed image formats
      );
      setState(() {
        if (result != null) {
          if (Platform.isAndroid || Platform.isIOS) {
            // For mobile platforms, use ImagePicker
            _imageFile = File(result.files.single.path!);
          } else {
            // For desktop platforms, store file path
            _filePath = result.files.single.path!;
          }
        }
      });
    } catch (e) {
      log('Error picking image: $e');
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _uploadEvent(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = await _uploadImage();

        await _addEventData(imageUrl);

        Navigator.pop(context); // Navigate back after successful upload
      } catch (e) {
        log('Error uploading event: $e');
        _showErrorSnackBar('Error uploading event: $e');
      }
    } else {
      _showErrorSnackBar('Please fill all fields');
    }
  }

  Future<String> _uploadImage() async {
    try {
      String filePath = _imageFile != null ? _imageFile!.path : _filePath!;
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('event_images/$fileName');
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _addEventData(String imageUrl) async {
    try {
      await Firebase.initializeApp(); // Initialize Firebase if not initialized
      CollectionReference events = FirebaseFirestore.instance.collection('events');
      await events.add({
        'title': _titleController.text,
        'content': _contentController.text,
        'personsAttending': int.tryParse(_personsController.text) ?? 0,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error adding event data: $e');
      rethrow;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _uploadEvent(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _personsController,
                decoration: const InputDecoration(labelText: 'Persons Attending'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of persons attending';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              _imageFile != null || _filePath != null
                  ? Image.file(_imageFile ?? File(_filePath!))
                  : InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200.0,
                  color: Colors.grey[200],
                  child: const Icon(Icons.add_a_photo, size: 50.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
