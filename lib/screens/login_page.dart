import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';
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
  final _emailController = TextEditingController(text:"anik_mi+omsemployee@yonefu.info");
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LoginHeader(isDark: isDark),
                  const SizedBox(height: 32),
                  _LoginCard(
                    isDark: isDark,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEmailField(),
                          const SizedBox(height: 18),
                          _buildPasswordField(isDark),
                          const SizedBox(height: 24),
                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      prefixIcon: Icons.email_rounded,
      validator: Validator.validateEmail,
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return AppTextField(
      label: 'Password',
      hint: 'Enter your password',
      controller: _passwordController,
      prefixIcon: Icons.lock_rounded,
      obscureText: _obscurePassword,
      maxLines: 1,
      validator: Validator.validatePassword,
      suffixIcon: IconButton(
        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        splashRadius: 20,
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          size: 20,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
}

/// Brand mark + title, styled like the app header's logo chip.
class _LoginHeader extends StatelessWidget {
  final bool isDark;
  const _LoginHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.corporate_fare_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium(isDark),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue to  OMS',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(isDark),
        ),
      ],
    );
  }
}

/// Bordered surface card that holds the form.
class _LoginCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _LoginCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
