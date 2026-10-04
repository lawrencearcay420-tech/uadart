import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/order.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order? order;

  const OrderSuccessScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        leading: const AppBackButton(fallbackRoute: '/orders'),
        elevation: 0,
      ),
      body: PageBackground(
        intensity: 0.5,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: padding, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 0,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ORDER CONFIRMED',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.black,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you for your order.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order == null ? 'ORDER RECEIVED' : 'ORDER #${order!.orderNumber}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order == null
                        ? 'Your order has been received.'
                        : '${order!.items.fold<int>(0, (total, item) => total + item.quantity)} items · ${CurrencyUtil.format(order!.total)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/orders'),
                        child: Text(
                          'VIEW ORDER',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.white : AppColors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      TextButton(
                        onPressed: () => context.go('/shop'),
                        child: Text(
                          'CONTINUE SHOPPING',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.white : AppColors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
