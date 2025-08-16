import 'package:flutter/material.dart';
import '../screens/story/story_viewer_page.dart';

class StoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final Function(int)? onStoryTap;
  
  const StoryWidget({
    Key? key,
    required this.stories,
    this.onStoryTap,
  }) : super(key: key);

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  @override
  Widget build(BuildContext context) {
    // Görülmeyenler başta, görülenler sonda olacak şekilde sıralama
    final sortedStories = List<Map<String, dynamic>>.from(widget.stories)
      ..sort((a, b) {
        final aViewed = a['isViewed'] == true;
        final bViewed = b['isViewed'] == true;
        if (aViewed == bViewed) return 0;
        if (aViewed) return 1;
        return -1;
      });

    // Instagram gradient renkleri
    const instagramGradient = LinearGradient(
      colors: [
        Color(0xFFF58529), // turuncu
        Color(0xFFDD2A7B), // pembe
        Color(0xFF8134AF), // mor
        Color(0xFF515BD4), // mavi
        Color(0xFFFEDA77), // sarı
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const greyGradient = LinearGradient(
      colors: [
        Color(0xFFBDBDBD),
        Color(0xFFE0E0E0),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedStories.length,
        itemBuilder: (context, index) {
          final story = sortedStories[index];
          final isViewed = story['isViewed'] ?? false;
          
          return GestureDetector(
            onTap: () {
              if (widget.onStoryTap != null) {
                widget.onStoryTap!(index);
              } else {
                // Instagram tarzı story viewer'ı aç
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryViewerPage(
                      stories: widget.stories,
                      initialStoryIndex: index,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  // Story Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isViewed ? greyGradient : instagramGradient,
                      color: null,
                    ),
                                          child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: story['userImage'] != null ? DecorationImage(
                            image: NetworkImage(story['userImage']),
                            fit: BoxFit.cover,
                          ) : null,
                        ),
                        child: story['userImage'] == null
                          ? Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 30,
                            )
                          : null,
                      ),
                  ),
                  const SizedBox(height: 8),
                  // Story Title
                  Text(
                    story['title'] ?? 'Story',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 