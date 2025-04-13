import 'package:chatify/models/contact.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;
  // Removed _auth field as it violates immutability
  ProfilePage(this._height, this._width);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        final _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream:
              _auth.user != null
                  ? DBService.instance.getUserDetails(_auth.user!.uid)
                  : null,
          builder: (_context, _snapshot) {
            if (!_snapshot.hasData) {
              return Center(
                child: SpinKitWanderingCubes(color: Colors.blue, size: 50.0),
              );
            }

            var _userData = _snapshot.data!;
            return Align(
              child: SizedBox(
                height: _height * 0.50,
                width: _width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _profileImage(_userData.image),
                    _userName(_userData.name),
                    _userEmail(_userData.email),
                    _logoutButton(_auth),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileImage(String _image) {
    double _imageSize = _height * 0.20;
    return Container(
      height: _imageSize,
      width: _imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageSize),
        image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(_image)),
      ),
    );
  }

  Widget _userName(String _username) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _username,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmail(String _email) {
    return Container(
      height: _height * 0.03,
      width: _width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton(AuthProvider _auth) {
    return _auth.status == AuthStatus.UnAuthenticating
        ? CircularProgressIndicator(color: Colors.red)
        : Container(
          height: _height * 0.06,
          width: _width * 0.8,
          child: MaterialButton(
            color: Colors.red,
            onPressed: () {
              _auth.logout(() async {});
            },
            child: Text(
              "LOGOUT",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        );
  }
}
