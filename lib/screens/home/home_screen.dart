import 'package:flutter/material.dart';

import '../dashboard/dashboard_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return const DashboardShell();
  }
}


