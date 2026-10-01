import 'package:flutter_ios_demo/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app boots into the todo screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterIosDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter iOS Demo'), findsOneWidget);
    expect(find.text('还没有待办事项'), findsOneWidget);
  });
}
