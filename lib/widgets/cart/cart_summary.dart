import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/data/models/promo.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class CartSummary extends StatelessWidget {
  final CartProvider cart;
  final bool showCheckoutButton;
  final VoidCallback? onCheckout;

  const CartSummary({
    super.key,
    required this.cart,
    this.showCheckoutButton = false,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(
          height: 1,
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 16),
        Text(
          'Items in your bag',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: AppColors.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                cart.removeItem(item.id);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.12)
                      : const Color(0xFFFAFAF9),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.07),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 68,
                        height: 76,
                        child: ProductImage(
                          image: item.image,
                          fit: BoxFit.contain,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey[100],
                          iconColor: isDark
                              ? Colors.white38
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Size ${item.size}  ·  ${item.color}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty ${item.quantity}  ·  ${CurrencyUtil.format(item.price)} each',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyUtil.format(item.totalPrice),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove ${item.productName}',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => cart.removeItem(item.id),
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const PromoCodeField(),
        const SizedBox(height: 16),
        _buildTotals(context, cart, isDark),
        if (showCheckoutButton) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CHECKOUT'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTotals(BuildContext context, CartProvider cart, bool isDark) {
    final textColor = isDark ? AppColors.white : AppColors.black;
    final mutedColor = isDark ? Colors.white70 : Colors.grey[600];

    return Column(
      children: [
        _buildSummaryRow(
          'Subtotal',
          CurrencyUtil.format(cart.subtotal),
          mutedColor,
          textColor,
          isBold: false,
          amountBold: false,
        ),
        const SizedBox(height: 8),
        _buildSummaryRow(
          'Shipping',
          cart.shipping == 0 ? 'FREE' : CurrencyUtil.format(cart.shipping),
          mutedColor,
          textColor,
          isBold: false,
        ),
        const SizedBox(height: 8),
        if (cart.discount > 0)
          _buildSummaryRow(
            'Discount',
            '-${CurrencyUtil.format(cart.discount)}',
            Colors.green,
            textColor,
            isBold: true,
          ),
        const SizedBox(height: 8),
        _buildSummaryRow(
          'Tax',
          CurrencyUtil.format(cart.tax),
          mutedColor,
          textColor,
          isBold: false,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _buildSummaryRow(
          'TOTAL',
          CurrencyUtil.format(cart.total),
          textColor,
          textColor,
          isBold: true,
          amountBold: true,
          isTotal: true,
        ),
        if (cart.remainingForFreeShipping > 0 && cart.subtotal > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add ${CurrencyUtil.format(cart.remainingForFreeShipping)} more for FREE shipping',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String amount,
    Color? labelColor,
    Color? amountColor, {
    bool isBold = false,
    bool amountBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: labelColor,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: amountBold ? FontWeight.w700 : FontWeight.w400,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

class PromoCodeField extends StatefulWidget {
  const PromoCodeField({super.key});

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cart.appliedPromo != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROMO APPLIED: ${cart.appliedPromo!.code}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.green),
              onPressed: () => cart.removePromo(),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              isDense: true,
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[300]!,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 42,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _applyPromo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('APPLY'),
          ),
        ),
      ],
    );
  }

  void _applyPromo() {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final cart = context.read<CartProvider>();
      Promo? matchingPromo;
      for (final p in Promo.defaults) {
        if (p.code == code && p.isValidFor(cart.subtotal)) {
          matchingPromo = p;
          break;
        }
      }

      setState(() => _isLoading = false);

      if (matchingPromo != null) {
        cart.applyPromo(matchingPromo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Promo applied successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Invalid or expired promo code'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
