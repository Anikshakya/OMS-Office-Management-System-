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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Icon placeholder
                Icon(
                  Icons.business_center_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium(isDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Nexus OMS',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(isDark),
                ),
                const SizedBox(height: 40),

                _buildLoginForm(),
                const SizedBox(height: 24),

                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            prefixIcon: Icons.email_rounded,
            validator: Validator.validateEmail,
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            prefixIcon: Icons.lock_rounded,
            obscureText: true,
            maxLines: 1,
            validator: Validator.validatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(() {
      final authController = Get.put(AuthController());
      return AppButton.primary(
        label: 'Sign In',
        isFullWidth: true,
        isLoading: authController.isLoginLoading.value,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            authController.login(
              email: _emailController.text,
              password: _passwordController.text,
            );
          }
        },
      );
    });
  }
}
