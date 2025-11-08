import 'package:equatable/equatable.dart';

/// Thực thể dịch vụ.
class ServiceEntity extends Equatable {
  final int id;
  final String name;
  final String unit;
  final double unitPrice;
  final double freeQuota;
  final bool isMandatory;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.freeQuota,
    required this.isMandatory,
  });

  @override
  List<Object?> get props => [id, name, unit, unitPrice, freeQuota, isMandatory];
}