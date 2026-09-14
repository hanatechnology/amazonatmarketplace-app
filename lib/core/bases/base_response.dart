
class BaseResponse<T> {
  T data;
  String message;
  // Meta? meta;

  BaseResponse({
    required this.data,
    required this.message,
  }); // required this.meta});

  factory BaseResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return BaseResponse<T>(
      data: fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
