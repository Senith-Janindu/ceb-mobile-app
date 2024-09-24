import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:ceb_app/screens/CameraScreen.dart';
import 'package:ceb_app/screens/about_screen.dart';
import 'package:ceb_app/screens/calculated_bill.dart';
import 'package:ceb_app/screens/signin_screen.dart';
import 'package:ceb_app/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class MeterReadingCapture extends StatefulWidget {
  final String accountNumber;

  MeterReadingCapture({required this.accountNumber});

  @override
  _MeterReadingCaptureState createState() => _MeterReadingCaptureState();
}

class _MeterReadingCaptureState extends State<MeterReadingCapture> {
  File? _image;
  String? _meterValue;
  bool _canReadMeter = false;
  String? _message;
  DateTime? _nextValidDate;
  String? _readingForMonth;
  String? _displayMonth;

  final TextRecognizer textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _checkLastMeterReading();
  }

  Future<void> _checkLastMeterReading() async {
    try {
      // Fetch the latest meter reading
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.accountNumber)
          .collection('meterReadings');

      final snapshot =
          await collection.orderBy('readOn', descending: true).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final latestReading = snapshot.docs.first;
        final lastReadDate = (latestReading['readOn'] as Timestamp).toDate();
        final daysSinceLastRead =
            DateTime.now().difference(lastReadDate).inDays;

        final now = DateTime.now();
        final previousMonth = now.subtract(
            const Duration(days: 31)); // Subtract one month (approximately)

        // Format the previous month with 'yyyy-MM' format
        _displayMonth = DateFormat('yyyy-MM').format(previousMonth);

        if (daysSinceLastRead >= 30) {
          setState(() {
            _canReadMeter = true;
            _readingForMonth = DateFormat('yyyy-MM').format(DateTime.now());
            print("Meter reading is allowed for $_readingForMonth.");
          });
        } else {
          final nextValidDate = lastReadDate.add(Duration(days: 30));
          setState(() {
            _canReadMeter = false;
            _nextValidDate = nextValidDate;
            _message =
                "More ${30 - daysSinceLastRead} days have to get next reading. You have to wait till ${DateFormat('dd/MM/yyyy').format(nextValidDate)}.";
            print(_message);
          });
        }
      } else {
        setState(() {
          _canReadMeter = false;
          _message = "No previous meter readings found.";
          print(_message);
        });
      }
    } catch (e) {
      setState(() {
        _canReadMeter = false;
        _message = "Error fetching meter readings: $e";
        print(_message);
      });
    }
  }

  void _onImageCaptured(File image) {
    setState(() {
      _image = image;
    });
    _cropAndAnalyzeImage(image);
  }

  Future<void> _cropAndAnalyzeImage(File image) async {
    // Read the image into bytes
    final bytes = await image.readAsBytes();
    final uiImage = await decodeImageFromList(bytes);

    // Define the ROI
    final roi = Rect.fromCenter(
      center: Offset(uiImage.width / 2, uiImage.height / 2),
      width: 190 * uiImage.width / MediaQuery.of(context).size.width,
      height: 50 * uiImage.height / MediaQuery.of(context).size.height,
    );

    // Convert to an image package image
    final imagePackage = img.decodeImage(bytes)!;

    // Crop the image based on the ROI
    final croppedImage = img.copyCrop(
      imagePackage,
      x: roi.left.toInt(),
      y: roi.top.toInt(),
      width: roi.width.toInt(),
      height: roi.height.toInt(),
    );

    // Convert the cropped image back to a File
    final croppedImageFile = File('${image.path}_cropped.png')
      ..writeAsBytesSync(img.encodePng(croppedImage));

    // Perform text recognition on the cropped image
    await _analyzeImage(croppedImageFile);
  }

  Future<void> _analyzeImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText += line.text + ' ';
      }
    }

    // Sanitize the extracted text to contain only digits
    String sanitizedText = extractedText.replaceAll(RegExp(r'\D'), '');

    setState(() {
      _meterValue = sanitizedText;
    });
  }

  void _proceedToBill() {
    if (_meterValue != null && _image != null && _readingForMonth != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CalculatedBill(
            accountNumber: widget.accountNumber,
            meterValue: _meterValue!,
            image: _image!,
            readingForMonth: _readingForMonth!,
          ),
        ),
      );
    }
  }

  void _retakeFalseReading() {
    _meterValue = null;
    _image = null;
    _readingForMonth = null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(onImageCaptured: _onImageCaptured),
      ),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_readingForMonth != null)
                  Text(
                    "Reading for $_displayMonth",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                SizedBox(height: 20),
                _image == null
                    ? Text(
                        "No image selected",
                        style: TextStyle(color: Colors.white),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 400,
                            child: Image.file(_image!),
                          ),
                          SizedBox(height: 20),
                          _meterValue != null
                              ? Text(
                                  "Meter Reading: $_meterValue kWh",
                                  style: TextStyle(color: Colors.white),
                                )
                              : CircularProgressIndicator(),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _proceedToBill,
                            child: const Text(
                              'Proceed to bill',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _retakeFalseReading,
                            child: const Text(
                              'Retake false reading',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Color(0xFFFFD400)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFFD400),
        onPressed: _canReadMeter
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CameraScreen(onImageCaptured: _onImageCaptured),
                  ),
                );
              }
            : null,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
