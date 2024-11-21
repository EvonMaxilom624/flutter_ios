import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../sidebar/sidebar_org.dart';
import '../user_organization/event_status.dart';
import '../widgets/appbar.dart';

class RequestEventPage extends StatefulWidget {
  const RequestEventPage({super.key});

  @override
  State<RequestEventPage> createState() => RequestEventPageState();
}

class RequestEventPageState extends State<RequestEventPage> {
  // Centralize configuration
  static const _config = (
  eventsCollection: 'Events',
  eventFilesPath: 'event_files',
  initialEventId: 100000,
  disableDuration: 5,
  maxBudgetAmount: 100000.0,
  );

  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  DateTimeRange? _dateTimeRange;
  PlatformFile? _sarfFile;
  PlatformFile? _requestLetterFile;

  String? _userId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _userId = AuthService().currentUser?.uid;
  }

  void _initializeControllers() {
    final fields = [
      'eventName', 'venue', 'participants',
      'budgetSource', 'budgetAmount', 'description'
    ];
    for (var field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  Future<void> _selectDateTimeRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null && picked.end.isAfter(picked.start)) {
      setState(() => _dateTimeRange = picked);
    } else if (picked != null) {
      _showSnackBar('End date must be after start date');
    }
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result?.files.isNotEmpty ?? false) {
      setState(() {
        if (type == 'sarf') _sarfFile = result!.files.first;
        else if (type == 'request') _requestLetterFile = result!.files.first;
      });
    }
  }

  Future<int> _getNextEventId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_config.eventsCollection)
        .orderBy('eventId', descending: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty
        ? (snapshot.docs.first.data()['eventId'] as int) + 1
        : _config.initialEventId;
  }

  Future<List<String?>> _uploadFiles(int eventId) async {
    final storage = FirebaseStorage.instance;
    final List<String?> fileUrls = List.filled(2, null); // Initialize with nulls

    try {
      // Upload SARF file
      if (_sarfFile != null && _sarfFile!.bytes != null) {
        final sarfRef = storage.ref().child('${_config.eventFilesPath}/${eventId}_sarf');
        await sarfRef.putData(_sarfFile!.bytes!);
        fileUrls[0] = await sarfRef.getDownloadURL();
        log("SARF Upload URL: ${fileUrls[0]}");
        log("Request Upload URL: ${fileUrls[1]}");

      }

      // Upload Request Letter file
      if (_requestLetterFile != null && _requestLetterFile!.bytes != null) {
        final requestRef = storage.ref().child('${_config.eventFilesPath}/${eventId}_request');
        await requestRef.putData(_requestLetterFile!.bytes!);
        fileUrls[1] = await requestRef.getDownloadURL();
      }
    } catch (e, stacktrace) {
      log('File upload error: $e', stackTrace: stacktrace);
      // Provide user feedback - show a snackbar or dialog
      _showSnackBar('File upload failed: $e');
      //You may want to handle different error codes in a more robust fashion
    }

    return fileUrls;
  }

  Future<void> _saveEventToFirestore(int eventId, List<String?> fileUrls) async {
    await FirebaseFirestore.instance.collection(_config.eventsCollection).add({
      'eventName': _controllers['eventName']!.text,
      'startDate': _dateTimeRange!.start,
      'endDate': _dateTimeRange!.end,
      'venue': _controllers['venue']!.text,
      'participants': _controllers['participants']!.text,
      'budgetSource': _controllers['budgetSource']!.text,
      'budgetAmount': double.tryParse(_controllers['budgetAmount']!.text) ?? 0.0,
      'description': _controllers['description']!.text,
      'sarfFileUrl': fileUrls[0],
      'requestLetterFileUrl': fileUrls[1],
      'status': '_forApproval',
      'requesterId': _userId,
      'eventId': eventId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _submitForm() async {
    if (_isSubmitting) return;

    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final eventId = await _getNextEventId();
      final fileUrls = await _uploadFiles(eventId);
      await _saveEventToFirestore(eventId, fileUrls);

      _showSnackBar('Event request submitted successfully!');
      _navigateToEventStatus();
    } catch (e) {
      _showSnackBar('Submission failed: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please complete all required fields');
      return false;
    }

    if (_dateTimeRange == null) {
      _showSnackBar('Please select a date range');
      return false;
    }

    if (_sarfFile == null || _requestLetterFile == null) {
      _showSnackBar('Please upload both required files');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToEventStatus() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventStatusPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Request Event'),
      drawer: const CollapsibleSidebarOrganization(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controllers['eventName'],
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
              controller: _controllers['venue'],
              decoration: const InputDecoration(labelText: 'Venue'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter the venue' : null,
            ),
            TextFormField(
              controller: _controllers['participants'],
              decoration: const InputDecoration(labelText: 'Participants'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter the participants' : null,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _controllers['budgetSource'],
                    decoration: const InputDecoration(labelText: 'Budget Source'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter the budget source' : null,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _controllers['budgetAmount'],
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
              controller: _controllers['description'],
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
              onPressed: _isSubmitting ? null : _submitForm,
              child: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
