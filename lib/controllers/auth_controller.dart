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

  Future<void> login({required String email, required String password}) async {
    isLoginLoading.value = true;
    try {
      var data = {"email": email, "password": password};
      var apiReasponse = await ApiRepo.apiPost(
        apiPath: "auth/login",
        data: data,
      );
      if (apiReasponse != null && apiReasponse["status"] == "success") {
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
      if (apiReasponse != null && apiReasponse["status"] == "success") {
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
}
