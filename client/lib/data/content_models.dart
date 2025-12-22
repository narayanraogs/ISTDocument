import 'dart:convert';
import 'dart:typed_data';

enum ContentType {
  text,
  image,
  table,
  file,
  code, // Used for 'Add Procedure' in old client, seemingly a file with readable content?
  excel,
  unknown
}

class ContentItem {
  ContentType type;
  String value; // Text content or Base64 string
  String fileName;
  String caption;
  bool isLandscape;

  ContentItem({
    required this.type,
    this.value = '',
    this.fileName = '',
    this.caption = '',
    this.isLandscape = false,
  });

  // Helper to get string name for API
  String get typeString {
    switch (type) {
      case ContentType.text: return 'Text';
      case ContentType.image: return 'Image';
      case ContentType.table: return 'Table';
      case ContentType.file: return 'File';
      case ContentType.code: return 'Code';
      case ContentType.excel: return 'Excel';
      default: return 'Unknown';
    }
  }

  static ContentType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'text': return ContentType.text;
      case 'image': return ContentType.image;
      case 'table': return ContentType.table;
      case 'file': return ContentType.file;
      case 'code': return ContentType.code;
      case 'excel': return ContentType.excel;
      default: return ContentType.unknown;
    }
  }
}

class ContentRequest {
  final String id;
  final String documentName;
  final String subsection;

  ContentRequest({
    required this.id,
    required this.documentName,
    required this.subsection,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'DocumentName': documentName,
        'Subsection': subsection,
      };
}

class ContentResponse {
  final bool ok;
  final String message;
  final int noOfItems;
  final List<ContentItem> items;

  ContentResponse({
    required this.ok,
    required this.message,
    required this.noOfItems,
    required this.items,
  });

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    bool ok = json['OK'] as bool? ?? false;
    String message = json['Message'] as String? ?? '';
    
    if (!ok) {
       return ContentResponse(ok: false, message: message, noOfItems: 0, items: []);
    }

    int count = json['NoOfItems'] as int? ?? 0;
    List<dynamic> types = json['ContentType'] ?? [];
    List<dynamic> values = json['Value'] ?? [];
    List<dynamic> fileNames = json['FileName'] ?? [];
    List<dynamic> captions = json['Captions'] ?? [];
    List<dynamic> landscapes = json['Landscape'] ?? [];

    List<ContentItem> parsedItems = [];
    
    // Safety check: ensure all arrays are at least 'count' long or handle missing data
    // The server code appends to all arrays, so they should be sync'd.
    for (int i = 0; i < count; i++) {
      if (i < types.length) {
        parsedItems.add(ContentItem(
          type: ContentItem.fromString(types[i].toString()),
          value: i < values.length ? values[i].toString() : '',
          fileName: i < fileNames.length ? fileNames[i].toString() : '',
          caption: i < captions.length ? captions[i].toString() : '',
          isLandscape: i < landscapes.length ? (landscapes[i] as bool? ?? false) : false,
        ));
      }
    }

    return ContentResponse(
      ok: ok,
      message: message,
      noOfItems: count,
      items: parsedItems,
    );
  }
}

class AddContentRequest {
  final String id;
  final String documentName;
  final String subsection;
  final List<ContentItem> items;

  AddContentRequest({
    required this.id,
    required this.documentName,
    required this.subsection,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'DocumentName': documentName,
      'Subsection': subsection,
      'NoOfItems': items.length,
      'ContentType': items.map((e) => e.typeString).toList(),
      'Value': items.map((e) => e.value).toList(),
      'FileName': items.map((e) => e.fileName).toList(),
      'Captions': items.map((e) => e.caption).toList(),
      'Landscape': items.map((e) => e.isLandscape).toList(),
    };
  }
}
