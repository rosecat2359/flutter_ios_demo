import 'package:flutter_ios_demo/state/todo_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoController', () {
    test('starts empty', () {
      final TodoController controller = TodoController();

      expect(controller.items, isEmpty);
      expect(controller.isEmpty, isTrue);
      expect(controller.total, 0);
      expect(controller.pending, 0);
      expect(controller.completed, 0);
    });

    test('seeds from initial titles, ignoring blank ones', () {
      final TodoController controller =
          TodoController(initialTitles: <String>['写代码', '  ', '喝水']);

      expect(controller.items.map((dynamic item) => item.title), <String>['写代码', '喝水']);
      expect(controller.pending, 2);
    });

    test('add trims the title and keeps insertion order', () {
      final TodoController controller = TodoController();

      controller.add('  写代码  ');
      controller.add('喝水');

      expect(controller.items.map((dynamic item) => item.title), <String>['写代码', '喝水']);
      expect(controller.total, 2);
      expect(controller.pending, 2);
    });

    test('add rejects empty and whitespace-only input without notifying', () {
      final TodoController controller = TodoController();
      int notifications = 0;
      controller.addListener(() => notifications++);

      expect(controller.add(''), isNull);
      expect(controller.add('   '), isNull);
      expect(controller.add('\n\t'), isNull);

      expect(controller.isEmpty, isTrue);
      expect(notifications, 0);
    });

    test('add returns the stored item and notifies once', () {
      final TodoController controller = TodoController();
      int notifications = 0;
      controller.addListener(() => notifications++);

      final dynamic item = controller.add('写代码');

      expect(item, isNotNull);
      expect(item.title, '写代码');
      expect(item.done, isFalse);
      expect(notifications, 1);
    });

    test('identical titles stay independent entries', () {
      final TodoController controller = TodoController();

      final dynamic first = controller.add('同名');
      final dynamic second = controller.add('同名');

      expect(first.id, isNot(second.id));
      expect(controller.total, 2);

      controller.toggle(first.id);
      expect(controller.items.first.done, isTrue);
      expect(controller.items.last.done, isFalse);
    });

    test('toggle flips completion and updates counters', () {
      final TodoController controller = TodoController();
      final dynamic item = controller.add('写代码');

      controller.toggle(item.id);
      expect(controller.items.single.done, isTrue);
      expect(controller.pending, 0);
      expect(controller.completed, 1);

      controller.toggle(item.id);
      expect(controller.items.single.done, isFalse);
      expect(controller.pending, 1);
      expect(controller.completed, 0);
    });

    test('toggle with an unknown id is a silent no-op', () {
      final TodoController controller = TodoController();
      controller.add('写代码');
      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggle('does-not-exist');

      expect(controller.items.single.done, isFalse);
      expect(notifications, 0);
    });

    test('remove deletes by id and ignores unknown ids', () {
      final TodoController controller = TodoController();
      final dynamic first = controller.add('第一条');
      controller.add('第二条');
      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.remove('nope');
      expect(notifications, 0);
      expect(controller.total, 2);

      controller.remove(first.id);
      expect(controller.items.map((dynamic item) => item.title), <String>['第二条']);
      expect(notifications, 1);
    });

    test('clearCompleted drops only completed entries', () {
      final TodoController controller = TodoController();
      final dynamic a = controller.add('A');
      controller.add('B');
      controller.toggle(a.id);

      controller.clearCompleted();

      expect(controller.items.map((dynamic item) => item.title), <String>['B']);
      expect(controller.completed, 0);
    });

    test('clearCompleted with nothing completed does not notify', () {
      final TodoController controller = TodoController();
      controller.add('A');
      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.clearCompleted();

      expect(controller.total, 1);
      expect(notifications, 0);
    });

    test('items getter exposes an unmodifiable view', () {
      final TodoController controller = TodoController();
      controller.add('A');

      expect(() => controller.items.clear(), throwsUnsupportedError);
    });
  });
}
