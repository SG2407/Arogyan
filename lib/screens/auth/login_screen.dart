import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDoctor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final user = UserService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        isDoctor: _isDoctor,
      );
      if (user != null) {
        // set session to logged in user
        SessionService.setCurrentUserId(user['id'] as String);
        if (_isDoctor) {
          context.go('/doctor');
        } else {
          context.go('/patient');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
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
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
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
                  onPressed: _handleLogin,
                  icon: Icon(Icons.login),
                  label: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
