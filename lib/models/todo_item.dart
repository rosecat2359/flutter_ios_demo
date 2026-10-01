/// A single todo entry.
///
/// Immutable on purpose: the UI rebuilds from a fresh list on every change, so
/// value equality is what makes `toggle`/`remove` cheap to reason about.
class TodoItem {
  const TodoItem({required this.id, required this.title, this.done = false});

  final String id;
  final String title;
  final bool done;

  TodoItem copyWith({String? title, bool? done}) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodoItem &&
        other.id == id &&
        other.title == title &&
        other.done == done;
  }

  @override
  int get hashCode => Object.hash(id, title, done);

  @override
  String toString() => 'TodoItem(id: $id, title: $title, done: $done)';
}
