import 'package:get/get.dart';
import 'package:oms/models/employee.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final Rx<Employee?> currentUser = Rx<Employee?>(null);
  final box = GetStorage();

  void setCurrentUser(Employee employee) {
    var data = box.read('userData');
    if (data != null && data is Map) {
      employee = employee.copyWith(
        id: data['id']?.toString(),
        name: data['name']?.toString(),
        email: data['email']?.toString(),
        designation: data['role']?.toString().toUpperCase() ?? employee.designation,
        avatarUrl: data['profile_image']?.toString() ?? employee.avatarUrl,
        status: (data['active'] == 1) ? 'Active' : 'Inactive',
      );
    }
    currentUser.value = employee;
  }

  void setCurrentUserFromApi(Map<String, dynamic> userData) {
    box.write('userData', userData);
    if (currentUser.value != null) {
      setCurrentUser(currentUser.value!);
    }
  }
}
