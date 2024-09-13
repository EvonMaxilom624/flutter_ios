import 'package:flutter/material.dart';
import 'package:flutter_ios/sidebar/sidebar_general.dart';
import 'package:flutter_ios/widgets/appbar.dart';
import 'package:flutter_ios/widgets/background.dart';

class GeneralUserDashboard extends StatelessWidget {
  const GeneralUserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
      ),
      drawer: CollapsibleSidebarGeneral(),
      body: CustomBackground(child: Center(child: Text('General User Content'))),
    );
  }
}
