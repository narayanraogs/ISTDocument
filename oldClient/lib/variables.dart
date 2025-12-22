import 'package:flutter/material.dart';

class Global {
  String documentName = '';
  final String clientID = '${DateTime.now().millisecondsSinceEpoch}';
  String url = 'http://172.18.11.241:9070';
}

List<String> urls = ['http://10.21.14.194:9070', 'http://172.18.11.241:9070'];

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
