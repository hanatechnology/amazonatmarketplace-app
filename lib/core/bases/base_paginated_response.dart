class BasePaginatedResponse<T> {
  List<T> data;
  int total;
  int page;
  int limit;
  int totalPages;
  bool hasPreviousPage;
  bool hasNextPage;

  BasePaginatedResponse(
      {required this.data,
      required this.total,
      required this.page,
      required this.limit,
      required this.totalPages,
      required this.hasPreviousPage,
      required this.hasNextPage});

  factory BasePaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    final List<dynamic>? dataList = json['data']['data'];
    final List<T> data = (dataList != null)
        ? dataList.map((item) => fromJson(item)).toList()
        : [];
    return BasePaginatedResponse(
      data: data,
      total: json['data']['total'],
      page: json['data']['page'],
      limit: json['data']['limit'],
      totalPages: json['data']['totalPages'],
      hasPreviousPage: json['data']['hasPreviousPage'],
      hasNextPage: json['data']['hasNextPage'],
    );
  }
}
