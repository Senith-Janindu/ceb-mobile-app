import 'package:ceb_app/reusable_widgets/reusable_widgets.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String accountNumber;
  final String otp;

  const ResetPasswordScreen({
    required this.accountNumber,
    required this.otp,
    Key? key,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _saveNewPassword() async {
    if (_otpController.text != widget.otp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect OTP')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.accountNumber);
    await userDoc.update({
      'password': _newPasswordController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password updated successfully')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(accountNumber: widget.accountNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD400),
        elevation: 0,
        title: const Text(
          "Reset Password",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                reusableTextField(
                  "OTP",
                  Icons.numbers_rounded,
                  true,
                  _otpController,
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "New Password",
                  Icons.lock_outline,
                  true,
                  _newPasswordController,
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "Confirm Password",
                  Icons.lock_outline,
                  true,
                  _confirmPasswordController,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    backgroundColor: Color(0xFFFFD400),
                  ),
                  onPressed: _saveNewPassword,
                  child: Center(
                      child: Text(
                    'Save New Password',
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
    );
  }
}
