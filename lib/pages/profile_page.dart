import 'package:chatify/models/contact.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final double _height;
  final double _width;

  ProfilePage(this._height, this._width);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FileImage? _image;
  bool isUpdatingProfileImage = false;
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
                height: widget._height * 0.50,
                width: widget._width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _profileImage(_userData.image),
                    _userName(_userData.name),
                    _userEmail(_userData.email),
                    _image != null ? _updateButton(_auth) : Container(),
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

  Widget _profileImage(String imageUrl) {
    double _imageSize = widget._height * 0.20;
    return GestureDetector(
      onTap: () async {
        MediaService.instance.getImageFromLibrary().then((file) {
          setState(() {
            _image = FileImage(file);
          });
        });
      },
      child: Container(
        height: _imageSize,
        width: _imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_imageSize),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: _image ?? NetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }

  Widget _userName(String _username) {
    return Container(
      height: widget._height * 0.05,
      width: widget._width,
      child: Text(
        _username,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmail(String _email) {
    return Container(
      height: widget._height * 0.03,
      width: widget._width,
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
          height: widget._height * 0.06,
          width: widget._width * 0.8,
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

  Widget _updateButton(AuthProvider _auth) {
    return isUpdatingProfileImage
        ? CircularProgressIndicator(color: Colors.blue)
        : Container(
          height: widget._height * 0.06,
          width: widget._width * 0.8,
          child: MaterialButton(
            color: Colors.blue,
            onPressed: () async {
              setState(() {
                isUpdatingProfileImage = true;
              });
              try {
                final userId = _auth.user!.uid;

                final currentUser =
                    await DBService.instance.getUserDetails(userId).first;
                final oldImageURL = currentUser.image;

                if (oldImageURL.isNotEmpty) {
                  try {
                    final ref = await FirebaseStorage.instance.refFromURL(
                      oldImageURL,
                    );
                    await ref.delete();
                  } catch (e) {
                    print("Failed to delete old image: $e");
                  }
                }

                final uploadTask = await CloudStorageService.instance
                    .uploadProfileImage(userId, (_image?.file.path)!);
                final taskSnapshot = await uploadTask;
                final newImageURL = await taskSnapshot.ref.getDownloadURL();

                await DBService.instance.updateProfileImage(
                  userId,
                  newImageURL,
                );
              } catch (e) {
                print("Update failed: $e");
              }
              setState(() {
                isUpdatingProfileImage = false;
              });
            },
            child: Text(
              "UPDATE",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        );
  }
}
