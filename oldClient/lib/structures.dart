class ClientID {
  String id = '';

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
    };
  }
}

class GetAllDocumentsName {
  List<String> documentNames = [];
  bool ok = false;
  String msg = '';

  GetAllDocumentsName();

  factory GetAllDocumentsName.fromJson(Map<String, dynamic> jsonData) {
    var docs = GetAllDocumentsName();
    var ack = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;
    docs.ok = ack;
    docs.msg = msg;
    if (ack) {
      var list = jsonData['DocumentNames'] as List;
      docs.documentNames = list.map((e) => e as String).toList();
    }
    return docs;
  }
}

class DocumentRequest {
  String id = '';
  String name = '';

  DocumentRequest();

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'Name': name,
    };
  }
}

class Ack {
  bool ok = false;
  String msg = '';

  Ack();

  factory Ack.fromJson(Map<String, dynamic> jsonData) {
    var ack = Ack();
    var ok = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;
    ack.ok = ok;
    ack.msg = msg;
    return ack;
  }
}

class DocumentDetails {
  String documentNumber = '';
  String preparedBy = '';
  String reviewedByName = '';
  String reviewedByTitle = '';
  String firstApproverName = '';
  String firstApproverTitle = '';
  String secondApproverName = '';
  String secondApproverTitle = '';
  bool EIDRequired = true;
  bool resultFormatRequired = true;
  bool ok = false;
  String msg = "";

  DocumentDetails();

  factory DocumentDetails.fromJson(Map<String, dynamic> jsonData) {
    var document = DocumentDetails();
    var num = jsonData['DocumentNumber'] as String;
    var prep = jsonData['PreparedBy'] as String;
    var reviewName = jsonData['ReviewedByName'] as String;
    var reviewTitle = jsonData['ReviewedByTitle'] as String;
    var firstName = jsonData['FirstApproverName'] as String;
    var firstTitle = jsonData['FirstApproverTitle'] as String;
    var secondName = jsonData['SecondApproverName'] as String;
    var secondTitle = jsonData['SecondApproverTitle'] as String;
    var EID = jsonData['EID'] as bool;
    var resultFormat = jsonData['ResultFormat'] as bool;
    var ok = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;
    document.documentNumber = num;
    document.preparedBy = prep;
    document.reviewedByName = reviewName;
    document.reviewedByTitle = reviewTitle;
    document.firstApproverName = firstName;
    document.firstApproverTitle = firstTitle;
    document.secondApproverName = secondName;
    document.secondApproverTitle = secondTitle;
    document.EIDRequired = EID;
    document.resultFormatRequired = resultFormat;
    document.ok = ok;
    document.msg = msg;
    return document;
  }
}

class DocumentDetailsRequest {
  String id = '';
  String documentName = '';
  String documentNumber = '';
  String preparedBy = '';
  String reviewedByName = '';
  String reviewedByTitle = '';
  String firstApproverName = '';
  String firstApproverTitle = '';
  String secondApproverName = '';
  String secondApproverTitle = '';
  bool EIDRequired = true;
  bool resultFormatRequired = true;

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'DocumentName': documentName,
      'DocumentNumber': documentNumber,
      'PreparedBy': preparedBy,
      'ReviewedByName': reviewedByName,
      'ReviewedByTitle': reviewedByTitle,
      'FirstApproverName': firstApproverName,
      'FirstApproverTitle': firstApproverTitle,
      'SecondApproverName': secondApproverName,
      'SecondApproverTitle': secondApproverTitle,
      'EID' : EIDRequired,
      'ResultFormat' : resultFormatRequired,
    };
  }
}

class SubsystemDetails {
  String satelliteClass = '';
  String satelliteName = '';
  String subsystemName = '';
  String satelliteImage = '';
  bool ok = false;
  String msg = "";

  SubsystemDetails();

  factory SubsystemDetails.fromJson(Map<String, dynamic> jsonData) {
    var ss = SubsystemDetails();
    var cls = jsonData['SatelliteClass'] as String;
    var satName = jsonData['SatelliteName'] as String;
    var ssName = jsonData['SubsystemName'] as String;
    var image = jsonData['SatelliteImage'] as String;
    var ok = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;

    ss.satelliteClass = cls;
    ss.satelliteName = satName;
    ss.subsystemName = ssName;
    ss.satelliteImage = image;
    ss.ok = ok;
    ss.msg = msg;

    return ss;
  }
}

class SubsystemDetailsRequest {
  String id = '';
  String documentName = '';
  String satelliteClass = '';
  String satelliteName = '';
  String subsystemName = '';
  String satelliteImage = '';
  bool ok = false;
  String msg = "";

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'DocumentName': documentName,
      'SatelliteClass': satelliteClass,
      'SatelliteName': satelliteName,
      'SubsystemName': subsystemName,
      'SatelliteImage': satelliteImage,
    };
  }
}

class ContentRequest {
  String id = '';
  String documentName = '';
  String subsection = '';

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'DocumentName': documentName,
      'Subsection': subsection,
    };
  }
}

class ContentResponse {
  int noOfItems = 0;
  List<String> contentType = [];
  List<String> fileName = [];
  List<String> value = [];
  List<String> captions = [];
  List<bool> landscape = [];
  bool ok = false;
  String msg = "";

  ContentResponse();

  factory ContentResponse.fromJson(Map<String, dynamic> jsonData) {
    var resp = ContentResponse();
    var items = jsonData['NoOfItems'] as int;
    var cType = jsonData['ContentType'] as List;
    var fName = jsonData['FileName'] as List;
    var val = jsonData['Value'] as List;
    var cap = jsonData['Captions'] as List;
    var ls = jsonData['Landscape'] as List;
    var ok = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;

    resp.noOfItems = items;
    resp.contentType = cType.map((e) => e as String).toList();
    resp.fileName = fName.map((e) => e as String).toList();
    resp.value = val.map((e) => e as String).toList();
    resp.captions = cap.map((e) => e as String).toList();
    resp.landscape = ls.map((e) => e as bool).toList();
    resp.ok = ok;
    resp.msg = msg;

    return resp;
  }
}

class AddContentRequest {
  String id = '';
  String documentName = '';
  String subsection = '';
  int noOfItems = 0;
  List<String> contentType = [];
  List<String> fileName = [];
  List<String> value = [];
  List<String> captions = [];
  List<bool> landscape = [];

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'DocumentName': documentName,
      'Subsection': subsection,
      'NoOfItems': noOfItems,
      'ContentType': contentType,
      'FileName': fileName,
      'Value': value,
      'Captions': captions,
      'Landscape': landscape
    };
  }
}

class CopyDocumentRequest {
  String id = '';
  String oldName = '';
  String newName = '';

  CopyDocumentRequest();

  Map<String, dynamic> toJSON() {
    return {
      'ID': id,
      'OldName': oldName,
      'NewName': newName,
    };
  }
}

class PDFResponse {
  String content = '';
  bool ok = false;
  String msg = '';

  PDFResponse();

  factory PDFResponse.fromJson(Map<String, dynamic> jsonData) {
    var resp = PDFResponse();
    var cnt = jsonData['Content'] as String;
    var ok = jsonData['OK'] as bool;
    var msg = jsonData['Message'] as String;

    resp.content = cnt;
    resp.ok = ok;
    resp.msg = msg;

    return resp;
  }
}
