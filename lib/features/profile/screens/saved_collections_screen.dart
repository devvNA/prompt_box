import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/screens/prompt_detail_screen.dart';
import '../providers/profile_provider.dart';

class SavedCollectionsScreen extends ConsumerStatefulWidget {
  const SavedCollectionsScreen({super.key});

  @override
  ConsumerState<SavedCollectionsScreen> createState() =>
      _SavedCollectionsScreenState();
}

class _SavedCollectionsScreenState
    extends ConsumerState<SavedCollectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Image Generation',
    'Text Generation',
    'UI/UX Design',
    'Code Assistant',
    'Marketing & Copy',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(PromptModel prompt) async {
    final result = await Navigator.of(context).push<PromptDetailResult>(
      MaterialPageRoute(builder: (_) => PromptDetailScreen(prompt: prompt)),
    );

    if (result != null && mounted) {
      if (result.action == 'delete') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.ink,
            content: Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prompt deleted from collection',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (result.action == 'update' && result.prompt != null) {
        // Handled via optimistic updates in detail screen directly
      }
    }
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          bottom: 24,
        ),
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Prompt copied to clipboard!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promptListAsync = ref.watch(bookmarkedPromptsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              children: [
                // Top Header Bar
                _buildHeader(promptListAsync.value?.length ?? 0),

                // Search Bar
                _buildSearchBar(),

                // Category Chips Filter
                _buildCategoryFilter(),

                const SizedBox(height: 10),

                // Prompt Grid / Content
                Expanded(
                  child: promptListAsync.when(
                    data: (prompts) => _buildGrid(prompts),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.ink),
                    ),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.danger,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load saved prompts',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 16),
                            BrutalButton(
                              text: 'Retry',
                              onPressed: () => ref
                                  .read(bookmarkedPromptsNotifierProvider.notifier)
                                  .refresh(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        16,
        AppSpacing.pagePadding,
        12,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVED PROMPTS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Your personal saved collection',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Total Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              '$totalCount SAVED',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: 6,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.ink, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Search saved prompts...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Icon(Icons.close, color: AppColors.ink, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 4,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: AppColors.ink,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<PromptModel> allPrompts) {
    // Filter by search query & category
    final filtered = allPrompts.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      return matchesCategory && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      if (_searchQuery.isNotEmpty || _selectedCategory != 'All') {
        return Center(
          child: EmptyState(
            title: 'No Matching Prompts',
            description:
                'No prompts found for "$_searchQuery" in $_selectedCategory.\nTry a different search term or category.',
            buttonText: 'Reset Filters',
            onButtonPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
                _searchController.clear();
              });
            },
          ),
        );
      }

      return Center(
        child: EmptyState(
          title: 'No Saved Prompts',
          description: 'You have not saved any prompts yet.\nExplore or create new prompts to build your collection.',
          buttonText: 'Explore Prompts',
          onButtonPressed: () => Navigator.of(context).pop(),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.ink,
      backgroundColor: AppColors.yellow,
      onRefresh: () => ref.read(bookmarkedPromptsNotifierProvider.notifier).refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = AppSpacing.gridCrossAxisCount(constraints.maxWidth);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              8,
              AppSpacing.pagePadding,
              32,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildPromptCard(filtered[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPromptCard(PromptModel item) {
    final isImage = item.hasImage;

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Area (Image or Abstract Graphic)
            Expanded(
              flex: 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isImage ? AppColors.borderMuted : AppColors.yellow,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.resultImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _buildAbstractGraphic(item.category),
                  ),

                  // IMAGE / TXT Badge
                  Positioned(
                    bottom: -10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isImage
                            ? AppColors.green
                            : const Color(0xFF60A5FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.ink, width: 1.8),
                      ),
                      child: Text(
                        isImage ? 'IMAGE' : 'TXT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),

                  // Bookmark active indicator icon on top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.ink, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Info & Actions Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name
                    Text(
                      item.category.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Action Row: Quick Copy & Open
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quick Copy Button
                          GestureDetector(
                            onTap: () => _copyToClipboard(item.content),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF7EE),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.copy,
                                    size: 12,
                                    color: AppColors.ink,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Open Details Arrow
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.ink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbstractGraphic(String category) {
    Color shapeColor;
    IconData icon;

    switch (category) {
      case 'Image Generation':
        shapeColor = const Color(0xFFF3523B);
        icon = Icons.palette_outlined;
        break;
      case 'Text Generation':
        shapeColor = const Color(0xFFFDE047);
        icon = Icons.edit_note;
        break;
      case 'UI/UX Design':
        shapeColor = const Color(0xFFC084FC);
        icon = Icons.view_quilt_outlined;
        break;
      case 'Code Assistant':
        shapeColor = const Color(0xFF60A5FA);
        icon = Icons.code;
        break;
      case 'Marketing & Copy':
        shapeColor = const Color(0xFF4ADE80);
        icon = Icons.campaign_outlined;
        break;
      default:
        shapeColor = const Color(0xFFFFD84D);
        icon = Icons.auto_awesome;
    }

    return Container(
      decoration: BoxDecoration(
        color: shapeColor.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: shapeColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.ink, size: 24),
        ),
      ),
    );
  }
}
