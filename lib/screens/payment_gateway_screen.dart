import 'package:ceb_app/screens/bill_payment.dart';
import 'package:ceb_app/screens/home_screen.dart';
import 'package:ceb_app/screens/payment_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final double amount;
  final String accountNumber;

  const PaymentGatewayScreen(
      {required this.amount, Key? key, required this.accountNumber})
      : super(key: key);

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expirationController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isPaying = false;
  String _selectedCardType = 'visa';
  String? _expirationError;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toString();
  }

  void _navigateToConfirmationScreen() {
    if (_validateExpirationDate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(
            amount: widget.amount,
            accountNumber: widget.accountNumber,
          ),
        ),
      );
    }
  }

  bool _validateExpirationDate() {
    final input = _expirationController.text;
    final now = DateTime.now();

    if (input.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(input)) {
      setState(() {
        _expirationError = 'Invalid date format.';
      });
      return false;
    }

    final parts = input.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');

    if (month == null || year == null || month < 1 || month > 12) {
      setState(() {
        _expirationError = 'Invalid month';
      });
      return false;
    }

    if (year < now.year || (year == now.year && month < now.month)) {
      setState(() {
        _expirationError = 'Card has expired';
      });
      return false;
    }

    if (year > now.year + 5) {
      setState(() {
        _expirationError = 'Invalid year';
      });
      return false;
    }

    setState(() {
      _expirationError = null;
    });
    return true;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                  enabled: false, // Disable editing
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              Text(
                'Card type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildCardTypeOption('visa', 'assets/images/visa.png'),
                  _buildCardTypeOption(
                      'mastercard', 'assets/images/mastercard.png'),
                  _buildCardTypeOption('amex', 'assets/images/amex.png'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Name on card',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.all(8),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Card number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.all(8),
                  hintText: 'xxxx xxxx xxxx xxxx',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter(),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiration',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _expirationController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: EdgeInsets.all(8),
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(),
                            errorText: _expirationError,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpirationDateInputFormatter(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: EdgeInsets.all(8),
                            hintText: 'xxx',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD400),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isPaying ? null : _navigateToConfirmationScreen,
                child: _isPaying
                    ? CircularProgressIndicator(color: Colors.black)
                    : Center(
                        child: Text(
                        'Pay now',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeOption(String type, String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardType = type;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedCardType == type
                ? Color(0xFFFFD400)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Image.asset(
          assetPath,
          width: 40,
          height: 25,
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text =
        newValue.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digits

    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    List<String> groups = [];
    for (var i = 0; i < text.length; i += 4) {
      groups.add(text.substring(i, i + 4 <= text.length ? i + 4 : text.length));
    }

    final formatted = groups.join(' ');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpirationDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    if (text.length >= 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
