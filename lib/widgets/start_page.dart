import 'package:flutter/material.dart';
import 'package:treering/widgets/mood_wheel.dart';
import 'package:treering/widgets/scaffold_with_nav.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _interacted = false;
  bool _showPrompt = false;
  bool _showButton = false;
  bool _showScaffold = false;
  bool _startTransition = false; 
  int _moodValue = 0;

  void _onUserInteraction([_]) {
    if (_interacted) return;

    setState(() => _interacted = true);

    // Fade in text immediately
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showPrompt = true);
    });

    // Show save button after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showButton = true);
    });

    // Show ScaffoldWithNav (header + nav) after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showScaffold = true);
    });
    
    // Navigate to HomePage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _startTransition = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/start_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          //  Green overlay that fades in
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            color: _startTransition
                ? const Color(0xFF2E4C2F).withOpacity(0.85)
                : Colors.transparent,
          ),

          //  Foreground content — your prompt, mood wheel, and save button
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _onUserInteraction,
              onPanUpdate: _onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _showPrompt ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: const Text(
                      'How was the day...',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),

                  MoodWheel(
                    interacted: _interacted,
                    onInteracted: _onUserInteraction,
                    value: _moodValue,
                    onChanged: (v) => setState(() => _moodValue = v),
                  ),
                  const SizedBox(height: 30),

                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text(
                        'save',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}