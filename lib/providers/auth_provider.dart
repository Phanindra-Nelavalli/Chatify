import 'package:chatify/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_service.dart';

enum AuthStatus {
  Authenticated,
  Authenticating,
  NotAuthenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late AuthStatus status = AuthStatus.NotAuthenticated;
  late FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();
  SnackbarService _snackbarService = SnackbarService.instance;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
  }

  void loginWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user;
      status = AuthStatus.Authenticated;
      _snackbarService.showSnackBarSuccess("Welcome, ${user?.email}");
      NavigationService.instance.navigateToReplacement("home");
      print(user);
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarService.showSnackBarError("Error Authenticating");
      user = null;
    }
    notifyListeners();
  }

  void createUserWithEmailAndPassword(
    String _email,
    String _password,
    Future<void> onSuccess(String _uid),
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user;
      await onSuccess(user!.uid);
      status = AuthStatus.Authenticated;
      _snackbarService.showSnackBarSuccess("Welcome ${user!.email}");
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      _snackbarService.showSnackBarError("Error Registering");
    }
    notifyListeners();
  }
}
