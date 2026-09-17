import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/screens/prompt_detail_screen.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;

  const ExploreScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Image Generation',
    'Text Generation',
    'UI/UX Design',
    'Code Assistant',
    'Marketing & Copy',
  ];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'likes'; // 'likes' or 'recent'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(PromptModel prompt) async {
    final result = await Navigator.of(context).push<PromptDetailResult>(
      MaterialPageRoute(builder: (_) => PromptDetailScreen(prompt: prompt)),
    );

    if (result != null && result.action == 'update' && result.prompt != null) {
      ref
          .read(explorePromptsNotifierProvider.notifier)
          .updatePrompt(result.prompt!);
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: AppColors.ink, width: 2),
              left: BorderSide(color: AppColors.ink, width: 2),
              right: BorderSide(color: AppColors.ink, width: 2),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SORT PROMPTS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.ink),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.favorite, color: AppColors.primary),
                  title: Text(
                    'Most Popular (Likes)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  trailing: _sortBy == 'likes'
                      ? const Icon(Icons.check_circle, color: AppColors.ink)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _sortBy == 'likes'
                          ? AppColors.ink
                          : AppColors.borderMuted,
                      width: 1.5,
                    ),
                  ),
                  onTap: () {
                    setState(() => _sortBy = 'likes');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.ink),
                  title: Text(
                    'Most Recent',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  trailing: _sortBy == 'recent'
                      ? const Icon(Icons.check_circle, color: AppColors.ink)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _sortBy == 'recent'
                          ? AppColors.ink
                          : AppColors.borderMuted,
                      width: 1.5,
                    ),
                  ),
                  onTap: () {
                    setState(() => _sortBy = 'recent');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicPromptsAsync = ref.watch(explorePromptsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Search & Sort bar
                _buildSearchAndSortBar(),

                // Horizontal Category filter chips
                _buildCategoryFilter(),

                const SizedBox(height: 8),

                // Prompt Grid
                Expanded(
                  child: publicPromptsAsync.when(
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
                              'Failed to load community prompts',
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
                                  .read(explorePromptsNotifierProvider.notifier)
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        16,
        AppSpacing.pagePadding,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMMUNITY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Explore prompts shared by creators',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),

          // Community pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8BF2FA),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.public, size: 14, color: AppColors.ink),
                const SizedBox(width: 4),
                Text(
                  'PUBLIC',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: 6,
      ),
      child: Row(
        children: [
          // Search Field
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
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim()),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search community prompts...',
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
          const SizedBox(width: 10),

          // Sort Button
          GestureDetector(
            onTap: _showSortModal,
            child: Container(
              width: 48,
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
              child: const Icon(
                Icons.swap_vert,
                color: AppColors.ink,
                size: 22,
              ),
            ),
          ),
        ],
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
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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
    // 1. Filter
    var list = allPrompts.where((p) {
      if (_selectedCategory != 'All') {
        if (p.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchContent = p.content.toLowerCase().contains(query);
        final matchAuthor = (p.authorName ?? '').toLowerCase().contains(query);
        final matchTags = p.tags.any((t) => t.toLowerCase().contains(query));
        return matchTitle || matchContent || matchAuthor || matchTags;
      }

      return true;
    }).toList();

    // 2. Sort
    if (_sortBy == 'likes') {
      list.sort((a, b) => b.likes.compareTo(a.likes));
    } else {
      list.sort((a, b) => (b.createdAt ?? DateTime(2000))
          .compareTo(a.createdAt ?? DateTime(2000)));
    }

    if (list.isEmpty) {
      if (_searchQuery.isNotEmpty || _selectedCategory != 'All') {
        return Center(
          child: EmptyState(
            title: 'No Matching Prompts',
            description:
                'No community prompts match "$_searchQuery" in $_selectedCategory.',
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

      return const Center(
        child: EmptyState(
          title: 'No Public Prompts',
          description:
              'No public prompts have been shared by the community yet.',
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.ink,
      backgroundColor: AppColors.yellow,
      onRefresh: () =>
          ref.read(explorePromptsNotifierProvider.notifier).refresh(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          8,
          AppSpacing.pagePadding,
          100, // Bottom padding for navigation
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildCommunityCard(list[index]);
        },
      ),
    );
  }

  Widget _buildCommunityCard(PromptModel item) {
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
            // Thumbnail Area
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

                  // Likes indicator top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref
                            .read(explorePromptsNotifierProvider.notifier)
                            .toggleLike(item.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isLiked
                              ? const Color(0xFFFFECEB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.danger,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.likes.toString(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
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

                    // Author info footer
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Author avatar
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.ink, width: 1),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  item.authorAvatar ??
                                      'https://hfjdvymiaipelonyyrsd.supabase.co/storage/v1/object/public/avatar/8e40f83a0f6b6f2e66803af56507b05d.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.authorName ?? 'Creator',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
