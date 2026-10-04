import 'package:clothingapp/widgets/common/show_product_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns the query without disposing the field during closing', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showProductSearch(context);
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'jacket');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(result, 'jacket');
    expect(tester.takeException(), isNull);
  });
}
