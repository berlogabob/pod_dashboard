import 'dart:async'; // ← Added for StreamSubscription

import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../painters/gesture_painter.dart';
import '../painters/landmark_painter.dart';
import '../utils/constants.dart';
import '../utils/gesture_recognizer.dart';
import '../utils/transform_utils.dart';
import '../widgets/status_overlay.dart';
import '../widgets/detection_controls.dart';
import '../models/gesture_status.dart';

class CameraHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final DatabaseReference clawPodRef;

  const CameraHomePage({
    super.key,
    required this.cameras,
    required this.clawPodRef,
  });

  @override
  State<CameraHomePage> createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  CameraController? _controller;
  HandLandmarkerPlugin? _landmarker;

  bool _isDetecting = false;
  GestureStatus _status = GestureStatus.empty;
  int _stableCount = 0;
  double _gestureX = 0;
  double _gestureY = 0;
  List<Landmark> _currentLandmarks = [];

  int _transformMode = 3;
  int _frameSkip = 0;

  StreamSubscription<NativeDeviceOrientation>? _orientationSub;

  int _imageRotation = 0; // ← Added missing field

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startOrientationListener();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    final frontCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium,
        enableAudio: false);
    await _controller!.initialize();

    _imageRotation = _controller!.description.sensorOrientation;

    _landmarker = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.5,
      delegate: HandLandmarkerDelegate.cpu,
    );

    if (mounted) setState(() {});
  }

  void _startOrientationListener() {
    _orientationSub = NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((orientation) {
      _updateTransformMode(orientation);

      if (_controller != null) {
        int sensorOri = _controller!.description.sensorOrientation;
        switch (orientation) {
          case NativeDeviceOrientation.portraitUp:
            _imageRotation = sensorOri;
            break;
          case NativeDeviceOrientation.portraitDown:
            _imageRotation = (sensorOri + 180) % 360;
            break;
          case NativeDeviceOrientation.landscapeLeft:
            _imageRotation = (sensorOri + 90) % 360;
            break;
          case NativeDeviceOrientation.landscapeRight:
            _imageRotation = (sensorOri + 270) % 360;
            break;
          default:
            _imageRotation = sensorOri;
        }
      }
    });
  }

  void _updateTransformMode(NativeDeviceOrientation? orientation) {
    if (orientation == null) return;
    setState(() {
      switch (orientation) {
        case NativeDeviceOrientation.landscapeLeft:
          _transformMode = 1;
          break;
        case NativeDeviceOrientation.landscapeRight:
          _transformMode = 2;
          break;
        case NativeDeviceOrientation.portraitDown:
          _transformMode = 3;
          break;
        default:
          _transformMode = 0;
      }
    });
  }

  Future<void> _toggleDetection() async {
    setState(() {
      _isDetecting = !_isDetecting;
      _status = GestureStatus.empty;
      _stableCount = 0;
      _currentLandmarks = [];
    });

    if (_isDetecting) {
      await _controller!.startImageStream(_processImage);
    } else {
      await _controller!.stopImageStream();
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_frameSkip < AppConstants.frameSkipCount) {
      _frameSkip++;
      return;
    }
    _frameSkip = 0;

    final List<Hand> hands = _landmarker!.detect(image, _imageRotation);

    if (hands.isEmpty) {
      if (mounted) {
        setState(() {
          _status = GestureStatus.empty;
          _stableCount = 0;
          _currentLandmarks = [];
        });
      }
      return;
    }

    final List<Landmark> landmarks = hands.first.landmarks;

    final recognizer = GestureRecognizer();
    final detected = recognizer.recognize(landmarks, _transformMode);

    double newGestureX = _gestureX;
    double newGestureY = _gestureY;

    if (detected != _status) {
      _stableCount = 0;
      if (landmarks.isNotEmpty) {
        newGestureX = landmarks[0].x * MediaQuery.of(context).size.width;
        newGestureY = landmarks[0].y * MediaQuery.of(context).size.height +
            AppConstants.gestureYOffset;
      }
    } else {
      _stableCount++;
      if (_stableCount >= AppConstants.requiredStableFrames) {
        _triggerGesture(detected);
      }
    }

    if (mounted) {
      setState(() {
        _status = detected;
        _currentLandmarks = landmarks;
        _gestureX = newGestureX;
        _gestureY = newGestureY;
      });
    }
  }

  void _triggerGesture(GestureStatus gesture) {
    if (gesture == GestureStatus.thumbsUp) {
      widget.clawPodRef.child('lock_state').set(3); // Open
    } else if (gesture == GestureStatus.thumbsDown) {
      widget.clawPodRef.child('lock_state').set(1); // Close
    }
    // OK gesture does nothing
  }

  @override
  void dispose() {
    _orientationSub?.cancel();
    _controller?.dispose();
    _landmarker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
          if (_currentLandmarks.isNotEmpty)
            CustomPaint(
              painter: LandmarkPainter(
                _currentLandmarks,
                MediaQuery.of(context).size,
                _controller!.description.sensorOrientation,
                _transformMode,
              ),
              child: const SizedBox.expand(),
            ),
          Center(child: StatusOverlay(_status)),
          if (_status == GestureStatus.thumbsUp ||
              _status == GestureStatus.thumbsDown)
            CustomPaint(
              painter: GesturePainter(
                _status == GestureStatus.thumbsUp ? '👍' : '👎',
                _gestureX,
                _gestureY,
                _status == GestureStatus.thumbsUp ? Colors.green : Colors.red,
              ),
              child: const SizedBox.expand(),
            ),
          DetectionControls(
            isDetecting: _isDetecting,
            onToggle: _toggleDetection,
          ),
        ],
      ),
    );
  }
}
