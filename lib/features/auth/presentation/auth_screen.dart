import 'package:flutter/material.dart';

import '../../../core/services/foodly_api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/auth_session.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.session, required this.onAuthenticated});

  final AuthSession session;
  final ValueChanged<AuthUser> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = _isLogin
          ? await widget.session.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await widget.session.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (mounted) widget.onAuthenticated(user);
    } on FoodlyApiException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Unable to connect. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Welcome back' : 'Create your account';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFFFE5D9),
                      child: Icon(Icons.restaurant_menu_rounded, color: FoodlyColors.primary, size: 42),
                    ),
                    const SizedBox(height: 24),
                    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Sign in to continue with Foodly AI.' : 'Sign up to save your Foodly AI account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name.' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email.' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                      validator: (value) => value == null || value.length < 8 ? 'Use at least 8 characters.' : null,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                        validator: (value) => value != _passwordController.text ? 'Passwords do not match.' : null,
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_isLogin ? 'Sign in' : 'Create account'),
                      ),
                    ),
                    TextButton(
                      onPressed: _isSubmitting ? null : _toggleMode,
                      child: Text(_isLogin ? 'New to Foodly AI? Create an account' : 'Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
