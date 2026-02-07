import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/shop_registration_provider.dart';
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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _descriptionController = TextEditingController();

  Map<String, String> _operatingTime = {};
  List<String> _imageUrls = [];

  @override
  void dispose() {
    _nameController.dispose();
    _regNumController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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
                validator: (v) => AddressValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: '위도',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          CoordinateValidator.validateLatitude(v ?? ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: '경도',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          CoordinateValidator.validateLongitude(v ?? ''),
                    ),
                  ),
                ],
              ),
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final params = CreateShopParams(
      name: _nameController.text.trim(),
      regNum: _regNumController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
