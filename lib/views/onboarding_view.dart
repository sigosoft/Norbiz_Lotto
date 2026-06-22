import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/theme.dart';
import '../configs/api_config.dart';
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
  double _scrollOffset = 0.0;
  List<dynamic> _apiScreens = [];
  bool _isLoadingApi = true;

  @override
  void initState() {
    super.initState();
    _fetchSplashScreens();
    _pageController.addListener(() {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _scrollOffset = _pageController.page ?? 0.0;
        });
      }
    });
  }

  Future<void> _fetchSplashScreens() async {
    try {
      final connect = GetConnect();
      connect.timeout = const Duration(seconds: 15);
      final String url = '${ApiConfig.baseUrl}${ApiConfig.splashScreens}';
      debugPrint('=== API CALL REQUEST ===');
      debugPrint('URL: $url');

      final response = await connect.get(url);

      debugPrint('=== API CALL RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['status'] == 'true' || data['status'] == true) {
          if (mounted) {
            setState(() {
              _apiScreens = data['data'] as List<dynamic>? ?? [];
              _isLoadingApi = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching splash screens: $e');
    }
    if (mounted) {
      setState(() {
        _isLoadingApi = false;
      });
    }
  }

  String getTitle(int index, String lang) {
    if (_apiScreens.isNotEmpty && index < _apiScreens.length) {
      final item = _apiScreens[index];
      if (lang == 'fr') {
        return item['title_tr'] ?? item['title_en'] ?? '';
      } else if (lang == 'ht') {
        return item['title_ht'] ?? item['title_en'] ?? '';
      }
      return item['title_en'] ?? '';
    }
    return _onboardingData[index]['titleKey'].toString().tr;
  }

  String getDescription(int index, String lang) {
    if (_apiScreens.isNotEmpty && index < _apiScreens.length) {
      final item = _apiScreens[index];
      if (lang == 'fr') {
        return item['content_tr'] ?? item['content_en'] ?? '';
      } else if (lang == 'ht') {
        return item['content_ht'] ?? item['content_en'] ?? '';
      }
      return item['content_en'] ?? '';
    }
    return _onboardingData[index]['descKey'].toString().tr;
  }

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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Animated background blue shape
                _buildAnimatedBlueShape(size),

                PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(size, illustrationHeight, index);
                  },
                ),
              ],
            ),
          ),

          // ── Text Content ────────────────────────────────────────────────────
          Expanded(child: _buildTextSection(size)),
        ],
      ),
    );
  }

  // Animated blue shape builder for smooth background morphing
  Widget _buildAnimatedBlueShape(Size size) {
    const fw = 390.0;
    const fh = 844.0;
    final sw = size.width / fw;
    final sh = size.height / fh;

    // Slide 0 Shape Properties (rotated top-left)
    final w0 = 200.0 * sw;
    final h0 = 472.39 * sh;
    final top0 = 8.72 * sh;
    final left0 = -70.0 * sw;
    final rotate0 = -44.6;
    final radius0 = 100.0 * sw;

    // Slide 1 Shape Properties (vertical bottom-center)
    final w1 = 200.0 * sw;
    final h1 = 472.39 * sh;
    final top1 = 363.0 * sh; // (438.0 - 75.0) * sh
    final left1 = 95.0 * sw;
    final rotate1 = -180.0;
    final radius1 = 100.0 * sw;

    // Slide 2 Shape Properties (rotated top-right)
    final w2 = 200.0 * sw;
    final h2 = 472.39 * sh;
    final top2 = 8.72 * sh; // (83.72 - 75.0) * sh
    final left2 = 260.0 * sw;
    final rotate2 = -315.4;
    final radius2 = 100.0 * sw;

    double w, h, top, left, rotate, radius;

    if (_scrollOffset <= 1.0) {
      final t = _scrollOffset;
      w = w0 + (w1 - w0) * t;
      h = h0 + (h1 - h0) * t;
      top = top0 + (top1 - top0) * t;
      left = left0 + (left1 - left0) * t;
      rotate = rotate0 + (rotate1 - rotate0) * t;
      radius = radius0 + (radius1 - radius0) * t;
    } else {
      final t = _scrollOffset - 1.0;
      w = w1 + (w2 - w1) * t;
      h = h1 + (h2 - h1) * t;
      top = top1 + (top2 - top1) * t;
      left = left1 + (left2 - left1) * t;
      rotate = rotate1 + (rotate2 - rotate1) * t;
      radius = radius1 + (radius2 - radius1) * t;
    }

    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: rotate * math.pi / 180,
        alignment: Alignment.center,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFF002C8B),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(radius),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds one illustration slide using exact Figma pixel measurements
  /// scaled via MediaQuery.
  Widget _buildSlide(Size size, double containerHeight, int index) {
    final data = _onboardingData[index];
    final imagePath =
        (data['image'] as String?) ?? 'lib/assets/images/Play.png';

    const fw = 390.0; // Figma frame width
    const fh = 844.0; // Figma frame height

    final sw = size.width / fw;
    final sh = size.height / fh;

    final imgW = 400.0 * sw;
    final imgTopInSlide = 60.0 * sh;
    final imgLeft = 1.0 * sw;

    final lang = Get.find<LocalizationController>().currentLanguage.value;
    final title = getTitle(index, lang);
    final desc = getDescription(index, lang);

    if (index == 1) {
      return SizedBox(
        width: size.width,
        height: containerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Text Content (Title & Description) at the top
            Positioned(
              top: (130.0 - 75.0) * sh, // Figma top 130px (minus top bar 75px)
              left: size.width * 0.07,
              right: size.width * 0.07,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size.width * 0.065,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12 * sh),
                  Text(
                    desc,
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

            // Image (Win.png) placed on top of the blue shape
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
            // Image (Secure.png) placed on top of the blue shape
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

    // Default slide (Index 0): Play.png positioned with Figma coordinates
    return SizedBox(
      width: size.width,
      height: containerHeight,
      child: Stack(
        children: [
          Positioned(
            top: imgTopInSlide,
            left: imgLeft,
            child: Image.asset(imagePath, width: imgW, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(Size size) {
    final lang = Get.find<LocalizationController>().currentLanguage.value;
    final title = getTitle(_currentPage, lang);
    final desc = getDescription(_currentPage, lang);

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
                    title,
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
                    desc,
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
                    getTitle(
                      _currentPage,
                      localizationController.currentLanguage.value,
                    ),
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    getDescription(
                      _currentPage,
                      localizationController.currentLanguage.value,
                    ),
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
