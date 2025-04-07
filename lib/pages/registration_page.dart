import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceheight;
  late double _devicewidth;

  late AuthProvider _auth;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FileImage? _image;

  late String _name;
  late String _email;
  late String _password;

  @override
  Widget build(BuildContext context) {
    _deviceheight = MediaQuery.of(context).size.height;
    _devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _registrationPageUI(),
        ),
      ),
    );
  }

  Widget _registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceheight * 0.75,
          width: _devicewidth,
          padding: EdgeInsets.symmetric(horizontal: _devicewidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heading(),
              _inputform(),
              _registerButton(),
              _backToLoginPage(),
            ],
          ),
        );
      },
    );
  }

  Widget _heading() {
    return Container(
      height: _deviceheight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get going!",
            style: TextStyle(
              fontSize: 35,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Please enter your details",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputform() {
    return Container(
      height: _deviceheight * 0.38,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSelector(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          MediaService.instance.getImageFromLibrary().then((file) {
            setState(() {
              _image = FileImage(file);
            });
          });
        },
        child: Container(
          height: _deviceheight * 0.10,
          width: _deviceheight * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              fit: BoxFit.cover,
              image:
                  _image ??
                  NetworkImage(
                    "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png",
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      validator: (_input) {
        return _input?.length != 0 ? null : "Enter your name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input!;
        });
      },
      decoration: InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      validator: (_input) {
        return _input?.length != 0 && _input!.contains("@")
            ? null
            : "Enter a valid email address";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input!;
        });
      },
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Email Address",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      validator: (_input) {
        return _input?.length != 0 ? null : "Enter a password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input!;
        });
      },
      decoration: InputDecoration(
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? Container(
          height: _deviceheight * 0.06,
          color: Colors.blue,
          child: Align(
            alignment: Alignment.center,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _image != null) {
                  _auth.createUserWithEmailAndPassword(_email, _password, (
                    String _uid,
                  ) async {
                    var _result = await CloudStorageService.instance
                        .uploadProfileImage(_uid, (_image?.file.path)!);
                    var snapshot = await _result;
                    var _imageURL = await snapshot.ref.getDownloadURL();
                    await DBService.instance.createUserInDB(
                      _uid,
                      _name,
                      _email,
                      _imageURL,
                    );
                  });
                }
              },
              child: Text(
                "REGISTER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        )
        : Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
  }

  Widget _backToLoginPage() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: Container(
        height: _deviceheight * 0.06,
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.arrow_back, color: Colors.white60, size: 40),
        ),
      ),
    );
  }
}
