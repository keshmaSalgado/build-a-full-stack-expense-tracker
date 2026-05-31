import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the authentication screen before login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ExpenseTrackerMobile());
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
