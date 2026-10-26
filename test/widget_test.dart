import 'package:flutter_test/flutter_test.dart';
import 'package:panchatantra_app/main.dart';

void main() {
  testWidgets('App renders splash screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PanchatantraApp());
    expect(find.textContaining('Panchatantra'), findsWidgets);
  });
}
