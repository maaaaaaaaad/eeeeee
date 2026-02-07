import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_form_provider.dart';
import 'package:mobile_owner/features/treatment/presentation/widgets/delete_treatment_dialog.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

class TreatmentFormPage extends ConsumerStatefulWidget {
  final String shopId;
  final Treatment? treatment;

  const TreatmentFormPage({
    super.key,
    required this.shopId,
    this.treatment,
  });

  @override
  ConsumerState<TreatmentFormPage> createState() => _TreatmentFormPageState();
}

class _TreatmentFormPageState extends ConsumerState<TreatmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  bool get _isEditMode => widget.treatment != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.treatment?.name ?? '');
    _priceController = TextEditingController(
        text: widget.treatment?.price.toString() ?? '');
    _durationController = TextEditingController(
        text: widget.treatment?.duration.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.treatment?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(treatmentFormNotifierProvider, (prev, next) {
      if (next.status == TreatmentFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? '시술이 수정되었습니다' : '시술이 등록되었습니다'),
          ),
        );
        Navigator.pop(context, true);
      }
      if (next.status == TreatmentFormStatus.deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시술이 삭제되었습니다')),
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

    final state = ref.watch(treatmentFormNotifierProvider);
    final isLoading = state.status == TreatmentFormStatus.loading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? '시술 수정' : '시술 등록',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '시술명',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => TreatmentNameValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '가격',
                  border: OutlineInputBorder(),
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => PriceValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: '소요시간 (분)',
                  border: OutlineInputBorder(),
                  suffixText: '분',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => DurationValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => DescriptionValidator.validate(v ?? ''),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? '수정하기' : '등록하기',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '삭제하기',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = int.parse(_priceController.text);
    final duration = int.parse(_durationController.text);
    final description = _descriptionController.text.trim();

    final notifier = ref.read(treatmentFormNotifierProvider.notifier);

    if (_isEditMode) {
      notifier.update(UpdateTreatmentParams(
        treatmentId: widget.treatment!.id,
        name: name,
        price: price,
        duration: duration,
        description: description.isEmpty ? null : description,
      ));
    } else {
      notifier.create(CreateTreatmentParams(
        shopId: widget.shopId,
        name: name,
        price: price,
        duration: duration,
        description: description.isEmpty ? null : description,
      ));
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await DeleteTreatmentDialog.show(
      context,
      treatmentName: widget.treatment!.name,
    );
    if (confirmed == true) {
      ref
          .read(treatmentFormNotifierProvider.notifier)
          .delete(widget.treatment!.id);
    }
  }
}
