import 'package:get/get.dart';
import 'package:oms/models/toast_notification.dart' show ToastType;
import 'package:oms/services/toast_service.dart';
import 'package:oms/screens/apply_leave_screen.dart';
import 'package:oms/screens/appraisal_screen.dart';

class AppController extends GetxController {
  final RxInt selectedPageIndex = 0.obs;

  void setPageIndex(int index) {
    if (index < 0 || index >= 7) return;

    if (index == 1) {
      Get.to(() => ApplyLeaveScreen());
      return;
    }

    if (index == 3) {
      Get.to(() => AppraisalScreen());
      return;
    }

    selectedPageIndex.value = index;
  }

  void showToast(String title, String message, ToastType type) {
    ToastService.showAppToast(title, message, type);
  }
}
