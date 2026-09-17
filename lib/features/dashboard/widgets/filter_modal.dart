import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brutal_button.dart';
import '../models/dashboard_filter_state.dart';

class FilterModal extends StatefulWidget {
  final List<String> availableTags;
  final DashboardFilterState initialState;
  final void Function({
    required String filterType,
    required String filterVisibility,
    required String sortBy,
    required String? selectedTag,
  }) onApply;

  const FilterModal({
    super.key,
    required this.availableTags,
    required this.initialState,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _tempType;
  late String _tempVisibility;
  late String _tempSort;
  String? _tempTag;

  @override
  void initState() {
    super.initState();
    _tempType = widget.initialState.filterType;
    _tempVisibility = widget.initialState.filterVisibility;
    _tempSort = widget.initialState.sortBy;
    _tempTag = widget.initialState.selectedTag;
  }

  void _reset() {
    setState(() {
      _tempType = 'all';
      _tempVisibility = 'all';
      _tempSort = 'newest';
      _tempTag = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.ink, width: 2),
          left: BorderSide(color: AppColors.ink, width: 2),
          right: BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: AppColors.ink, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'FILTER & SORT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSectionTitle('SORT BY'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChoiceChip(
                            label: 'Newest',
                            icon: Icons.schedule,
                            isSelected: _tempSort == 'newest',
                            onTap: () => setState(() => _tempSort = 'newest'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Most Popular',
                            icon: Icons.favorite,
                            isSelected: _tempSort == 'likes',
                            onTap: () => setState(() => _tempSort = 'likes'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Oldest',
                            icon: Icons.history,
                            isSelected: _tempSort == 'oldest',
                            onTap: () => setState(() => _tempSort = 'oldest'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Title (A-Z)',
                            icon: Icons.sort_by_alpha,
                            isSelected: _tempSort == 'alpha',
                            onTap: () => setState(() => _tempSort = 'alpha'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSectionTitle('PROMPT TYPE'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChoiceChip(
                            label: 'All Types',
                            isSelected: _tempType == 'all',
                            onTap: () => setState(() => _tempType = 'all'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'With Image',
                            icon: Icons.image,
                            isSelected: _tempType == 'image',
                            onTap: () => setState(() => _tempType = 'image'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Text Only',
                            icon: Icons.text_snippet,
                            isSelected: _tempType == 'text',
                            onTap: () => setState(() => _tempType = 'text'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSectionTitle('VISIBILITY'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChoiceChip(
                            label: 'All',
                            isSelected: _tempVisibility == 'all',
                            onTap: () => setState(() => _tempVisibility = 'all'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Public Only',
                            icon: Icons.public,
                            isSelected: _tempVisibility == 'public',
                            onTap: () => setState(() => _tempVisibility = 'public'),
                          ),
                          _buildFilterChoiceChip(
                            label: 'Private Only',
                            icon: Icons.lock_outline,
                            isSelected: _tempVisibility == 'private',
                            onTap: () => setState(() => _tempVisibility = 'private'),
                          ),
                        ],
                      ),
                      if (widget.availableTags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildFilterSectionTitle('FILTER BY TAG'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.availableTags.map((tag) {
                            final isSelected =
                                _tempTag?.toLowerCase() == tag.toLowerCase();
                            return _buildFilterChoiceChip(
                              label: '#$tag',
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _tempTag = isSelected ? null : tag;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _reset,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.ink, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'RESET',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BrutalButton(
                      text: 'APPLY FILTERS',
                      onPressed: () {
                        widget.onApply(
                          filterType: _tempType,
                          filterVisibility: _tempVisibility,
                          sortBy: _tempSort,
                          selectedTag: _tempTag,
                        );
                        Navigator.pop(context);
                      },
                      variant: BrutalButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.ink, width: 1.8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.ink),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.muted,
        letterSpacing: 0.8,
      ),
    );
  }
}
