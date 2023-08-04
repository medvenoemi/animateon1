import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ScannerApp());
}

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
  String? _imagePath;
  List<Uint8List> descriptors = [];
  Timer? _timer; // Timer for half-second processing

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

    if (!mounted || _cameraController == null) return;

    setState(() {
      _isCameraInitialized = true;
    });

    await _generateDescriptors(); // Generate descriptors from local images

    // Start the timer, which calls the _scanImage method every half-second
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _scanImage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when leaving the screen
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _generateDescriptors() async {
    final List<String> imageFiles = [
      'lib/images/image1.jpg',
      'lib/images/image2.jpg',
      // Add more image file paths if you have more images in the folder
    ];

    for (var imagePath in imageFiles) {
      final bytes = await _getImageBytesFromPath(imagePath);
      if (bytes != null) {
        final descriptor = _generateDescriptor(bytes);
        descriptors.add(descriptor);
      }
    }
  }

  Future<Uint8List?> _getImageBytesFromPath(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }

  Uint8List _generateDescriptor(Uint8List bytes) {
    final image = imglib.decodeImage(bytes)!;
    final resizedImage = imglib.copyResize(image, width: 8, height: 8);
    final grayscaleImage = imglib.grayscale(resizedImage);

    // Calculate the histogram from the pixel values
    final histogram = List<int>.filled(256, 0);
    for (int y = 0; y < grayscaleImage.height; y++) {
      for (int x = 0; x < grayscaleImage.width; x++) {
        final pixel = grayscaleImage.getPixel(x, y);
        final luminance = 0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
        final pixelValue = (luminance * 255).toInt();
        histogram[pixelValue]++; // Increment histogram for the corresponding pixel value
      }
    }

    // Create the descriptor based on the histogram
    final descriptor = Uint8List(256);
    for (int i = 0; i < histogram.length; i++) {
      descriptor[i] = histogram[i].clamp(0, 255).toInt(); // Clamp values between 0 and 255, then convert to int
    }

    return descriptor;
  }

  Future<void> _scanImage() async {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera is not initialized.');
      return;
    }

    final String? imagePath = (await _cameraController!.takePicture())?.path;

    if (imagePath != null) {
      final frameDescriptor = _generateDescriptor(await File(imagePath).readAsBytes());
      _compareDescriptors(frameDescriptor);

      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  void _compareDescriptors(Uint8List frameDescriptor) {
    // Example: Compare the captured frame with the previously generated descriptors
    for (var descriptor in descriptors) {
      final diff = _calculateDifference(frameDescriptor, descriptor);
      print('Difference: $diff');
    }
  }

  int _calculateDifference(Uint8List descriptor1, Uint8List descriptor2) {
    int diff = 0;
    for (int i = 0; i < descriptor1.length; i++) {
      diff += (descriptor1[i] - descriptor2[i]).abs();
    }
    return diff;
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
            child: _imagePath != null
                ? Image.file(
                    File(_imagePath!),
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
