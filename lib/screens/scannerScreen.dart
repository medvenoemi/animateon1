import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() => runApp(ScannerApp());

class ScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner App',
      home: ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    _scanImage(); // Indítja a szkennelést az alkalmazás betöltésekor
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _scanImage() async {
    if (!_isCameraInitialized || !_cameraController!.value.isInitialized) {
      print('Camera is not initialized.');
      return;
    }

    final XFile image = await _cameraController!.takePicture();

    if (image != null) {
      // TODO: Add image processing logic here to simulate image scanning
      // For example, you can apply filters or adjust the perspective.

      // Delay the image display for 2 seconds (adjust the duration as needed)
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: Stack(
        children: [
          Center(
            child: _imageFile != null
                ? Image.file(
                    _imageFile!,
                    width: 300,
                    height: 300,
                  )
                : _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}