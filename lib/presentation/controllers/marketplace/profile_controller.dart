import 'package:get/get.dart';

class ProfileController extends GetxController {
  final userProfile = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    isLoading.value = true;
    try {
      // Load user profile logic
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile(Map<String, dynamic> data) {
    userProfile.assignAll(data);
  }

  void refreshProfile() {
    loadUserProfile();
  }
}
