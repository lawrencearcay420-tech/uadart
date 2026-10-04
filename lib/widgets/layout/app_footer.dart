import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Under Asawa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Good clothes. Thoughtfully made.',
            style: TextStyle(color: textColor, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 64,
            runSpacing: 20,
            children: [
              _buildColumn('SHOP', [
                'New Arrivals',
                'Clothing',
                'Accessories',
                'Sale',
              ], textColor),
              _buildColumn('HELP', [
                'Shipping',
                'Returns',
                'Size Guide',
                'Contact',
              ], textColor),
              _buildColumn('ACCOUNT', [
                'Profile',
                'Orders',
                'Wishlist',
              ], textColor),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 Under Asawa Clothing',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
      String header, List<String> items, Color? textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )),
      ],
    );
  }
}
