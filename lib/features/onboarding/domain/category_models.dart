import 'package:json_annotation/json_annotation.dart';

part 'category_models.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;

  Category({
    required this.id,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class SubCategory {
  final String id;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String categoryId;

  SubCategory({
    required this.id,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.categoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryToJson(this);
}

@JsonSerializable()
class CreateCategoryRequest {
  final String name;

  CreateCategoryRequest({required this.name});

  factory CreateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCategoryRequestToJson(this);
}

@JsonSerializable()
class CreateSubCategoryRequest {
  final String name;
  final String categoryId;

  CreateSubCategoryRequest({
    required this.name,
    required this.categoryId,
  });

  factory CreateSubCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubCategoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSubCategoryRequestToJson(this);
}
