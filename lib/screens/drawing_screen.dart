import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/custom_button.dart';
import '../theme/colors.dart';
import '../theme/custom_icons.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  DrawingScreenState createState() => DrawingScreenState();
}

class DrawingScreenState extends State<DrawingScreen> {
  Color _selectedColor = Colors.black; // Default color
  bool _isCanvasBlank = true; // Tracks if the canvas is blank
  bool _isBrushSelected = true; // Initially, brush is selected

  // Access to the canvas state
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();

  void _onCanvasChanged(bool isBlank) {
    setState(() {
      _isCanvasBlank = isBlank;
    });
  }

  void _selectTool(bool isBrush) {
    setState(() {
      _isBrushSelected = isBrush;
    });
  }

  void _undoAction() {
    _canvasKey.currentState?.undo(); // Call the undo method from DrawingCanvas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 64.0, horizontal: 16.0),
            child: Text(
              "Please draw your signature here!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible( // Changed from Expanded to Flexible
            child: DrawingCanvas(
              key: _canvasKey, // Assigning the key to access DrawingCanvas state
              selectedColor: _selectedColor,
              isBrushSelected: _isBrushSelected,
              onCanvasChanged: _onCanvasChanged,
              isEraserSelected: !_isBrushSelected,
            ),
          ),
          SafeArea( // Wrap toolbar in SafeArea to avoid overlapping with system UI
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16.0),
                      GestureDetector(
                        onTap: () => setState(() => _selectedColor = Colors.black),
                        child: _buildColorCircle(Colors.black),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () => setState(() => _selectedColor = Colors.red),
                        child: _buildColorCircle(Colors.red),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () => setState(() => _selectedColor = const Color(0xFF1700A2)),
                        child: _buildColorCircle(const Color(0xFF1700A2)),
                      ),
                      const Spacer(),
                      _buildToolButton(
                        icon: CustomIcons.undo, // Undo button
                        isSelected: false,
                        onPressed: _undoAction, // Calls undo action
                      ),
                      const SizedBox(width: 8.0),
                      _buildToolButton(
                        icon: CustomIcons.eraser,
                        isSelected: !_isBrushSelected,
                        onPressed: () => _selectTool(false),
                      ),
                      const SizedBox(width: 8.0),
                      _buildToolButton(
                        icon: CustomIcons.paintBrush,
                        isSelected: _isBrushSelected,
                        onPressed: () => _selectTool(true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      if (!_isCanvasBlank) {
                        // Navigate to the next screen
                      }
                    },
                    bgColor: _isCanvasBlank ? AppColors.lightGray : AppColors.primary,
                    textColor: _isCanvasBlank ? AppColors.black : AppColors.onPrimary,
                    isEnabled: !_isCanvasBlank,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildToolButton({required IconData icon, required bool isSelected, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.lightGreen : AppColors.lightGray,
        ),
        child: Icon(icon, color: AppColors.black),
      ),
    );
  }
}
