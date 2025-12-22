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
          documentNames: []
        );
      }
    } catch (e) {
      return GetAllDocumentsResponse(
        ok: false,
        message: 'Connection error: $e',
        documentNames: []
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
        body: jsonEncode(AddDocumentRequest(id: clientId, name: documentName).toJson()),
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
