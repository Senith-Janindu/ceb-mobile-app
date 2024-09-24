import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BillDetail extends StatefulWidget {
  final String accountNumber;
  final String month;

  const BillDetail({Key? key, required this.accountNumber, required this.month})
      : super(key: key);

  @override
  State<BillDetail> createState() => _BillDetailState();
}

class _BillDetailState extends State<BillDetail> {
  Map<String, dynamic> billData = {};
  bool isLoading = true;
  double totalPayable = 0.0;

  @override
  void initState() {
    super.initState();
    fetchBillDetails();
  }

  void fetchBillDetails() async {
    try {
      // Fetch the bill details from the 'meterReadings' subcollection
      DocumentSnapshot billSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .collection('meterReadings')
          .doc(widget.month)
          .get();

      // Fetch the user document to get the credit value
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .get();

      if (billSnapshot.exists && userSnapshot.exists) {
        setState(() {
          // Combine both maps, with credit from user document
          billData = billSnapshot.data() as Map<String, dynamic>;
          billData['credit'] = userSnapshot['credit'] ?? 0.0;

          // Calculate the total payable
          double monthlyBill = (billData['monthlyBill'] ?? 0.0).toDouble();
          double fixedCharge = (billData['fixedCharge'] ?? 0.0).toDouble();
          // double credit = (billData['credit'] ?? 0.0).toDouble();

          totalPayable = monthlyBill + fixedCharge;

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching bill details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    120,
                    10,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "Your Bill Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity, // Full width for the card
                        child: Card(
                          color: Colors.white, // White background for the card
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account number: ${widget.accountNumber}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Read on: ${billData['readOn'] != null ? formatTimestamp(billData['readOn']) : 'N/A'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Meter Reading: ${billData['endReading'] ?? 'N/A'} - ${billData['pastReading'] ?? 'N/A'} = ${billData['units'] ?? 'N/A'} Units",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Number of units: ${billData['units'] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Value for units: Rs.${billData['monthlyBill'] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Fixed charge: Rs.${billData['fixedCharge'] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Total Monthly bill: Rs.$totalPayable",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Due date: ${billData['dueDate'] != null ? formatTimestamp(billData['dueDate']) : 'N/A'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
