import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prompt/models/prompt_model.dart';
import '../models/dashboard_filter_state.dart';

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilterState>(() {
      return DashboardFilterNotifier();
    });

class DashboardFilterNotifier extends Notifier<DashboardFilterState> {
  @override
  DashboardFilterState build() {
    return const DashboardFilterState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateFilters({
    String? type,
    String? visibility,
    String? sortBy,
    String? tag,
    bool clearTag = false,
  }) {
    state = state.copyWith(
      filterType: type,
      filterVisibility: visibility,
      sortBy: sortBy,
      selectedTag: tag,
      clearTag: clearTag,
    );
  }

  void resetAll() {
    state = const DashboardFilterState();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void removeSort() {
    state = state.copyWith(sortBy: 'newest');
  }

  void removeTypeFilter() {
    state = state.copyWith(filterType: 'all');
  }

  void removeVisibilityFilter() {
    state = state.copyWith(filterVisibility: 'all');
  }

  void removeTagFilter() {
    state = state.copyWith(clearTag: true);
  }

  List<PromptModel> applyFilters(List<PromptModel> prompts) {
    var filtered = prompts.where((p) {
      // 1. Category filter
      if (state.selectedCategory != 'All') {
        final cat = state.selectedCategory.toLowerCase();
        final pCat = p.category.toLowerCase();
        if (cat == 'image' && !pCat.contains('image')) return false;
        if (cat == 'text' && !pCat.contains('text')) return false;
        if (cat == 'design' &&
            !pCat.contains('design') &&
            !pCat.contains('ui/ux')) {
          return false;
        }
        if (cat == 'code' &&
            !pCat.contains('code') &&
            !pCat.contains('assistant')) {
          return false;
        }
        if (cat != 'image' &&
            cat != 'text' &&
            cat != 'design' &&
            cat != 'code') {
          if (pCat != cat) return false;
        }
      }

      // 2. Search query filter
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchContent = p.content.toLowerCase().contains(query);
        final matchTags = p.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchTitle && !matchContent && !matchTags) return false;
      }

      // 3. Prompt Type filter
      if (state.filterType == 'image' && !p.hasImage) return false;
      if (state.filterType == 'text' && p.hasImage) return false;

      // 4. Visibility filter
      if (state.filterVisibility == 'public' && !p.isPublic) return false;
      if (state.filterVisibility == 'private' && p.isPublic) return false;

      // 5. Tag filter
      if (state.selectedTag != null) {
        final cleanSelected = state.selectedTag!.toLowerCase().replaceAll(
          '#',
          '',
        );
        final hasTag = p.tags.any(
          (t) => t.toLowerCase().replaceAll('#', '') == cleanSelected,
        );
        if (!hasTag) return false;
      }

      return true;
    }).toList();

    // 6. Sorting
    switch (state.sortBy) {
      case 'likes':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'oldest':
        filtered.sort(
          (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
            b.createdAt ?? DateTime(2000),
          ),
        );
        break;
      case 'alpha':
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'newest':
      default:
        filtered.sort(
          (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
            a.createdAt ?? DateTime(2000),
          ),
        );
        break;
    }

    return filtered;
  }
}
