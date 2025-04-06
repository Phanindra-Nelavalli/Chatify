import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackbarService {
  BuildContext? _buildContext;

  static SnackbarService instance = SnackbarService();

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        content: Text(_message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showSnackBarSuccess(String _message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        content: Text(_message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
