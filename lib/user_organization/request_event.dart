import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'dart:io';

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
//TODO 09/20/24 need to test phone file
  Future<void> _pickRequestLetterFile() async {

    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _requestLetterFile = result.files.first;
      });
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _dateTimeRange != null &&
        _sarfFile != null &&
        _requestLetterFile != null) {
      try {
        // Upload files to Firebase Storage
        final storage = FirebaseStorage.instance;
        final sarfFileRef = storage
            .ref()
            .child('event_files/${DateTime.now().millisecondsSinceEpoch}_sarf');
        final requestLetterFileRef = storage.ref().child(
            'event_files/${DateTime.now().millisecondsSinceEpoch}_request');

        await sarfFileRef.putFile(File(_sarfFile!.path!));
        await requestLetterFileRef.putFile(File(_requestLetterFile!.path!));

        final sarfFileUrl = await sarfFileRef.getDownloadURL();
        final requestLetterFileUrl =
            await requestLetterFileRef.getDownloadURL();

        // Save data to Firestore
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
          'status': '_forApproval', // Hardcoded status
        });

        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Event request submitted successfully!')),
        );
      } catch (e) {
        // Handle errors
        log('Error submitting event request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit event request.')),
        );
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
                onPressed: _submitForm,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
