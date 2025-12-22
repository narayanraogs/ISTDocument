export 'document_models.dart';
class ClientID {
  final String id;

  ClientID({required this.id});

  Map<String, dynamic> toJson() => {'ID': id};
}

class GetAllDocumentsResponse {
  final bool ok;
  final String message;
  final List<String> documentNames;

  GetAllDocumentsResponse({
    required this.ok,
    required this.message,
    required this.documentNames,
  });

  factory GetAllDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllDocumentsResponse(
      ok: json['OK'] as bool? ?? false,
      message: json['Message'] as String? ?? '',
      documentNames: (json['DocumentNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class AddDocumentRequest {
  final String id;
  final String name;

  AddDocumentRequest({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'ID': id,
        'Name': name,
      };
}

class Ack {
  final bool ok;
  final String message;

  Ack({required this.ok, required this.message});

  factory Ack.fromJson(Map<String, dynamic> json) {
    return Ack(
      ok: json['OK'] as bool? ?? false,
      message: json['Message'] as String? ?? '',
    );
  }
}
