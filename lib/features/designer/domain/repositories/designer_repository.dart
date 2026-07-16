import 'package:dartz/dartz.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';

abstract class DesignerRepository {
  Future<Either<Failure, Designer>> createDesigner(
      CreateDesignerParams params);
  Future<Either<Failure, Designer>> getDesigner(String shopId, String designerId);
  Future<Either<Failure, List<Designer>>> listDesigners(String shopId);
  Future<Either<Failure, Designer>> updateDesigner(
      UpdateDesignerParams params);
  Future<Either<Failure, void>> deleteDesigner(String shopId, String designerId);
}
