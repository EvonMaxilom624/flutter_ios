import 'dart:developer';
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/user_organization/event_status.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:path/path.dart' as path;


class RequestEventPage extends StatefulWidget {
  const RequestEventPage({super.key});

  @override
  State<RequestEventPage> createState() => RequestEventPageState();
}

class RequestEventPageState extends State<RequestEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _budgetSourceController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTimeRange? _dateTimeRange;
  PlatformFile? _sarfFile;
  PlatformFile? _requestLetterFile;
  Timer? _debounceTimer;
  String? _userId;
  bool _isButtonDisabled = false;
  final int _disableDuration = 5;

  static const String eventsCollectionName = 'Events';
  static const String eventFilesStoragePath = 'event_files';


  Future<void> _selectDateTimeRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateTimeRange && picked.end.isAfter(picked.start)) {
      setState(() {
        _dateTimeRange = picked;
      });
    } else if (picked != null && !picked.end.isAfter(picked.start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be after start date.')));
    }
  }

  Future<void> _pickFile(String fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      if (fileType == 'sarf') {
        setState(() => _sarfFile = result.files.first);
      } else if (fileType == 'request') {
        setState(() => _requestLetterFile = result.files.first);
      }
      log('Picked $fileType file: ${result.files.first.name}');
    } else {
      log('No $fileType file selected.');
    }
  }

  Future<int> _getNextEventId() async {
    final eventsCollection = FirebaseFirestore.instance.collection(eventsCollectionName);
    final querySnapshot = await eventsCollection
        .orderBy('eventId', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastEvent = querySnapshot.docs.first.data();
      return (lastEvent['eventId'] as int) + 1;
    } else {
      return 100000;
    }
  }

  Future<List<String?>> _uploadFiles(int eventId) async {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('event_files'); // Reference to the main 'event_files' folder
    final List<String?> downloadUrls = [];

    try {
      // Upload SARF file
      if (_sarfFile != null && _sarfFile!.bytes != null) {
        final sarfFileRef = storageRef.child('$eventId/${path.basename(_sarfFile!.path!)}'); //Corrected path
        log('Uploading SARF: ${_sarfFile!.name} to ${sarfFileRef.fullPath}'); // More descriptive log
        final uploadTask = sarfFileRef.putData(_sarfFile!.bytes!);
        await uploadTask;
        final sarfUrl = await sarfFileRef.getDownloadURL();
        downloadUrls.add(sarfUrl);
        log('SARF URL: $sarfUrl');
      } else {
        downloadUrls.add(null);
        log('SARF file not uploaded (null file or bytes)');
      }

      // Upload Request Letter file
      if (_requestLetterFile != null && _requestLetterFile!.bytes != null) {
        final requestLetterFileRef = storageRef.child('$eventId/${path.basename(_requestLetterFile!.path!)}'); //Corrected path
        log('Uploading Request Letter: ${_requestLetterFile!.name} to ${requestLetterFileRef.fullPath}'); // More descriptive log
        final uploadTask = requestLetterFileRef.putData(_requestLetterFile!.bytes!);
        await uploadTask;
        final requestLetterUrl = await requestLetterFileRef.getDownloadURL();
        downloadUrls.add(requestLetterUrl);
        log('Request Letter URL: $requestLetterUrl');
      } else {
        downloadUrls.add(null);
        log('Request Letter file not uploaded (null file or bytes)');
      }

      return downloadUrls;
    } on FirebaseException catch (e) {
      log('FirebaseException during upload: ${e.message} - ${e.code}'); // Include error code
      throw Exception('File upload failed: ${e.message}');
    } catch (e) {
      log('Exception during upload: $e');
      throw Exception('File upload failed: $e');
    }
  }



  Future<void> _saveEventToFirestore(int eventId, String? sarfUrl, String? requestLetterUrl) async {
    try {
      await FirebaseFirestore.instance.collection(eventsCollectionName).add({
        'eventName': _eventNameController.text,
        'startDate': _dateTimeRange!.start,
        'endDate': _dateTimeRange!.end,
        'venue': _venueController.text,
        'participants': _participantsController.text,
        'budgetSource': _budgetSourceController.text,
        'budgetAmount': double.tryParse(_budgetAmountController.text) ?? 0.0,
        'description': _descriptionController.text,
        'sarfFileUrl': sarfUrl,
        'requestLetterFileUrl': requestLetterUrl,
        'status': '_forApproval',
        'requesterId': _userId,
        'eventId': eventId,
      });
    } on FirebaseException catch (e) {
      log('Firestore error: ${e.message} - Code: ${e.code}');
      throw Exception("Firestore error: ${e.message}");
    }
    catch (e){
      log('Generic exception in Firestore: $e');
      throw Exception("Firestore error: $e");
    }
  }

  void _submitForm() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSubmission();
    });
  }

  Future<void> _performSubmission() async {
    if (_formKey.currentState!.validate()) {
      if (_dateTimeRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date range.') ),
        );
        return;
      }

      if (_sarfFile == null || _requestLetterFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload both files.') ),
        );
        return;
      }

      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.') ),
        );
        return;
      }

      setState(() => _isButtonDisabled = true);

      try {
        log('Form data:');
        log('Event Name: ${_eventNameController.text}');
        log('Venue: ${_venueController.text}');
        log('Participants: ${_participantsController.text}');
        log('Budget Source: ${_budgetSourceController.text}');
        log('Budget Amount: ${_budgetAmountController.text}');
        log('Description: ${_descriptionController.text}');

        final nextEventId = await _getNextEventId();
        log('Next Event ID: $nextEventId');
        final fileUrls = await _uploadFiles(nextEventId);
        await _saveEventToFirestore(nextEventId, fileUrls[0], fileUrls[1]);

        log('Event saved successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event request submitted successfully!') ),
        );
        Timer(Duration(seconds: _disableDuration), (){
          setState(() {
            _isButtonDisabled = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EventStatusPage()),
          );
        });

      } on Exception catch (e) {
        log('Error during submission: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit event request: $e') ),
        );
      } finally {
        setState(() => _isButtonDisabled = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and upload files.') ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.uid;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Request Event'),
      drawer: const CollapsibleSidebarOrganization(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // ... TextFormFields for event details
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter the event name' : null,
              ),
              ListTile(
                title: Text(_dateTimeRange == null
                    ? 'Select Date Range'
                    : '${_dateTimeRange!.start.toLocal()} - ${_dateTimeRange!.end.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTimeRange(context),
              ),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter the venue' : null,
              ),
              TextFormField(
                controller: _participantsController,
                decoration: const InputDecoration(labelText: 'Participants'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter the participants' : null,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _budgetSourceController,
                      decoration: const InputDecoration(labelText: 'Budget Source'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the budget source' : null,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetAmountController,
                      decoration: const InputDecoration(labelText: 'Budget Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the budget amount';
                        }
                        final amount = double.tryParse(value);
                        return amount == null || amount <= 0 ? 'Please enter a valid positive amount' : null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(_sarfFile == null ? 'Upload SARF File' : _sarfFile!.name),
                trailing: const Icon(Icons.upload_file),
                onTap: () => _pickFile('sarf'),
              ),
              ListTile(
                title: Text(_requestLetterFile == null ? 'Upload Request Letter' : _requestLetterFile!.name),
                trailing: const Icon(Icons.upload_file),
                onTap: () => _pickFile('request'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isButtonDisabled ? null : _submitForm,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}