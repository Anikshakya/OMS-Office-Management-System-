import 'package:get/get.dart';
import 'package:oms/app_config/app_routes.dart';
import 'package:oms/models/toast_notification.dart' show ToastType;
import 'package:oms/services/toast_service.dart';

class AppController extends GetxController {
  final RxInt selectedPageIndex = 0.obs;

  void setPageIndex(int index) {
    if (index < 0 || index >= AppRoutes.authenticatedPageCount) return;

    if (index == 1) {
      Get.toNamed(AppRoutes.applyLeave);
      return;
    }

    if (index == 3) {
      Get.toNamed(AppRoutes.appraisal);
      return;
    }

    selectedPageIndex.value = index;
  }

  void showToast(String title, String message, ToastType type) {
    ToastService.showAppToast(title, message, type);
  }
}
