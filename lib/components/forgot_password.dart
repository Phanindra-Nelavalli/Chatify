import 'package:chatify/constant.dart';
import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/snackbar_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();

    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => _emailFieldDialougBox(context, _emailController),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: kprimarycolor,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        ),
        child: Text(
          "Forgot Pasword",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _emailFieldDialougBox(
    BuildContext context,
    TextEditingController _emailController,
  ) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.all(20),
      title: Text(
        "Forgot Password",
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          color: kprimarycolor,
          fontFamily: 'sans-serif',
        ),
      ),
      content: Container(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(
                color: Colors.black, 
                fontSize: 16,
              ),
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter Your Email ID",

                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 23, 22, 22),
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 64, 62, 62),
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kprimarycolor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kprimarycolor,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(width: 5),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    bool isSendingMail =
                        auth.status == AuthStatus.ResetingPassword;
                    return isSendingMail
                        ? Center(
                          child: CircularProgressIndicator(
                            color: kprimarycolor,
                          ),
                        )
                        : ElevatedButton(
                          onPressed: () async {
                            String email = _emailController.text.trim();

                            if (email.isNotEmpty && email.contains("@")) {
                              auth.passwordReset(email);

                              void statusListener() async {
                                if (auth.status ==
                                    AuthStatus.PasswordResetEmailSent) {
                                  auth.removeListener(statusListener);

                                  Navigator.of(context).pop();

                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => _emailSentDialougBox(
                                          email,
                                          context,
                                        ),
                                  );
                                } else if (auth.status == AuthStatus.Error) {
                                  auth.removeListener(statusListener);

                                  Navigator.of(context).pop();
                                  SnackbarService.instance.showSnackBarError(
                                    "Failed to send password reset email. Try again.",
                                  );
                                }
                              }

                              auth.addListener(statusListener);
                            } else {
                              SnackbarService.instance.showSnackBarError(
                                "Please Enter Valid Email Address",
                              );
                            }
                          },
                          child: Text("Reset"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: kprimarycolor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailSentDialougBox(String email, BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.all(20),
      title: Row(
        children: [
          Icon(Icons.email_outlined, color: kprimarycolor),
          SizedBox(width: 10),
          Text(
            "Email Sent",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kprimarycolor,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ),
      content: Container(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "A password reset email has been sent to:",
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 14),
            Text(
              "Please check your inbox and follow the instructions to reset your password.",
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: kprimarycolor,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(width: 5),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        const gmailUrl =
                            'https://mail.google.com/mail/u/0/#inbox';

                        launchUrl(Uri.parse(gmailUrl));
                      },

                      child: Text("Open Email"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: kprimarycolor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
