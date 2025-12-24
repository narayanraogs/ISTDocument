export 'document_models.dart';
export 'subsystem_models.dart';
export 'content_models.dart';

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
      documentNames:
          (json['DocumentNames'] as List<dynamic>?)
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

  Map<String, dynamic> toJson() => {'ID': id, 'Name': name};
}

class CopyDocumentRequest {
  final String oldName;
  final String newName;
  final String id;

  CopyDocumentRequest({
    required this.oldName,
    required this.newName,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'OldName': oldName,
    'NewName': newName,
    'ID': id,
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

class DeleteDocumentRequest {
  final String name;
  final String password;

  DeleteDocumentRequest({required this.name, required this.password});

  Map<String, dynamic> toJson() => {'Name': name, 'Password': password};
}

class PdfResponse {
  final bool ok;
  final String content; // Base64 content

  PdfResponse({required this.ok, required this.content});

  factory PdfResponse.fromJson(Map<String, dynamic> json) {
    return PdfResponse(ok: json['OK'] ?? false, content: json['Content'] ?? '');
  }
}
