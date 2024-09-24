import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:ceb_app/screens/submit_complain_screen.dart';
import 'package:ceb_app/screens/customer_requests_screen.dart'; // Assuming you have this screen
import 'package:ceb_app/screens/tips_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';

class CustomerService extends StatefulWidget {
  final String accountNumber;

  const CustomerService({super.key, required this.accountNumber});

  @override
  State<CustomerService> createState() => _CustomerServiceState();
}

class _CustomerServiceState extends State<CustomerService> {
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
          color: hexStringToColor("720F11"),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              120, // Adjusted the top padding to move the logo up
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Other services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD400), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value for the desired roundedness
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Complains(accountNumber: widget.accountNumber),
                      ),
                    );
                  },
                  child: const ListTile(
                    leading: Icon(Icons.report_problem, color: Colors.black),
                    title: Center(
                        child: Text(
                      'Submit your complains',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    )),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD400), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value for the desired roundedness
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewRequest(accountNumber: widget.accountNumber),
                      ),
                    );
                  },
                  child: const ListTile(
                    leading: Icon(Icons.add_box, color: Colors.black),
                    title: Center(
                        child: Text(
                      'Submit a request to get a new connection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    )),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD400), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the value for the desired roundedness
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Tips(),
                      ),
                    );
                  },
                  child: const ListTile(
                    leading: Icon(Icons.lightbulb, color: Colors.black),
                    title: Center(
                        child: Text(
                      'Tips for reduce your electricity usage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    )),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
