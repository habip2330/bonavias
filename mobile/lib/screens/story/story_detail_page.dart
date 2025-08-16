import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/story_service.dart';
import '../../models/story_model.dart';

class StoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryDetailPage({required this.story, Key? key}) : super(key: key);

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> with SingleTickerProviderStateMixin {
  List<StoryItem> _storyItems = [];
  int _currentContentIndex = 0;
  bool _loading = true;
  Timer? _timer;
  double _progress = 0.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _fetchStoryItems();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _nextContent();
        }
      });
    });
  }

  Future<void> _fetchStoryItems() async {
    setState(() {
      _loading = true;
      _currentContentIndex = 0;
      _progress = 0.0;
    });
    final storyId = widget.story['id'];
    try {
      final items = await StoryService.fetchStoryItems(storyId);
      setState(() {
        _storyItems = items;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _storyItems = [];
        _loading = false;
      });
      _startTimer();
    }
  }

  void _nextContent() {
    if (_currentContentIndex < _storyItems.length - 1) {
      setState(() {
        _currentContentIndex++;
        _progress = 0.0;
      });
      _startTimer();
    } else {
      if (!_isClosing) {
        _isClosing = true;
        _fadeController.forward();
      }
    }
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
        _progress = 0.0;
      });
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth / 2) {
              _previousContent();
            } else {
              _nextContent();
            }
          },
          child: Stack(
            children: [
              if (_loading)
                const Center(child: CircularProgressIndicator()),
              if (!_loading && _storyItems.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      // Story Image
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          _storyItems[_currentContentIndex].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).cardColor,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Theme.of(context).colorScheme.onBackground,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Story Content
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.story['title'] ?? '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _storyItems[_currentContentIndex].description,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Progress Bar
              if (!_loading && _storyItems.isNotEmpty)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: List.generate(
                      _storyItems.length,
                      (index) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: index == _currentContentIndex
                              ? LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onBackground),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              // Close Button
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onBackground,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 