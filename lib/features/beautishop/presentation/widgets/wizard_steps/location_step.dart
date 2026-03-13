import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_wizard_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/address_search_bottom_sheet.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/map_preview.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class LocationStep extends ConsumerStatefulWidget {
  const LocationStep({super.key});

  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  late final TextEditingController _detailAddressController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(shopRegistrationWizardProvider);
    _detailAddressController =
        TextEditingController(text: state.detailAddress);
  }

  @override
  void dispose() {
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopRegistrationWizardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '위치 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _openAddressSearch,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '주소',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.search),
              ),
              child: Text(
                state.selectedLocation?.displayAddress ?? '주소를 검색해주세요',
                style: TextStyle(
                  fontSize: 16,
                  color: state.selectedLocation != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _detailAddressController,
            decoration: const InputDecoration(
              labelText: '상세주소',
              hintText: '예: 2층 201호',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => ref
                .read(shopRegistrationWizardProvider.notifier)
                .updateDetailAddress(v),
          ),
          if (state.selectedLocation != null) ...[
            const SizedBox(height: 16),
            MapPreview(
              key: ValueKey(
                '${state.selectedLocation!.latitude},${state.selectedLocation!.longitude}',
              ),
              latitude: state.selectedLocation!.latitude,
              longitude: state.selectedLocation!.longitude,
            ),
          ],
        ],
      ),
    );
  }

  void _openAddressSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddressSearchBottomSheet(
        onSelected: _onAddressSelected,
      ),
    );
  }

  void _onAddressSelected(GeocodeResult result) {
    ref
        .read(shopRegistrationWizardProvider.notifier)
        .updateSelectedLocation(result);
  }
}
