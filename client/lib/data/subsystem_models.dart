class SubsystemDetails {
  final String satelliteClass;
  final String satelliteName;
  final String subsystemName;
  final String satelliteImage; // Base64 string

  SubsystemDetails({
    required this.satelliteClass,
    required this.satelliteName,
    required this.subsystemName,
    required this.satelliteImage,
  });

  factory SubsystemDetails.fromJson(Map<String, dynamic> json) {
    return SubsystemDetails(
      satelliteClass: json['SatelliteClass'] as String? ?? '',
      satelliteName: json['SatelliteName'] as String? ?? '',
      subsystemName: json['SubsystemName'] as String? ?? '',
      satelliteImage: json['SatelliteImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'SatelliteClass': satelliteClass,
        'SatelliteName': satelliteName,
        'SubsystemName': subsystemName,
        'SatelliteImage': satelliteImage,
      };
}

class SubsystemDetailsRequest {
  final String id;
  final String documentName;
  final String satelliteClass;
  final String satelliteName;
  final String subsystemName;
  final String satelliteImage;

  SubsystemDetailsRequest({
    required this.id,
    required this.documentName,
    required this.satelliteClass,
    required this.satelliteName,
    required this.subsystemName,
    required this.satelliteImage,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'DocumentName': documentName,
        'SatelliteClass': satelliteClass,
        'SatelliteName': satelliteName,
        'SubsystemName': subsystemName,
        'SatelliteImage': satelliteImage,
      };
}

class SubsystemDetailsResponse {
  final bool ok;
  final String message;
  final String satelliteClass;
  final String satelliteName;
  final String subsystemName;
  final String satelliteImage;

  SubsystemDetailsResponse({
    required this.ok,
    required this.message,
    this.satelliteClass = '',
    this.satelliteName = '',
    this.subsystemName = '',
    this.satelliteImage = '',
  });

  factory SubsystemDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SubsystemDetailsResponse(
      ok: json['OK'] as bool? ?? false,
      message: json['Message'] as String? ?? '',
      satelliteClass: json['SatelliteClass'] as String? ?? '',
      satelliteName: json['SatelliteName'] as String? ?? '',
      subsystemName: json['SubsystemName'] as String? ?? '',
      satelliteImage: json['SatelliteImage'] as String? ?? '',
    );
  }
}
