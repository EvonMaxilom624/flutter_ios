import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/user_organization/profile_edit.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class OrgProfilePage extends StatefulWidget {
  const OrgProfilePage({super.key});

  @override
  State<OrgProfilePage> createState() => _OrgProfilePageState();
}

class _OrgProfilePageState extends State<OrgProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = "Organization Name";
  String _president = "";
  String _externalVP = "";
  String _internalVP = "";
  String _secretary = "";
  String _assistantSecretary = "";
  String _treasurer = "";
  String _assistantTreasurer = "";
  String _auditor = "";
  String _assistantAuditor = "";
  String _pio1 = "";
  String _pio2 = "";

  @override
  void initState() {
    super.initState();
    _loadOrganizationDetails();
  }

  void _loadOrganizationDetails() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('organizations').doc('orgProfile').get();
      if (doc.exists) {
        setState(() {
          _name = doc['name'];
          _president = doc['president'];
          _externalVP = doc['externalVP'];
          _internalVP = doc['internalVP'];
          _secretary = doc['secretary'];
          _assistantSecretary = doc['assistantSecretary'];
          _treasurer = doc['treasurer'];
          _assistantTreasurer = doc['assistantTreasurer'];
          _auditor = doc['auditor'];
          _assistantAuditor = doc['assistantAuditor'];
          _pio1 = doc['pio1'];
          _pio2 = doc['pio2'];
        });
      }
    } catch (e) {
      log("Error loading data: $e");
    }
  }

  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrgProfilePage(
          president: _president,
          externalVP: _externalVP,
          internalVP: _internalVP,
          secretary: _secretary,
          assistantSecretary: _assistantSecretary,
          treasurer: _treasurer,
          assistantTreasurer: _assistantTreasurer,
          auditor: _auditor,
          assistantAuditor: _assistantAuditor,
          pio1: _pio1,
          pio2: _pio2,
          onSave: _loadOrganizationDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Organization Profile',
      ),
      drawer: const CollapsibleSidebarOrganization(),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Center(
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage(
                          'assets/profile_placeholder.png',
                        ), // TODO Replace with your image asset or network image
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    Text(
                      _name,
                      style: const TextStyle(fontSize: 19.0),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                const Divider(),
                const Text(
                  "Officers",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                _buildOfficerEntry("President", _president),
                _buildOfficerEntry("External VP", _externalVP),
                _buildOfficerEntry("Internal VP", _internalVP),
                _buildOfficerEntry("Secretary", _secretary),
                _buildOfficerEntry("Assistant Secretary", _assistantSecretary),
                _buildOfficerEntry("Treasurer", _treasurer),
                _buildOfficerEntry("Assistant Treasurer", _assistantTreasurer),
                _buildOfficerEntry("Auditor", _auditor),
                _buildOfficerEntry("Assistant Auditor", _assistantAuditor),
                _buildOfficerEntry("PIO 1", _pio1),
                _buildOfficerEntry("PIO 2", _pio2),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _navigateToEditPage,
                  child: const Text("Edit Details"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfficerEntry(String title, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title: ${name.isNotEmpty ? name : 'N/A'}',
            style: const TextStyle(fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}