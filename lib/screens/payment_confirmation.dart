import 'package:ceb_app/screens/bill_payment.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/screens/payment_success_screen.dart'; // Import the new screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final double amount;
  final String accountNumber;

  const PaymentConfirmationScreen(
      {required this.amount, Key? key, required this.accountNumber})
      : super(key: key);

  @override
  _PaymentConfirmationScreenState createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessing = false;

  void _confirmPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Fetch and update totalPayable and credit
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.accountNumber);
    final userSnapshot = await userDoc.get();
    final openingBalance = userSnapshot['credit'];
    final monthlyBill = userSnapshot['lastMonthBill'];
    final currentTotalPayable = openingBalance + monthlyBill;

    final newOpeningBalance = currentTotalPayable - widget.amount;
    await userDoc.update({
      'credit': newOpeningBalance,
      'lastMonthBill': 0,
    });

    setState(() {
      _isProcessing = false;
    });

    // Navigate to the PaymentSuccessScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
                amount: widget.amount,
                accountNumber: widget.accountNumber,
              )),
    );
  }

  void _cancelPayment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BillPaymentScreen(accountNumber: widget.accountNumber),
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
          "Ceylon Electricity Board",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Confirm the payment?",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                "\LKR${widget.amount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                onPressed: _isProcessing ? null : _confirmPayment,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Confirm payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                onPressed: _cancelPayment,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
