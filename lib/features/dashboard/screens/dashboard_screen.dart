import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../explore/screens/explore_screen.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/providers/prompt_provider.dart';
import '../../prompt/screens/create_prompt_screen.dart';
import '../providers/dashboard_filter_provider.dart';
import '../widgets/filter_modal.dart';
import '../widgets/prompt_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const DashboardScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = ['All', 'Image', 'Text', 'Design', 'Code'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetAllFilters() {
    _searchController.clear();
    ref.read(dashboardFilterProvider.notifier).resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final promptsAsync = ref.watch(promptListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildCategories(),
                    _buildActiveFilterChips(),
                    Expanded(child: _buildGrid(promptsAsync)),
                  ],
                ),

            // Floating Action Button
            Positioned(
              bottom: widget.showBottomNav ? 80 : 20,
              right: AppSpacing.pagePadding,
              child: _buildFloatingButton(),
            ),

            // Bottom Navigation
            if (widget.showBottomNav)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        24,
        AppSpacing.pagePadding,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROMPTBOX',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your prompt library, organized.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
              image: const DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://hfjdvymiaipelonyyrsd.supabase.co/storage/v1/object/public/avatar/8e40f83a0f6b6f2e66803af56507b05d.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final filterState = ref.watch(dashboardFilterProvider);
    final hasActive = filterState.hasActiveFilters;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.ink, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(dashboardFilterProvider.notifier).updateSearchQuery(val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search prompts...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (filterState.searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(dashboardFilterProvider.notifier).clearSearch();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.ink,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterModal(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasActive ? AppColors.yellow : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.ink, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, color: AppColors.ink, size: 22),
                ),
                if (hasActive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '${filterState.activeFilterCount}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final selectedCategory = ref.watch(dashboardFilterProvider).selectedCategory;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: 8,
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ref.read(dashboardFilterProvider.notifier).updateCategory(cat);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ink, width: 2),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                  ],
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    final filterState = ref.watch(dashboardFilterProvider);
    if (!filterState.hasActiveFilters) return const SizedBox.shrink();

    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: [
          if (filterState.sortBy != 'newest')
            _buildActiveChip(
              label: 'Sort: ${filterState.sortBy == 'likes' ? 'Popular' : filterState.sortBy == 'oldest' ? 'Oldest' : 'A-Z'}',
              onRemove: () => ref.read(dashboardFilterProvider.notifier).removeSort(),
            ),
          if (filterState.filterType != 'all')
            _buildActiveChip(
              label: filterState.filterType == 'image' ? 'With Image' : 'Text Only',
              onRemove: () => ref.read(dashboardFilterProvider.notifier).removeTypeFilter(),
            ),
          if (filterState.filterVisibility != 'all')
            _buildActiveChip(
              label: filterState.filterVisibility == 'public' ? 'Public' : 'Private',
              onRemove: () => ref.read(dashboardFilterProvider.notifier).removeVisibilityFilter(),
            ),
          if (filterState.selectedTag != null)
            _buildActiveChip(
              label: '#${filterState.selectedTag}',
              onRemove: () => ref.read(dashboardFilterProvider.notifier).removeTagFilter(),
            ),
          GestureDetector(
            onTap: () {
              ref.read(dashboardFilterProvider.notifier).resetAll();
              _searchController.clear();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                'Clear all',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    final allPrompts = ref.read(promptListNotifierProvider).asData?.value ?? [];
    final availableTags = allPrompts
        .expand((p) => p.tags)
        .map((t) => t.trim().replaceAll('#', ''))
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    availableTags.sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return FilterModal(
          availableTags: availableTags,
          initialState: ref.read(dashboardFilterProvider),
          onApply: ({
            required filterType,
            required filterVisibility,
            required selectedTag,
            required sortBy,
          }) {
            ref.read(dashboardFilterProvider.notifier).updateFilters(
                  type: filterType,
                  visibility: filterVisibility,
                  sortBy: sortBy,
                  tag: selectedTag,
                );
          },
        );
      },
    );
  }

  Widget _buildGrid(AsyncValue<List<PromptModel>> promptsAsync) {
    return promptsAsync.when(
      data: (prompts) {
        final filtered = ref.read(dashboardFilterProvider.notifier).applyFilters(prompts);

        if (filtered.isEmpty) {
          final filterState = ref.read(dashboardFilterProvider);
          if (filterState.searchQuery.isNotEmpty || 
              filterState.selectedCategory != 'All' || 
              filterState.hasActiveFilters) {
            return Center(
              child: EmptyState(
                title: 'No Matching Prompts',
                description: 'No prompts match your active search or filter criteria.',
                buttonText: 'Reset Filters',
                onButtonPressed: _resetAllFilters,
              ),
            );
          }

          return Center(
            child: EmptyState(
              title: 'No Prompts Yet',
              description: 'Start building your prompt library by creating your first prompt.',
              buttonText: 'Create Prompt',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreatePromptScreen()),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(promptListNotifierProvider.notifier).refresh(),
          color: AppColors.ink,
          backgroundColor: AppColors.yellow,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = AppSpacing.gridCrossAxisCount(constraints.maxWidth);
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  8,
                  AppSpacing.pagePadding,
                  100,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return PromptCard(
                    prompt: filtered[index],
                    onUpdate: () => ref.read(promptListNotifierProvider.notifier).refresh(),
                    onDelete: () => ref.read(promptListNotifierProvider.notifier).refresh(),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.ink)),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              'Error loading prompts',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            BrutalButton(
              text: 'Retry',
              onPressed: () =>
                  ref.read(promptListNotifierProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<PromptModel>(
          MaterialPageRoute(builder: (_) => const CreatePromptScreen()),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.ink, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', true),
          _buildNavItem(
            Icons.search,
            'Explore',
            false,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ExploreScreen()));
            },
          ),
          _buildNavItem(Icons.grid_view, 'Categories', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.ink : AppColors.muted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.ink : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
