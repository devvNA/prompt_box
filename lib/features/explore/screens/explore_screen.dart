import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/screens/prompt_detail_screen.dart';

class ExploreItem {
  final PromptModel prompt;
  final String authorAvatar;

  const ExploreItem({
    required this.prompt,
    required this.authorAvatar,
  });
}

class ExploreScreen extends StatefulWidget {
  final bool showBottomNav;

  const ExploreScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Image', 'Text', 'Design', 'Code'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'likes'; // 'likes' or 'recent'

  late final List<ExploreItem> _allPrompts;

  @override
  void initState() {
    super.initState();
    _allPrompts = [
      ExploreItem(
        authorAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100',
        prompt: PromptModel(
          id: 'exp-1',
          title: 'Astronaut in Space',
          category: 'Image Generation',
          content:
              'A high-detail cinematic photography prompt for an astronaut floating gracefully in deep space, Earth glowing on the helmet visor, stars and cosmic nebula, 8k resolution, photorealistic.',
          tags: ['sci-fi', 'space'],
          resultImageUrl:
              'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?auto=format&fit=crop&q=80&w=400',
          isPublic: true,
          authorName: 'raka.dev',
          likes: 342,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
      ExploreItem(
        authorAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100',
        prompt: PromptModel(
          id: 'exp-2',
          title: 'Anime Character',
          category: 'Image Generation',
          content:
              'A stylized anime portrait illustration of a character with expressive eyes, wind in hair, watercolor aesthetic, vibrant pastel lighting, Studio Ghibli vibes, 4k digital art.',
          tags: ['anime', 'illustration'],
          resultImageUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400',
          isPublic: true,
          authorName: 'natsuki',
          likes: 215,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ),
      ExploreItem(
        authorAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
        prompt: PromptModel(
          id: 'exp-3',
          title: 'Cozy Room Interior',
          category: 'UI/UX Design',
          content:
              'Warm cozy isometric bedroom interior with wooden furniture, reading corner with books and indoor plants, soft golden sunlight through curtains, 3d render Octane, minimalist aesthetic.',
          tags: ['interior', '3d'],
          resultImageUrl:
              'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&q=80&w=400',
          isPublic: true,
          authorName: 'luna',
          likes: 188,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ),
      ExploreItem(
        authorAvatar:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=100',
        prompt: PromptModel(
          id: 'exp-4',
          title: 'Landing Page Copy',
          category: 'Text Generation',
          content:
              'Write compelling, high-converting hero section website copy for an AI SaaS startup. Include an attention-grabbing H1, value-driven subhead, and strong dual CTA buttons with social proof bullets.',
          tags: ['marketing', 'copy'],
          resultImageUrl: null,
          isPublic: true,
          authorName: 'andika',
          likes: 176,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ),
      ExploreItem(
        authorAvatar:
            'https://i.pravatar.cc/100?img=11',
        prompt: PromptModel(
          id: 'exp-5',
          title: 'Cinematic Coffee Photography',
          category: 'Image Generation',
          content:
              'A cinematic product photography prompt for a premium coffee cup, with dramatic lighting, shallow depth of field, and a warm tone. The scene includes coffee beans, wooden table, and soft sunlight.',
          tags: ['coffee', 'product', 'cinematic'],
          resultImageUrl:
              'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&q=80&w=400',
          isPublic: true,
          authorName: 'Devit Nur Azaqi',
          likes: 512,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ),
      ExploreItem(
        authorAvatar:
            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80&w=100',
        prompt: PromptModel(
          id: 'exp-6',
          title: 'Riverpod Clean Architecture',
          category: 'Code Assistant',
          content:
              'Generate a complete clean architecture pattern in Flutter using riverpod: AsyncNotifierProvider, functional state models, domain repository abstraction, and offline caching.',
          tags: ['flutter', 'code', 'architecture'],
          resultImageUrl: null,
          isPublic: true,
          authorName: 'alex_dev',
          likes: 264,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExploreItem> get _filteredPrompts {
    var list = _allPrompts.where((item) {
      final p = item.prompt;
      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Image' && p.category != 'Image Generation') {
          return false;
        }
        if (_selectedCategory == 'Text' && p.category != 'Text Generation') {
          return false;
        }
        if (_selectedCategory == 'Design' && p.category != 'UI/UX Design') {
          return false;
        }
        if (_selectedCategory == 'Code' && p.category != 'Code Assistant') {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesContent = p.content.toLowerCase().contains(query);
        final matchesTags = p.tags.any((t) => t.toLowerCase().contains(query));
        final matchesAuthor = (p.authorName ?? '').toLowerCase().contains(query);
        return matchesTitle || matchesContent || matchesTags || matchesAuthor;
      }

      return true;
    }).toList();

    // Sort
    if (_sortBy == 'likes') {
      list.sort((a, b) => b.prompt.likes.compareTo(a.prompt.likes));
    } else {
      list.sort((a, b) => (b.prompt.createdAt ?? DateTime(2000))
          .compareTo(a.prompt.createdAt ?? DateTime(2000)));
    }

    return list;
  }

  void _showFilterModal() {
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
                      'SORT & FILTER',
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
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
                  title: Text('Most Popular', style: AppTypography.bodyBold),
                  trailing: _sortBy == 'likes'
                      ? const Icon(Icons.check_circle, color: AppColors.ink)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _sortBy == 'likes' ? AppColors.ink : AppColors.borderMuted,
                      width: 1.5,
                    ),
                  ),
                  tileColor: _sortBy == 'likes' ? AppColors.yellow : null,
                  onTap: () {
                    setState(() => _sortBy = 'likes');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.ink),
                  title: Text('Newest First', style: AppTypography.bodyBold),
                  trailing: _sortBy == 'recent'
                      ? const Icon(Icons.check_circle, color: AppColors.ink)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _sortBy == 'recent' ? AppColors.ink : AppColors.borderMuted,
                      width: 1.5,
                    ),
                  ),
                  tileColor: _sortBy == 'recent' ? AppColors.yellow : null,
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

  void _openDetail(PromptModel prompt) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PromptDetailScreen(prompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPrompts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Header Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover amazing prompts from the community.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Search Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Search input
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.ink,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.ink,
                                        offset: Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: AppColors.ink,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (val) {
                                            setState(() {
                                              _searchQuery = val.trim();
                                            });
                                          },
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Search public prompts...',
                                            hintStyle: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF6B7280),
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
                                            size: 18,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Filter button
                              GestureDetector(
                                onTap: _showFilterModal,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.ink,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.ink,
                                        offset: Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: AppColors.ink,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Category Pills
                      SliverToBoxAdapter(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Row(
                            children: _categories.map((cat) {
                              final isActive = cat == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isActive ? 17 : 18,
                                      vertical: isActive ? 9 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.yellow
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.ink,
                                        width: isActive ? 2 : 1.5,
                                      ),
                                      boxShadow: isActive
                                          ? const [
                                              BoxShadow(
                                                color: AppColors.ink,
                                                offset: Offset(2, 2),
                                                blurRadius: 0,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      cat,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Grid
                      if (filtered.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No matching prompts found',
                                    style: AppTypography.cardTitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try adjusting your search or category filter.',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filtered[index];
                                return _buildCard(item);
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom Navigation
                if (widget.showBottomNav)
                  _buildBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ExploreItem item) {
    final p = item.prompt;
    final isImage = p.hasImage;

    return GestureDetector(
      onTap: () => _openDetail(p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Card Image Area with Overlapping Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 135,
                  decoration: BoxDecoration(
                    color: isImage ? AppColors.borderMuted : AppColors.yellow,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: p.resultImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.borderMuted,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.borderMuted,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 28, color: AppColors.muted),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.article_outlined,
                            size: 40,
                            color: AppColors.ink.withValues(alpha: 0.6),
                          ),
                        ),
                ),

                // Badge Overlapping
                Positioned(
                  bottom: -10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isImage
                          ? const Color(0xFF4ADE80) // badge-green
                          : const Color(0xFF38BDF8), // badge-blue
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.ink, width: 1.5),
                    ),
                    child: Text(
                      isImage ? 'IMAGE' : 'TXT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: p.tags.take(2).map((tag) {
                        final cleanTag = tag.startsWith('#') ? tag : '#$tag';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cleanTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    // Footer with likes & user info
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: Color(0xFFE5484D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${p.likes}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: item.authorAvatar,
                                width: 18,
                                height: 18,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const CircleAvatar(
                                  radius: 9,
                                  backgroundColor: AppColors.borderMuted,
                                  child: Icon(Icons.person, size: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                p.authorName ?? 'community',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
          _buildNavItem(
            Icons.home_outlined,
            'Home',
            false,
            onTap: () => Navigator.of(context).pop(),
          ),
          _buildNavItem(
            Icons.search,
            'Explore',
            true,
          ),
          _buildNavItem(
            Icons.grid_view,
            'Categories',
            false,
          ),
          _buildNavItem(
            Icons.person_outline,
            'Profile',
            false,
          ),
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
