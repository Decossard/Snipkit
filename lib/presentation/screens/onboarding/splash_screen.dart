import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/screen_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final isAuth = ref.read(authProvider).isAuthenticated;
      context.go(isAuth ? '/home' : '/welcome');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ScreenShell(
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Text(
              'snipkit',
              style: GoogleFonts.inter(
                fontSize: 64,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6B6B),
                letterSpacing: -1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
