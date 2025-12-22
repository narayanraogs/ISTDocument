class DocumentDetails {
  final String documentNumber;
  final String preparedBy;
  final String reviewedByName;
  final String reviewedByTitle;
  final String firstApproverName;
  final String firstApproverTitle;
  final String secondApproverName;
  final String secondApproverTitle;
  final bool eidRequired;
  final bool resultFormatRequired;

  DocumentDetails({
    required this.documentNumber,
    required this.preparedBy,
    required this.reviewedByName,
    required this.reviewedByTitle,
    required this.firstApproverName,
    required this.firstApproverTitle,
    required this.secondApproverName,
    required this.secondApproverTitle,
    required this.eidRequired,
    required this.resultFormatRequired,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) {
    return DocumentDetails(
      documentNumber: json['DocumentNumber'] as String? ?? '',
      preparedBy: json['PreparedBy'] as String? ?? '',
      reviewedByName: json['ReviewedByName'] as String? ?? '',
      reviewedByTitle: json['ReviewedByTitle'] as String? ?? '',
      firstApproverName: json['FirstApproverName'] as String? ?? '',
      firstApproverTitle: json['FirstApproverTitle'] as String? ?? '',
      secondApproverName: json['SecondApproverName'] as String? ?? '',
      secondApproverTitle: json['SecondApproverTitle'] as String? ?? '',
      eidRequired: json['EID'] as bool? ?? true,
      resultFormatRequired: json['ResultFormat'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocumentNumber': documentNumber,
        'PreparedBy': preparedBy,
        'ReviewedByName': reviewedByName,
        'ReviewedByTitle': reviewedByTitle,
        'FirstApproverName': firstApproverName,
        'FirstApproverTitle': firstApproverTitle,
        'SecondApproverName': secondApproverName,
        'SecondApproverTitle': secondApproverTitle,
        'EID': eidRequired,
        'ResultFormat': resultFormatRequired,
      };
}

class DocumentDetailsRequest {
  final String id;
  final String documentName;
  final DocumentDetails details;

  DocumentDetailsRequest({
    required this.id,
    required this.documentName,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'DocumentName': documentName,
        ...details.toJson(),
      };
}

class DocumentDetailsResponse {
  final bool ok;
  final String message;
  final DocumentDetails? details;

  DocumentDetailsResponse({
    required this.ok,
    required this.message,
    this.details,
  });

  factory DocumentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentDetailsResponse(
      ok: json['OK'] as bool? ?? false,
      message: json['Message'] as String? ?? '',
      details: json['OK'] == true ? DocumentDetails.fromJson(json) : null,
    );
  }
}
