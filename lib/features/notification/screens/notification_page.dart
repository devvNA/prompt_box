import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> _filters = ['All', 'Unread', 'Likes', 'System'];
  String _selectedFilter = 'All';

  final List<NotificationModel> _notifications = [
    const NotificationModel(
      id: 'notif-1',
      title: 'Prompt Liked',
      description: 'raka.dev and 14 others liked "Astronaut in Space".',
      time: '12m ago',
      icon: Icons.favorite,
      iconColor: AppColors.danger,
      isRead: false,
    ),
    const NotificationModel(
      id: 'notif-2',
      title: 'Trending Prompt',
      description: 'Your prompt "Cinematic Coffee Photography" was added to Community Highlights!',
      time: '2h ago',
      icon: Icons.local_fire_department,
      iconColor: AppColors.primary,
      isRead: false,
    ),
    const NotificationModel(
      id: 'notif-3',
      title: 'Prompt Saved',
      description:
          'natsuki saved your prompt "Anime Character" to their collection.',
      time: '1d ago',
      icon: Icons.bookmark,
      iconColor: AppColors.purple,
      isRead: true,
    ),
    const NotificationModel(
      id: 'notif-4',
      title: 'System Update',
      description:
          'PromptBox v1.0.0 is live with Neo-Brutalist theme and gallery view.',
      time: '3d ago',
      icon: Icons.rocket_launch,
      iconColor: Color(0xFF60A5FA),
      isRead: true,
    ),
  ];

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'Likes') {
      return _notifications.where((n) => n.icon == Icons.favorite).toList();
    } else if (_selectedFilter == 'System') {
      return _notifications
          .where((n) => n.icon == Icons.rocket_launch)
          .toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay updated with activity on your prompts.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.yellow
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.ink,
                                width: isSelected ? 2 : 1.5,
                              ),
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
                            child: Text(
                              filter,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Notification list
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications in this filter',
                            style: AppTypography.caption,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: item.isRead
                                    ? Colors.white
                                    : const Color(0xFFFFFDF0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ink,
                                    offset: item.isRead
                                        ? const Offset(2, 2)
                                        : const Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: item.iconColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.ink,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 20,
                                      color: item.iconColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.title,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.ink,
                                                  ),
                                            ),
                                            Text(
                                              item.time,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    color: AppColors.muted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: const Color(0xFF4B5563),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
