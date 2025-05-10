import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_service.dart';

enum AuthStatus {
  Authenticated,
  Authenticating,
  NotAuthenticated,
  UserNotFound,
  UnAuthenticating,
  PasswordResetEmailSent,
  ResetingPassword,
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
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      NavigationService.instance.navigateToReplacement("home");
      await DBService.instance.updateUserLastSeen(user!.uid);
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void passwordReset(String email) async {
    status = AuthStatus.ResetingPassword;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      status = AuthStatus.PasswordResetEmailSent;
      _snackbarService.showSnackBarSuccess("Password reset email sent");
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
      _snackbarService.showSnackBarError("Failed to send reset email");
    }
    notifyListeners();
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
      await DBService.instance.updateUserLastSeen(user!.uid);
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
      await DBService.instance.updateUserLastSeen(user!.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      _snackbarService.showSnackBarError("Error Registering");
    }
    notifyListeners();
  }

  void logout(Future<void> onSuccess()) async {
    status = AuthStatus.UnAuthenticating;
    notifyListeners();
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      NavigationService.instance.navigateToReplacement("login");
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarService.showSnackBarError("Error in Logout");
    }
    notifyListeners();
  }
}
