import 'package:get/get.dart';
import 'package:oms/api_config/api_repo.dart';

class AuthController extends GetxController {
  final RxBool isLoginLoading = false.obs;

  Future<void> login(String username, String password) async {
    isLoginLoading.value = true;
    try {
      await ApiRepo.apiPost(apiPath: "", data: {
        'username': username,
        'password': password,
      });
      // Handle successful login, e.g., navigate to the home screen
    } finally {
      isLoginLoading.value = false;
    }
  }
}