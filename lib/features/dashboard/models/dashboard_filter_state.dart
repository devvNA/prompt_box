class DashboardFilterState {
  final String searchQuery;
  final String selectedCategory; // 'All', 'Image', 'Text', 'Design', 'Code'
  final String filterType; // 'all', 'image', 'text'
  final String filterVisibility; // 'all', 'public', 'private'
  final String sortBy; // 'newest', 'likes', 'oldest', 'alpha'
  final String? selectedTag;

  const DashboardFilterState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.filterType = 'all',
    this.filterVisibility = 'all',
    this.sortBy = 'newest',
    this.selectedTag,
  });

  DashboardFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    String? filterType,
    String? filterVisibility,
    String? sortBy,
    String? selectedTag,
    bool clearTag = false,
  }) {
    return DashboardFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filterType: filterType ?? this.filterType,
      filterVisibility: filterVisibility ?? this.filterVisibility,
      sortBy: sortBy ?? this.sortBy,
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
    );
  }

  bool get hasActiveFilters =>
      filterType != 'all' ||
      filterVisibility != 'all' ||
      sortBy != 'newest' ||
      selectedTag != null;

  int get activeFilterCount {
    int count = 0;
    if (filterType != 'all') count++;
    if (filterVisibility != 'all') count++;
    if (sortBy != 'newest') count++;
    if (selectedTag != null) count++;
    return count;
  }
}
