import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/task_details_screen.dart';

void main() {
  runApp(const SlaTrackerApp());
}

class SlaTrackerApp extends StatelessWidget {
  const SlaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.signIn,
      routes: {
        AppRoutes.signIn: (context) => const SignInScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.taskForm: (context) => const TaskFormScreen(),
        AppRoutes.taskDetails: (context) => const TaskDetailsScreen(),
        // Teammates: send Erin a PR (or ask) to add your screen's route here
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Coming soon')),
          body: Center(child: Text('${settings.name} is not built yet')),
        ),
      ),
    );
  }
}
