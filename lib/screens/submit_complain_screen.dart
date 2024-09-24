import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Complains extends StatefulWidget {
  final String accountNumber;

  const Complains({super.key, required this.accountNumber});

  @override
  State<Complains> createState() => _ComplainsState();
}

class _ComplainsState extends State<Complains> {
  final TextEditingController _complainController = TextEditingController();
  bool _isSubmitting = false; // To track the submission state

  void _submitComplain() async {
    final String complain = _complainController.text.trim();

    if (complain.isEmpty) {
      _showAlertDialog(
        "Error",
        "Please enter your complaint.",
        Icons.error_outline,
        Colors.red,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Timestamp now = Timestamp.now();
      final String date = now.toDate().toString().split(' ')[0]; // YYYY-MM-DD
      final String documentId =
          '${widget.accountNumber}_${date.replaceAll('-', '_')}_${now.seconds}';

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(documentId)
          .set({
        'userAccountNumber': widget.accountNumber,
        'complaint': complain,
        'submittedAt': now,
        'status': 'Pending',
      });

      _showAlertDialog(
        "Success",
        "Complaint submitted successfully!",
        Icons.check_circle_outline,
        Colors.green,
      );

      _complainController.clear(); // Clear the text field
    } catch (e) {
      _showAlertDialog(
        "Error",
        "Failed to submit complaint. Please try again.",
        Icons.error_outline,
        Colors.red,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showAlertDialog(
      String title, String message, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD400),
        elevation: 0,
        title: const Text(
          "Ceylon Electricity Board",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'About') {
                _navigateToAbout();
              } else if (value == 'Logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'About', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF720F11),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              80,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    "Submit your complaints",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 350,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Complaints:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _complainController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your complaints here',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitComplain,
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Color(0xFFFFD400))
                      : ListTile(
                          title: Center(
                              child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 18.0),
                          )),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
