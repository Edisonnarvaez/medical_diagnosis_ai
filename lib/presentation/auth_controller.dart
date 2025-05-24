import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';

import 'package:medical_diagnosis_ai/core/config/app_config.dart';
import 'package:appwrite/models.dart';

class AuthController extends GetxController {
  final Account account = Account(AppwriteConfig.getClient());
  final Rx<User?> user = Rx<User?>(null);

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<bool> checkAuth() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      //Get.snackbar('Error', e.toString());
      return false;
    }
  }

  Future<void> createAccount(String email, String password) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      await login(email, password);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final userData = await account.get();
      user.value = userData;
      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      user.value = null;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
