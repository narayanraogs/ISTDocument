import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:html' as html;

class Constants {
  static String get baseUrl {
    if (kIsWeb) {
      // Get the base URL from the browser's address bar
      final uri = Uri.parse(html.window.location.href);
      // Construct the base URL using the protocol, host, and port
      String baseUrl = '${uri.scheme}://${uri.host}';
      if (uri.hasPort) {
        baseUrl += ':${uri.port}';
      }
      return baseUrl;
    } else {
      // Fallback for non-web platforms (e.g., local development or Linux app)
      return 'http://127.0.0.1:8080';
    }
  }
}
