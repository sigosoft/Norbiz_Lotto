import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/theme.dart';
import '../controllers/localization_controller.dart';
import 'auth/signin_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'titleKey': 'play_anytime',
      'descKey': 'onboarding_desc',
      'image': 'lib/assets/images/Play.png',
      'bgType': 'rectangle', // rotated rect with rounded bottom corners
    },
    {
      'titleKey': 'win_big',
      'descKey': 'onboarding_desc',
      'image': 'lib/assets/images/Win.png',
      'bgType': 'circle',
    },
    {
      'titleKey': 'fast_secure',
      'descKey': 'onboarding_desc',
      'image': 'lib/assets/images/Secure.png',
      'bgType': 'circle',
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAll(() => const SignInView());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Obx(() {
      final textDirection = localizationController.textDirection;
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: orientation == Orientation.portrait
              ? _buildPortrait(context, size, localizationController)
              : _buildLandscape(context, size, localizationController),
        ),
      );
    });
  }

  // ─── PORTRAIT ─────────────────────────────────────────────────────────────

  Widget _buildPortrait(
    BuildContext context,
    Size size,
    LocalizationController localizationController,
  ) {
    // Figma base frame: 390 × 844 px
    // Illustration area: ~57% of screen height (matches Figma proportions)
    final illustrationHeight = size.height * 0.57;

    return SafeArea(
      child: Column(
        children: [
          // ── Top Action Bar ─────────────────────────────────────────────────
          // Figma: language box at top, height ~35px → size.height*(35/844)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.045,
              vertical: size.height * 0.012,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLanguageSelector(size, localizationController),
                _buildSkipButton(size),
              ],
            ),
          ),

          // ── Illustration: swipeable pages ───────────────────────────────────
          SizedBox(
            height: illustrationHeight,
            width: size.width,
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.none,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return _buildSlide(size, illustrationHeight, index);
              },
            ),
          ),

          // ── Text Content ────────────────────────────────────────────────────
          Expanded(child: _buildTextSection(size)),
        ],
      ),
    );
  }

  /// Builds one illustration slide using exact Figma pixel measurements
  /// scaled via MediaQuery.
  Widget _buildSlide(Size size, double containerHeight, int index) {
    final data = _onboardingData[index];
    final bgType = (data['bgType'] as String?) ?? 'rectangle';
    final imagePath =
        (data['image'] as String?) ?? 'lib/assets/images/Play.png';

    // ── Figma base frame (390 × 844 px) ──────────────────────────────────────
    const fw = 390.0; // Figma frame width
    const fh = 844.0; // Figma frame height

    // Scale factors: maps Figma px → device px
    final sw = size.width / fw;
    final sh = size.height / fh;

    // ── Blue shape ───────────────────────────────────────────────────────────────
    //  Shape: rounded-bottom rectangle, 45° rotated
    //  Dimensions (user-confirmed): w=300.47, h=200.39  color=#002C8B
    //
    //  GOAL: near tip at top-left corner, far tip ends at CENTER of illustration.
    //
    //  Maths (all in Figma px on 390×844 frame):
    //    diagonal = sqrt(300.47² + 200.39²) ≈ 361 px
    //    half-diag along 45° ≈ 361/sqrt(2) ≈ 127.3 px
    //    illustration center = (195, illustrationH/2) ≈ (195, 240) px
    //    shape center = center − (127.3, 127.3) = (67.7, 112.7)
    //    Positioned left  = cx − shapeW/2 = 67.7 − 150.2 = −82.5 px
    //    Positioned top   = cy − shapeH/2 = 112.7 − 100.2 =  12.5 px
    //  Result: near tip ≈ (−60, −15) → top-left area (slightly off-screen)
    //          far  tip ≈ (195, 240) → center of illustration  ✓
    final shapeW = 700.47 * sw;
    final shapeH = 240.39 * sh;
    final shapeTopInSlide = 00.0 * sh; //  12.5 px in Figma frame
    final shapeLeft = -400.0 * sw; // -82.5 px in Figma frame
    final shapeRadius = 100.0 * sw;
    // bottom-left & bottom-right = 100 px

    // ── Image (Figma exact values) ─────────────────────────────────────────────
    //  width  652.35 px  →  size.width  * (652.35/390)
    //  height 381    px  →  size.height * (381/844)
    //  top   175     px  →  relative to illustration = 175−75 = 100 px
    //  left -173     px  →  size.width  * (-173/390)
    final imgW = 400.0 * sw;
    final imgTopInSlide = 60.0 * sh;
    final imgLeft = 1.0 * sw;

    if (index == 1) {
      return SizedBox(
        width: size.width,
        height: containerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. White base
            Container(color: Colors.white),

            // 2. Text Content (Title & Description) at the top
            Positioned(
              top: (130.0 - 75.0) * sh, // Figma top 130px (minus top bar 75px)
              left: size.width * 0.07,
              right: size.width * 0.07,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data['titleKey'].toString().tr,
                    style: TextStyle(
                      fontSize: size.width * 0.065,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12 * sh),
                  Text(
                    data['descKey'].toString().tr,
                    style: TextStyle(
                      fontSize: size.width * 0.033,
                      color: Colors.grey.shade600,
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 3. Blue shape (width 234.47, height 472.39, top 438, left 79, radius 100, rotation 180)
            Positioned(
              top: (438.0 - 75.0) * sh, // Figma top 438px (minus top bar 75px)
              left: 95.0 * sw,
              child: Transform.rotate(
                angle: 180 * math.pi / 180, // 180 degrees
                alignment: Alignment.center,
                child: Container(
                  width: 200.0 * sw,
                  height: 472.39 * sh,
                  decoration: BoxDecoration(
                    color: const Color(0xFF002C8B),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0 * sw),
                      bottomRight: Radius.circular(100.0 * sw),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Image (Win.png) placed on top of the blue shape
            Positioned(
              top: (340.0 - 75.0) * sh, // Center it vertically around y=300px
              left: (390.0 - 320.0) / 2 * sw,
              child: Image.asset(
                imagePath,
                width: 320.0 * sw,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    }

    if (index == 2) {
      return SizedBox(
        width: size.width,
        height: containerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. White base
            Container(color: Colors.white),

            // 2. Blue shape (width 234.47, height 472.39, top 83.72, left 109.39, radius 100, rotation 44.6)
            Positioned(
              top:
                  (83.72 - 75.0) * sh, // Figma top 83.72px (minus top bar 75px)
              left: 250.0 * sw,
              child: Transform.rotate(
                angle: 44.6 * math.pi / 180, // 44.6 degrees
                alignment: Alignment.center,
                child: Container(
                  width: 220.0 * sw,
                  height: 442.0 * sh,
                  decoration: BoxDecoration(
                    color: const Color(0xFF002C8B),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.0 * sw),
                      bottomRight: Radius.circular(100.0 * sw),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Image (Secure.png) placed on top of the blue shape
            Positioned(
              top: (200.0 - 75.0) * sh, // Center it vertically
              left: (390.0 - 320.0) / 2 * sw,
              child: Image.asset(
                imagePath,
                width: 320.0 * sw,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    }

    if (bgType == 'rectangle') {
      return ClipRect(
        child: SizedBox(
          width: size.width,
          height: containerHeight,
          child: Stack(
            children: [
              // 1. White base
              Container(color: Colors.white),

              // 2. Rotated dark-navy rectangle (Figma shape)
              Positioned(
                top: shapeTopInSlide,
                left: shapeLeft,
                child: Transform.rotate(
                  angle: 45 * math.pi / 180, // 45° clockwise
                  alignment: Alignment.center,
                  child: Container(
                    width: shapeW,
                    height: shapeH,
                    decoration: BoxDecoration(
                      color: const Color(0xFF002C8B),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(shapeRadius),
                        bottomRight: Radius.circular(shapeRadius),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Play.png positioned with Figma coordinates
              Positioned(
                top: imgTopInSlide,
                left: imgLeft,
                child: Image.asset(imagePath, width: imgW, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      );
    }

    // ── Screens 2 & 3: Large dark-navy circle background ─────────────────────
    return ClipRect(
      child: SizedBox(
        width: size.width,
        height: containerHeight,
        child: Stack(
          children: [
            Container(color: Colors.white),
            Center(
              child: Container(
                width: size.width * 0.78,
                height: size.width * 0.78,
                decoration: const BoxDecoration(
                  color: Color(0xFF002C8B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.01),
                child: Image.asset(
                  imagePath,
                  width: size.width * 0.82,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSection(Size size) {
    final data = _onboardingData[_currentPage];

    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title + Description
          Opacity(
            opacity: _currentPage == 1 ? 0.0 : 1.0,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.022),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    data['titleKey'].toString().tr,
                    key: ValueKey<int>(_currentPage),
                    style: TextStyle(
                      fontSize: size.width * 0.065,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    data['descKey'].toString().tr,
                    key: ValueKey<String>('d$_currentPage'),
                    style: TextStyle(
                      fontSize: size.width * 0.033,
                      color: Colors.grey.shade600,
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Dots + Next + Copyright
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [_buildDotsIndicator(size), _buildNextButton(size)],
              ),
              SizedBox(height: size.height * 0.010),
              Text(
                '© 2026 Norbiz Lotto — All Rights Reserved',
                style: TextStyle(
                  fontSize: size.width * 0.026,
                  color: _currentPage == 1
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.012),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LANDSCAPE ────────────────────────────────────────────────────────────

  Widget _buildLandscape(
    BuildContext context,
    Size size,
    LocalizationController localizationController,
  ) {
    final data = _onboardingData[_currentPage];

    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final bgType =
                        (_onboardingData[index]['bgType'] as String?) ??
                        'rectangle';
                    final imgPath =
                        (_onboardingData[index]['image'] as String?) ?? '';
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Colors.white),
                        if (bgType == 'rectangle')
                          Positioned(
                            top: 0,
                            left: -size.height * 0.22,
                            child: Transform.rotate(
                              angle: 45 * math.pi / 180,
                              child: Container(
                                width: size.height * 0.28,
                                height: size.height * 0.56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF002C8B),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(
                                      size.height * 0.12,
                                    ),
                                    bottomRight: Radius.circular(
                                      size.height * 0.12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Container(
                              width: size.height * 0.5,
                              height: size.height * 0.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF002C8B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        Center(
                          child: Image.asset(
                            imgPath,
                            width: size.width * 0.36,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.025,
                    vertical: size.height * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLanguageSelector(size, localizationController),
                      _buildSkipButton(size),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['titleKey'].toString().tr,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    data['descKey'].toString().tr,
                    style: TextStyle(
                      fontSize: size.width * 0.02,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDotsIndicator(size),
                      _buildNextButton(size),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───────────────────────────────────────────────────────

  /// Language selector pill
  /// Figma: width 124px, height 35px, radius 45px, border 0.5px
  Widget _buildLanguageSelector(
    Size size,
    LocalizationController localizationController,
  ) {
    // MediaQuery scaling from Figma 390×844 frame
    final boxW = size.width * (124.0 / 390.0); // 124/390
    final boxH = size.height * (35.0 / 844.0); // 35/844
    final radius = size.width * (45.0 / 390.0); // 45/390 → full pill

    return Container(
      width: boxW,
      height: boxH,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppTheme.primaryOrange,
          width: 0.5, // Figma: 0.5px border
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            size: boxH * 0.55,
            color: AppTheme.primaryDarkBlue,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: DropdownButton<String>(
              value: localizationController.currentLanguage.value,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: boxH * 0.55,
                color: AppTheme.primaryDarkBlue,
              ),
              style: TextStyle(
                color: AppTheme.primaryDarkBlue,
                fontWeight: FontWeight.w600,
                fontSize: boxH * 0.45,
              ),
              onChanged: (lang) {
                if (lang != null) localizationController.changeLanguage(lang);
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'ht', child: Text('Kreyòl')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skip / Close button — rounded square, grey X
  Widget _buildSkipButton(Size size) {
    final btnSize = size.height * (35.0 / 844.0);
    return GestureDetector(
      onTap: () => Get.offAll(() => const SignInView()),
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Icon(
          Icons.close,
          color: Colors.grey.shade600,
          size: btnSize * 0.55,
        ),
      ),
    );
  }

  Widget _buildDotsIndicator(Size size) {
    return Row(
      children: List.generate(
        _onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          height: 8,
          width: _currentPage == index ? 22 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primaryOrange
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(Size size) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: size.width * 0.13,
        height: size.width * 0.13,
        decoration: const BoxDecoration(
          color: AppTheme.primaryOrange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x44F57C00),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
