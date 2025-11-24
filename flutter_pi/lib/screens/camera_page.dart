import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../components/sockets/socket_services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late SocketService socketService;
  Uint8List? currentFrame;
  bool isConnected = false;
  int frameCount = 0;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    socketService.initSocketConnection(
      serverUrl: 'http://127.0.0.1:5000',
      onSpeedUpdate: (newSpeed) {}, 
      onGpsUpdate: (lat, lon) {}, 
      onCameraFrame: (imageBytes) {
        setState(() {
          currentFrame = imageBytes;
          frameCount++;
          isConnected = true;
        });
      },
    );
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ROS2 Camera Stream'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Frames: $frameCount',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera feed display
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepPurple.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: currentFrame != null
                      ? Image.memory(
                          currentFrame!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,  // Prevents flicker
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.deepPurple.shade300,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Waiting for camera feed...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Camera info card
            Card(
              color: Colors.deepPurple.shade300,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Topic',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '/camera/image_raw',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.photo_size_select_large, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Resolution',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '1280x720',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.speed, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Frame Rate',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '30 FPS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
