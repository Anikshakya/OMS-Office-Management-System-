import 'package:get/get.dart';
import 'package:oms/app_config/app_routes.dart';
import 'package:oms/models/toast_notification.dart';

class AppController extends GetxController {
  final RxInt selectedPageIndex = 0.obs;

  final RxList<ToastNotification> toasts = <ToastNotification>[].obs;

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
    final toast = ToastNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
    );
    toasts.add(toast);

    Future.delayed(const Duration(seconds: 4), () {
      toasts.removeWhere((t) => t.id == toast.id);
    });
  }

  void dismissToast(String id) {
    toasts.removeWhere((t) => t.id == id);
  }
}
