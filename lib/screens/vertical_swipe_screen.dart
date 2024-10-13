import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/custom_button.dart';
import 'end_screen.dart';

class VerticalSwipeScreen extends StatefulWidget {
  const VerticalSwipeScreen({super.key});

  @override
  VerticalSwipeScreenState createState() => VerticalSwipeScreenState();
}

class VerticalSwipeScreenState extends State<VerticalSwipeScreen> {
  int _currentImageIndex = 0;
  static const int lastId = 6;
  final List<String> _imagePaths = [
    'start_end',
    'assets/swipe_images/image6.jpg',
    'assets/swipe_images/image7.jpg',
    'assets/swipe_images/image8.jpg',
    'assets/swipe_images/image9.jpg',
    'assets/swipe_images/image10.jpg',
    'return',
  ];
  final List<bool> _passed1State = List.generate(7, (_) => false);
  final List<bool> _passed2State = List.generate(7, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vertical Swipe Gallery')),
      body: Row(
        children: [
          _buildProgressCircles(),
          _buildVerticalCarousel(),
        ],
      ),
    );
  }

  bool _allPassed() {
    return _passed2State.sublist(1, _passed2State.length - 1).every((e) => e);
  }

  Widget _buildProgressCircles() {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          double distanceFromCenter = (index - _currentImageIndex).abs().toDouble();
          double opacity = 1.0 - (distanceFromCenter * 0.2).clamp(0.0, 0.7);  // Max opacity reduction

          return Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
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

  Widget _buildVerticalCarousel() {
    return Expanded(
      child: PageView.builder(
        scrollDirection: Axis.vertical,
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
          if (index == 0 || index == lastId) {
            return _buildSwipeInstructions(index);
          } else {
            return _buildZoomableImage(_imagePaths[index]);
          }
        },
      ),
    );
  }

  Widget _buildSwipeInstructions(int index) {
    if (_allPassed() && index == 0) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                  "All done!",
                  style: TextStyle(
                    fontSize: 32.0, fontWeight: FontWeight.normal,
                  )
              ),
              const Padding(padding: EdgeInsets.all(16)),
              const Icon(
                Icons.check_box,
                color: AppColors.secondary,
                size: 72.0,
              ),
              const Spacer(),
              _buildFinishButton()
            ],
          )
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
            index == 0 ? 'assets/swipe_images/up.png' : 'assets/swipe_images/down.png',
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomableImage(String imagePath) {
    return GestureDetector(
      onScaleUpdate: (details) {
        // Handle image zoom
      },
      child: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Color _getCircleColor(int index) {
    if (_passed1State[index] && !_passed2State[index]) return AppColors.lightGreen;
    if (_passed2State[index]) return AppColors.peach;
    return Colors.white;
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomButton(
          text: 'Finish!',
          bgColor: AppColors.primary,
          textColor: AppColors.onPrimary,
          onPressed: () => {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const EndScreen())
            )
          }
      ),
    );
  }
}
