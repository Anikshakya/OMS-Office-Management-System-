import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';
import 'package:oms/screens/reset_password.dart';
import 'package:oms/theme/app_typography.dart';
import 'package:oms/theme/app_colors.dart';
import 'package:oms/widgets/common/custom_inputs.dart';
import 'package:oms/widgets/common/custom_buttons.dart';
import 'package:oms/app_config/validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await _authController.forgotPassword(email: email);
    if (!mounted) return;

    // OTP sent -> go to reset password page.
    // Get.off replaces this page, so back from reset returns to login.
    if (success) {
      Get.off(() => ResetPasswordPage(email: email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Stack(
        children: [
          // 1. Ambient background glow orbs (same as login)
          Positioned(
            top: -100,
            right: -80,
            child: _buildGlowOrb(
              color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _buildGlowOrb(
              color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
              size: 350,
            ),
          ),

          // 2. Main content
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ForgotHeader(isDark: isDark),
                          const SizedBox(height: 36),
                          _GlassCard(
                            isDark: isDark,
                            child: _buildFormContent(),
                          ),
                          const SizedBox(height: 32),
                          _buildFooter(isDark),
                        ],
                      ),
                    ),
                  ),
                ),

                // Back button (top-left)
                Positioned(top: 8, left: 12, child: _buildBackButton(isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email',
            hint: 'name@company.com',
            controller: _emailController,
            prefixIcon: Icons.alternate_email_rounded,
            validator: Validator.validateEmail,
          ),
          const SizedBox(height: 28),
          Obx(
            () => AppButton.primary(
              label: 'Send Verification Code',
              isFullWidth: true,
              isLoading: _authController.isForgotLoading.value,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: 18),
          _buildBackToLoginLink(),
        ],
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
        child: const Text(
          'Back to Sign In',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Material(
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Get.back(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Text(
      'Protected by OMS Enterprise Security',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildGlowOrb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

/// Brand header: icon badge + title + subtitle
class _ForgotHeader extends StatelessWidget {
  final bool isDark;
  const _ForgotHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your email and we'll send you a verification code to reset your password",
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(isDark).copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Frosted glass card (same style as login card)
class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _GlassCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.75)
                : AppColors.surfaceLight.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
