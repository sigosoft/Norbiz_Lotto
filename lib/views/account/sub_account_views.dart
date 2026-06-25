import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../configs/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/localization_controller.dart';
import '../../models/bank_model.dart';
import '../../models/transaction_model.dart';
import '../../configs/toast.dart';
import '../auth/signin_view.dart';

// ------------------------------------------------------------
// Helper: Dashed Border Container
// ------------------------------------------------------------
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

// ------------------------------------------------------------
// 1. Account Info / Edit Profile View
// ------------------------------------------------------------
class AccountInfoView extends StatelessWidget {
  const AccountInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();

    final nameParts = authController.userName.value.split(' ');
    final firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts.first : '',
    );
    final lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    final phoneController = TextEditingController(
      text: authController.userPhone.value,
    );
    final emailController = TextEditingController(
      text: authController.userEmail.value,
    );
    final dobController = TextEditingController(
      text: authController.userDob.value,
    );
    var genderVal = authController.userGender.value.obs;

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'account_info'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'first_name'.tr,
                            controller: firstNameController,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: 'last_name'.tr,
                            controller: lastNameController,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'gender'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 1.0,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: genderVal.value,
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Color(0xFF0F172A),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'Male',
                                                child: Text('Male'.tr),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Female',
                                                child: Text('Female'.tr),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null)
                                                genderVal.value = val;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  label: 'dob'.tr,
                                  controller: dobController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: 'phone_number'.tr,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: 'Email',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => const EditAccountInfoView());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFE9900),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'edit'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: TextButton.icon(
                              onPressed: () =>
                                  _showDeleteAccountBottomSheet(context),
                              icon: Image.asset(
                                "lib/assets/images/Delete.png",
                                width: 15,
                                height: 15,
                              ),
                              label: Text(
                                'delete_account'.tr,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE9900),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountBottomSheet(BuildContext context) {
    final authController = Get.find<AuthController>();
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Close Button
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7ED),
                          foregroundColor: const Color(0xFFFE9900),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final passwordController = TextEditingController();
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Delete Account'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Please enter your password to confirm account deletion.'
                                        .tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Password'.tr,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Cancel'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final pwd = passwordController.text.trim();
                                    if (pwd.isEmpty) {
                                      showToast(
                                        'Please enter your password.'.tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }
                                    Get.back(); // close dialog
                                    Get.back(); // close bottom sheet
                                    authController.deleteAccount(pwd);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(80, 38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text('Yes'.tr),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE9900),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ------------------------------------------------------------
// 1b. Edit Account Info View
// ------------------------------------------------------------
class EditAccountInfoView extends StatelessWidget {
  const EditAccountInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();

    final nameParts = authController.userName.value.split(' ');
    final firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts.first : '',
    );
    final lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    String initialPhone = authController.userMobileRaw.value;
    if (initialPhone.isEmpty) {
      final phone = authController.userPhone.value.trim();
      if (phone.startsWith('+')) {
        final spaceIndex = phone.indexOf(' ');
        if (spaceIndex != -1) {
          initialPhone = phone.substring(spaceIndex + 1).trim();
        } else {
          String cleaned = phone.replaceFirst('+', '');
          final dialCodeNoPlus = authController.selectedCountryDialCode.value
              .replaceFirst('+', '');
          if (cleaned.startsWith(dialCodeNoPlus)) {
            initialPhone = cleaned.substring(dialCodeNoPlus.length).trim();
          } else {
            initialPhone = cleaned;
          }
        }
      } else {
        initialPhone = phone;
      }
    }
    final phoneController = TextEditingController(text: initialPhone);
    final emailController = TextEditingController(
      text: authController.userEmail.value,
    );
    final dobController = TextEditingController(
      text: authController.userDob.value,
    );
    final String initialGender = authController.userGender.value;
    final String defaultGender =
        (initialGender.toLowerCase() == 'female' ||
            initialGender.toLowerCase() == 'femelle')
        ? 'Female'
        : 'Male';
    var genderVal = defaultGender.obs;

    return Obx(() {
      final textDirection = localizationController.textDirection;
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 38,
                                width: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Color(0xFF0F172A),
                                  size: 24,
                                ),
                              ),
                            ),
                            const Text(
                              'Edit Information',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 38),
                          ],
                        ),
                      ),
                      // Scrollable Form
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    Obx(() {
                                      final localPath = authController
                                          .selectedImagePath
                                          .value;
                                      final remoteUrl =
                                          authController.userImageUrl.value;
                                      final name =
                                          authController.userName.value;

                                      Widget imageWidget;
                                      if (localPath.isNotEmpty) {
                                        imageWidget = ClipOval(
                                          child: Image.file(
                                            File(localPath),
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else if (remoteUrl.isNotEmpty) {
                                        imageWidget = ClipOval(
                                          child: Image.network(
                                            remoteUrl,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 90,
                                                    height: 90,
                                                    color: const Color(
                                                      0xFFFFD15B,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      name.isNotEmpty
                                                          ? name[0]
                                                                .toUpperCase()
                                                          : 'J',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 32,
                                                        color: Color(
                                                          0xFF1E293B,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        );
                                      } else {
                                        imageWidget = Container(
                                          width: 90,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFD15B),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : 'J',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 32,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        );
                                      }

                                      return GestureDetector(
                                        onTap: () async {
                                          try {
                                            final picker = ImagePicker();
                                            final image = await picker
                                                .pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                            if (image != null) {
                                              authController
                                                      .selectedImagePath
                                                      .value =
                                                  image.path;
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              'Error picking image: $e',
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: imageWidget,
                                        ),
                                      );
                                    }),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () async {
                                          try {
                                            final picker = ImagePicker();
                                            final image = await picker
                                                .pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                            if (image != null) {
                                              authController
                                                      .selectedImagePath
                                                      .value =
                                                  image.path;
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              'Error picking image: $e',
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryOrange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                label: 'First Name',
                                controller: firstNameController,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Last Name',
                                controller: lastNameController,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Gender',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => Container(
                                            height: 48,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                                width: 1.0,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: genderVal.value,
                                                isExpanded: true,
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF0F172A),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                items: [
                                                  DropdownMenuItem(
                                                    value: 'Male',
                                                    child: Text('Male'.tr),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Female',
                                                    child: Text('Female'.tr),
                                                  ),
                                                ],
                                                onChanged: (val) {
                                                  if (val != null)
                                                    genderVal.value = val;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'Date of Birth',
                                      controller: dobController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Phone Number',
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email',
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final success = await authController
                                        .updateProfile(
                                          firstNameController.text,
                                          lastNameController.text,
                                          phoneController.text,
                                          emailController.text,
                                          genderVal.value,
                                          dobController.text,
                                        );
                                    if (success) {
                                      Get.back();
                                      showToast(
                                        'Profile updated successfully.'.tr,
                                        title: 'Success',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE9900),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (authController.isLoading.value) {
                      return Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFE9900),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE9900),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// 2. Wallet Transactions List View
// ------------------------------------------------------------
class TransactionsView extends StatelessWidget {
  const TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final localizationController = Get.find<LocalizationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountController.fetchTransactions();
    });

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'transactions'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  // Filter Tabs
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: ['All', 'Deposits', 'Withdrawals'].map((
                        filter,
                      ) {
                        return Obx(() {
                          final isSelected =
                              accountController.activeTxFilter.value == filter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  accountController.changeTxFilter(filter),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryOrange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryOrange
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  filter == 'Deposits'
                                      ? 'Deposits'
                                      : filter == 'Withdrawals'
                                      ? 'Withdrawals'
                                      : 'All',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryDarkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),

                  // Transactions list
                  Expanded(
                    child: Obx(() {
                      final list = accountController.filteredTransactions;
                      if (list.isEmpty) {
                        final String displayMsg =
                            'no_transactions'.tr == 'no_transactions'
                            ? 'No Transactions'
                            : 'no_transactions'.tr;
                        return Center(
                          child: Text(
                            displayMsg,
                            style: const TextStyle(
                              color: AppTheme.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final tx = list[index];
                          final isDeposit = tx.type == TransactionType.deposit;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDeposit
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeposit
                                        ? Icons.south_west_rounded
                                        : Icons.north_east_rounded,
                                    color: isDeposit
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryDarkBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 10,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            tx.date,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDeposit
                                            ? Colors.green
                                            : (tx.status ==
                                                      TransactionStatus
                                                          .processing
                                                  ? Colors.orange
                                                  : Colors.red),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildTxStatusTag(tx.status),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTxStatusTag(TransactionStatus status) {
    String label = 'Completed';
    Color bg = Colors.green.shade50;
    Color textCol = Colors.green;

    if (status == TransactionStatus.processing) {
      label = 'Processing';
      bg = Colors.orange.shade50;
      textCol = Colors.orange;
    } else if (status == TransactionStatus.failed) {
      label = 'Failed';
      bg = Colors.red.shade50;
      textCol = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 8,
          color: textCol,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 3. Bank Accounts / Withdrawal Targets
// ------------------------------------------------------------
class BankAccountsView extends StatelessWidget {
  BankAccountsView({Key? key}) : super(key: key) {
    try {
      Get.find<AccountController>().fetchBankAccounts();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final localizationController = Get.find<LocalizationController>();

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'Bank Accounts',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    final addAccountButton = GestureDetector(
      onTap: () => Get.to(() => const AddBankAccountView()),
      child: DashedBorderContainer(
        borderRadius: 16,
        color: const Color(0xFFCBD5E1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  "lib/assets/images/AddAccount.png",
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'add_bank'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDarkBlue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'withdraw_desc'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: Obx(() {
                      if (accountController.isBankLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFE9900),
                          ),
                        );
                      }

                      if (accountController.savedAccounts.isEmpty) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: addAccountButton,
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: accountController.savedAccounts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final acc =
                                    accountController.savedAccounts[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Left: full-height Saving Account.png background image
                                        Image.asset(
                                          'lib/assets/images/Saving Account.png',
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                        // Right: label+value rows with asset icon buttons
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Row 1: Account Holder + Edit
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Account Holder',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            acc.accountHolder,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppTheme
                                                                  .primaryDarkBlue,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => Get.to(
                                                        () =>
                                                            EditBankAccountView(
                                                              account: acc,
                                                            ),
                                                      ),
                                                      child: Image.asset(
                                                        'lib/assets/images/Edit.png',
                                                        width: 18,
                                                        height: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                // Row 2: Account Number + Delete
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Account Number',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            acc.accountNumber,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppTheme
                                                                  .primaryDarkBlue,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Delete image button (no background)
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.dialog(
                                                          AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            title: Text(
                                                              'Delete Account'
                                                                  .tr,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xFF0F172A,
                                                                ),
                                                              ),
                                                            ),
                                                            content: Text(
                                                              'Want to delete account?'
                                                                  .tr,
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Get.back(),
                                                                child: Text(
                                                                  'No'.tr,
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                  accountController
                                                                      .deleteBankAccount(
                                                                        acc.id,
                                                                      );
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  minimumSize:
                                                                      const Size(
                                                                        80,
                                                                        38,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Yes'.tr,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: Image.asset(
                                                        'lib/assets/images/Delete.png',
                                                        width: 18,
                                                        height: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 150),
                            addAccountButton,
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showAddAccountSheet(
    BuildContext context,
    AccountController controller,
  ) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final bankController = TextEditingController();

    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'add_bank'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: holderController,
                  decoration: const InputDecoration(
                    hintText: 'Account Holder Name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Account Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(hintText: 'Bank Name'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (holderController.text.isNotEmpty &&
                        numberController.text.isNotEmpty &&
                        bankController.text.isNotEmpty) {
                      controller.addBankAccount(
                        holder: holderController.text,
                        number: numberController.text,
                        bank: bankController.text,
                      );
                    }
                  },
                  child: Text('Add Account'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ------------------------------------------------------------
// 3b. Add Bank Account View
// ------------------------------------------------------------
class AddBankAccountView extends StatelessWidget {
  const AddBankAccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final localizationController = Get.find<LocalizationController>();

    final bankNameController = TextEditingController();
    final holderNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final confirmAccountNumberController = TextEditingController();
    final swiftController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          const Text(
            'Add Bank Account',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Bank Name',
                            controller: bankNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Account Holder Name',
                            controller: holderNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Account Number',
                            controller: accountNumberController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Confirm Account Number',
                            controller: confirmAccountNumberController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'SWIFT / BIC Code',
                            controller: swiftController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Currency',
                            controller: currencyController,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (bankNameController.text.isEmpty) {
                                  showToast(
                                    'Please enter Bank Name'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (holderNameController.text.isEmpty) {
                                  showToast(
                                    'Please enter Account Holder Name'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (accountNumberController.text.isEmpty) {
                                  showToast(
                                    'Please enter Account Number'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (accountNumberController.text !=
                                    confirmAccountNumberController.text) {
                                  showToast(
                                    'Account Numbers do not match'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }

                                accountController.addBankAccount(
                                  holder: holderNameController.text,
                                  number: accountNumberController.text,
                                  bank: bankNameController.text,
                                  swift: swiftController.text,
                                  currency: currencyController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFE9900),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE9900),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// 3c. Edit Bank Account View
// ------------------------------------------------------------
class EditBankAccountView extends StatelessWidget {
  final BankAccountModel account;
  const EditBankAccountView({Key? key, required this.account})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final localizationController = Get.find<LocalizationController>();

    final bankNameController = TextEditingController(text: account.bankName);
    final holderNameController = TextEditingController(
      text: account.accountHolder,
    );
    final accountNumberController = TextEditingController(
      text: account.accountNumber,
    );
    final confirmAccountNumberController = TextEditingController(
      text: account.accountNumber,
    );
    final swiftController = TextEditingController(
      text: account.branchName ?? '',
    );
    final currencyController = TextEditingController(
      text: account.currency ?? 'USD',
    );

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          const Text(
            'Bank Account Details',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  customHeaderRow,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Bank Name',
                            controller: bankNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Account Holder Name',
                            controller: holderNameController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Account Number',
                            controller: accountNumberController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Confirm Account Number',
                            controller: confirmAccountNumberController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'SWIFT / BIC Code',
                            controller: swiftController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Currency',
                            controller: currencyController,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (bankNameController.text.isEmpty) {
                                  showToast(
                                    'Please enter Bank Name'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (holderNameController.text.isEmpty) {
                                  showToast(
                                    'Please enter Account Holder Name'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (accountNumberController.text.isEmpty) {
                                  showToast(
                                    'Please enter Account Number'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }
                                if (accountNumberController.text !=
                                    confirmAccountNumberController.text) {
                                  showToast(
                                    'Account Numbers do not match'.tr,
                                    title: 'Error',
                                  );
                                  return;
                                }

                                accountController.updateBankAccount(
                                  id: account.id,
                                  holder: holderNameController.text,
                                  number: accountNumberController.text,
                                  bank: bankNameController.text,
                                  swift: swiftController.text,
                                  currency: currencyController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFE9900),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE9900),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// 4. Policy (Privacy, Terms, Anti-Fraud, Under-18) HTML mock
// ------------------------------------------------------------
class PolicyView extends StatefulWidget {
  final String policyType;

  const PolicyView({Key? key, required this.policyType}) : super(key: key);

  @override
  State<PolicyView> createState() => _PolicyViewState();
}

class _PolicyViewState extends State<PolicyView> {
  @override
  void initState() {
    super.initState();
    if (widget.policyType == 'privacy') {
      try {
        Get.find<AccountController>().fetchPrivacyPolicy();
      } catch (_) {}
    } else if (widget.policyType == 'terms') {
      try {
        Get.find<AccountController>().fetchTermsAndConditions();
      } catch (_) {}
    } else if (widget.policyType == 'fraud') {
      try {
        Get.find<AccountController>().fetchAntiFraudPolicy();
      } catch (_) {}
    } else if (widget.policyType == 'age') {
      try {
        Get.find<AccountController>().fetchUnder18ProtectionPolicy();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;
      final Widget view;
      if (widget.policyType == 'privacy') {
        view = _buildPrivacyPolicyDynamic(context, localizationController);
      } else if (widget.policyType == 'terms') {
        view = _buildTermsAndConditionsDynamic(context, localizationController);
      } else if (widget.policyType == 'fraud') {
        view = _buildAntiFraudPolicyDynamic(context, localizationController);
      } else if (widget.policyType == 'age') {
        view = _buildUnder18PolicyDynamic(context, localizationController);
      } else {
        view = _buildUnder18Policy(context);
      }
      return Directionality(textDirection: textDirection, child: view);
    });
  }

  /// Strips HTML tags from a string and returns plain text.
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Parses an HTML string into a list of sections.
  /// Each section has a [heading] (from <h3>) and [items] (from <li>).
  /// Text between headings with no <li> becomes a [paragraph].
  List<Map<String, dynamic>> _parseSections(String html) {
    final sections = <Map<String, dynamic>>[];

    // Split on <h3> tags
    final h3Pattern = RegExp(r'<h3>(.*?)<\/h3>', dotAll: true);
    final matches = h3Pattern.allMatches(html).toList();

    // Text before first heading (intro paragraph)
    final firstHeadingStart = matches.isEmpty
        ? html.length
        : matches.first.start;
    final intro = _stripHtml(html.substring(0, firstHeadingStart)).trim();
    if (intro.isNotEmpty) {
      sections.add({'type': 'intro', 'text': intro});
    }

    for (int i = 0; i < matches.length; i++) {
      final heading = _stripHtml(matches[i].group(1) ?? '');
      final contentStart = matches[i].end;
      final contentEnd = i + 1 < matches.length
          ? matches[i + 1].start
          : html.length;
      final block = html.substring(contentStart, contentEnd);

      // Extract <li> items
      final liPattern = RegExp(r'<li>(.*?)<\/li>', dotAll: true);
      final liMatches = liPattern.allMatches(block).toList();
      if (liMatches.isNotEmpty) {
        final items = liMatches.map((m) {
          final raw = m.group(1) ?? '';
          // Check for <strong> prefix
          final strongMatch = RegExp(
            r'<strong>(.*?)<\/strong>(.*)',
            dotAll: true,
          ).firstMatch(raw);
          if (strongMatch != null) {
            return {
              'bold': _stripHtml(strongMatch.group(1) ?? ''),
              'text': _stripHtml(strongMatch.group(2) ?? ''),
            };
          }
          return {'bold': '', 'text': _stripHtml(raw)};
        }).toList();
        // Extract any paragraph text before/between the <ul>
        final ulStart = block.indexOf('<ul>');
        String? paraText;
        if (ulStart > 0) {
          paraText = _stripHtml(block.substring(0, ulStart)).trim();
        }
        sections.add({
          'type': 'section',
          'heading': heading,
          'para': paraText?.isNotEmpty == true ? paraText : null,
          'items': items,
        });
      } else {
        // No list items — treat as paragraph section
        final para = _stripHtml(block).trim();
        sections.add({
          'type': 'section',
          'heading': heading,
          'para': para.isNotEmpty ? para : null,
          'items': <Map<String, dynamic>>[],
        });
      }
    }

    return sections;
  }

  Widget _buildPrivacyPolicyDynamic(
    BuildContext context,
    LocalizationController localizationController,
  ) {
    final accountController = Get.find<AccountController>();
    final lang = localizationController.currentLanguage.value;

    final title = lang == 'fr'
        ? accountController.policyTitleFr.value
        : lang == 'ht'
        ? accountController.policyTitleHt.value
        : accountController.policyTitleEn.value;

    final content = lang == 'fr'
        ? accountController.policyContentFr.value
        : lang == 'ht'
        ? accountController.policyContentHt.value
        : accountController.policyContentEn.value;

    final displayTitle = title.isNotEmpty ? title : 'Privacy Policy';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (accountController.isPolicyLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFE9900)),
                  );
                }

                if (content.isEmpty &&
                    !accountController.isPolicyLoading.value) {
                  return _buildPrivacyPolicy(context);
                }

                final sections = _parseSections(content);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sections.map((section) {
                        if (section['type'] == 'intro') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['text'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        final heading = section['heading'] as String? ?? '';
                        final para = section['para'] as String?;
                        final items =
                            (section['items'] as List<Map<String, dynamic>>?) ??
                            [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(heading),
                            if (para != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                para,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildCard(
                                children: items.map<Widget>((item) {
                                  final bold = item['bold'] as String? ?? '';
                                  final text = item['text'] as String? ?? '';
                                  if (bold.isNotEmpty) {
                                    return _buildBulletItemWithBoldPrefix(
                                      context,
                                      '$bold: ',
                                      text,
                                    );
                                  }
                                  return _buildBulletItem(text);
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                      // Static "Questions?" contact footer — unchanged
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002C8B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Questions?",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Our team is available to assist you with any concerns.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE9900),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mail_rounded,
                                        color: Color(0xFFFE9900),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "support@norbizlotto.com",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionsDynamic(
    BuildContext context,
    LocalizationController localizationController,
  ) {
    final accountController = Get.find<AccountController>();
    final lang = localizationController.currentLanguage.value;

    final title = lang == 'fr'
        ? accountController.termsTitleFr.value
        : lang == 'ht'
        ? accountController.termsTitleHt.value
        : accountController.termsTitleEn.value;

    final content = lang == 'fr'
        ? accountController.termsContentFr.value
        : lang == 'ht'
        ? accountController.termsContentHt.value
        : accountController.termsContentEn.value;

    final displayTitle = title.isNotEmpty ? title : 'Terms & Conditions';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (accountController.isTermsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFE9900)),
                  );
                }

                if (content.isEmpty &&
                    !accountController.isTermsLoading.value) {
                  return _buildTermsAndConditions(context);
                }

                final sections = _parseSections(content);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sections.map((section) {
                        if (section['type'] == 'intro') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['text'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        final heading = section['heading'] as String? ?? '';
                        final para = section['para'] as String?;
                        final items =
                            (section['items'] as List<Map<String, dynamic>>?) ??
                            [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(heading),
                            if (para != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                para,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildCard(
                                children: items.map<Widget>((item) {
                                  final bold = item['bold'] as String? ?? '';
                                  final text = item['text'] as String? ?? '';
                                  if (bold.isNotEmpty) {
                                    return _buildBulletItemWithBoldPrefix(
                                      context,
                                      '$bold: ',
                                      text,
                                    );
                                  }
                                  return _buildBulletItem(text);
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                      const SizedBox(height: 32),
                      // Static "Questions?" contact footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002C8B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Questions?",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Our team is available to assist you with any concerns.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                // Optional email client launch trigger (handled cleanly)
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE9900),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mail_rounded,
                                        color: Color(0xFFFE9900),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "support@norbizlotto.com",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntiFraudPolicyDynamic(
    BuildContext context,
    LocalizationController localizationController,
  ) {
    final accountController = Get.find<AccountController>();
    final lang = localizationController.currentLanguage.value;

    final title = lang == 'fr'
        ? accountController.fraudTitleFr.value
        : lang == 'ht'
        ? accountController.fraudTitleHt.value
        : accountController.fraudTitleEn.value;

    final content = lang == 'fr'
        ? accountController.fraudContentFr.value
        : lang == 'ht'
        ? accountController.fraudContentHt.value
        : accountController.fraudContentEn.value;

    final displayTitle = title.isNotEmpty ? title : 'Anti-Fraud Policy';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (accountController.isFraudLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFE9900)),
                  );
                }

                if (content.isEmpty &&
                    !accountController.isFraudLoading.value) {
                  return _buildAntiFraudPolicy(context);
                }

                final sections = _parseSections(content);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sections.map((section) {
                        if (section['type'] == 'intro') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['text'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        final heading = section['heading'] as String? ?? '';
                        final para = section['para'] as String?;
                        final items =
                            (section['items'] as List<Map<String, dynamic>>?) ??
                            [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(heading),
                            if (para != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                para,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildCard(
                                children: items.map<Widget>((item) {
                                  final bold = item['bold'] as String? ?? '';
                                  final text = item['text'] as String? ?? '';
                                  if (bold.isNotEmpty) {
                                    return _buildBulletItemWithBoldPrefix(
                                      context,
                                      '$bold: ',
                                      text,
                                    );
                                  }
                                  return _buildBulletItem(text);
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002C8B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Reporting Fraud",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Users may report suspicious activity to",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                // Optional email client launch trigger (handled cleanly)
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE9900),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mail_rounded,
                                        color: Color(0xFFFE9900),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "support@norbizlotto.com",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnder18PolicyDynamic(
    BuildContext context,
    LocalizationController localizationController,
  ) {
    final accountController = Get.find<AccountController>();
    final lang = localizationController.currentLanguage.value;

    final title = lang == 'fr'
        ? accountController.under18TitleFr.value
        : lang == 'ht'
        ? accountController.under18TitleHt.value
        : accountController.under18TitleEn.value;

    final content = lang == 'fr'
        ? accountController.under18ContentFr.value
        : lang == 'ht'
        ? accountController.under18ContentHt.value
        : accountController.under18ContentEn.value;

    final displayTitle = title.isNotEmpty ? title : 'Under-18 Protection';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (accountController.isUnder18Loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFE9900)),
                  );
                }

                if (content.isEmpty &&
                    !accountController.isUnder18Loading.value) {
                  return _buildUnder18Policy(context);
                }

                final sections = _parseSections(content);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...sections.map((section) {
                        if (section['type'] == 'intro') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['text'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        final heading = section['heading'] as String? ?? '';
                        final para = section['para'] as String?;
                        final items =
                            (section['items'] as List<Map<String, dynamic>>?) ??
                            [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(heading),
                            if (para != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                para,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildCard(
                                children: items.map<Widget>((item) {
                                  final bold = item['bold'] as String? ?? '';
                                  final text = item['text'] as String? ?? '';
                                  if (bold.isNotEmpty) {
                                    return _buildBulletItemWithBoldPrefix(
                                      context,
                                      '$bold: ',
                                      text,
                                    );
                                  }
                                  return _buildBulletItem(text);
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002C8B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Reporting Fraud",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Users may report suspicious activity to",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                // Optional email client launch trigger (handled cleanly)
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE9900),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mail_rounded,
                                        color: Color(0xFFFE9900),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "support@norbizlotto.com",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row matching screen exactly
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto ("we", "our", "the Company") is committed to protecting your personal information and ensuring transparency in how your data is collected, used, and safeguarded. This Privacy Policy explains the types of information we collect, how we use it, and the rights you have regarding your data',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Information We Collect"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may collect the following categories of information:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Personal Identification: ",
                          "full name, date of birth, gender",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Contact Information: ",
                          "phone number, email address",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Account Information: ",
                          "login credentials, wallet balance, transaction history",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Device Information: ",
                          "IP address, device type, operating system, usage analytics",
                        ),
                        _buildBulletItemWithBoldPrefix(
                          context,
                          "Verification Data: ",
                          "identity documents, age verification, anti-fraud checks",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("How We Use Your Information"),
                    const SizedBox(height: 8),
                    const Text(
                      "Your information is used to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Create and manage your Norbiz Lotto account",
                        ),
                        _buildBulletItem(
                          "Process deposits, withdrawols, and lottery bets",
                        ),
                        _buildBulletItem("Verify identity and prevent fraud"),
                        _buildBulletItem("Provide customer support"),
                        _buildBulletItem(
                          "Improve app performance and user experience",
                        ),
                        _buildBulletItem(
                          "Comply with legal and regulatory requirements",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Sharing"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may share your information with:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Licensed payment processors"),
                        _buildBulletItem("Identity verification partners"),
                        _buildBulletItem(
                          "Regulatory authorities (when required by law)",
                        ),
                        _buildBulletItem(
                          "Fraud-prevention and security partners",
                        ),
                      ],
                      footer: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF3FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(19),
                            bottomRight: Radius.circular(19),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "We do not sell your personal information .",
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Security"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "We use encryption, secure servers, and continuous monitoring to protect your data from unauthorized access or misuse.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Your Rights"),
                    const SizedBox(height: 8),
                    const Text(
                      "You may:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Request access to your data"),
                        _buildBulletItem("Request corrections"),
                        _buildBulletItem(
                          "Request deletion (subject to legal retention rules)",
                        ),
                        _buildBulletItem("Withdraw consent"),
                        _buildBulletItem("Request a copy of your data"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Data Retention"),
                    const SizedBox(height: 8),
                    const Text(
                      "We retain your information only as long as necessary for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Legal compliance"),
                        _buildBulletItem("Transaction history"),
                        _buildBulletItem("Anti-fraud monitoring"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Questions?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Our team is available to assist you with any concerns.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFFE9900),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children, Widget? footer}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          if (footer != null) footer,
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 6.0,
        bottom: 6.0,
        right: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItemWithBoldPrefix(
    BuildContext context,
    String boldPrefix,
    String normalText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 6.0,
        bottom: 6.0,
        right: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: boldPrefix,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'These Terms & Conditions govern your use of the Norbiz Lotto mobile application and services. By creating an account or placing a bet, you agree to these terms',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Eligibility"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "You must be 18 years or older to use the platform",
                        ),
                        _buildBulletItem(
                          "You must provide accurate and verifiable information",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Account Registration"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "Users must register with a valid phone number and maintain the confdentiality of their login credentials",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Betting Rules"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("All bets are final once confirmed"),
                        _buildBulletItem(
                          "Bets cannot be modified or cancelled after submission",
                        ),
                        _buildBulletItem(
                          "Winnings are calculated based on the official draw results",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Wallet & Payments"),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Deposits must come from authorized payment methods",
                        ),
                        _buildBulletItem(
                          "Withdrawals may require identity verification",
                        ),
                        _buildBulletItem(
                          "The Company may apply service fees where applicable",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Fraud & Misconduct"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto reserves the right to suspend or terminate accounts involved in:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Fraudulent activity"),
                        _buildBulletItem("Multiple account creation"),
                        _buildBulletItem("Manipulation of results"),
                        _buildBulletItem(
                          "Chargebacks or unauthorized transactions",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Limitation of Liability"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto is not responsible for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Network issues"),
                        _buildBulletItem(
                          "Delays caused by third-party providers",
                        ),
                        _buildBulletItem(
                          "Incorrect information submitted by users",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Changes to Terms"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto is not responsible for:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "We may update these Terms & Conditions at any time. Continued use of the app constitutes acceptance of the updated terms.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Questions?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Our team is available to assist you with any concerns.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntiFraudPolicy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Anti-Fraud Policy',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto is committed to maintaining a secure, transparent, and fair gaming environment. This Anti-Fraud Policy outlines the measures we take to detect, prevent, and respond to fraudulent activity',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Purpose"),
                    const SizedBox(height: 8),
                    const Text(
                      "This policy ensures:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Fair play"),
                        _buildBulletItem("Protection of user accounts"),
                        _buildBulletItem(
                          "Integrity of all lottery transactions",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Prohibited Activities"),
                    const SizedBox(height: 8),
                    const Text(
                      "The following actions are strictly forbidden:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Creating multiple accounts"),
                        _buildBulletItem(
                          "Using false or stolen identity information",
                        ),
                        _buildBulletItem("Manipulating betting systems"),
                        _buildBulletItem(
                          "Attempting to interfere with draw results",
                        ),
                        _buildBulletItem(
                          "Unauthorized access to another user's account",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Monitoring & Detection"),
                    const SizedBox(height: 8),
                    const Text(
                      "We use:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Automated fraud-detection systems"),
                        _buildBulletItem(
                          "Manual review of suspicious transactions",
                        ),
                        _buildBulletItem("Device fingerprinting"),
                        _buildBulletItem("IP and geolocation checks"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Verification Requirements"),
                    const SizedBox(height: 8),
                    const Text(
                      "We may request:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Government-issued ID"),
                        _buildBulletItem("Proof of address"),
                        _buildBulletItem("Proof of payment ownership"),
                      ],
                      footer: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF3FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(19),
                            bottomRight: Radius.circular(19),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Failure to comply may result in account suspension",
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Consequences of Fraud"),
                    const SizedBox(height: 8),
                    const Text(
                      "If fraud is detected, Norbiz Lotto may:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Freeze the account"),
                        _buildBulletItem("Cancel pending bets"),
                        _buildBulletItem("Withhold winnings"),
                        _buildBulletItem("Report the case to authorities"),
                        _buildBulletItem("Permanently ban the user"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Reporting Fraud",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Users may report suspicious activity to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnder18Policy(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 38,
                        width: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Under-18 Protection',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Norbiz Lotto is fully committed to preventing minors from accessing, participating in, or being exposed to any form of gambling activity. This policy establishes strict measures to ensure that individuals under the age of 18 are protected at all times',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Zero-Tolerance Rule"),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto maintains a strict zero-tolerance policy regarding under-age gambling. No person under the age of 18 years is permitted to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Create an account"),
                        _buildBulletItem("Access the platform"),
                        _buildBulletItem(
                          "Place bets or participate in any game",
                        ),
                        _buildBulletItem("Make deposits or withdrawals"),
                        _buildBulletItem("Claim winnings"),
                        _buildBulletItem(
                          "Use any Norbiz Lotto service, directly or indirectly",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Any attempt to bypass age restrictions will result in immediate account suspension and notification to the appropriate authorities if required",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Age Verification Procedures"),
                    const SizedBox(height: 8),
                    const Text(
                      "To ensure full compliance, Norbiz Lotto implements multi-layered verification:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Mandatory identity verification (ID, passport, or national document)",
                        ),
                        _buildBulletItem(
                          "Proof of age validated through official documents",
                        ),
                        _buildBulletItem(
                          "Automated system checks to detect inconsistencies",
                        ),
                        _buildBulletItem(
                          "Manual review by the Compliance Team when necessary",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No account becomes fully active until age verification is successfully completed",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Parental & Guardian Responsibility"),
                    const SizedBox(height: 8),
                    const Text(
                      "Parents and legal guardians are encouraged to:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Monitor devices accessible to minors",
                        ),
                        _buildBulletItem("Use parental control tools"),
                        _buildBulletItem(
                          "Ensure minors do not have access to payment methods linked to gambling",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Norbiz Lotto cannot be held responsible for unauthorized access resulting from negligence by parents or guardians",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Marketing & Communication Restrictions",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Norbiz Lotto strictly prohibits:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Any marketing material targeting minors",
                        ),
                        _buildBulletItem(
                          "Use of imagery, language, or themes appealing to children",
                        ),
                        _buildBulletItem(
                          "Advertising on platforms primarily used by minors",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "All communication is designed for an adult audience only",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Account Monitoring & Fraud Prevention",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "The platform uses advanced monitoring tools to detect:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "Suspicious activity suggesting under-age access",
                        ),
                        _buildBulletItem(
                          "Accounts created using fake or borrowed identification",
                        ),
                        _buildBulletItem(
                          "Attempts by adults to place bets on behalf of minors",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Any violation leads to permanent account closure",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Reporting Under-Age Gambling"),
                    const SizedBox(height: 8),
                    const Text(
                      "The platform uses advanced monitoring tools to detect:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        const Text(
                          "Users, partners, and third parties are encouraged to report any suspicion of under-age gambling. Reports can be submitted to the Norbiz Lotto Compliance Department for immediate investigation",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Compliance With International Standards",
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This policy aligns with:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem(
                          "International responsible gaming standards",
                        ),
                        _buildBulletItem("Anti-fraud and KYC regulations"),
                        _buildBulletItem(
                          "Local and international gambling compliance frameworks",
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Norbiz Lotto ensures continuous updates to remain aligned with evolving legal requirements.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Enforcement & Sanctions"),
                    const SizedBox(height: 8),
                    const Text(
                      "Any breach of this policy results in:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildBulletItem("Immediate account suspension"),
                        _buildBulletItem(
                          "Confiscation of funds if required by law",
                        ),
                        _buildBulletItem(
                          "Notification to regulatory authorities",
                        ),
                        _buildBulletItem(
                          "Permanent exclusion from the platform",
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002C8B),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Reporting Fraud",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Users may report suspicious activity to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              // Optional email client launch trigger (handled cleanly)
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE9900),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFFFE9900),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "support@norbizlotto.com",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 5. Help Center Support Channels
// ------------------------------------------------------------
class HelpCenterView extends StatelessWidget {
  const HelpCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final accountController = Get.find<AccountController>();

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom Header Row matching screen exactly
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    height: 62,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 38,
                              width: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF0F172A),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Help Center',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // WhatsApp Card
                          _buildWhatsAppCard(),
                          const SizedBox(height: 16),

                          // Email Support Card
                          _buildEmailCard(),
                          const SizedBox(height: 16),

                          // Support Info Card
                          _buildSupportInfoCard(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWhatsAppCard() {
    final accountController = Get.find<AccountController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'lib/assets/images/whatsapp.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'WhatsApp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chat with us directly on your mobile device for on-the-go support.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                accountController.launchWhatsApp(
                  accountController.whatsappNumber.value,
                  accountController.whatsappUrl.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE9900),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Start Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    final accountController = Get.find<AccountController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'lib/assets/images/mail.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email Support',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Detailed inquiries? Send us an email and we'll reply within 2 hours.",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final email = accountController.contactEmail.value.isNotEmpty
                    ? accountController.contactEmail.value
                    : "support@norbizlotto.com";
                accountController.launchURL("mailto:$email");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE9900),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Send Mail',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfoCard() {
    final accountController = Get.find<AccountController>();
    final businessHours =
        (accountController.workingHoursStart.value.isNotEmpty &&
            accountController.workingHoursEnd.value.isNotEmpty)
        ? "Available ${accountController.workingHoursStart.value} - ${accountController.workingHoursEnd.value}"
        : 'Available 9 AM - 10 PM';
    final waNumber = accountController.whatsappNumber.value.isNotEmpty
        ? accountController.whatsappNumber.value
        : '+1 1234567800';
    final supportEmail = accountController.contactEmail.value.isNotEmpty
        ? accountController.contactEmail.value
        : 'support@norbizlotto.com';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFFFE9900),
              size: 24,
            ),
            title: 'Business Hours',
            subtitle: businessHours,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: Image.asset(
              'lib/assets/images/whatsapp.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            title: 'WhatsApp',
            subtitle: waNumber,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            iconWidget: Image.asset(
              'lib/assets/images/mail.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            title: 'Support Email',
            subtitle: supportEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: Center(child: iconWidget)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// Change Password View
// ------------------------------------------------------------
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final localizationController = Get.find<LocalizationController>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final isCurrentPasswordVisible = false.obs;
    final isNewPasswordVisible = false.obs;
    final isConfirmPasswordVisible = false.obs;

    final customHeaderRow = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 24,
              ),
            ),
          ),
          Text(
            'Change Password'.tr,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 38), // Spacer of same width to center the title
        ],
      ),
    );

    return Obx(() {
      final textDirection = localizationController.textDirection;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFEFF3FD),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.pageBackgroundGradient,
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      customHeaderRow,
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => _buildTextField(
                                  label: 'Current Password'.tr,
                                  controller: currentPasswordController,
                                  obscureText: !isCurrentPasswordVisible.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isCurrentPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        isCurrentPasswordVisible.value =
                                            !isCurrentPasswordVisible.value,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => _buildTextField(
                                  label: 'enter_new_password'.tr,
                                  controller: newPasswordController,
                                  obscureText: !isNewPasswordVisible.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isNewPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        isNewPasswordVisible.value =
                                            !isNewPasswordVisible.value,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => _buildTextField(
                                  label: 'enter_confirm_password'.tr,
                                  controller: confirmPasswordController,
                                  obscureText: !isConfirmPasswordVisible.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        isConfirmPasswordVisible.value =
                                            !isConfirmPasswordVisible.value,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final currentPwd =
                                        currentPasswordController.text;
                                    final newPwd = newPasswordController.text;
                                    final confirmPwd =
                                        confirmPasswordController.text;

                                    if (currentPwd.isEmpty) {
                                      showToast(
                                        'Please enter your current password.'
                                            .tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }
                                    if (newPwd.isEmpty) {
                                      showToast(
                                        'Please enter your new password.'.tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }
                                    if (newPwd.length < 6) {
                                      showToast(
                                        'Password must be at least 6 characters.'
                                            .tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }
                                    if (confirmPwd.isEmpty) {
                                      showToast(
                                        'Please confirm your new password.'.tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }
                                    if (newPwd != confirmPwd) {
                                      showToast(
                                        'Passwords do not match.'.tr,
                                        title: 'Error',
                                      );
                                      return;
                                    }

                                    // Call actual API using AuthController
                                    final success = await authController
                                        .changePassword(
                                          currentPwd,
                                          newPwd,
                                          confirmPwd,
                                        );
                                    if (success) {
                                      Get.back();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE9900),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'save'.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (authController.isLoading.value) {
                      return Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFE9900),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFE9900),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// 6. Deposit Funds View
// ------------------------------------------------------------
class DepositFundsView extends StatefulWidget {
  const DepositFundsView({Key? key}) : super(key: key);

  @override
  State<DepositFundsView> createState() => _DepositFundsViewState();
}

class _DepositFundsViewState extends State<DepositFundsView> {
  final TextEditingController _amountController = TextEditingController();
  final List<double> _predefinedAmounts = [500, 1000, 2000, 5000, 7000, 10000];
  double? _selectedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final accountController = Get.find<AccountController>();

    return Directionality(
      textDirection: localizationController.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.pageBackgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom Header Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 38,
                            width: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF0F172A),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Deposit Funds',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Deposit Amount Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF002C8B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Deposit Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Predefined grid of amounts (3 columns)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 2.3,
                                    ),
                                itemCount: _predefinedAmounts.length,
                                itemBuilder: (context, index) {
                                  final amount = _predefinedAmounts[index];
                                  final isSelected = _selectedAmount == amount;
                                  final displayVal =
                                      amount == 1000 ||
                                          amount == 2000 ||
                                          amount == 5000 ||
                                          amount == 7000 ||
                                          amount == 10000
                                      ? '${amount.toInt().toString().substring(0, amount.toInt().toString().length - 3)},000'
                                      : amount.toInt().toString();

                                  return GestureDetector(
                                    onTap: () => _selectAmount(amount),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFFFF7ED)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFFE9900)
                                              : const Color(
                                                  0xFFFE9900,
                                                ).withOpacity(0.3),
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        displayVal,
                                        style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              // Custom Amount TextField
                              Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFE9900,
                                    ).withOpacity(0.4),
                                    width: 1.0,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      final parsed = double.tryParse(
                                        val.replaceAll(',', ''),
                                      );
                                      _selectedAmount = parsed;
                                    });
                                  },
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter custom amount',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              final text = _amountController.text.replaceAll(
                                ',',
                                '',
                              );
                              final amount = double.tryParse(text) ?? 0.0;
                              if (amount > 0) {
                                Get.dialog(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Text(
                                      'Confirm Deposit'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    content: Text(
                                      '${'Are you sure you want to deposit'.tr} \$${amount.toStringAsFixed(2)}?',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 14,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          'Cancel'.tr,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Get.back();
                                          await Future.delayed(const Duration(milliseconds: 150));
                                          accountController.depositFunds(amount);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFE9900),
                                          minimumSize: const Size(80, 38),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text('ok'.tr),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showToast(
                                  'Please enter a valid deposit amount.',
                                  title: 'Error',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFE9900),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
