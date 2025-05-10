import 'package:chatify/models/contact.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final double _height;
  final double _width;

  ProfilePage(this._height, this._width);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
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
                    _imageFile != null ? _updateButton(_auth) : Container(),
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

  // Improved _profileImage method with better error handling
  Widget _profileImage(String imageUrl) {
    double _imageSize = widget._height * 0.20;
    return GestureDetector(
      onTap: () async {
        try {
          final pickedFile = await MediaService.instance.getImageFromLibrary();
          // ignore: unnecessary_null_comparison
          if (pickedFile != null) {
            try {
              final croppedFile = await ImageCropper().cropImage(
                sourcePath: pickedFile.path,
                compressQuality: 70,
                uiSettings: [
                  AndroidUiSettings(
                    toolbarTitle: 'Crop Image',
                    toolbarColor: Colors.blue,
                    toolbarWidgetColor: Colors.black,
                    initAspectRatio: CropAspectRatioPreset.square,
                    lockAspectRatio: false,
                    aspectRatioPresets: [
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9,
                      CropAspectRatioPreset.ratio3x2,
                    ],
                  ),
                  IOSUiSettings(
                    title: 'Crop Image',
                    aspectRatioPresets: [
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio7x5,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.ratio5x3,
                    ],
                  ),
                ],
              );

              if (croppedFile != null) {
                final file = File(croppedFile.path);
                setState(() {
                  _imageFile = file;
                  _image = FileImage(file);
                });
              }
            } catch (e) {
              // Show user-friendly error message for cropping failures
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to crop image: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
              print('Image cropping error: $e');
            }
          }
        } catch (e) {
          // Handle image picking errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to pick image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          print('Image picking error: $e');
        }
      },
      child: Container(
        height: _imageSize,
        width: _imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_imageSize),
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
                _image ??
                (imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : AssetImage('assets/default_profile.png')
                        as ImageProvider),
          ),
        ),
      ),
    );
  }

  // Improved _updateButton method with better error handling
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
                    // Continue with uploading new image even if deleting old one fails
                  }
                }

                final uploadTask = await CloudStorageService.instance
                    .uploadProfileImage(userId, _imageFile!.path);
                final taskSnapshot = await uploadTask;
                final newImageURL = await taskSnapshot.ref.getDownloadURL();

                await DBService.instance.updateProfileImage(
                  userId,
                  newImageURL,
                );

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile image updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  _imageFile =
                      null; // Clear the image file after successful update
                });
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Update failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
                print("Update failed: $e");
              } finally {
                if (mounted) {
                  setState(() {
                    isUpdatingProfileImage = false;
                  });
                }
              }
            },
            child: Text(
              "UPDATE",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
}
