import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';
import 'package:oms/theme/app_typography.dart';
import 'package:oms/theme/app_colors.dart';
import 'package:oms/widgets/common/custom_inputs.dart';
import 'package:oms/widgets/common/custom_buttons.dart';
import 'package:oms/app_config/validator.dart';

class ResetPasswordPage extends StatefulWidget {
  /// The email the OTP was sent to (passed from ForgotPasswordPage).
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _authController.resetPassword(
        email: widget.email,
        token: _tokenController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Stack(
        children: [
          // 1. Ambient background glow orbs
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
                          _ResetHeader(isDark: isDark, email: widget.email),
                          const SizedBox(height: 36),
                          _GlassCard(
                            isDark: isDark,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTokenField(),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(isDark),
                                  const SizedBox(height: 20),
                                  _buildConfirmField(isDark),
                                  const SizedBox(height: 28),
                                  _buildResetButton(),
                                  const SizedBox(height: 18),
                                  _buildResendLink(),
                                ],
                              ),
                            ),
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
  // Fields
  // ---------------------------------------------------------------------------

  Widget _buildTokenField() {
    return AppTextField(
      label: 'Verification Code',
      hint: 'Enter the code from your email',
      controller: _tokenController,
      prefixIcon: Icons.pin_outlined,
      maxLines: 1,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Verification code is required';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return AppTextField(
      label: 'New Password',
      hint: '••••••••••••',
      controller: _passwordController,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      maxLines: 1,
      validator: Validator.validatePassword,
      suffixIcon: _buildVisibilityToggle(
        isDark: isDark,
        obscured: _obscurePassword,
        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }

  Widget _buildConfirmField(bool isDark) {
    return AppTextField(
      label: 'Confirm Password',
      hint: '••••••••••••',
      controller: _confirmController,
      prefixIcon: Icons.lock_reset_rounded,
      obscureText: _obscureConfirm,
      maxLines: 1,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      suffixIcon: _buildVisibilityToggle(
        isDark: isDark,
        obscured: _obscureConfirm,
        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
      ),
    );
  }

  Widget _buildVisibilityToggle({
    required bool isDark,
    required bool obscured,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Buttons & links
  // ---------------------------------------------------------------------------

  Widget _buildResetButton() {
    return Obx(
      () => AppButton.primary(
        label: 'Reset Password',
        isFullWidth: true,
        isLoading: _authController.isResetLoading.value,
        onPressed: _submit,
      ),
    );
  }

  Widget _buildResendLink() {
    return Center(
      child: Obx(
        () => GestureDetector(
          onTap: _authController.isForgotLoading.value
              ? null
              : () => _authController.forgotPassword(email: widget.email),
          child: Text(
            _authController.isForgotLoading.value
                ? 'Sending...'
                : "Didn't get a code? Resend",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
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

/// Brand header: icon badge + title + subtitle with the email highlighted
class _ResetHeader extends StatelessWidget {
  final bool isDark;
  final String email;
  const _ResetHeader({required this.isDark, required this.email});

  @override
  Widget build(BuildContext context) {
    final mutedColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.6,
    );

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
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the code we sent to',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(isDark).copyWith(color: mutedColor),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.w700),
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
