import 'package:flutter/material.dart';
import 'dart:async';

class StoryViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialStoryIndex;
  final int initialContentIndex;

  const StoryViewerPage({
    Key? key,
    required this.stories,
    required this.initialStoryIndex,
    this.initialContentIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  
  int _currentStoryIndex = 0;
  int _currentContentIndex = 0;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialStoryIndex;
    _currentContentIndex = widget.initialContentIndex;
    
    _pageController = PageController(initialPage: _currentStoryIndex);
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _startProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startProgress() {
    if (_currentStoryIndex >= widget.stories.length) {
      Navigator.pop(context);
      return;
    }

    final currentStory = widget.stories[_currentStoryIndex];
    final contents = currentStory['contents'] as List<Map<String, dynamic>>? ?? [];
    
    if (_currentContentIndex >= contents.length) {
      _nextStory();
      return;
    }

    _timer?.cancel();
    _progressController.reset();
    _progressController.forward();
    
    _timer = Timer(const Duration(seconds: 5), () {
      if (!_isPaused) {
        _nextContent();
      }
    });
  }

  void _nextContent() {
    final currentStory = widget.stories[_currentStoryIndex];
    final contents = currentStory['contents'] as List<Map<String, dynamic>>? ?? [];
    
    if (_currentContentIndex < contents.length - 1) {
      setState(() {
        _currentContentIndex++;
      });
      _startProgress();
    } else {
      _nextStory();
    }
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
      _startProgress();
    } else {
      _previousStory();
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _currentContentIndex = 0;
      });
      _pageController.animateToPage(
        _currentStoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        final currentStory = widget.stories[_currentStoryIndex];
        final contents = currentStory['contents'] as List<Map<String, dynamic>>? ?? [];
        _currentContentIndex = contents.length - 1;
      });
      _pageController.animateToPage(
        _currentStoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _onTap() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _timer?.cancel();
      _progressController.stop();
    } else {
      _startProgress();
    }
  }

  void _onLongPress() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    _progressController.stop();
  }

  void _onLongPressEnd() {
    setState(() {
      _isPaused = false;
    });
    _startProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        onLongPress: _onLongPress,
        onLongPressEnd: (_) => _onLongPressEnd(),
        child: Stack(
          children: [
            // Story Content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStoryIndex = index;
                  _currentContentIndex = 0;
                });
                _timer?.cancel();
                _progressController.reset();
                _startProgress();
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, storyIndex) {
                final story = widget.stories[storyIndex];
                final contents = story['contents'] as List<Map<String, dynamic>>? ?? [];
                
                return _buildStoryContent(story, contents);
              },
            ),
            
            // Progress Bars
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: _buildProgressBars(),
            ),
            
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),
            
            // Navigation Buttons
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  // Previous Story/Content
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentContentIndex > 0) {
                          _previousContent();
                        } else {
                          _previousStory();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                  ),
                  
                  // Next Story/Content
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentContentIndex < _getCurrentContents().length - 1) {
                          _nextContent();
                        } else {
                          _nextStory();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(Map<String, dynamic> story, List<Map<String, dynamic>> contents) {
    if (contents.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                story['title'] ?? 'Story',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentContent = contents[_currentContentIndex];
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: currentContent['image'] != null ? DecorationImage(
          image: NetworkImage(currentContent['image']),
          fit: BoxFit.cover,
        ) : null,
        color: currentContent['image'] == null ? Colors.black : null,
      ),
      child: Stack(
        children: [
          // Content Overlay
          if (currentContent['text'] != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentContent['text'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBars() {
    final currentStory = widget.stories[_currentStoryIndex];
    final contents = currentStory['contents'] as List<Map<String, dynamic>>? ?? [];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(contents.length, (index) {
          return Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.only(right: index < contents.length - 1 ? 4 : 0),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  double progress = 0;
                  if (index < _currentContentIndex) {
                    progress = 1.0;
                  } else if (index == _currentContentIndex) {
                    progress = _progressController.value;
                  }
                  
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    final currentStory = widget.stories[_currentStoryIndex];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: currentStory['userImage'] != null ? DecorationImage(
                image: NetworkImage(currentStory['userImage']),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: currentStory['userImage'] == null
                ? Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStory['title'] ?? 'Story',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_currentContentIndex + 1}/${_getCurrentContents().length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCurrentContents() {
    final currentStory = widget.stories[_currentStoryIndex];
    return currentStory['contents'] as List<Map<String, dynamic>>? ?? [];
  }
} 