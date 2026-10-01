import 'package:flutter/material.dart';
import 'package:flutter_ios_demo/screens/todo_home_page.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: TodoHomePage()));
}

Future<void> _addTodo(WidgetTester tester, String title) async {
  await tester.enterText(find.byType(TextField), title);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '添加'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty state before anything is added', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    expect(find.text('还没有待办事项'), findsOneWidget);
    expect(find.text('Flutter iOS Demo'), findsOneWidget);
  });

  testWidgets('add button stays disabled until the input has content', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    final Finder addButton = find.widgetWithText(FilledButton, '添加');
    expect(tester.widget<FilledButton>(addButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(addButton).onPressed,
      isNull,
      reason: 'whitespace-only input must not be addable',
    );

    await tester.enterText(find.byType(TextField), '写代码');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(addButton).onPressed, isNotNull);
  });

  testWidgets('adding a todo renders it and clears the input', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await _addTodo(tester, '写代码');

    expect(find.text('写代码'), findsOneWidget);
    expect(find.text('还没有待办事项'), findsNothing);
    expect(find.text('待完成 1 项'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '');
  });

  testWidgets('tapping the checkbox completes a todo and updates the counter', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await _addTodo(tester, '写代码');

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    expect(find.text('全部完成 🎉'), findsOneWidget);
    final CheckboxListTile tile =
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(tile.value, isTrue);
  });

  testWidgets('the delete icon removes a todo and restores the empty state', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await _addTodo(tester, '写代码');

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('写代码'), findsNothing);
    expect(find.text('还没有待办事项'), findsOneWidget);
  });

  testWidgets('clear-completed is disabled until something is completed', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await _addTodo(tester, '写代码');

    final Finder sweep = find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined);
    expect(tester.widget<IconButton>(sweep).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(sweep).onPressed, isNotNull);

    await tester.tap(sweep);
    await tester.pumpAndSettle();
    expect(find.text('还没有待办事项'), findsOneWidget);
  });

  testWidgets('multiple todos keep independent completion state', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await _addTodo(tester, '第一条');
    await _addTodo(tester, '第二条');

    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(find.text('待完成 2 项'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('待完成 1 项'), findsOneWidget);
  });
}
