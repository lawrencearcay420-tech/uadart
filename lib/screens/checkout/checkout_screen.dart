import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/page_background.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/currency.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/core/utils/validators.dart';
import 'package:clothingapp/data/models/address.dart';
import 'package:clothingapp/providers/cart_provider.dart';
import 'package:clothingapp/providers/order_provider.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/widgets/cart/cart_summary.dart';
import 'package:clothingapp/widgets/common/glass_panel.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';
import 'package:clothingapp/widgets/common/loading_state.dart';
import 'package:clothingapp/widgets/common/product_image.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum CheckoutStep { contact, payment, review }

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutStep _currentStep = CheckoutStep.contact;
  bool _isPlacingOrder = false;
  final _contactFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalController = TextEditingController();

  String _selectedPayment = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep == CheckoutStep.contact) {
      if (_validateContact()) {
        setState(() => _currentStep = CheckoutStep.payment);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please correct the highlighted fields to continue.'),
          ),
        );
      }
    } else if (_currentStep == CheckoutStep.payment) {
      setState(() => _currentStep = CheckoutStep.review);
    } else {
      await _placeOrder();
    }
  }

  bool _validateContact() {
    return _contactFormKey.currentState?.validate() ?? false;
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    if (cart.items.isEmpty) return;
    final customer = auth.currentUser;
    if (customer == null) {
      context.go(
        Uri(
          path: '/login',
          queryParameters: {
            'redirect': GoRouterState.of(context).uri.toString(),
          },
        ).toString(),
      );
      return;
    }

    final address = Address(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      barangay: _barangayController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      postalCode: _postalController.text.trim(),
    );

    setState(() => _isPlacingOrder = true);
    try {
      final order = await orderProvider.createOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        shipping: cart.shipping,
        discount: cart.discount,
        tax: cart.tax,
        total: cart.total,
        paymentMethod: _selectedPayment,
        shippingAddress: address,
        customer: customer,
      );
      if (!mounted) return;
      cart.clear();
      cart.removePromo();
      context.go('/order-success', extra: order);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to place your order: $error')),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _selectPayment(String method) {
    setState(() => _selectedPayment = method);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        elevation: 0,
        leading: const AppBackButton(fallbackRoute: '/shop'),
        title: Text(
          cart.items.isEmpty && !cart.isLoading ? 'Your bag' : 'Checkout',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STEP ${_currentStep.index + 1} OF 3',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageBackground(
        intensity: 0.2,
        child: cart.isLoading
            ? const LoadingState(message: 'Loading your bag...')
            : cart.items.isEmpty
            ? _buildEmptyBag(context, isDark)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: Responsive.isDesktop(context) ? 2 : 3,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete your order',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.black,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter your delivery details and review your purchase.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: EdgeInsets.all(
                                Responsive.isMobile(context) ? 16 : 24,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkGrey
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.12 : 0.035,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStepper(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 22,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                    ),
                                  ),
                                  _buildCurrentStep(cart, isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (Responsive.isDesktop(context))
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildCartSummary(context, cart, isDark),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: cart.isLoading || cart.items.isEmpty
          ? null
          : Responsive.isMobile(context)
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cart.items.isNotEmpty)
                    _buildCartSummary(context, cart, isDark),
                  const SizedBox(height: 8),
                  _buildBottomButton(cart),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 16,
                ),
                child: _buildBottomButton(cart),
              ),
            ),
    );
  }

  Widget _buildEmptyBag(BuildContext context, bool isDark) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGrey : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 32,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your bag is empty',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore the collection and add items to your bag. Your selections will be ready here when you are.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/shop'),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('EXPLORE THE COLLECTION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foreground,
                      foregroundColor: isDark
                          ? AppColors.black
                          : AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['CONTACT & SHIPPING', 'PAYMENT', 'REVIEW ORDER'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isActive = index == _currentStep.index;
        final completed = index < _currentStep.index;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: completed
                    ? Colors.black
                    : (isActive
                          ? Colors.black
                          : (isDark ? Colors.grey[800] : Colors.grey[300])),
                child: completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive || completed
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: completed
                      ? (isDark ? Colors.white : AppColors.black)
                      : (isActive
                            ? (isDark ? Colors.white : AppColors.black)
                            : (isDark ? Colors.white38 : Colors.grey[500])),
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentStep(CartProvider cart, bool isDark) {
    switch (_currentStep) {
      case CheckoutStep.contact:
        return _buildContactForm(isDark);
      case CheckoutStep.payment:
        return _buildPaymentForm(isDark);
      case CheckoutStep.review:
        return _buildReview(cart, isDark);
    }
  }

  Widget _buildContactForm(bool isDark) {
    return Form(
      key: _contactFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact Information', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            'Full Name',
            _nameController,
            validator: Validators.validateName,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Email',
            _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Phone',
            _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Shipping Address', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            'Street Address',
            _streetController,
            validator: Validators.validateAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Barangay',
            _barangayController,
            validator: Validators.validateAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'City',
            _cityController,
            validator: Validators.validateAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Province',
            _provinceController,
            validator: Validators.validateAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Postal Code',
            _postalController,
            keyboardType: TextInputType.number,
            validator: Validators.validatePostalCode,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(bool isDark) {
    final paymentMethods = [
      'Cash on Delivery',
      'GCash',
      'Maya',
      'Credit / Debit Card',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Method', isDark),
        const SizedBox(height: 8),
        Text(
          'Demo checkout payment selections.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        ...paymentMethods.map((method) => _buildPaymentOption(method, isDark)),
      ],
    );
  }

  Widget _buildPaymentOption(String method, bool isDark) {
    final isSelected = _selectedPayment == method;
    final foreground = isDark ? AppColors.white : AppColors.black;
    return GestureDetector(
      onTap: () => _selectPayment(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.035))
              : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
          border: Border.all(
            color: isSelected
                ? foreground
                : (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? foreground : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              method,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(CartProvider cart, bool isDark) {
    final foreground = isDark ? AppColors.white : AppColors.black;
    final muted = isDark ? Colors.white60 : Colors.grey[600];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Review Order', isDark),
        const SizedBox(height: 16),
        GlassPanel(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Delivery details', isDark),
              const SizedBox(height: 12),
              Text(
                _nameController.text.trim(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
              Text(
                '${_streetController.text.trim()}, ${_barangayController.text.trim()}\n'
                '${_cityController.text.trim()}, ${_provinceController.text.trim()} ${_postalController.text.trim()}',
                style: TextStyle(fontSize: 13, height: 1.5, color: muted),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Text(
                    'Payment method',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      _selectedPayment,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ProductImage(
                    image: item.image,
                    fit: BoxFit.contain,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                  ),
                ),
              ),
              title: Text(
                item.productName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
              subtitle: Text(
                'Size ${item.size} · ${item.color} · Qty ${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              trailing: Text(
                CurrencyUtil.format(item.totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.white : AppColors.black,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          validator: validator,
          style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
          decoration: InputDecoration(
            hintText: label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.grey[50],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.white : AppColors.black,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartProvider cart,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CartSummary(cart: cart),
    );
  }

  Widget _buildBottomButton(CartProvider cart) {
    final buttonText = _currentStep == CheckoutStep.payment
        ? 'CONTINUE TO REVIEW'
        : (_currentStep == CheckoutStep.review
              ? 'PLACE ORDER'
              : 'CONTINUE TO PAYMENT');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: cart.items.isEmpty || _isPlacingOrder ? null : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPlacingOrder
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(buttonText),
      ),
    );
  }
}
