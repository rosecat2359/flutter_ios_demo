import 'package:flutter/foundation.dart';

import '../models/todo_item.dart';

/// In-memory todo state.
///
/// This is plain Dart on purpose: no plugin, no network, no persistence. That
/// keeps the demo buildable on any platform (including a bare iOS simulator on
/// a CI runner) and keeps the logic fully unit-testable.
class TodoController extends ChangeNotifier {
  TodoController({Iterable<String> initialTitles = const <String>[]}) {
    for (final title in initialTitles) {
      add(title);
    }
  }

  final List<TodoItem> _items = <TodoItem>[];
  int _nextId = 0;

  /// Items in insertion order.
  List<TodoItem> get items => List<TodoItem>.unmodifiable(_items);

  int get total => _items.length;

  int get pending => _items.where((TodoItem item) => !item.done).length;

  int get completed => total - pending;

  bool get isEmpty => _items.isEmpty;

  /// Adds [title] and returns it, or returns `null` when the title is blank.
  ///
  /// Blank input is rejected rather than stored, so the list can never contain
  /// an entry the user cannot see or select.
  TodoItem? add(String title) {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final TodoItem item = TodoItem(id: '${_nextId++}', title: trimmed);
    _items.add(item);
    notifyListeners();
    return item;
  }

  /// Flips the completion state of [id]. No-op when [id] is unknown.
  void toggle(String id) {
    final int index = _items.indexWhere((TodoItem item) => item.id == id);
    if (index == -1) {
      return;
    }

    final TodoItem item = _items[index];
    _items[index] = item.copyWith(done: !item.done);
    notifyListeners();
  }

  /// Removes [id]. No-op when [id] is unknown.
  void remove(String id) {
    final int before = _items.length;
    _items.removeWhere((TodoItem item) => item.id == id);
    if (_items.length != before) {
      notifyListeners();
    }
  }

  /// Removes every completed entry. No-op when nothing is completed.
  void clearCompleted() {
    if (completed == 0) {
      return;
    }

    _items.removeWhere((TodoItem item) => item.done);
    notifyListeners();
  }
}
