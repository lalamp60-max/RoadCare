import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

import '../home/home_screen.dart';
import '../admin/admin_login_screen.dart';
import 'register_screen.dart';
import '../../widgets/roadcare_photo_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  // =========================================================
  // SERVICE
  // =========================================================

  final AuthService _authService = AuthService();

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoading = false;

  bool _obscurePassword = true;

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // =========================================================
  // USER LOGIN
  // =========================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // =====================================================
      // INVALID LOGIN
      // =====================================================

      if (user == null) {
        _showMessage('Invalid email or password.', isError: true);

        return;
      }

      // =====================================================
      // USER ID CHECK
      // =====================================================

      if (user.id == null) {
        _showMessage('User ID not found.', isError: true);

        return;
      }

      // =====================================================
      // USER LOGIN SUCCESS
      // =====================================================

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: user.id!, userName: user.name),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Login error: ${e.toString()}', isError: true);
    }
  }

  // =========================================================
  // OPEN ADMIN LOGIN
  // =========================================================

  void _openAdminLogin() {
    if (_isLoading) {
      return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),

              const SizedBox(width: 12),

              Expanded(child: Text(message)),
            ],
          ),

          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,

          behavior: SnackBarBehavior.floating,

          margin: const EdgeInsets.all(20),

          duration: const Duration(seconds: 2),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // OPEN REGISTER
  // =========================================================

  Future<void> _openRegister() async {
    if (_isLoading) {
      return;
    }

    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoadCarePhotoAuthLayout(
        imageAsset: 'assets/images/city-avenue.jpg',
        eyebrow: 'Community road safety',
        title: 'Welcome back.',
        description: 'Sign in to report hazards, share precise locations and follow repairs in your area.',
        onBack: () => Navigator.of(context).maybePop(),
        content: _buildLoginForm(),
      ),
    );
  }

  // =========================================================
  // LOGIN FORM
  // =========================================================

  Widget _buildLoginForm() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign in to your account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF102A43),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your next safer street starts with a report.',
                style: TextStyle(color: Color(0xFF627D98), height: 1.4),
              ),
              const SizedBox(height: 28),

              // =================================================
              // EMAIL
              // =================================================
              const Text(
                'Email Address',

                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF102A43),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.next,

                enabled: !_isLoading,

                decoration: InputDecoration(
                  hintText: 'Enter your email',

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF1565C0),
                  ),

                  filled: true,

                  fillColor: const Color(0xFFF5F8FC),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  final email = value.trim();

                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              // =================================================
              // PASSWORD
              // =================================================
              const Text(
                'Password',

                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF102A43),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _passwordController,

                obscureText: _obscurePassword,

                textInputAction: TextInputAction.done,

                enabled: !_isLoading,

                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _login();
                  }
                },

                decoration: InputDecoration(
                  hintText: 'Enter your password',

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF1565C0),
                  ),

                  suffixIcon: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },

                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),

                  filled: true,

                  fillColor: const Color(0xFFF5F8FC),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }

                  if (value.length < 6) {
                    return 'Password must contain at least 6 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // USER LOGIN BUTTON
              // =================================================
              SizedBox(
                height: 55,

                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: const Color(0xFF90CAF9),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    elevation: 3,
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          width: 25,
                          height: 25,

                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.login),

                            SizedBox(width: 10),

                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // DIVIDER
              // =================================================
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),

                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Color(0xFF829AB1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // ADMIN LOGIN BUTTON
              // =================================================
              SizedBox(
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _openAdminLogin,

                  icon: const Icon(Icons.admin_panel_settings_outlined),

                  label: const Text(
                    'Admin Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),

                    side: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.3,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =================================================
              // REGISTER
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Flexible(
                    child: Text(
                      "Don't have an account?",

                      style: TextStyle(color: Color(0xFF627D98)),
                    ),
                  ),

                  TextButton(
                    onPressed: _isLoading ? null : _openRegister,

                    child: const Text(
                      'Create Account',

                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =================================================
              // FOOTER
              // =================================================
              const Text(
                'RoadCare • Road Damage Reporting System',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
