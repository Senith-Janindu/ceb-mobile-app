import 'package:ceb_app/reusable_widgets/app_bar.dart';
import 'package:ceb_app/screens/bill_payment.dart';
import 'package:ceb_app/screens/customer_service_screen.dart';
import 'package:ceb_app/screens/meter_reading_capture_screen.dart';
import 'package:ceb_app/screens/past_bill_details.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:ceb_app/screens/about_screen.dart'; // Import the AboutScreen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ceb_app/utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  final String accountNumber;

  const HomeScreen({Key? key, required this.accountNumber}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
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
        automaticallyImplyLeading: false,
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
              120,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    backgroundColor: Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.fit_screen_outlined,
                      size: 35.0,
                      color: Colors.black), // Suitable icon for meter reading
                  label: const Text(
                    'Get meter reading',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MeterReadingCapture(
                              accountNumber: widget.accountNumber)),
                    );
                  },
                ),
                SizedBox(height: 35),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    backgroundColor: Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.history,
                      size: 35.0,
                      color:
                          Colors.black), // Suitable icon for past bill details
                  label: const Text(
                    'Past bill details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PastBillDetails(
                              accountNumber: widget.accountNumber)),
                    );
                  },
                ),
                SizedBox(height: 35),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    backgroundColor: Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.payment,
                      size: 35.0,
                      color: Colors.black), // Suitable icon for bill payments
                  label: const Text(
                    'Bill payments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BillPaymentScreen(
                              accountNumber: widget.accountNumber)),
                    );
                  },
                ),
                SizedBox(height: 35),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 70),
                    backgroundColor: Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.support_agent,
                      size: 35.0,
                      color: Colors.black), // Suitable icon for other services
                  label: const Text(
                    'Other service',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerService(
                              accountNumber: widget.accountNumber)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
