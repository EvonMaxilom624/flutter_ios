

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class EditOrgProfilePage extends StatefulWidget {

  final String president;
  final String externalVP;
  final String internalVP;
  final String secretary;
  final String assistantSecretary;
  final String treasurer;
  final String assistantTreasurer;
  final String auditor;
  final String assistantAuditor;
  final String pio1;
  final String pio2;
  final VoidCallback onSave;

  const EditOrgProfilePage({

    required this.president,
    required this.externalVP,
    required this.internalVP,
    required this.secretary,
    required this.assistantSecretary,
    required this.treasurer,
    required this.assistantTreasurer,
    required this.auditor,
    required this.assistantAuditor,
    required this.pio1,
    required this.pio2,
    required this.onSave,
    super.key,
  });

  @override
  State<EditOrgProfilePage> createState() => _EditOrgProfilePageState();
}

class _EditOrgProfilePageState extends State<EditOrgProfilePage> {

  late TextEditingController _presidentController;
  late TextEditingController _externalVPController;
  late TextEditingController _internalVPController;
  late TextEditingController _secretaryController;
  late TextEditingController _assistantSecretaryController;
  late TextEditingController _treasurerController;
  late TextEditingController _assistantTreasurerController;
  late TextEditingController _auditorController;
  late TextEditingController _assistantAuditorController;
  late TextEditingController _pio1Controller;
  late TextEditingController _pio2Controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _presidentController = TextEditingController(text: widget.president);
    _externalVPController = TextEditingController(text: widget.externalVP);
    _internalVPController = TextEditingController(text: widget.internalVP);
    _secretaryController = TextEditingController(text: widget.secretary);
    _assistantSecretaryController = TextEditingController(text: widget.assistantSecretary);
    _treasurerController = TextEditingController(text: widget.treasurer);
    _assistantTreasurerController = TextEditingController(text: widget.assistantTreasurer);
    _auditorController = TextEditingController(text: widget.auditor);
    _assistantAuditorController = TextEditingController(text: widget.assistantAuditor);
    _pio1Controller = TextEditingController(text: widget.pio1);
    _pio2Controller = TextEditingController(text: widget.pio2);
  }

  @override
  void dispose() {

    _presidentController.dispose();
    _externalVPController.dispose();
    _internalVPController.dispose();
    _secretaryController.dispose();
    _assistantSecretaryController.dispose();
    _treasurerController.dispose();
    _assistantTreasurerController.dispose();
    _auditorController.dispose();
    _assistantAuditorController.dispose();
    _pio1Controller.dispose();
    _pio2Controller.dispose();
    super.dispose();
  }

  void _saveDetails() async {
    try {
      await _firestore.collection('organizations').doc('OrgProfile').set({

        'president': _presidentController.text,
        'externalVP': _externalVPController.text,
        'internalVP': _internalVPController.text,
        'secretary': _secretaryController.text,
        'assistantSecretary': _assistantSecretaryController.text,
        'treasurer': _treasurerController.text,
        'assistantTreasurer': _assistantTreasurerController.text,
        'auditor': _auditorController.text,
        'assistantAuditor': _assistantAuditorController.text,
        'pio1': _pio1Controller.text,
        'pio2': _pio2Controller.text,
      });
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      log("Error saving data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Organization Profile',
      ),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5.0),
                const Divider(),
                const Text(
                  "Officers",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                _buildOfficerEntry("President", _presidentController),
                _buildOfficerEntry("External VP", _externalVPController),
                _buildOfficerEntry("Internal VP", _internalVPController),
                _buildOfficerEntry("Secretary", _secretaryController),
                _buildOfficerEntry("Assistant Secretary", _assistantSecretaryController),
                _buildOfficerEntry("Treasurer", _treasurerController),
                _buildOfficerEntry("Assistant Treasurer", _assistantTreasurerController),
                _buildOfficerEntry("Auditor", _auditorController),
                _buildOfficerEntry("Assistant Auditor", _assistantAuditorController),
                _buildOfficerEntry("PIO 1", _pio1Controller),
                _buildOfficerEntry("PIO 2", _pio2Controller),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _saveDetails,
                  child: const Text("Save Details"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfficerEntry(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
              ),
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}