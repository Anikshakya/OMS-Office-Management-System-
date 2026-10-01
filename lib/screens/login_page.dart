import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  RxBool isLoginLoading = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // //auth controller
  // Future<void> _login() async {

  //   if (!_formKey.currentState!.validate()) return;

  //   try {
  //     isLoginLoading(true);
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     write("token", _emailController.text.trim());

  //     // Login successful - navigate to home
  //     if (!mounted) return;
  //     Get.offAll(() => HomePage());
  //   } on FirebaseAuthException catch (e) {
  //     if (!mounted) return;

  //     String errorMessage = 'Login failed. Please try again.';
  //     if (e.code == 'user-not-found') {
  //       errorMessage = 'No user found with this email.';
  //     } else if (e.code == 'wrong-password') {
  //       errorMessage = 'Incorrect password.';
  //     } else if (e.code == 'invalid-email') {
  //       errorMessage = 'Invalid email address.';
  //     }

  //    showErrorToast(errorMessage);
  //   } catch (e) {
  //     if (!mounted) return;
  //     showErrorToast('An error occurred: $e');
  //   } finally {
  //     isLoginLoading(false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome!'),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                loginCreds(),
                const SizedBox(height: 30),

                // Login Button
                loginButton(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //login credentials
  Form loginCreds() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 400 : 20),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              // headingText: "Email",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              // headingText: "Password",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding loginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 400 : 20),
      child: Obx(() {
        AuthController authController = AuthController();
        // Use Obx to make it reactive
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authController.isLoginLoading.isTrue
                ? () {}
                : () => authController.login(
                    email: _emailController.text,
                    password: _passwordController.text,
                  ),
            child: Text("Login"),
            // color: darkBlue,
            // text: "Login",
            // onPressed: isLoginLoading.isTrue
            //   ? null
            //   : () => _login(),
            // height: kIsWeb ? 56.h : 50.h,
            // width: double.infinity,
            // isLoading: isLoginLoading.isTrue,
          ),
        );
      }),
    );
  }
}
