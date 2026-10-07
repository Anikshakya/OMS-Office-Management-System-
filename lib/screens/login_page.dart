import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';
import 'package:oms/screens/forgot_password.dart';
import 'package:oms/theme/app_typography.dart';
import 'package:oms/theme/app_colors.dart';
import 'package:oms/widgets/common/custom_inputs.dart';
import 'package:oms/widgets/common/custom_buttons.dart';
import 'package:oms/app_config/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(
    text: "anik_mi+omsemployee@yonefu.info",
  );
  final _passwordController = TextEditingController(text: "1qaZXCde3@ws");
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
          // 1. Ambient Background Glow Orbs
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

          // 2. Main Scrollable Content
          SafeArea(
            child: Center(
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
                      _LoginHeader(isDark: isDark),
                      const SizedBox(height: 36),
                      _LoginCard(
                        isDark: isDark,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildEmailField(),
                              const SizedBox(height: 20),
                              _buildPasswordField(isDark),
                              const SizedBox(height: 14),
                              _buildForgotPasswordLink(isDark),
                              const SizedBox(height: 28),
                              _buildLoginButton(),
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
          ),
        ],
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

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'name@company.com',
      controller: _emailController,
      prefixIcon: Icons.alternate_email_rounded,
      validator: Validator.validateEmail,
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return AppTextField(
      label: 'Password',
      hint: '••••••••••••',
      controller: _passwordController,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      maxLines: 1,
      validator: Validator.validatePassword,
      suffixIcon: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          Get.to(() => ForgotPasswordPage());
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => AppButton.primary(
        label: 'Sign In',
        isFullWidth: true,
        isLoading: _authController.isLoginLoading.value,
        onPressed: _submit,
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
}

/// Brand header with elevated dual-layer badge
class _LoginHeader extends StatelessWidget {
  final bool isDark;
  const _LoginHeader({required this.isDark});

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
            Icons.corporate_fare_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your OMS workspace',
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

/// Frosted Glass / Elevated Surface Card
class _LoginCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _LoginCard({required this.isDark, required this.child});

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
