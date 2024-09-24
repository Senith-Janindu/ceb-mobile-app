import 'package:ceb_app/reusable_widgets/reusable_widgets.dart';
import 'package:ceb_app/screens/forgotPassword.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/screens/signup_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _accountNumberTextController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("720F11"),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/ceb_logo.png"),
                SizedBox(
                  height: 10,
                ),
                const Text(
                  "Ceylon Electricity Board",
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                reusableTextField(
                  "Enter Account Number",
                  Icons.person_outline,
                  false,
                  _accountNumberTextController,
                ),
                SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : signInSignUpButton(context, true, () async {
                        setState(() {
                          _isLoading = true;
                        });

                        String accountNumber =
                            _accountNumberTextController.text;
                        String password = _passwordTextController.text;

                        if (accountNumber.isNotEmpty && password.isNotEmpty) {
                          try {
                            // Get the user document
                            DocumentSnapshot userDoc = await _firestore
                                .collection('users')
                                .doc(accountNumber)
                                .get();

                            if (userDoc.exists) {
                              // Check if the password matches
                              if (userDoc['password'] == password) {
                                // Navigate to HomeScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                        accountNumber: accountNumber),
                                  ),
                                );
                              } else {
                                _showAlertDialog(context, "Invalid Password",
                                    "The password you entered is incorrect.");
                              }
                            } else {
                              _showAlertDialog(
                                  context,
                                  "Invalid Account Number",
                                  "The account number you entered does not exist.");
                            }
                          } catch (e) {
                            _showAlertDialog(context, "Error",
                                "An error occurred: ${e.toString()}");
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          _showAlertDialog(context, "Missing Fields",
                              "Please fill out all fields.");
                        }
                      }),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column signUpOption() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have account ?",
                style: TextStyle(color: Colors.white70)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: const Text(
                " Sign Up",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Not remember password ? ",
                style: TextStyle(color: Colors.white70)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: const Text(
                "Reset Password",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Function to show alert dialog
  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
