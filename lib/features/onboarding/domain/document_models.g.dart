// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentData _$DocumentDataFromJson(Map<String, dynamic> json) => DocumentData(
  document: DocumentInfo.fromJson(json['document'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DocumentDataToJson(DocumentData instance) =>
    <String, dynamic>{'document': instance.document};

DocumentInfo _$DocumentInfoFromJson(Map<String, dynamic> json) => DocumentInfo(
  id: json['id'] as String,
  url: json['url'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$DocumentInfoToJson(DocumentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
    };
