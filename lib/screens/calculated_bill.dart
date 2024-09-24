import 'dart:io';
import 'package:ceb_app/screens/bill_payment.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatedBill extends StatefulWidget {
  final String accountNumber;
  final String meterValue;
  final File image;
  final String readingForMonth;

  CalculatedBill({
    required this.accountNumber,
    required this.meterValue,
    required this.image,
    required this.readingForMonth,
  });

  @override
  _CalculatedBillState createState() => _CalculatedBillState();
}

class _CalculatedBillState extends State<CalculatedBill> {
  int? _previousReading;
  int? _currentReading;
  double? _monthlyCharge;
  double _fixedCharge = 150.0;
  double? _totalMonthlyBill;
  int? _monthlyUnits;

  //Below 60 units
  static const double? less_30_rate = 6.0;
  static const double? less_30_fixed = 100.0;

  static const double? between_31_60_rate = 9.0;
  static const double? between_31_60_fixed = 250.0;

  //Above 60 units
  static const double? first_60_rate = 15.0;
  static const double? first_60_fixed = 0.0;

  static const double? between_60_90_rate = 18.0;
  static const double? between_60_90_fixed = 400.0;

  static const double? between_90_120_rate = 30.0;
  static const double? between_90_120_fixed = 1000.0;

  static const double? between_120_180_rate = 42.0;
  static const double? between_120_180_fixed = 1500.0;

  static const double? more_than_180_rate = 65.0;
  static const double? more_than_180_fixed = 2000.0;

  @override
  void initState() {
    super.initState();
    _fetchPreviousReading();
  }

  Future<void> _fetchPreviousReading() async {
    try {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .collection('meterReadings');

      final previousMonth = DateFormat('yyyyMM').format(
        DateTime(
          int.parse(widget.readingForMonth.split('-')[0]),
          int.parse(widget.readingForMonth.split('-')[1]) - 1,
        ),
      );

      final snapshot = await collection.doc(previousMonth).get();

      if (snapshot.exists) {
        final previousReading = snapshot['endReading'];
        final currentReading = int.parse(widget.meterValue);
        final monthlyUnits = (currentReading - previousReading) as int;

        // Calculate the monthly charge based on the tariff rates
        double monthlyCharge = 0;
        if (monthlyUnits <= 30) {
          monthlyCharge = monthlyUnits * less_30_rate!;
          _fixedCharge = less_30_fixed!;
        } else if (monthlyUnits <= 60) {
          monthlyCharge =
              30 * less_30_rate! + ((monthlyUnits - 30) * between_31_60_rate!);
          _fixedCharge = between_31_60_fixed!;
        } else {
          _fixedCharge = first_60_fixed!;
          int remainingUnits = monthlyUnits;
          if (remainingUnits >= 60) {
            monthlyCharge += 60 * first_60_rate!;
            remainingUnits -= 60;
          }
          if (remainingUnits > 0) {
            int units = remainingUnits <= 30 ? remainingUnits : 30;
            monthlyCharge += units * between_60_90_rate!;
            _fixedCharge = between_60_90_fixed!;
            remainingUnits -= units;
          }
          if (remainingUnits > 0) {
            int units = remainingUnits <= 30 ? remainingUnits : 30;
            monthlyCharge += units * between_90_120_rate!;
            _fixedCharge = between_90_120_fixed!;
            remainingUnits -= units;
          }
          if (remainingUnits > 0) {
            int units = remainingUnits <= 60 ? remainingUnits : 60;
            monthlyCharge += units * between_120_180_rate!;
            _fixedCharge = between_120_180_fixed!;
            remainingUnits -= units;
          }
          if (remainingUnits > 0) {
            monthlyCharge += remainingUnits * more_than_180_rate!;
            _fixedCharge = more_than_180_fixed!;
          }
        }

        final totalMonthlyBill = monthlyCharge + _fixedCharge;

        setState(() {
          _previousReading = previousReading;
          _currentReading = currentReading;
          _monthlyUnits = monthlyUnits;
          _monthlyCharge = monthlyCharge;
          _totalMonthlyBill = totalMonthlyBill;
        });
      } else {
        setState(() {
          _previousReading = null;
        });
      }
    } catch (e) {
      print("Error fetching previous reading: $e");
    }
  }

  Future<void> _saveAndProceed() async {
    try {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .collection('meterReadings');

      final previousMonth = DateFormat('yyyyMM').format(
        DateTime(
          int.parse(widget.readingForMonth.split('-')[0]),
          int.parse(widget.readingForMonth.split('-')[1]),
        ),
      );

      await collection.doc(previousMonth).get().then((snapshot) async {
        DateTime readOn = snapshot['readOn'].toDate();
        DateTime dueDate = readOn.add(Duration(days: 60));

        // Update the document for the previous month
        await collection.doc(previousMonth).update({
          'units': _monthlyUnits,
          'endReading': int.parse(widget.meterValue),
          'readOn': Timestamp.fromDate(DateTime.now()),
          'monthlyBill': _monthlyCharge,
          'fixedCharge': _fixedCharge,
          'totalPayable': _totalMonthlyBill,
          'dueDate': Timestamp.fromDate(dueDate),
        });
        print("current month updated");
        // Calculate the next month
        final nextMonthDate = DateFormat('yyyyMM').format(
          DateTime(
            int.parse(widget.readingForMonth.split('-')[0]),
            int.parse(widget.readingForMonth.split('-')[1]) + 1,
          ),
        );

        print(nextMonthDate);
        // final nextMonth = DateFormat('yyyyMM').format(nextMonthDate);

        // Create a new document for the next month
        await collection.doc(nextMonthDate).set({
          'dueDate': Timestamp.fromDate(DateTime.now()),
          'fixedCharge': 0,
          'imagePath': widget.image.path,
          'monthlyBill': 0,
          'pastReading': int.parse(widget.meterValue),
          'readOn': Timestamp.fromDate(DateTime.now()),
          'endReading': 0,
          'totalPayable': 0,
          'units': 0,
        });

        // Fetch the current value of totalPayable from the user's document
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.accountNumber);
        final userSnapshot = await userDoc.get();
        final currentTotalPayable = userSnapshot['totalPayable'];
        final previousLastMonthBill = userSnapshot['lastMonthBill'];
        final previousOpeningBalance = userSnapshot['credit'];

        // Update the totalPayable field with the new value
        // final newTotalPayable = currentTotalPayable + _totalMonthlyBill!;
        await userDoc.update({
          // 'totalPayable': previousLastMonthBill + _totalMonthlyBill,
          'lastMonthBill': _totalMonthlyBill,
          'credit': previousOpeningBalance + previousLastMonthBill,
        });

        // Show success message and navigate to PastBillDetails screen
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text(
                  "Bill for the previous month is successfully saved!"),
              actions: [
                TextButton(
                  child: const Text("Pay"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BillPaymentScreen(
                              accountNumber: widget.accountNumber)),
                    );
                  },
                ),
                TextButton(
                  child: const Text("Back to Home"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(accountNumber: widget.accountNumber)),
                    );
                  },
                ),
              ],
            );
          },
        );
      });
    } catch (e) {
      print("Error saving and proceeding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD400),
        elevation: 0,
        title: const Text(
          "Calculated Bill",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Bill for ${widget.readingForMonth}",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 20),
                _monthlyCharge != null
                    ? Column(
                        children: [
                          Text(
                            "Previous Reading: $_previousReading kWh",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "New Reading: $_currentReading kWh",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "Monthly number of units: $_monthlyUnits",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Monthly charge: $_monthlyCharge.00",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Fixed charge: $_fixedCharge",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Total monthly bill: $_totalMonthlyBill.00",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _saveAndProceed,
                            child: const Text(
                              'Save and proceed',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
