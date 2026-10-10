import 'package:flutter_test/flutter_test.dart';
import 'package:sla_task_tracker/main.dart';

void main() {
  testWidgets('Sign in screen shows the four team members', (tester) async {
    await tester.pumpWidget(const SlaTrackerApp());

    expect(find.text('SLA Task Tracker'), findsOneWidget);
    expect(find.text('Select your name to continue'), findsOneWidget);
    expect(find.text('Erin'), findsOneWidget);
    expect(find.text('Cynthia'), findsOneWidget);
    expect(find.text('Cherish'), findsOneWidget);
    expect(find.text('Merveille'), findsOneWidget);
  });
}
