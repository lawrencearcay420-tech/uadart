import 'package:flutter/material.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/data/models/product.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final Product product;

  const StockAdjustmentDialog({super.key, required this.product});

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final size in widget.product.sizes) {
      _controllers[size] = TextEditingController(
        text: widget.product.inventory[size]?.toString() ?? '0',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, int> _getNewInventory() {
    final inventory = <String, int>{};
    for (final entry in _controllers.entries) {
      inventory[entry.key] = int.tryParse(entry.value.text.trim()) ?? 0;
    }
    return inventory;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalStock = _getNewInventory().values.fold<int>(0, (sum, v) => sum + v);

    return AlertDialog(
      title: Text('Adjust stock: ${widget.product.name}'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._controllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key, style: TextStyle(color: isDark ? AppColors.white : AppColors.black)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: const InputDecoration(
                            hintText: 'Qty',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.grey[100])!.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total stock:', style: TextStyle(color: isDark ? AppColors.white : AppColors.black)),
                  Text('$totalStock', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_getNewInventory()),
          child: const Text('Save stock'),
        ),
      ],
    );
  }
}
