import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final Function(File) onImageCaptured;

  CameraScreen({required this.onImageCaptured});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isInitialized = false;
  bool _isPreview = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    final image = await _cameraController.takePicture();
    setState(() {
      _capturedImage = image;
      _isPreview = true;
    });
  }

  void _retakeImage() {
    setState(() {
      _capturedImage = null;
      _isPreview = false;
    });
  }

  void _confirmImage() {
    if (_capturedImage != null) {
      widget.onImageCaptured(File(_capturedImage!.path));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Capture Meter Reading"),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Center(
            child: Container(
              width: 190,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
          if (_isPreview && _capturedImage != null)
            Positioned.fill(
              child: Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          if (_isPreview)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _retakeImage,
                    child: Text(
                      "Retake",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _confirmImage,
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: !_isPreview
          ? FloatingActionButton(
              backgroundColor: Color(0xFFFFD400),
              onPressed: _captureImage,
              child: Icon(Icons.camera),
            )
          : null,
    );
  }
}
