import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class AddressSearchBottomSheet extends ConsumerStatefulWidget {
  final void Function(GeocodeResult) onSelected;

  const AddressSearchBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  ConsumerState<AddressSearchBottomSheet> createState() =>
      _AddressSearchBottomSheetState();
}

class _AddressSearchBottomSheetState
    extends ConsumerState<AddressSearchBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressSearchNotifierProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '도로명 + 건물번호 (예: 테헤란로 123)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(addressSearchNotifierProvider.notifier)
                                .clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  ref.read(addressSearchNotifierProvider.notifier).search(value);
                },
                onSubmitted: (value) {
                  ref
                      .read(addressSearchNotifierProvider.notifier)
                      .searchImmediate(value);
                },
              ),
            ),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AddressSearchState state) {
    switch (state.status) {
      case AddressSearchStatus.initial:
        return const Center(
          child: Text(
            '주소를 입력해주세요',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );
      case AddressSearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AddressSearchStatus.error:
        return Center(
          child: Text(
            state.errorMessage ?? '오류가 발생했습니다',
            style: const TextStyle(color: AppColors.error),
          ),
        );
      case AddressSearchStatus.success:
        if (state.results.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '검색 결과가 없습니다',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  '도로명+건물번호 또는 동+번지로 검색해주세요\n(예: 테헤란로 123, 역삼동 456-7)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.disabled,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.results.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final result = state.results[index];
            return ListTile(
              title: Text(
                result.displayAddress,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: result.jibunAddress.isNotEmpty &&
                      result.jibunAddress != result.displayAddress
                  ? Text(
                      result.jibunAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
              leading: const Icon(Icons.location_on_outlined),
              onTap: () {
                widget.onSelected(result);
                Navigator.pop(context);
              },
            );
          },
        );
    }
  }
}
