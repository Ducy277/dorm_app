import '../../domain/entities/service_entity.dart';

/// Model đại diện cho dịch vụ đi kèm của phòng.
class ServiceModel {
  final int id;
  final String name;
  final String unit;
  final double unitPrice;
  final double freeQuota;
  final bool isMandatory;

  ServiceModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.freeQuota,
    required this.isMandatory,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      unitPrice: num.tryParse(json['unit_price'].toString())?.toDouble() ?? 0,
      freeQuota: num.tryParse(json['free_quota'].toString())?.toDouble() ?? 0,
      //isMandatory: json['is_mandatory'] as bool,
      isMandatory: json['is_mandatory'] == true || json['is_mandatory'] == 1,
    );
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      name: name,
      unit: unit,
      unitPrice: unitPrice,
      freeQuota: freeQuota,
      isMandatory: isMandatory,
    );
  }
}