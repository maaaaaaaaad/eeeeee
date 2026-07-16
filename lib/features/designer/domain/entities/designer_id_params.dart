import 'package:equatable/equatable.dart';

class DesignerIdParams extends Equatable {
  final String shopId;
  final String designerId;

  const DesignerIdParams({
    required this.shopId,
    required this.designerId,
  });

  @override
  List<Object?> get props => [shopId, designerId];
}
