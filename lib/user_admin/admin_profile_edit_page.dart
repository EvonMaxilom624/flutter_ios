import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class AdminProfileEditPage extends StatefulWidget {
  final String uid;
  final String name;
  final String? email;
  final String? imageUrl;

  const AdminProfileEditPage({
    required this.uid,
    required this.name,
    this.email,
    this.imageUrl,
    super.key,
  });

  @override
  _AdminProfileEditPageState createState() => _AdminProfileEditPageState();
}

class _AdminProfileEditPageState extends State<AdminProfileEditPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();


  XFile? _imageFile;
  String? _updatedImageUrl;
  firebase_storage.UploadTask? _uploadTask;


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email ?? '';
  }



  Future<void> _saveChanges() async {

    try {
      await _firestore
          .collection('users')
          .doc(widget.uid)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'imageUrl': _updatedImageUrl ?? widget.imageUrl,
      });

      log('Saved changes to user profile.');
      Navigator.pop(context);
    } catch (e) {
      log('Error saving changes: $e');
    }
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
      final ref = _storage.ref().child('user_images/${widget.uid}.jpg');
      _uploadTask = ref.putFile(File(_imageFile!.path));
      await _uploadTask!.whenComplete(() async {
        final url = await ref.getDownloadURL();
        if (mounted) {
          setState(() {
            _updatedImageUrl = url;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile is updated. Restart to load profile picture.'),
              ),
            );
          });
        }
      });

      log('Updated image URL: $_updatedImageUrl');
    } catch (e) {
      log('Error uploading image: $e');
    } finally{
      _uploadTask = null;
    }
  }

  @override
  void dispose() {
    _uploadTask?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Admin Profile', // Changed title
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
                        ? NetworkImage(widget.imageUrl!)
                        : const AssetImage(
                        'assets/default_avatar.png'))
                    as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter new name',
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter new email',
                ),
              ),

              const SizedBox(height: 10.0),
              const Divider(),
              const SizedBox(height: 10.0),

              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}