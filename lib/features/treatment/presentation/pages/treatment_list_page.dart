import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/presentation/pages/treatment_form_page.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_list_provider.dart';
import 'package:mobile_owner/features/treatment/presentation/widgets/treatment_card.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class TreatmentListPage extends ConsumerStatefulWidget {
  final String shopId;

  const TreatmentListPage({super.key, required this.shopId});

  @override
  ConsumerState<TreatmentListPage> createState() => _TreatmentListPageState();
}

class _TreatmentListPageState extends ConsumerState<TreatmentListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(treatmentListNotifierProvider(widget.shopId).notifier)
          .loadTreatments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treatmentListNotifierProvider(widget.shopId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '시술 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppColors.pastelPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(TreatmentListState state) {
    switch (state.status) {
      case TreatmentListStatus.initial:
      case TreatmentListStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.pastelPink),
        );
      case TreatmentListStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? '오류가 발생했습니다',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      case TreatmentListStatus.loaded:
        if (state.treatments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_cut, size: 48, color: AppColors.textHint),
                SizedBox(height: 16),
                Text(
                  '등록된 시술이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.treatments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final treatment = state.treatments[index];
            return TreatmentCard(
              treatment: treatment,
              onTap: () => _navigateToEdit(treatment),
            );
          },
        );
    }
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TreatmentFormPage(shopId: widget.shopId),
      ),
    );
    if (result == true) {
      ref
          .read(treatmentListNotifierProvider(widget.shopId).notifier)
          .refresh();
    }
  }

  Future<void> _navigateToEdit(Treatment treatment) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TreatmentFormPage(
          shopId: widget.shopId,
          treatment: treatment,
        ),
      ),
    );
    if (result == true) {
      ref
          .read(treatmentListNotifierProvider(widget.shopId).notifier)
          .refresh();
    }
  }
}
