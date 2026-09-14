
class BaseListResponse<T> {
  List<T> data;
  String message;
  // Meta? meta;

  BaseListResponse({
    required this.data,
    required this.message,
  }); // required this.meta});

  factory BaseListResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    final List<dynamic>? dataList = json['data'];

    final List<T> data = (dataList != null)
        ? dataList.map((item) => fromJson(item)).toList()
        : [];
    return BaseListResponse<T>(
      data: data,
      message: json['message'] ?? '',
    );
  }
}
