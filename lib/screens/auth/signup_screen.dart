import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/services/session_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDoctor = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final id = await UserService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        isDoctor: _isDoctor,
      );

      if (!mounted) return;
      // Set session to the newly created user
      SessionService.setCurrentUserId(id);
      if (_isDoctor) {
        context.go('/doctor');
      } else {
        context.go('/patient');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text('I am a Doctor'),
                  value: _isDoctor,
                  onChanged: (bool value) {
                    setState(() {
                      _isDoctor = value;
                    });
                  },
                  activeColor: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _handleSignup,
                  icon: Icon(Icons.person_add),
                  label: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
