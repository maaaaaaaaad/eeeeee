import 'package:flutter/material.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class CategoryChipList extends StatelessWidget {
  final List<CategorySummary> categories;

  const CategoryChipList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text(
        '설정된 카테고리 없음',
        style: TextStyle(fontSize: 14, color: AppColors.textHint),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categories
          .map((cat) => Chip(
                label: Text(
                  cat.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: AppColors.lightPink,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))
          .toList(),
    );
  }
}
