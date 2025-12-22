import 'package:flutter/material.dart';

class NavigationItem {
  final String id;
  final String title;
  final String section; // e.g., "Introduction", "Checkout Details"
  final IconData? icon;

  const NavigationItem({
    required this.id,
    required this.title,
    required this.section,
    this.icon,
  });
}

class AppState extends ChangeNotifier {
  final String clientId = '${DateTime.now().millisecondsSinceEpoch}';

  // Document State
  String? _selectedDocument;
  String? get selectedDocument => _selectedDocument;

  // Theme State
  ThemeMode _themeMode = ThemeMode.light; // Default to light
  ThemeMode get themeMode => _themeMode;

  // Navigation State
  String _currentRoute = 'dashboard';
  String get currentRoute => _currentRoute;

  // Sidebar Expansion State
  // Map of Section Title -> Is Expanded
  final Map<String, bool> _expandedSections = {
    'Information': true,
    'Introduction': false,
    'Checkout Details': false,
    'Test Details': false,
    'Annexure': false,
  };
  Map<String, bool> get expandedSections => _expandedSections;

  bool _isSidebarVisible = true;
  bool get isSidebarVisible => _isSidebarVisible;

  // Actions
  void selectDocument(String? docName) {
    _selectedDocument = docName;
    // Reset to info or dashboard when document changes
    _currentRoute = (docName != null) ? 'info_document' : 'dashboard';
    notifyListeners();
  }

  void navigateTo(String routeId) {
    _currentRoute = routeId;
    notifyListeners();
  }

  void toggleSection(String section) {
    // If we want accordion style (only one open at a time):
    // _expandedSections.updateAll((key, value) => false);
    
    // Using simple toggle (multiple open allowed):
    if (_expandedSections.containsKey(section)) {
      _expandedSections[section] = !(_expandedSections[section] ?? false);
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarVisible = !_isSidebarVisible;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
