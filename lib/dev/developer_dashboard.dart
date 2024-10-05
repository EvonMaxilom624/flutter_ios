import 'package:flutter/material.dart';
import 'package:flutter_ios/dev/developer_sidebar.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class DevBoard extends StatelessWidget {
  const DevBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      drawer: const CollapsibleSidebarDeveloper(),
      body: const CustomBackground(child: Center(child: Text('Welcome my developer!'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Request function logic here
        },
        child: const Icon(Icons.request_page),
      ),
    );
  }
}
