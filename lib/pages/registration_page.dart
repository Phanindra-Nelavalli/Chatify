import 'package:chatify/services/navigation_service.dart';
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

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceheight = MediaQuery.of(context).size.height;
    _devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Align(alignment: Alignment.center, child: _registrationPageUI()),
    );
  }

  Widget _registrationPageUI() {
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
        onChanged: () {},
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
    return Container(
      height: _deviceheight * 0.10,
      width: _devicewidth * 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          image: NetworkImage(
            "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png",
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
        setState(() {});
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
        setState(() {});
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
        setState(() {});
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
    return Container(
      height: _deviceheight * 0.06,
      color: Colors.blue,
      child: Align(
        alignment: Alignment.center,
        child: MaterialButton(
          onPressed: () {
            _formKey.currentState!.validate();
          },
          child: Text(
            "REGISTER",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
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
