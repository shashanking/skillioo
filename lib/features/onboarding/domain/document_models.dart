import 'package:json_annotation/json_annotation.dart';

part 'document_models.g.dart';

// ─── Response Models ───

@JsonSerializable()
class DocumentData {
  final DocumentInfo document;

  const DocumentData({required this.document});

  factory DocumentData.fromJson(Map<String, dynamic> json) =>
      _$DocumentDataFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentDataToJson(this);
}

@JsonSerializable()
class DocumentInfo {
  final String id;
  final String url;
  final String type;

  const DocumentInfo({required this.id, required this.url, required this.type});

  factory DocumentInfo.fromJson(Map<String, dynamic> json) =>
      _$DocumentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentInfoToJson(this);
}

// ─── Enums ───

class DocumentType {
  static const String profilePhoto = 'PROFILE_PHOTO';
  static const String video = 'VIDEO';
  static const String image = 'IMAGE';
  static const String event = 'EVENT';
}
