import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../widgets/roadcare_photo_layout.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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
  // ADMIN LOGIN
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
      final admin = await DatabaseHelper.instance.loginAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // =======================================================
      // INVALID ADMIN LOGIN
      // =======================================================

      if (admin == null) {
        _showMessage('Invalid admin email or password.', isError: true);

        return;
      }

      // =======================================================
      // ADMIN LOGIN SUCCESS
      // =======================================================

      final int adminId = admin['id'] as int;

      final String adminName = (admin['name'] ?? 'RoadCare Admin').toString();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              AdminDashboardScreen(adminId: adminId, adminName: adminName),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Admin login error: ${e.toString()}', isError: true);
    }
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
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoadCarePhotoAuthLayout(
        imageAsset: 'assets/images/road-crew.jpg',
        eyebrow: 'RoadCare operations',
        title: 'Keep the city moving.',
        description: 'Review incoming reports, coordinate repairs and keep residents informed.',
        onBack: _isLoading ? null : () => Navigator.of(context).maybePop(),
        content: _buildAdminLoginForm(),
      ),
    );
  }

  // =========================================================
  // ADMIN LOGIN FORM
  // =========================================================

  Widget _buildAdminLoginForm() {
    return Form(
      key: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          // ===================================================
          // ADMIN ICON
          // ===================================================

          Center(
            child: Container(
              width: 115,
              height: 115,

              decoration: BoxDecoration(
                color: const Color(0xFFE3EBF5),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.admin_panel_settings,
                size: 65,
                color: Color(0xFF45679B),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ===================================================
          // TITLE
          // ===================================================
          const Text(
            'RoadCare Admin',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171B21),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Sign in to manage road damage reports',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 17, color: Color(0xFF4F5660)),
          ),

          const SizedBox(height: 38),

          // ===================================================
          // EMAIL
          // ===================================================
          const Text(
            'Admin Email',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF30353B),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _emailController,

            enabled: !_isLoading,

            keyboardType: TextInputType.emailAddress,

            textInputAction: TextInputAction.next,

            decoration: InputDecoration(
              hintText: 'Enter admin email',

              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF4D525A),
              ),

              filled: true,

              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF555A62)),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF555A62)),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF45679B),
                  width: 2,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter admin email';
              }

              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }

              return null;
            },
          ),

          const SizedBox(height: 22),

          // ===================================================
          // PASSWORD
          // ===================================================
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF30353B),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _passwordController,

            enabled: !_isLoading,

            obscureText: _obscurePassword,

            textInputAction: TextInputAction.done,

            onFieldSubmitted: (_) {
              if (!_isLoading) {
                _login();
              }
            },

            decoration: InputDecoration(
              hintText: 'Enter admin password',

              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF4D525A),
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
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,

                  color: const Color(0xFF555A62),
                ),
              ),

              filled: true,

              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF555A62)),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF555A62)),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF45679B),
                  width: 2,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter admin password';
              }

              if (value.length < 6) {
                return 'Password must contain at least 6 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 30),

          // ===================================================
          // LOGIN BUTTON
          // ===================================================
          SizedBox(
            height: 58,

            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _login,

              icon: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,

                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login),

              label: Text(
                _isLoading ? 'Signing in...' : 'Admin Login',

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF45679B),

                foregroundColor: Colors.white,

                disabledBackgroundColor: const Color(0xFF90A7C7),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                elevation: 3,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ===================================================
          // DEFAULT ADMIN ACCOUNT
          // ===================================================
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: const Color(0xFFE7EDF5),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: const [
                Text(
                  'Default Admin Account',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20252B),
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Email: admin@roadcare.com',

                  style: TextStyle(fontSize: 16, color: Color(0xFF30353B)),
                ),

                SizedBox(height: 5),

                Text(
                  'Password: Admin@123',

                  style: TextStyle(fontSize: 16, color: Color(0xFF30353B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ===================================================
          // FOOTER
          // ===================================================
          const Text(
            'RoadCare • Admin Panel',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 12, color: Color(0xFF9FB3C8)),
          ),
        ],
      ),
    );
  }
}
