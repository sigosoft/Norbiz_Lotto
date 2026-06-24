import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:norbiz_loto/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import 'navigation/main_navigation_view.dart';
import 'onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        final authController = Get.find<AuthController>();
        authController.userName.value =
            prefs.getString('user_name') ?? 'John Doe';
        authController.userPhone.value = prefs.getString('user_phone') ?? '';
        authController.userMobileRaw.value =
            prefs.getString('user_phone') ?? '';
        authController.userEmail.value = prefs.getString('user_email') ?? '';

        Get.find<HomeController>().fetchHomeData();
        Get.offAll(() => const MainNavigationView());
      } else {
        Get.offAll(() => const OnboardingView());
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
      Get.offAll(() => const OnboardingView());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen size using MediaQuery for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final logoWidth = screenSize.width * 0.75;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Radial gradient: warm golden-orange glow at top center fading to white
          // matching the exact Figma splash design
          gradient: RadialGradient(
            center: Alignment(0.0, -0.65), // positioned at top center
            radius: 0.85,
            colors: [
              Color(0xFFFFB300), // warm amber/golden-orange at center
              Color(0xFFFFCC66), // lighter amber mid
              Color(0xFFFFF5E0), // very light warm cream
              Colors.white, // pure white at edges/bottom
            ],
            stops: [0.0, 0.25, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: logoWidth,
            child: Image.asset(
              'lib/assets/images/Logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
