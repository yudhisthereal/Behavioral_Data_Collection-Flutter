import 'package:behavioral_data_collection/models/gesture_data.dart';
import 'package:behavioral_data_collection/screens/vertical_swipe_screen.dart';
import 'package:behavioral_data_collection/services/data_storage.dart';
import 'package:behavioral_data_collection/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HorizontalSwipeScreen extends StatefulWidget {
  const HorizontalSwipeScreen({super.key});

  @override
  HorizontalSwipeScreenState createState() => HorizontalSwipeScreenState();
}

class HorizontalSwipeScreenState extends State<HorizontalSwipeScreen> {
  final GestureSession gestureSession = GestureSession();
  final DataStorage dataStorage = DataStorage();
  int _currentImageIndex = 0;
  static const int lastId = 6;
  final List<String> _imagePaths = [
    'start_end',  // Placeholder for first item
    'assets/swipe_images/image1.jpg',
    'assets/swipe_images/image2.jpg',
    'assets/swipe_images/image3.jpg',
    'assets/swipe_images/image4.jpg',
    'assets/swipe_images/image5.jpg',
    'return', // Placeholder for last item
  ];
  final List<bool> _passed1State = List.generate(7, (_) => false);
  final List<bool> _passed2State = List.generate(7, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horizontal Swipe Gallery')),
      body: Column(
        children: [
          _buildProgressCircles(),
          _buildHorizontalCarousel(),
          if (_currentImageIndex == 0 && _allPassed()) _buildNextButton(),
        ],
      ),
    );
  }

  bool _allPassed() {
    return _passed2State.sublist(1, _passed2State.length - 1).every((e) => e);
  }

  Widget _buildProgressCircles() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          double distanceFromCenter = (index - _currentImageIndex).abs().toDouble();
          double opacity = 1.0 - (distanceFromCenter * 0.2).clamp(0.0, 0.7);  // Max opacity reduction

          return Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar(
                radius: _currentImageIndex == index ? 24 : 20,
                backgroundColor: _getCircleColor(index),
                child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalCarousel() {
    return Expanded(
      child: Listener(
        onPointerDown: (event) {
          gestureSession.startGesture(event.localPosition, event.pressure);
        },
        onPointerUp: (event) {
          gestureSession.endGesture(event.localPosition);
        },
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
              if (index != 0 && index != lastId) {
                if (!_passed1State[index]) {
                  _passed1State[index] = true;
                } else if (!_passed2State[index]) {
                  _passed2State[index] = true;
                }
              }
            });
          },
          itemCount: _imagePaths.length,
          itemBuilder: (context, index) {
            if (index == 0 || index == 6) {
              return _buildSwipeInstructions(index);
            } else {
              return _buildZoomableImage(_imagePaths[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSwipeInstructions(int index) {
    if (_allPassed()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Well done!",
              style: TextStyle(
                  fontSize: 32.0, fontWeight: FontWeight.normal,
              )
            ),
            Padding(padding: EdgeInsets.all(16)),
            Icon(
              Icons.check_box,
              color: AppColors.secondary,
              size: 72.0,
            )
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            index == 0 ? "Reach the end of the gallery!" : "Return to the first item!",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Image.asset(
            index == 0 ? 'assets/swipe_images/left.png' : 'assets/swipe_images/right.png',
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomableImage(String imagePath) {
    return Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.fitHeight,
        ),
    );
  }

  Color _getCircleColor(int index) {
    if (_passed1State[index] && !_passed2State[index]) return AppColors.lightGreen;
    if (_passed2State[index]) return AppColors.peach;
    return Colors.white;
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomButton(
          text: 'Next',
          bgColor: AppColors.primary,
          textColor: AppColors.onPrimary,
          onPressed: () => {
            dataStorage.saveHorizontalGestureData(gestureSession.toList()),
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const VerticalSwipeScreen())
            )
          }
      ),
    );
  }
}
