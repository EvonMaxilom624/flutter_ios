import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/user_organization/event_status.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'dart:io';
import 'dart:async';

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
  bool _isButtonDisabled = false; // Flag to track button state
  final int _disableDuration = 5;



  Future<void> _selectDateTimeRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateTimeRange) {
      setState(() {
        _dateTimeRange = picked;
      });
    }
  }

  Future<void> _pickSarfFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _sarfFile = result.files.first;
      });
    }
  }

  Future<void> _pickRequestLetterFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _requestLetterFile = result.files.first;
      });
    }
  }

  void _submitForm() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSubmission();
    });
  }

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.uid; // Get the user ID
  }

  Future<int> _getNextEventId() async {
    final eventsCollection = FirebaseFirestore.instance.collection('Events');
    final querySnapshot = await eventsCollection.orderBy('eventId', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastEvent = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return (lastEvent['eventId'] as int) + 1;
    } else {
      return 100000; // Starting ID
    }
  }

  Future<void> _performSubmission() async {
    if (_formKey.currentState!.validate() &&
        _dateTimeRange != null &&
        _sarfFile != null &&
        _requestLetterFile != null &&
        _userId != null) {
      setState(() {
        _isButtonDisabled = true; // Disable the button
      });
      try {
        // Check if an event with the same details already exists
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Events')
            .where('eventName', isEqualTo: _eventNameController.text)
            .where('startDate', isEqualTo: _dateTimeRange!.start)
            .where('endDate', isEqualTo: _dateTimeRange!.end)
            .where('venue', isEqualTo: _venueController.text)
            .where('participants', isEqualTo: _participantsController.text)
            .where('budgetSource', isEqualTo: _budgetSourceController.text)
            .where('budgetAmount', isEqualTo: _budgetAmountController.text)
            .where('description', isEqualTo: _descriptionController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Event already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('An event with these details already exists.')),
          );
          return;
        }

        // Get the next event ID
        final nextEventId = await _getNextEventId();

        // Event doesn't exist, proceed with submission
        final storage = FirebaseStorage.instance;
        final sarfFileRef = storage
            .ref()
            .child('event_files/${nextEventId}_sarf'); // Use event ID in file name
        final requestLetterFileRef = storage
            .ref()
            .child('event_files/${nextEventId}_request'); // Use event ID in file name

        await sarfFileRef.putFile(File(_sarfFile!.path!));
        await requestLetterFileRef.putFile(File(_requestLetterFile!.path!));

        final sarfFileUrl = await sarfFileRef.getDownloadURL();
        final requestLetterFileUrl = await requestLetterFileRef.getDownloadURL();


        await FirebaseFirestore.instance.collection('Events').add({
          'eventName': _eventNameController.text,
          'startDate': _dateTimeRange!.start,
          'endDate': _dateTimeRange!.end,
          'venue': _venueController.text,
          'participants': _participantsController.text,
          'budgetSource': _budgetSourceController.text,
          'budgetAmount': double.parse(_budgetAmountController.text),
          'description': _descriptionController.text,
          'sarfFileUrl': sarfFileUrl,
          'requestLetterFileUrl': requestLetterFileUrl,
          'status': '_forApproval',
          'requesterId': _userId,
          'eventId': nextEventId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Event request submitted successfully!')),
        );
      } catch (e) {
        log('Error submitting event request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit event request.')),
        );
      } finally {
        // Re-enable the button after the specified duration
        Timer(Duration(seconds: _disableDuration), () {
          setState(() {
            _isButtonDisabled = false;
          });
          Navigator.pushReplacement( // Use pushReplacement to prevent going back to the form
            context,
            MaterialPageRoute(builder: (context) => const EventStatusPage()),
          );
        });
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and upload files.')),
      );
    }
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
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'What',
                  hintText: 'Event Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(_dateTimeRange == null
                    ? 'When'
                    : '${_dateTimeRange!.start.toLocal()} - ${_dateTimeRange!.end.toLocal()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTimeRange(context),
              ),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Where',
                  hintText: 'Venue',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the venue';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _participantsController,
                decoration: const InputDecoration(
                  labelText: 'Who',
                  hintText: 'Participants',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the participants';
                  }
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _budgetSourceController,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        hintText: 'Budget Source',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the budget source';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the budget amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title:
                    Text(_sarfFile == null ? 'Upload SARF' : _sarfFile!.name),
                trailing: const Icon(Icons.attach_file),
                onTap: _pickSarfFile,
              ),
              ListTile(
                title: Text(_requestLetterFile == null
                    ? 'Upload Request Letter'
                    : _requestLetterFile!.name),
                trailing: const Icon(Icons.attach_file),
                onTap: _pickRequestLetterFile,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isButtonDisabled ? null : _submitForm, // Disable if _isButtonDisabled is true
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
