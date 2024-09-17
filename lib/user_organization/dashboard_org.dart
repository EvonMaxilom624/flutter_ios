import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_org.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class OrganizationUserDashboard extends StatelessWidget {
  const OrganizationUserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      drawer: const CollapsibleSidebarOrganization(),
      body: const CustomBackground(child: Center(child: Text('Organization User Content'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Request function logic here
        },
        child: const Icon(Icons.request_page),
      ),
    );
  }
}
