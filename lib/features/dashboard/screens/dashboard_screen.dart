import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../explore/screens/explore_screen.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/screens/create_prompt_screen.dart';
import '../../prompt/screens/prompt_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const DashboardScreen({super.key, this.showBottomNav = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> categories = ['All', 'Image', 'Text', 'Design', 'Code'];
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'title': 'Cute Cat Portrait',
      'type': 'IMAGE',
      'category': 'Image Generation',
      'content': 'A cinematic cute fluffy cat portrait, soft golden hour lighting, 8k resolution, detailed fur, shallow depth of field, warm cozy aesthetic.',
      'imageUrl': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'tags': ['#photo', '#animal'],
      'isPublic': true,
      'author': 'Devit Nur Azaqi',
      'likes': 12,
    },
    {
      'id': '2',
      'title': 'Minimalist Architecture',
      'type': 'IMAGE',
      'category': 'UI/UX Design',
      'content': 'Clean minimalist architectural facade with brutalist concrete geometry, stark contrast shadows, neutral palette, and modern aesthetic.',
      'imageUrl': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'tags': ['#design', '#minimal'],
      'isPublic': true,
      'author': 'Devit Nur Azaqi',
      'likes': 24,
    },
    {
      'id': '3',
      'title': 'Flutter Clean Architecture',
      'type': 'TXT',
      'category': 'Code Assistant',
      'content': 'Write a clean architecture layered pattern for a Flutter application using Riverpod StateNotifier, repository pattern, and immutable models with serialization.',
      'imageUrl': null, // No image for TXT
      'tags': ['#flutter', '#code'],
      'isPublic': false,
      'author': 'Devit Nur Azaqi',
      'likes': 8,
    },
    {
      'id': '4',
      'title': 'Cinematic Mountain',
      'type': 'IMAGE',
      'category': 'Image Generation',
      'content': 'Epic cinematic landscape of misty mountain peaks at sunrise, dramatic volumetric god-rays, 35mm film grain, hyper-realistic details.',
      'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
      'tags': ['#landscape', '#cinematic'],
      'isPublic': true,
      'author': 'Devit Nur Azaqi',
      'likes': 31,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategories(),
                Expanded(child: _buildGrid()),
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
                  'https://i.pravatar.cc/100?img=11',
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
                  const Icon(Icons.search, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search prompts...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
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
            child: const Icon(Icons.tune, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
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
                setState(() {
                  selectedCategory = cat;
                });
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

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        8,
        AppSpacing.pagePadding,
        100,
      ), // Bottom padding for FAB and Nav
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildCard(item);
      },
    );
  }

  void _openDetail(Map<String, dynamic> item) async {
    final prompt = PromptModel(
      id: (item['id'] ?? item['title']).toString(),
      title: item['title'] as String,
      content:
          (item['content'] ??
                  'A cinematic prompt for ${item['title']} with professional composition, high detail, and creative styling.')
              as String,
      category:
          (item['category'] ??
                  (item['type'] == 'IMAGE'
                      ? 'Image Generation'
                      : 'Text Generation'))
              as String,
      tags: (item['tags'] as List<dynamic>)
          .map((e) => e.toString().replaceAll('#', ''))
          .toList(),
      resultImageUrl: item['imageUrl'] as String?,
      isPublic: (item['isPublic'] ?? true) as bool,
      authorName: (item['author'] ?? 'Devit Nur Azaqi') as String,
      likes: (item['likes'] ?? 0) as int,
    );

    final result = await Navigator.of(context).push<PromptDetailResult>(
      MaterialPageRoute(builder: (_) => PromptDetailScreen(prompt: prompt)),
    );

    if (result != null && mounted) {
      if (result.action == 'delete') {
        setState(() {
          _items.removeWhere(
            (i) => (i['id'] ?? i['title']).toString() == result.deletedId,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt deleted successfully'),
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.action == 'update' && result.prompt != null) {
        final updated = result.prompt!;
        setState(() {
          final index = _items.indexWhere(
            (i) => (i['id'] ?? i['title']).toString() == updated.id,
          );
          if (index != -1) {
            _items[index] = {
              'id': updated.id,
              'title': updated.title,
              'content': updated.content,
              'category': updated.category,
              'type': updated.hasImage ? 'IMAGE' : 'TXT',
              'imageUrl': updated.resultImageUrl,
              'tags': updated.tags
                  .map((t) => t.startsWith('#') ? t : '#$t')
                  .toList(),
              'isPublic': updated.isPublic,
              'author': updated.authorName ?? 'Devit Nur Azaqi',
              'likes': updated.likes,
            };
          }
        });
      }
    }
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isImage = item['type'] == 'IMAGE';

    return GestureDetector(
      onTap: () => _openDetail(item),
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
            // Image / Abstract Graphic area
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
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item['imageUrl'] as String,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _buildAbstractShapes(),
                  ),
                  // Badge Overlapping
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
                            : const Color(0xFF60A5FA), // tag-blue
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Text(
                        item['type'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
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
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
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
                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (item['tags'] as List<String>).map((tag) {
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
                            tag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Footer (Likes & Options)
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: AppColors.ink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item['likes']}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.more_horiz,
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

  Widget _buildAbstractShapes() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 15,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.ink, offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 25,
          child: Transform.rotate(
            angle: 0.8,
            child: Container(
              width: 15,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 20,
          child: Transform.rotate(
            angle: 0.8,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () async {
        final newPrompt = await Navigator.of(context).push<PromptModel>(
          MaterialPageRoute(builder: (_) => const CreatePromptScreen()),
        );
        if (newPrompt != null) {
          setState(() {
            _items.insert(0, {
              'id': newPrompt.id,
              'title': newPrompt.title,
              'content': newPrompt.content,
              'category': newPrompt.category,
              'type': newPrompt.hasImage ? 'IMAGE' : 'TXT',
              'imageUrl': newPrompt.resultImageUrl,
              'tags': newPrompt.tags
                  .map((t) => t.startsWith('#') ? t : '#$t')
                  .toList(),
              'isPublic': newPrompt.isPublic,
              'author': newPrompt.authorName ?? 'Devit Nur Azaqi',
              'likes': 0,
            });
          });
        }
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
