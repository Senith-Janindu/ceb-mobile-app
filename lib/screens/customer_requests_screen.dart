import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewRequest extends StatefulWidget {
  final String accountNumber;

  const NewRequest({super.key, required this.accountNumber});

  @override
  State<NewRequest> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  String? _selectedDistrict;

  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya'
  ];

  bool _isSubmitting = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDistrict != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final Timestamp now = Timestamp.now();
        final String documentId = '${widget.accountNumber}_${now.seconds}';

        await FirebaseFirestore.instance
            .collection('newRequests')
            .doc(documentId)
            .set({
          'accountNumber': widget.accountNumber,
          'name': _nameController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'address1': _address1Controller.text.trim(),
          'address2': _address2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'zipCode': _zipController.text.trim(),
          'district': _selectedDistrict,
          'submittedAt': now,
        });

        _showAlertDialog(
          "Success",
          "Request submitted successfully!",
          Icons.check_circle_outline,
          Colors.green,
          () => Navigator.of(context).pop(),
        );
      } catch (e) {
        _showAlertDialog(
          "Error",
          "Failed to submit request. Please try again.",
          Icons.error_outline,
          Colors.red,
          () => Navigator.of(context).pop(),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      _showAlertDialog(
        "Error",
        "Please fill all fields and select a district.",
        Icons.error_outline,
        Colors.red,
        () => Navigator.of(context).pop(),
      );
    }
  }

  void _showAlertDialog(String title, String message, IconData icon,
      Color iconColor, VoidCallback onPressed) {
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
              onPressed: onPressed,
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
              20,
              20,
              0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      "New Connection Request",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField("Name", _nameController),
                  SizedBox(height: 10),
                  _buildTextField("Telephone", _telephoneController),
                  SizedBox(height: 10),
                  _buildTextField("Address line 1", _address1Controller),
                  SizedBox(height: 10),
                  _buildTextField("Address line 2", _address2Controller),
                  SizedBox(height: 10),
                  _buildTextField("City", _cityController),
                  SizedBox(height: 10),
                  _buildTextField("Zip code", _zipController),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    hint: Text("Select District"),
                    items: _districts.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a district' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Color(0xFFFFD400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.black)
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
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
