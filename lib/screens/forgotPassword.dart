import 'package:ceb_app/reusable_widgets/reusable_widgets.dart';
import 'package:ceb_app/screens/resetPassword.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String generatedOTP;

  void _resetPassword() async {
    if (_accountNumberController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telephoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_accountNumberController.text);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No account found with that account number')),
      );
      return;
    }

    final email = userSnapshot['email'];
    final phone = userSnapshot['phone'];

    if (_emailController.text != email || _telephoneController.text != phone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email or telephone number does not match')),
      );
      return;
    }

    generatedOTP = (Random().nextInt(899999) + 100000).toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OTP'),
          content: Text('Your OTP is: $generatedOTP'),
          actions: [
            TextButton(
              child: Text('Add new password'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(
                      accountNumber: _accountNumberController.text,
                      otp: generatedOTP,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD400),
        elevation: 0,
        title: const Text(
          "Forgot Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(color: Colors.black),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("720F11"),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reusableTextField(
                    'Account Number',
                    Icons.person_outline,
                    false,
                    _accountNumberController,
                  ),
                  SizedBox(height: 20),
                  reusableTextField(
                    'Email',
                    Icons.email_outlined,
                    false,
                    _emailController,
                  ),
                  SizedBox(height: 20),
                  reusableTextField(
                    'Telephone Number',
                    Icons.call,
                    false,
                    _telephoneController,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width, 50),
                      backgroundColor: Color(0xFFFFD400),
                    ),
                    onPressed: _resetPassword,
                    child: Center(
                        child: Text(
                      'Reset Password',
                      style: const TextStyle(
                        color: Color(0xFF720F11),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
