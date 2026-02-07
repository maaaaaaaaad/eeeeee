import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/category_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class CategorySelectionPage extends ConsumerStatefulWidget {
  final String shopId;
  final List<String> currentCategoryIds;

  const CategorySelectionPage({
    super.key,
    required this.shopId,
    required this.currentCategoryIds,
  });

  @override
  ConsumerState<CategorySelectionPage> createState() =>
      _CategorySelectionPageState();
}

class _CategorySelectionPageState extends ConsumerState<CategorySelectionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(categoryNotifierProvider.notifier);
      notifier.loadCategories().then((_) {
        notifier.initSelectedCategories(widget.currentCategoryIds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryNotifierProvider);

    ref.listen<CategoryState>(categoryNotifierProvider, (prev, next) {
      if (next.status == CategoryStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리가 저장되었습니다')),
        );
        Navigator.pop(context, true);
      }
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '카테고리 설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(state),
      bottomNavigationBar: state.status == CategoryStatus.loaded ||
              state.status == CategoryStatus.saving
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed:
                      state.status == CategoryStatus.saving ? null : _onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state.status == CategoryStatus.saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(CategoryState state) {
    switch (state.status) {
      case CategoryStatus.initial:
      case CategoryStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case CategoryStatus.error:
        return Center(
          child: Text(
            state.errorMessage ?? '카테고리를 불러올 수 없습니다',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        );
      case CategoryStatus.loaded:
      case CategoryStatus.saving:
      case CategoryStatus.saved:
        return _buildCategoryList(state);
    }
  }

  Widget _buildCategoryList(CategoryState state) {
    if (state.allCategories.isEmpty) {
      return const Center(
        child: Text(
          '등록된 카테고리가 없습니다',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: state.allCategories.map((category) {
          final isSelected = state.selectedCategoryIds.contains(category.id);
          return FilterChip(
            label: Text(category.name),
            selected: isSelected,
            onSelected: (_) {
              ref
                  .read(categoryNotifierProvider.notifier)
                  .toggleCategory(category.id);
            },
            selectedColor: AppColors.lightPink,
            checkmarkColor: AppColors.darkPink,
          );
        }).toList(),
      ),
    );
  }

  void _onSave() {
    ref
        .read(categoryNotifierProvider.notifier)
        .saveCategories(widget.shopId);
  }
}
