    import 'package:flutter/material.dart';
    import 'dart:math';
    import 'dart:async'; // Import for Timer
    import '../theme/colors.dart';

    class CardSwipeScreen extends StatefulWidget {
      const CardSwipeScreen({super.key});

      @override
      CardSwipeScreenState createState() => CardSwipeScreenState();
    }

    class CardSwipeScreenState extends State<CardSwipeScreen> with SingleTickerProviderStateMixin {
      List<bool> passedCircles = List.generate(8, (_) => false);
      bool isAnimating = false;
      double cardRotation = -0.05; // Initial card rotation
      double cardOffsetX = 0.0; // X position offset for the card
      double cardOffsetY = 0.0; // Y position offset for the card

      // Define a list of arrow rotations (in degrees)
      List<double> arrowRotations = [
        270.0, // Arrow pointing down (0 degrees originally)
        315.0, // Arrow pointing diagonally down-right
        0.0,   // Arrow pointing to the right (90 degrees originally)
        45.0,  // Arrow pointing diagonally up-right
        90.0,  // Arrow pointing up (180 degrees originally)
        135.0, // Arrow pointing diagonally up-left
        180.0, // Arrow pointing to the left (270 degrees originally)
        225.0  // Arrow pointing diagonally down-left
      ];

      int currentArrowIndex = 0; // Index of the current arrow rotation
      late double arrowRotation; // Current arrow rotation
      double? gestureAngle; // Store the gesture angle
      Offset? gestureStart; // Store gesture start position
      Offset? gestureEnd; // Store gesture end position
      late AnimationController _controller;
      double thresholdAngle = 60.0; // Acceptable angle delta in degrees

      @override
      void initState() {
        super.initState();
        arrowRotation = arrowRotations[currentArrowIndex]; // Set initial arrow rotation
        _controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        );
      }

      void _onPanStart(DragStartDetails details) {
        // Store the starting position of the gesture
        gestureStart = details.localPosition;
      }

      void _onPanUpdate(DragUpdateDetails details) {
        // Update the ending position of the gesture
        setState(() {
          gestureEnd = details.localPosition;
        });
      }

      void _onPanEnd(DragEndDetails details) {
        // Calculate the swipe angle using the start and end positions
        if (gestureStart != null && gestureEnd != null) {
          double swipeAngle = _getSwipeAngle(gestureStart!, gestureEnd!);

          // Determine the direction of the arrow based on the current circle index
          int arrowIndex = passedCircles.indexOf(false);
          if (arrowIndex == -1) return; // All circles passed

          // Calculate expected direction of arrow based on the arrow index
          double arrowAngle = arrowRotations[arrowIndex]; // Get the angle from the list

          // Check if swipe angle matches the arrow direction within the threshold
          if (_isSwipeAngleAcceptable(swipeAngle, arrowAngle)) {
            _animateCardAndUpdateCircleStatus(arrowAngle);
          }

          // Store the gesture angle for display
          gestureAngle = swipeAngle;

          // Clear gesture line after a short delay
          Timer(const Duration(milliseconds: 500), () {
            setState(() {
              gestureEnd = null; // Clear the gesture line
            });
          });
        }
      }

      double _getSwipeAngle(Offset start, Offset end) {
        // Calculate the angle using atan2 based on the start and end points
        double angle = atan2(end.dy - start.dy, end.dx - start.dx) * (180 / pi);

        // Adjust the angle so that 0 degrees is pointing down
        angle = (angle + 270) % 360;

        return angle;
      }

      bool _isSwipeAngleAcceptable(double swipeAngle, double arrowAngle) {
        // Handle wrapping from 360 to 0 degrees
        double angleDifference = (swipeAngle - arrowAngle).abs();
        if (angleDifference > 180) {
          angleDifference = 360 - angleDifference; // Account for wrap around
        }
        return angleDifference <= thresholdAngle; // Check if within the threshold
      }

      void _showFinishScreen() {
        setState(() {
          isAnimating = true;
        });
      }

      void _updateCircleStatus(double arrowAngle) {
        setState(() {
          int nextPendingIndex = passedCircles.indexOf(false);
          if (nextPendingIndex != -1) {
            passedCircles[nextPendingIndex] = true;
            _rotateArrow();
          }

          if (passedCircles.every((circle) => circle)) {
            _showFinishScreen();
          }
        });
      }

      void _animateCardAndUpdateCircleStatus(double arrowAngle) {
        // Calculate the translation offsets based on the arrow angle
        double radians = (arrowAngle + 90) * (pi / 180);
        double distance = 100; // Distance to move the card

        // Set the end position based on the arrow angle
        final endX = cardOffsetX + distance * cos(radians);
        final endY = cardOffsetY + distance * sin(radians);

        // Create a Tween for the animation
        Tween<Offset> tween = Tween<Offset>(
          begin: Offset(cardOffsetX, cardOffsetY),
          end: Offset(endX, endY),
        );

        // Create a CurvedAnimation for ease-out effect
        final curvedAnimation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        );

        // Attach listener before starting the animation
        _controller.addListener(() {
          // Update the card's position using the Tween and the CurvedAnimation
          setState(() {
            final animatedValue = tween.transform(curvedAnimation.value);
            cardOffsetX = animatedValue.dx;
            cardOffsetY = animatedValue.dy;
          });
        });

        // Start the animation
        _controller.forward().then((_) {
          // Use Future.delayed to reset the card's position after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              // Reset card position after the delay
              cardOffsetX = 0.0;
              cardOffsetY = 0.0;
            });
          });

          // Now update circle status
          _updateCircleStatus(arrowAngle);

          // Reset the animation controller for the next use
          _controller.reset();
        });
      }



      void _rotateArrow() {
        // Update the arrow index and ensure it wraps around
        currentArrowIndex = (currentArrowIndex + 1) % arrowRotations.length;
        arrowRotation = arrowRotations[currentArrowIndex];
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 50),
              // Text "Swipe the Card"
              const Text(
                'Swipe the Card',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              // Line separator
              const Divider(
                color: AppColors.primary,
                thickness: 2,
              ),
              const SizedBox(height: 20),
              // Circle numbers (flex layout)
              Flexible(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: List.generate(8, (index) {
                    bool passed = passedCircles[index];
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.black,
                          width: 2,
                        ),
                        color: passed ? AppColors.lightGreen : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              // Swipe container
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isAnimating) ...[
                          // Arrow indicators using the image with rotation and offset
                          Transform.translate(
                            offset: Offset(
                              100 * cos((arrowRotation + 90) * (pi / 180)), // Offset X based on rotation
                              100 * sin((arrowRotation + 90) * (pi / 180)), // Offset Y based on rotation
                            ),
                            child: Transform.rotate(
                              angle: arrowRotation * (pi / 180), // Convert degrees to radians
                              child: Image.asset(
                                'assets/arrow.png',
                                width: 48, // Set a suitable size for the arrows
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                        // Card image with rotation and translation (above the arrow)
                        Transform.translate(
                          offset: Offset(cardOffsetX, cardOffsetY), // Translate card
                          child: Transform.rotate(
                            angle: cardRotation,
                            child: Image.asset(
                              'assets/card.png', // Replace with your card image asset path
                              width: 64,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (passedCircles.every((circle) => circle))
              // Finish text and stop button
                Column(
                  children: [
                    const Text(
                      "You've finished the game!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        // Navigate to end screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EndScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: const BorderSide(color: AppColors.black, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Stop'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }

      @override
      void dispose() {
        _controller.dispose();
        super.dispose();
      }
    }

    class EndScreen extends StatelessWidget {
      const EndScreen({super.key});

      @override
      Widget build(BuildContext context) {
        return const Scaffold(
          body: Center(
            child: Text(
              'End Screen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }
    }
