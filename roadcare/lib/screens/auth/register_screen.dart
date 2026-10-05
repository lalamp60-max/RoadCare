import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../widgets/roadcare_photo_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final int userId = await DatabaseHelper.instance.registerUser(
        username: usernameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (userId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 700));

        if (!mounted) return;

        Navigator.pop(context);
      } else if (userId == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this email already exists.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF176B87)),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF4F7F9),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF176B87), width: 1.5),
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
        imageAsset: 'assets/images/neighborhood-road.jpg',
        eyebrow: 'Better roads begin together',
        title: 'Make your voice count.',
        description: 'Join neighbors who are helping their communities travel more safely.',
        onBack: () => Navigator.of(context).maybePop(),
        content: Form(
          key: _formKey,

          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF102A43),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Start reporting and tracking road issues near you.',
                      style: TextStyle(color: Color(0xFF627D98), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // USERNAME
              TextFormField(
                controller: usernameController,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  label: 'Username',
                  icon: Icons.person_outline,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }

                  if (value.trim().length < 2) {
                    return 'Name must contain at least 2 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // EMAIL
              TextFormField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                ),

                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // PASSWORD
              TextFormField(
                controller: passwordController,

                obscureText: obscurePassword,

                textInputAction: TextInputAction.next,

                decoration: inputDecoration(
                  label: 'Password',
                  icon: Icons.lock_outline,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }

                  if (value.length < 6) {
                    return 'Password must contain at least 6 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // CONFIRM PASSWORD
              TextFormField(
                controller: confirmPasswordController,

                obscureText: obscureConfirmPassword,

                textInputAction: TextInputAction.done,

                decoration: inputDecoration(
                  label: 'Confirm Password',
                  icon: Icons.lock_reset_outlined,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }

                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF176B87),

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: Colors.grey.shade400,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Color(0xFF627D98)),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF176B87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
