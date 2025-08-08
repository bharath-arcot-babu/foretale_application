import 'package:flutter/material.dart';

class PaginationManager<T> extends ChangeNotifier {
  // Pagination properties
  final bool enablePagination;
  int pageSize;
  int currentPage = 0;
  List<T> allData = [];
  List<T> currentPageData = [];

  // Callback for when data changes
  final VoidCallback? onDataChanged;

  PaginationManager({
    required this.enablePagination,
    required this.pageSize,
    required List<T> initialData,
    this.onDataChanged,
  }) {
    _initializeData(initialData);
  }

  void _initializeData(List<T> data) {
    allData = List.from(data);
    if (enablePagination) {
      currentPageData = _getCurrentPageData();
    } else {
      currentPageData = allData;
    }
  }

  /// Get the current page data
  List<T> _getCurrentPageData() {
    if (!enablePagination) return allData;
    
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allData.length);
    return allData.sublist(startIndex, endIndex);
  }

  /// Get the current page data (public method)
  List<T> getCurrentPageData() {
    return _getCurrentPageData();
  }

  /// Get total number of pages
  int get totalPages => (allData.length / pageSize).ceil();

  /// Get current page number (1-based)
  int get currentPageNumber => currentPage + 1;

  /// Check if there's a next page
  bool get hasNextPage => currentPage < totalPages - 1;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 0;

  /// Get total number of items
  int get totalItems => allData.length;

  /// Get start index of current page (1-based for display)
  int get currentPageStartIndex => (currentPage * pageSize) + 1;

  /// Get end index of current page (1-based for display)
  int get currentPageEndIndex {
    final endIndex = (currentPage + 1) * pageSize;
    return endIndex > totalItems ? totalItems : endIndex;
  }

  /// Navigate to next page
  void nextPage() {
    if (hasNextPage) {
      currentPage++;
      _updateCurrentPageData();
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (hasPreviousPage) {
      currentPage--;
      _updateCurrentPageData();
    }
  }

  /// Navigate to specific page
  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage = page;
      _updateCurrentPageData();
    }
  }

  /// Go to first page
  void goToFirstPage() {
    if (currentPage != 0) {
      currentPage = 0;
      _updateCurrentPageData();
    }
  }

  /// Go to last page
  void goToLastPage() {
    final lastPage = totalPages - 1;
    if (currentPage != lastPage) {
      currentPage = lastPage;
      _updateCurrentPageData();
    }
  }

  /// Update all data and reset to first page
  void updateAllData(List<T> newData) {
    allData = List.from(newData);
    currentPage = 0; // Reset to first page
    _updateCurrentPageData();
  }

  /// Update page size and reset to first page
  void updatePageSize(int newPageSize) {
    pageSize = newPageSize;
    currentPage = 0; // Reset to first page
    _updateCurrentPageData();
  }

  /// Get current page data for display
  List<T> get data => currentPageData;

  /// Check if pagination is enabled
  bool get isEnabled => enablePagination;

  /// Update current page data and notify listeners
  void _updateCurrentPageData() {
    currentPageData = _getCurrentPageData();
    onDataChanged?.call();
    notifyListeners();
  }

  /// Get page info string for display
  String getPageInfoString() {
    if (!enablePagination) {
      return 'Showing all ${totalItems} items';
    }
    
    if (totalItems == 0) {
      return 'No items';
    }
    
    return 'Showing ${currentPageStartIndex}-${currentPageEndIndex} of $totalItems items';
  }

  /// Get page navigation info string
  String getPageNavigationString() {
    if (!enablePagination) {
      return '';
    }
    
    return 'Page $currentPageNumber of $totalPages';
  }

  /// Check if the manager has any data
  bool get hasData => allData.isNotEmpty;

  /// Get the number of items on the current page
  int get currentPageItemCount => currentPageData.length;

  /// Check if current page is empty
  bool get isCurrentPageEmpty => currentPageData.isEmpty;

  /// Get the maximum page number that can be navigated to
  int get maxPageNumber => totalPages;

  /// Check if the given page number is valid
  bool isValidPageNumber(int pageNumber) {
    return pageNumber >= 0 && pageNumber < totalPages;
  }

  /// Get the page number for a given item index
  int getPageNumberForItemIndex(int itemIndex) {
    if (!enablePagination || itemIndex < 0 || itemIndex >= totalItems) {
      return -1;
    }
    return (itemIndex / pageSize).floor();
  }

  /// Get the item index for a given page and position on that page
  int getItemIndexForPagePosition(int pageNumber, int positionOnPage) {
    if (!enablePagination || pageNumber < 0 || pageNumber >= totalPages) {
      return -1;
    }
    return (pageNumber * pageSize) + positionOnPage;
  }

  /// Dispose the pagination manager
  @override
  void dispose() {
    super.dispose();
  }
} 