import 'dart:developer';

import 'package:get_storage/get_storage.dart';

final box = GetStorage();

//Always retuns String "" if value is null
dynamic read(String storageName) {
  dynamic result = box.read(storageName) ?? "";
  return result;
}

void write(String storageName, dynamic value) {
  box.write(storageName, value ?? "");
}

void remove(String storageName) {
  box.remove(storageName);
}

void clearAllData() {
  var currentLang = read(StorageKeys.lang);
  log('\x1B[31mAlert => Clearing all cached data\x1B[0m');

  var currentUrl = read(StorageKeys.serverModeKey);

  // Clear Box
  box.erase();

  // Store Previous Server
  write(StorageKeys.serverModeKey, currentUrl);

  // Write the preserved value back
  write(StorageKeys.lang, currentLang);
}

class StorageKeys {
  static const String apiToken = 'apiToken';
  static const String isDevMode = 'isDevMode';
  static const String serverModeKey = 'serverModeKey';
  static const String lang = 'lang';
  static const String userBarcode = 'userBarcode';
  static const String userEmail = 'userEmail';
  static const String userId = 'userId';
}
