import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/bill_detail_screen.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PastBillDetails extends StatefulWidget {
  final String accountNumber;

  const PastBillDetails({Key? key, required this.accountNumber})
      : super(key: key);

  @override
  State<PastBillDetails> createState() => _PastBillDetailsState();
}

class _PastBillDetailsState extends State<PastBillDetails> {
  List<String> billMonths = [];

  @override
  void initState() {
    super.initState();
    fetchBillMonths();
  }

  void fetchBillMonths() async {
    try {
      QuerySnapshot billSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .collection('meterReadings')
          .where('endReading',
              isNotEqualTo: 0) // Filter for endReading not equal to 0
          .get();

      setState(() {
        billMonths = billSnapshot.docs.map((doc) => doc.id).toList();

        // Sort the list in descending order (highest to lowest)
        billMonths.sort((a, b) => b.compareTo(a));
      });
    } catch (e) {
      print("Error fetching bill months: $e");
    }
  }

  String formatMonth(String month) {
    String year = month.substring(0, 4);
    String formattedMonth = month.substring(4, 6);
    return "$year-$formattedMonth";
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
                  'Past Bill Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ...billMonths.map((month) => Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BillDetail(
                                        accountNumber: widget.accountNumber,
                                        month: month,
                                      )),
                            );
                          },
                          child: ListTile(
                            title: Center(
                                child: Text(
                              formatMonth(month),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            )),
                          ),
                        ),
                        SizedBox(height: 20), // Add space between buttons
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
