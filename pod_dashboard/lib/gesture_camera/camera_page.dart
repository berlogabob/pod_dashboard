import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:firebase_database/firebase_database.dart';

import 'gesture_painter.dart';
import 'landmark_painter.dart';
import 'gesture_recognizer.dart';
import 'transform_utils.dart';
import 'constants.dart';
import 'status_overlay.dart';
import 'detection_controls.dart';
import 'gesture_status.dart';

class CameraHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final DatabaseReference? clawPodRef;

  const CameraHomePage({
    super.key,
    required this.cameras,
    this.clawPodRef,
  });

  @override
  State<CameraHomePage> createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  CameraController? _controller;
  HandLandmarkerPlugin? _landmarker;

  bool _isDetecting = false;
  bool _processing = false;

  GestureStatus _status = GestureStatus.empty;
  int _stableCount = 0;
  double _gestureX = 0;
  double _gestureY = 0;
  List<Landmark> _currentLandmarks = [];

  int _transformMode = 3;
  int _frameSkip = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startOrientationListener();
  }

  Future<void> _initializeCamera() async {
    final frontCamera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);

    await _controller!.initialize();

    _landmarker = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.5,
      delegate: HandLandmarkerDelegate.gpu,
    );

    if (mounted) setState(() {});
  }

  void _startOrientationListener() {
    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((event) {
      switch (event) {
        case NativeDeviceOrientation.portraitUp:
          _transformMode = 3;
          break;
        case NativeDeviceOrientation.portraitDown:
          _transformMode = 1;
          break;
        case NativeDeviceOrientation.landscapeLeft:
          _transformMode = 2;
          break;
        case NativeDeviceOrientation.landscapeRight:
          _transformMode = 0;
          break;
        default:
          _transformMode = 3;
      }
      if (mounted) setState(() {});
    });
  }

  void _toggleDetection() {
    setState(() {
      _isDetecting = !_isDetecting;
      if (!_isDetecting) {
        _status = GestureStatus.empty;
        _stableCount = 0;
        _currentLandmarks = [];
      }
    });
    if (_isDetecting) {
      _controller!.startImageStream(_processImage);
    } else {
      _controller!.stopImageStream();
    }
  }

  void _processImage(CameraImage image) {
    if (!_isDetecting || _landmarker == null || _processing || _frameSkip++ % AppConstants.frameSkipCount != 0) return;

    _processing = true;

    final int sensorOrientation = _controller!.description.sensorOrientation;
    final List<dynamic> result = _landmarker!.detect(image, sensorOrientation);

    if (result.isEmpty) {
      if (mounted) {
        setState(() {
          _status = GestureStatus.empty;
          _stableCount = 0;
          _currentLandmarks = [];
        });
      }
      _processing = false;
      return;
    }

    final landmarks = result[0].landmarks as List<Landmark>;

    if (mounted) {
      setState(() {
        _currentLandmarks = landmarks;
      });
    }

    final recognizer = GestureRecognizer();
    final detectedGesture = recognizer.recognize(landmarks, _transformMode);

    print('Detected gesture: $detectedGesture');

    if (detectedGesture == GestureStatus.warmup) {
      if (mounted) {
        setState(() {
          _status = GestureStatus.warmup;
          _stableCount = 0;
        });
      }
      _processing = false;
      return;
    }

    if (detectedGesture == _status) {
      _stableCount++;
    } else {
      _stableCount = 1;
    }

    print('Stable count: $_stableCount / 1');  // TEMP: 1 for immediate emoji

    if (_stableCount >= 1) {  // TEMP: changed to 1 for immediate feedback
      print('STABLE GESTURE CONFIRMED: $detectedGesture');

      if (mounted) {
        setState(() {
          _status = detectedGesture;
          final handCenter = landmarks[0];
          _gestureX = handCenter.x * MediaQuery.of(context).size.width;
          _gestureY = handCenter.y * MediaQuery.of(context).size.height + AppConstants.gestureYOffset;
        });
      }

      // Firebase control
      if (detectedGesture == GestureStatus.thumbsUp && widget.clawPodRef != null) {
        widget.clawPodRef!.child('lock_state').set(3);
        print('Firebase: unlock (3)');
      } else if (detectedGesture == GestureStatus.thumbsDown && widget.clawPodRef != null) {
        widget.clawPodRef!.child('lock_state').set(1);
        print('Firebase: lock (1)');
      }
    }

    _processing = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _landmarker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),

          if (_isDetecting && _currentLandmarks.isNotEmpty)
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

          // DEBUG TEXT OVERLAY
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                'Status: $_status\nStable: $_stableCount',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          if (_status == GestureStatus.thumbsUp ||
              _status == GestureStatus.thumbsDown ||
              _status == GestureStatus.ok)
            CustomPaint(
              painter: GesturePainter(
                _status == GestureStatus.thumbsUp
                    ? '👍'
                    : _status == GestureStatus.thumbsDown
                        ? '👎'
                        : '👌',
                _gestureX,
                _gestureY,
                _status == GestureStatus.thumbsUp || _status == GestureStatus.ok
                    ? Colors.green
                    : Colors.red,
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