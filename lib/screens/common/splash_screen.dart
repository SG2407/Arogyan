import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(Duration(seconds: 1), () {
        _checkSessionAndNavigate();
      });
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    final userId = SessionService.getCurrentUserId();
    final isSessionActive = SessionService.isSessionActive();

    if (userId != null && isSessionActive) {
      // Session is active, check user role and navigate
      final user = UserService.getUserById(userId);
      if (user != null) {
        final isDoctor = user['isDoctor'] as bool? ?? false;
        if (mounted) {
          context.go(isDoctor ? '/doctor' : '/patient');
        }
      }
    } else if (mounted) {
      // No active session, check for remembered credentials
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;

      if (rememberMe && mounted) {
        // Auto-login with remembered credentials
        final email = prefs.getString('email') ?? '';
        final password = prefs.getString('password') ?? '';
        final isDoctor = prefs.getBool('isDoctor') ?? false;

        final user = UserService.login(
          email: email,
          password: password,
          isDoctor: isDoctor,
        );

        if (user != null && mounted) {
          SessionService.setCurrentUserId(user['id'] as String);
          context.go(isDoctor ? '/doctor' : '/patient');
        } else if (mounted) {
          context.go('/login');
        }
      } else if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 80,
                        color: colorScheme.onPrimary,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Aarogyan',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Health Assistant',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
