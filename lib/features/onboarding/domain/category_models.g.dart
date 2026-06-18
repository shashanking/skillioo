// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  deleted: json['deleted'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'deleted': instance.deleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'name': instance.name,
};

SubCategory _$SubCategoryFromJson(Map<String, dynamic> json) => SubCategory(
  id: json['id'] as String,
  deleted: json['deleted'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$SubCategoryToJson(SubCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deleted': instance.deleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'categoryId': instance.categoryId,
    };

CreateCategoryRequest _$CreateCategoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateCategoryRequest(name: json['name'] as String);

Map<String, dynamic> _$CreateCategoryRequestToJson(
  CreateCategoryRequest instance,
) => <String, dynamic>{'name': instance.name};

CreateSubCategoryRequest _$CreateSubCategoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateSubCategoryRequest(
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$CreateSubCategoryRequestToJson(
  CreateSubCategoryRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'categoryId': instance.categoryId,
};
