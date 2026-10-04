import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clothingapp/backgrounds/login_background.dart';
import 'package:clothingapp/core/utils/validators.dart';
import 'package:clothingapp/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _rememberedEmailKey = 'login_remembered_email';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.go(_destination);
      }
    });
  }

  String get _destination {
    final destination = widget.redirectTo;
    if (destination != null &&
        destination.startsWith('/') &&
        !destination.startsWith('//')) {
      return destination;
    }
    return '/';
  }

  Future<void> _loadRememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final rememberedEmail = preferences.getString(_rememberedEmailKey);
    if (!mounted || rememberedEmail == null) return;
    setState(() {
      _emailController.text = rememberedEmail;
      _rememberMe = true;
    });
  }

  Future<void> _saveRememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await preferences.setString(
        _rememberedEmailKey,
        _emailController.text.trim(),
      );
    } else {
      await preferences.remove(_rememberedEmailKey);
    }
  }

  Future<void> _showForgotPasswordInfo() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Forgot your password?'),
        content: const Text(
          'Password recovery by email is not available in this demo store yet. '
          'Please use “Continue as demo user” or contact the store administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    const primaryText = Colors.white;
    const secondaryText = Color(0xFFB8B8B8);
    const fieldFill = Color(0xFF202020);
    const fieldBorder = Color(0xFF555555);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LoginBackground(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UA.',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        _isSigningUp ? 'CREATE ACCOUNT' : 'WELCOME BACK',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSigningUp
                            ? 'Create an account to get started.'
                            : 'Sign in to access your collection.',
                        style: TextStyle(fontSize: 14, color: secondaryText),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isSigningUp) ...[
                              const Text(
                                'FULL NAME',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: _fieldDecoration(
                                  hintText: 'Your name',
                                  fieldFill: fieldFill,
                                  fieldBorder: fieldBorder,
                                  secondaryText: secondaryText,
                                ),
                                validator: Validators.validateName,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            const Text(
                              'EMAIL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldFill,
                                hintText: 'you@example.com',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: secondaryText,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: fieldBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: fieldBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 15,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: fieldFill,
                                hintText: '••••••••',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: secondaryText,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: fieldBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: fieldBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                suffixIcon: const Icon(
                                  Icons.visibility_off,
                                  size: 20,
                                  color: secondaryText,
                                ),
                              ),
                              obscureText: true,
                              validator: Validators.validatePassword,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 15,
                                color: primaryText,
                              ),
                            ),
                            if (!_isSigningUp) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: Colors.white,
                                    checkColor: Colors.black,
                                    side: const BorderSide(color: secondaryText),
                                    onChanged: (value) async {
                                      setState(
                                        () => _rememberMe = value ?? false,
                                      );
                                      if (!_rememberMe) {
                                        await _saveRememberedEmail();
                                      }
                                    },
                                  ),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _showForgotPasswordInfo,
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryText,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final router = GoRouter.of(context);
                                          if (_isSigningUp) {
                                            await auth.register(
                                              _nameController.text,
                                              _emailController.text,
                                            );
                                          } else {
                                            await _saveRememberedEmail();
                                            if (!mounted) return;
                                            await auth.login(
                                              _emailController.text.trim(),
                                              _passwordController.text,
                                            );
                                          }
                                          if (!mounted) return;
                                          if (auth.isAuthenticated) {
                                            router.go(_destination);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isSigningUp
                                            ? 'CREATE ACCOUNT'
                                            : 'SIGN IN',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSigningUp = !_isSigningUp;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            _isSigningUp
                                ? 'Already have an account? Sign in'
                                : 'New here? Create an account',
                            style: const TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (!_isSigningUp) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              final router = GoRouter.of(context);
                              await auth.loginAsDemo();
                              if (!mounted) return;
                              if (auth.isAuthenticated) {
                                router.go(_destination);
                              }
                            },
                            child: const Text(
                              'Continue as demo user',
                              style: TextStyle(
                                color: secondaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required Color fieldFill,
    required Color fieldBorder,
    required Color secondaryText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fieldFill,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: secondaryText),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }
}
