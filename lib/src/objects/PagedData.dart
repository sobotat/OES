
class PagedData<T> {

  PagedData({
    required this.page,
    required this.pageSize,
    required this.havePrev,
    required this.haveNext
  });

  int page;
  int pageSize;
  bool havePrev;
  bool haveNext;
  List<T> data = [];

  factory PagedData.fromJson(Map<String, dynamic> json) {
    return PagedData(
      page: json['page'],
      pageSize: json['pageSize'],
      havePrev: json['hasPreviousPage'],
      haveNext: json['hasNextPage'],
    );
  }
}