import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ceb_app/reusable_widgets/reusable_widgets.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _accNumTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordConfirmTextController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD400),
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("720F11"),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter UserName",
                    Icons.person_outline,
                    false,
                    _userNameTextController,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Email",
                    Icons.email_outlined,
                    false,
                    _emailTextController,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Phone number",
                    Icons.call,
                    false,
                    _phoneTextController,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Account No",
                    Icons.wb_iridescent_outlined,
                    false,
                    _accNumTextController,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Enter Password",
                    Icons.lock_outline,
                    true,
                    _passwordTextController,
                  ),
                  const SizedBox(height: 20),
                  reusableTextField(
                    "Confirm Password",
                    Icons.lock_outline,
                    true,
                    _passwordConfirmTextController,
                  ),
                  const SizedBox(height: 20),
                  signInSignUpButton(context, false, () {
                    _signUpUser();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUpUser() async {
    // Collect the input values
    String username = _userNameTextController.text;
    String email = _emailTextController.text;
    String phone = _phoneTextController.text;
    String accountNumber = _accNumTextController.text;
    String password = _passwordTextController.text;
    String confirmPassword = _passwordConfirmTextController.text;

    // Validation
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        accountNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog("Please fill in all the fields.");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorDialog("Please enter a valid 10-digit phone number.");
      return;
    }

    if (accountNumber.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(accountNumber)) {
      _showErrorDialog("Please enter a valid 10-digit account number.");
      return;
    }

    if (!_isPasswordStrong(password)) {
      _showErrorDialog(
          "Password must be at least 8 characters long, include at least one uppercase letter, one lowercase letter, one number, and one special symbol.");
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(accountNumber);

      // Create a new user document
      await userDoc.set({
        'name': username,
        'email': email,
        'phone': phone,
        'password': password,
        'createdAt': Timestamp.now(),
      });

      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(accountNumber: accountNumber),
        ),
      );
    } catch (e) {
      _showErrorDialog("Failed to sign up. Please try again.");
    }
  }

  bool _isPasswordStrong(String password) {
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;

    return hasUpperCase &&
        hasLowerCase &&
        hasDigits &&
        hasSpecialCharacters &&
        hasMinLength;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
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
