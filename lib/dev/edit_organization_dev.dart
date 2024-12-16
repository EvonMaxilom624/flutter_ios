import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ios/user_admin/organization_list.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrganizationScreenDev extends StatefulWidget {
  final Organization organization;

  const EditOrganizationScreenDev({super.key, required this.organization});

  @override
  State<EditOrganizationScreenDev> createState() => _EditOrganizationScreenDevState();
}

class _EditOrganizationScreenDevState extends State<EditOrganizationScreenDev> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.organization.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateOrganization() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('organizations').doc(widget.organization.docId).update({
          'name': _nameController.text,
        });
        await _firestore.collection('users').doc(widget.organization.docId).update({
          'name': _nameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating organization: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Organization',
      ),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _updateOrganization,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
