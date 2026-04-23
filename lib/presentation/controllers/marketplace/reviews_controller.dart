import 'package:get/get.dart';

class ReviewsController extends GetxController {
  final reviews = <dynamic>[].obs;
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  void loadReviews() {
    // Load reviews logic
  }

  void calculateAverageRating() {
    // Calculate average rating from reviews
  }

  void refreshReviews() {
    loadReviews();
  }
}
