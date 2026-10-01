import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../state/todo_controller.dart';

/// Single-screen todo list: add, complete, delete.
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TodoController _controller = TodoController();
  final TextEditingController _textController = TextEditingController();

  /// Mirrors whether the input holds non-blank text, so the add button can be
  /// disabled without rebuilding on every unrelated change.
  bool _canAdd = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final bool canAdd = _textController.text.trim().isNotEmpty;
    if (canAdd != _canAdd) {
      setState(() => _canAdd = canAdd);
    }
  }

  void _submit() {
    if (_controller.add(_textController.text) == null) {
      return;
    }

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter iOS Demo'),
        actions: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return IconButton(
                onPressed:
                    _controller.completed == 0 ? null : _controller.clearCompleted,
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: '清除已完成',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildInputRow(),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                if (_controller.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _controller.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final TodoItem item = _controller.items[index];
                    return _buildRow(context, item);
                  },
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              if (_controller.isEmpty) {
                return const SizedBox.shrink();
              }

              final int remaining = _controller.pending;
              final String label = remaining == 0
                  ? '全部完成 🎉'
                  : '待完成 $remaining 项';
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: '新待办',
                hintText: '添加一个待办事项…',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _canAdd ? _submit : null,
            icon: const Icon(Icons.add),
            label: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.checklist_rtl,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text('还没有待办事项', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '在上方输入内容，点击“添加”开始。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, TodoItem item) {
    return Dismissible(
      key: ValueKey<String>('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => _controller.remove(item.id),
      child: CheckboxListTile(
        key: ValueKey<String>('item-${item.id}'),
        value: item.done,
        onChanged: (_) => _controller.toggle(item.id),
        title: Text(
          item.title,
          style: item.done
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '删除',
          onPressed: () => _controller.remove(item.id),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
