import 'package:flutter/material.dart';
import 'package:treering/widgets/mood_wheel.dart';
import 'package:treering/screens/home_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  bool _interacted = false;
  bool _showPrompt = false;
  bool _showButton = false;
  int _moodValue = 0;

  late AnimationController _controller;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _bgColor = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.transparent, end: Colors.black),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.black, end: const Color(0xFF004D40)), // or Dark green 0xFF004D40
          weight: 50,
        ),
      ],
    ).animate(_controller);
  }



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

    // Show ScaffoldWithNav (header + nav) + background animation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        //setState(() => _showScaffold = true);
        _controller.forward(); // start background transition 1
      }
    });

    // Navigate when animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        //Navigator.pushNamed(context, '/');
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(initialMood: _moodValue))); 
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  1. Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/start_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Animated overlay (image → black → dark green)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgColor,
              builder: (context, child) {
                return Container(color: _bgColor.value);
              },
            ),
          ),

          //  Foreground content: prompt, mood wheel, and save button
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
                        //Navigator.pushNamed(context, '/');
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(initialMood: _moodValue)));
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