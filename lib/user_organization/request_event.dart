import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/widgets/appbar.dart';

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
  String? _sarfFile;
  String? _requestLetterFile;

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

  Future<void> _pickFile() async {
    // Placeholder for file picking logic
    // You can use packages like file_picker or image_picker for this
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
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
                    : '${_dateTimeRange!.start} - ${_dateTimeRange!.end}'),
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
                title: Text(_sarfFile == null ? 'Upload SARF' : _sarfFile!),
                trailing: const Icon(Icons.attach_file),
                onTap: _pickFile,
              ),
              ListTile(
                title: Text(_requestLetterFile == null
                    ? 'Upload Request Letter'
                    : _requestLetterFile!),
                trailing: const Icon(Icons.attach_file),
                onTap: _pickFile,
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
