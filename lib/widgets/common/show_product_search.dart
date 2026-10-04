import 'package:flutter/material.dart';

Future<String?> showProductSearch(
  BuildContext context, {
  String initialQuery = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ProductSearchDialog(initialQuery: initialQuery),
  );
}

class _ProductSearchDialog extends StatefulWidget {
  final String initialQuery;

  const _ProductSearchDialog({required this.initialQuery});

  @override
  State<_ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<_ProductSearchDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.black;

    return AlertDialog(
      title: const Text('Search products'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Product name, category, or keyword',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Clear search',
              onPressed: _controller.clear,
              icon: const Icon(Icons.close),
            ),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: foreground,
            foregroundColor: isDark ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          icon: const Icon(Icons.search, size: 17),
          label: const Text('Search'),
        ),
      ],
    );
  }
}
