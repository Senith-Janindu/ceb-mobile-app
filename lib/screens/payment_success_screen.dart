import 'package:flutter/material.dart';
import 'package:ceb_app/screens/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String accountNumber;

  const PaymentSuccessScreen(
      {required this.amount, Key? key, required this.accountNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD400),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          "Payment Success",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Payment Successful!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Amount Paid: LKR ${amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(accountNumber: accountNumber)),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Go to Home',
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
