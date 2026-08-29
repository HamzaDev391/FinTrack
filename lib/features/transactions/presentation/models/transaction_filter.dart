enum TransactionSort { newest, oldest, highestAmount, lowestAmount }

class TransactionFilter {
  const TransactionFilter({
    this.searchQuery = '',
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.sort = TransactionSort.newest,
  });

  final String searchQuery;
  final String? type;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionSort sort;

  TransactionFilter copyWith({
    String? searchQuery,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionSort? sort,
    bool clearType = false,
    bool clearCategory = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : type ?? this.type,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      sort: sort ?? this.sort,
    );
  }

  bool get hasFilters {
    return searchQuery.isNotEmpty ||
        type != null ||
        categoryId != null ||
        startDate != null ||
        endDate != null ||
        sort != TransactionSort.newest;
  }
}
