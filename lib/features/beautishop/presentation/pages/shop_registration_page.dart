import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/address_search_bottom_sheet.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/map_preview.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_url_list.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

class ShopRegistrationPage extends ConsumerStatefulWidget {
  const ShopRegistrationPage({super.key});

  @override
  ConsumerState<ShopRegistrationPage> createState() =>
      _ShopRegistrationPageState();
}

class _ShopRegistrationPageState extends ConsumerState<ShopRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNumController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  Map<String, String> _operatingTime = {};
  List<String> _imageUrls = [];
  GeocodeResult? _selectedLocation;

  @override
  void dispose() {
    _nameController.dispose();
    _regNumController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopRegistrationNotifierProvider);

    ref.listen<ShopRegistrationState>(shopRegistrationNotifierProvider,
        (prev, next) {
      if (next.status == ShopRegistrationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('샵이 등록되었습니다')),
        );
        Navigator.pop(context, true);
      } else if (next.status == ShopRegistrationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? '등록에 실패했습니다')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '샵 등록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              _buildSectionTitle('기본 정보'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: '샵 이름',
                validator: (v) => ShopNameValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _regNumController,
                label: '사업자등록번호',
                keyboardType: TextInputType.number,
                validator: (v) => BusinessNumberValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: '전화번호',
                keyboardType: TextInputType.phone,
                validator: (v) => PhoneNumberValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('위치 정보'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                label: '주소',
                readOnly: true,
                onTap: _openAddressSearch,
                validator: (v) => AddressValidator.validate(v ?? ''),
                suffixIcon: const Icon(Icons.search),
              ),
              if (_selectedLocation != null) ...[
                const SizedBox(height: 12),
                _buildMapPreview(),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('영업 시간'),
              const SizedBox(height: 12),
              OperatingTimeForm(
                onChanged: (value) => _operatingTime = value,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('추가 정보'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: '샵 설명',
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              const Text(
                '이미지 URL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ShopImageUrlList(
                onChanged: (urls) => _imageUrls = urls,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.status == ShopRegistrationStatus.loading
                      ? null
                      : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state.status == ShopRegistrationStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '등록하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            ),
          ),
        ),
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
    setState(() {
      _selectedLocation = result;
      _addressController.text = result.displayAddress;
    });
  }

  Widget _buildMapPreview() {
    return MapPreview(
      key: ValueKey(
        '${_selectedLocation!.latitude},${_selectedLocation!.longitude}',
      ),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입력 정보를 확인해주세요')),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 검색하여 선택해주세요')),
      );
      return;
    }

    final params = CreateShopParams(
      name: _nameController.text.trim(),
      regNum: _regNumController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      operatingTime: _operatingTime,
      shopDescription: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      shopImages: _imageUrls,
    );

    ref.read(shopRegistrationNotifierProvider.notifier).register(params);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
