import 'package:get/get.dart';
import 'package:oms/api_config/api_repo.dart';
import 'package:oms/controllers/app_data_controller.dart';
import 'package:oms/services/cache_service.dart';
import 'package:oms/services/toast_service.dart';
import 'package:oms/controllers/app_controller.dart';
import 'package:oms/screens/dashboard.dart';
import 'package:oms/screens/login_page.dart';

class AuthController extends GetxController {
  final RxBool isLoginLoading = false.obs;
  final RxBool isLogoutLoading = false.obs;
  final RxBool isForgotLoading = false.obs;
  final RxBool isResetLoading = false.obs;

  Future<void> login({required String email, required String password}) async {
    isLoginLoading.value = true;
    try {
      var data = {"email": email, "password": password};
      var apiReasponse = await ApiRepo.apiPost(
        apiPath: "auth/login",
        data: data,
      );
      // ApiRepo returns a plain String (not a Map) for network/timeout errors,
      // so check the type before indexing, otherwise `"..."["status"]` throws.
      if (apiReasponse is Map && apiReasponse["status"] == "success") {
        write(StorageKeys.apiToken, apiReasponse['data']['token']);

        if (apiReasponse['data']['user'] != null) {
          Get.find<AppDataController>().setCurrentUserFromApi(
            apiReasponse['data']['user'],
          );
        }

        Get.find<AppController>().selectedPageIndex.value = 0;
        Get.offAll(() => const Dashboard());
        // Handle successful login, e.g., navigate to the home screen
      } else {
        // Handle login failure, e.g., show error message
        ToastService.showErrorToast(
          "Login failed. Please check your credentials.",
        );
      }
      // Handle successful login, e.g., navigate to the home screen
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLogoutLoading.value = true;
    try {
      var apiReasponse = await ApiRepo.apiPost(
        apiPath: "auth/logout",
        data: {},
      );
      if (apiReasponse is Map && apiReasponse["status"] == "success") {
        clearAllData();
        Get.offAll(() => const LoginPage());
        // Handle successful login, e.g., navigate to the home screen
      } else {
        // Handle login failure, e.g., show error message
        ToastService.showErrorToast(
          "Logout failed. Please check your credentials.",
        );
      }
      // Handle successful login, e.g., navigate to the home screen
    } finally {
      isLogoutLoading.value = false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    isForgotLoading.value = true;
    try {
      var data = {"email": email};
      var apiResponse = await ApiRepo.apiPost(
        apiPath: "auth/forgot-password",
        data: data,
      );

      // ApiRepo returns a plain String (not a Map) for network/timeout errors,
      // so check the type before indexing.
      if (apiResponse is Map && apiResponse["status"] == "success") {
        ToastService.showSuccessToast(
          apiResponse["message"] ?? "Password reset link sent to your email.",
        );
        return true;
      } else {
        ToastService.showErrorToast(
          "Could not send reset link. Please check your email and try again.",
        );
        return false;
      }
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    isResetLoading.value = true;
    try {
      var data = {
        "email": email,
        "token": token,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };
      var apiResponse = await ApiRepo.apiPost(
        apiPath: "auth/reset-password",
        data: data,
      );

      // ApiRepo returns a plain String (not a Map) for network/timeout errors,
      // so check the type before indexing.
      if (apiResponse is Map && apiResponse["status"] == "success") {
        ToastService.showSuccessToast(
          apiResponse["message"] ??
              "Password reset successfully. Please sign in.",
        );
        Get.offAll(() => const LoginPage());
      } else {
        ToastService.showErrorToast(
          apiResponse is Map && apiResponse["message"] != null
              ? apiResponse["message"].toString()
              : "Reset failed. Please check the code and try again.",
        );
      }
    } finally {
      isResetLoading.value = false;
    }
  }
}
