import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/responsive.dart';
import 'package:clothingapp/data/models/address.dart';
import 'package:clothingapp/providers/account_settings_provider.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/theme_provider.dart';
import 'package:clothingapp/data/models/user.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';
import 'package:clothingapp/widgets/common/app_back_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<Address> _addresses = [];
  bool _settingsLoaded = false;
  StorageRepository? _storage;

  @override
  void initState() {
    super.initState();
    _loadAccountSettings();
  }

  Future<void> _loadAccountSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final storage = StorageRepository(preferences);
      final addresses = await storage.loadAddresses();
      if (!mounted) return;
      setState(() {
        _storage = storage;
        _addresses = addresses;
        _settingsLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _settingsLoaded = true);
      _showMessage('Unable to load account settings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AccountSettingsProvider>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.getHorizontalPadding(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.white : AppColors.black,
          leading: const AppBackButton(),
          title: const Text('Account'),
        ),
        body: const Center(child: Text('Please log in')),
      );
    }

    final baseTheme = Theme.of(context);
    final accent = isDark ? AppColors.white : AppColors.black;
    final fieldBorder = isDark ? Colors.white24 : Colors.black26;

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: accent,
          secondary: accent,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          titleTextStyle: TextStyle(
            color: isDark ? AppColors.white : AppColors.black,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[700],
            fontSize: 14,
            height: 1.5,
          ),
        ),
        inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: isDark ? AppColors.nearBlack : AppColors.offWhite,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accent, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: isDark ? AppColors.black : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? (isDark ? AppColors.black : AppColors.white)
                : null,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? accent.withValues(alpha: 0.65)
                : null,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.nearBlack : AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.nearBlack : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const AppBackButton(),
          title: const Text(
            'My Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: () => auth.logout(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 28, padding, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(user, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('ACCOUNT', isDark),
                  const SizedBox(height: 12),
                  _buildMenuItems(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('PREFERENCES', isDark),
                  const SizedBox(height: 12),
                  _buildPreferences(context, isDark, settings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(User user, bool isDark) {
    final surface = isDark ? AppColors.darkGrey : AppColors.white;
    final secondary = isDark ? Colors.white70 : Colors.grey[600];
    final role = user.role.index == UserRole.customer.index
        ? 'Customer'
        : 'Administrator';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isDark ? AppColors.warmGrey : AppColors.offWhite,
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: secondary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.warmGrey : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.coolGrey : Colors.grey[700],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    final items = [
      {'icon': Icons.person, 'title': 'Edit Profile'},
      {'icon': Icons.location_on, 'title': 'My Address'},
      {'icon': Icons.favorite, 'title': 'Wishlist', 'route': '/wishlist'},
      {'icon': Icons.receipt_long, 'title': 'My Orders', 'route': '/orders'},
      {'icon': Icons.notifications, 'title': 'Notifications'},
      {'icon': Icons.help_outline, 'title': 'Help & Support'},
      {'icon': Icons.info_outline, 'title': 'About Us'},
    ];
    if (context.read<AuthProvider>().isAdmin) {
      items.insert(0, {
        'icon': Icons.admin_panel_settings_outlined,
        'title': 'Admin product management',
        'route': '/admin',
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          final icon = item['icon'] as IconData;
          final title = item['title'] as String;
          final route = item['route'] as String?;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 3,
                ),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: isDark
                      ? AppColors.warmGrey
                      : AppColors.offWhite,
                  child: Icon(
                    icon,
                    size: 17,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                onTap: () {
                  if (route != null) {
                    context.go(route);
                  } else {
                    _handleAccountAction(title);
                  }
                },
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferences(
    BuildContext context,
    bool isDark,
    AccountSettingsProvider settings,
  ) {
    final themeProvider = context.watch<AppThemeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          _buildPreferenceRow(
            context,
            'Dark Mode',
            Switch(
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeThumbColor: isDark ? AppColors.black : AppColors.white,
            ),
            isDark,
          ),
          const Divider(height: 1),
          _buildPreferenceRow(
            context,
            'Reduced Motion',
            Switch(
              value: settings.reducedMotion,
              onChanged: _settingsLoaded
                  ? (value) => _updatePreference(
                      () => settings.setReducedMotion(value),
                    )
                  : null,
              activeThumbColor: isDark ? AppColors.black : AppColors.white,
            ),
            isDark,
          ),
          const Divider(height: 1),
          _buildPreferenceRow(
            context,
            'Notifications',
            Switch(
              value: settings.notificationsEnabled,
              onChanged: _settingsLoaded
                  ? (value) => _updatePreference(
                      () => settings.setNotificationsEnabled(value),
                    )
                  : null,
              activeThumbColor: isDark ? AppColors.black : AppColors.white,
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(
    BuildContext context,
    String label,
    Widget control,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.white : AppColors.black,
          ),
        ),
        control,
      ],
    );
  }

  Future<void> _updatePreference(Future<void> Function() update) async {
    try {
      await update();
    } catch (error) {
      _showMessage('Unable to save this preference: $error');
    }
  }

  void _handleAccountAction(String title) {
    switch (title) {
      case 'Edit Profile':
        _showEditProfile();
      case 'My Address':
        _showAddresses();
      case 'Notifications':
        _showNotificationSettings();
        break;
      case 'Help & Support':
        _showInformation(
          title,
          'For help with orders, deliveries, or returns, contact '
          'support@underasawa.com. Please include your order number '
          'when asking about an existing order.',
        );
        break;
      case 'About Us':
        _showInformation(
          title,
          'Under Asawa offers considered everyday clothing essentials, '
          'designed around comfort, quality, and quiet confidence.',
        );
        break;
    }
  }

  Future<void> _showEditProfile() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.white : AppColors.black;
    final secondary = isDark ? Colors.white70 : Colors.grey[700]!;
    final surface = isDark ? AppColors.darkGrey : AppColors.white;
    final fieldFill = isDark ? AppColors.nearBlack : AppColors.offWhite;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogBaseTheme = Theme.of(dialogContext);
          final neutralDialogTheme = dialogBaseTheme.copyWith(
            colorScheme: dialogBaseTheme.colorScheme.copyWith(
              primary: foreground,
              secondary: foreground,
              surface: surface,
              onSurface: foreground,
            ),
            inputDecorationTheme: dialogBaseTheme.inputDecorationTheme.copyWith(
              filled: true,
              fillColor: fieldFill,
              labelStyle: TextStyle(color: secondary),
              prefixIconColor: secondary,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: foreground, width: 1.4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.4,
                ),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: foreground,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: secondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );

          return Theme(
            data: neutralDialogTheme,
            child: AlertDialog(
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              title: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(dialogContext, false),
                    icon: Icon(Icons.arrow_back, color: foreground),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit profile',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Update your personal information',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            return RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(email)
                                ? null
                                : 'Enter a valid email address';
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: const InputDecoration(
                            labelText: 'Phone number (optional)',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Save changes'),
                ),
              ],
            ),
          );
        },
      );
      if (saved == true && mounted) {
        await context.read<AuthProvider>().updateProfile(
          nameController.text.trim(),
          emailController.text.trim(),
          phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
        );
        _showMessage('Profile updated.');
      }
    } catch (error) {
      _showMessage('Unable to update profile: $error');
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  Future<void> _showAddresses() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(child: Text('My addresses')),
              IconButton(
                tooltip: 'Add address',
                onPressed: () async {
                  final address = await _editAddress();
                  if (address == null || !mounted) return;
                  await _saveAddress(address);
                  setDialogState(() {});
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: _addresses.isEmpty
                ? const Text('No saved addresses yet. Add one to get started.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _addresses.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(address.fullName),
                        subtitle: Text(
                          '${address.fullAddress}\n${address.phone}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              final updated = await _editAddress(
                                initialAddress: address,
                              );
                              if (updated != null) {
                                await _saveAddress(
                                  updated,
                                  replaceId: address.id,
                                );
                              }
                            } else if (action == 'delete') {
                              await _deleteAddress(address);
                            }
                            setDialogState(() {});
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Address?> _editAddress({Address? initialAddress}) async {
    final address = initialAddress;
    final controllers = <String, TextEditingController>{
      'fullName': TextEditingController(text: address?.fullName ?? ''),
      'phone': TextEditingController(text: address?.phone ?? ''),
      'street': TextEditingController(text: address?.street ?? ''),
      'barangay': TextEditingController(text: address?.barangay ?? ''),
      'city': TextEditingController(text: address?.city ?? ''),
      'province': TextEditingController(text: address?.province ?? ''),
      'postalCode': TextEditingController(text: address?.postalCode ?? ''),
    };
    final formKey = GlobalKey<FormState>();
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(dialogContext, false),
                icon: const Icon(Icons.arrow_back),
              ),
              Text(address == null ? 'Add address' : 'Edit address'),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: controllers.entries.map((entry) {
                    final label = switch (entry.key) {
                      'fullName' => 'Full name',
                      'phone' => 'Phone',
                      'street' => 'Street address',
                      'barangay' => 'Barangay',
                      'city' => 'City',
                      'province' => 'Province',
                      _ => 'Postal code',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(labelText: label),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (saved != true) return null;
      return Address(
        id: address?.id,
        fullName: controllers['fullName']!.text.trim(),
        phone: controllers['phone']!.text.trim(),
        street: controllers['street']!.text.trim(),
        barangay: controllers['barangay']!.text.trim(),
        city: controllers['city']!.text.trim(),
        province: controllers['province']!.text.trim(),
        postalCode: controllers['postalCode']!.text.trim(),
        isDefault: address?.isDefault ?? _addresses.isEmpty,
      );
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _saveAddress(Address address, {String? replaceId}) async {
    final storage = _storage;
    if (storage == null) {
      _showMessage('Address storage is not ready. Please try again.');
      return;
    }
    try {
      final updated = [..._addresses];
      if (replaceId == null) {
        updated.add(address);
      } else {
        final index = updated.indexWhere((item) => item.id == replaceId);
        if (index < 0) return;
        updated[index] = address;
      }
      await storage.saveAddresses(updated);
      if (mounted) setState(() => _addresses = updated);
    } catch (error) {
      _showMessage('Unable to save address: $error');
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final storage = _storage;
    if (storage == null) {
      _showMessage('Address storage is not ready. Please try again.');
      return;
    }
    try {
      final updated = _addresses
          .where((item) => item.id != address.id)
          .toList();
      await storage.saveAddresses(updated);
      if (mounted) setState(() => _addresses = updated);
    } catch (error) {
      _showMessage('Unable to delete address: $error');
    }
  }

  Future<void> _showInformation(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationSettings() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.arrow_back),
            ),
            const Expanded(child: Text('Notifications')),
          ],
        ),
        content: Consumer<AccountSettingsProvider>(
          builder: (context, settings, _) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable notifications'),
            subtitle: const Text(
              'Controls notification preferences for this app.',
            ),
            value: settings.notificationsEnabled,
            onChanged: (value) => _updatePreference(
              () => settings.setNotificationsEnabled(value),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
