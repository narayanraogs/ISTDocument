import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../data/models.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    baseUrl = Constants.baseUrl;
  }

  Future<GetAllDocumentsResponse> getAllDocumentNames(String clientId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getAllDocumentNames'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(ClientID(id: clientId).toJson()),
      );

      if (response.statusCode == 200) {
        return GetAllDocumentsResponse.fromJson(jsonDecode(response.body));
      } else {
        return GetAllDocumentsResponse(
          ok: false,
          message: 'Server error: ${response.statusCode}',
          documentNames: [],
        );
      }
    } catch (e) {
      return GetAllDocumentsResponse(
        ok: false,
        message: 'Connection error: $e',
        documentNames: [],
      );
    }
  }

  Future<Ack> addDocument(String clientId, String documentName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          AddDocumentRequest(id: clientId, name: documentName).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }

  Future<Ack> copyDocument(
    String clientId,
    String oldName,
    String newName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/copyDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          CopyDocumentRequest(
            id: clientId,
            oldName: oldName,
            newName: newName,
          ).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }

  Future<DocumentDetailsResponse> getDocumentDetails(
    String clientId,
    String documentName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getDocumentDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          AddDocumentRequest(id: clientId, name: documentName).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return DocumentDetailsResponse.fromJson(jsonDecode(response.body));
      } else {
        return DocumentDetailsResponse(
          ok: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return DocumentDetailsResponse(
        ok: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<Ack> addDocumentDetails(
    String clientId,
    String documentName,
    DocumentDetails details,
  ) async {
    try {
      final request = DocumentDetailsRequest(
        id: clientId,
        documentName: documentName,
        details: details,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/addDocumentDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }

  Future<SubsystemDetailsResponse> getSubsystemDetails(
    String clientId,
    String documentName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getSubsystemDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          AddDocumentRequest(id: clientId, name: documentName).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return SubsystemDetailsResponse.fromJson(jsonDecode(response.body));
      } else {
        return SubsystemDetailsResponse(
          ok: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SubsystemDetailsResponse(
        ok: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<Ack> addSubsystemDetails(
    String clientId,
    String documentName,
    SubsystemDetails details,
  ) async {
    try {
      final request = SubsystemDetailsRequest(
        id: clientId,
        documentName: documentName,
        satelliteClass: details.satelliteClass,
        satelliteName: details.satelliteName,
        subsystemName: details.subsystemName,
        satelliteImage: details.satelliteImage,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/addSubsystemDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }

  Future<ContentResponse> getContent(
    String clientId,
    String documentName,
    String subsection,
  ) async {
    try {
      final request = ContentRequest(
        id: clientId,
        documentName: documentName,
        subsection: subsection,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/getContent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return ContentResponse.fromJson(jsonDecode(response.body));
      } else {
        return ContentResponse(
          ok: false,
          message: 'Server error: ${response.statusCode}',
          noOfItems: 0,
          items: [],
        );
      }
    } catch (e) {
      return ContentResponse(
        ok: false,
        message: 'Connection error: $e',
        noOfItems: 0,
        items: [],
      );
    }
  }

  Future<Ack> addContent(
    String clientId,
    String documentName,
    String subsection,
    List<ContentItem> items,
  ) async {
    try {
      final request = AddContentRequest(
        id: clientId,
        documentName: documentName,
        subsection: subsection,
        items: items,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/addContent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }

  Future<PdfResponse> compileDocument(
    String clientId,
    String documentName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compileDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          AddDocumentRequest(id: clientId, name: documentName).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return PdfResponse.fromJson(jsonDecode(response.body));
      } else {
        return PdfResponse(
          ok: false,
          content: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PdfResponse(ok: false, content: 'Connection error: $e');
    }
  }

  Future<PdfResponse> getSignaturePage(
    String clientId,
    String documentName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getSignaturePage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          AddDocumentRequest(id: clientId, name: documentName).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return PdfResponse.fromJson(jsonDecode(response.body));
      } else {
        return PdfResponse(
          ok: false,
          content: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PdfResponse(ok: false, content: 'Connection error: $e');
    }
  }

  Future<Ack> deleteDocument(
    String clientId,
    String documentName,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/deleteDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          DeleteDocumentRequest(
            name: documentName,
            password: password,
          ).toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return Ack.fromJson(jsonDecode(response.body));
      } else {
        return Ack(ok: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return Ack(ok: false, message: 'Connection error: $e');
    }
  }
}
