import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const OnboardingView());
    });
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
