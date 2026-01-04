import 'package:flutter/material.dart';
import 'package:responsi/models/story_model.dart';
import 'package:responsi/services/chat_service.dart';
import 'package:responsi/services/story_service.dart';

class StoryViewPage extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewPage({
    Key? key,
    required this.stories,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ChatService _chatService = ChatService();
  final StoryService _storyService = StoryService();
  bool _isSendingMessage = false;
  bool _isManuallyPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    // Add listener to rebuild UI during animation
    _animationController.addListener(() {
      setState(() {});
    });

    // Listen to focus changes on message field
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _pauseStory();
      } else if (!_isManuallyPaused) {
        _resumeStory();
      }
    });

    _startStory();
    _markCurrentStoryAsViewed();
  }

  void _markCurrentStoryAsViewed() {
    if (_currentIndex >= 0 && _currentIndex < widget.stories.length) {
      final story = widget.stories[_currentIndex];
      _storyService.markStoryAsViewed(story.id);
    }
  }

  void _startStory() {
    _animationController.forward(from: 0);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
      _markCurrentStoryAsViewed();
    } else {
      Navigator.pop(context, true); // Return true to indicate stories were viewed
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
      _markCurrentStoryAsViewed();
    }
  }

  void _pauseStory() {
    _animationController.stop();
  }

  void _resumeStory() {
    _animationController.forward();
  }

  Future<void> _sendMessageToChat() async {
    if (_messageController.text.isEmpty) return;
    
    setState(() => _isSendingMessage = true);
    _pauseStory();

    try {
      final currentStory = widget.stories[_currentIndex];
      final storyOwnerId = currentStory.userId;

      // Get or create conversation
      final conversationId = await _chatService.getOrCreateConversation(storyOwnerId);
      
      if (conversationId != null) {
        // Send story reply message with story preview
        final success = await _chatService.sendStoryMessage(
          conversationId,
          storyOwnerId,
          currentStory.id,
          currentStory.imageUrl,
          _messageController.text,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reply sent to ${currentStory.username ?? "user"}!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          _messageController.clear();
          
          // Optional: Navigate to chat after sending
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ChatDetailPage(
          //       conversationId: conversationId,
          //       otherUserId: storyOwnerId,
          //       otherUserName: currentStory.username ?? 'User',
          //       otherUserAvatar: currentStory.avatarUrl,
          //     ),
          //   ),
          // );
        } else {
          throw Exception('Failed to send message');
        }
      } else {
        throw Exception('Failed to create conversation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSendingMessage = false);
      _resumeStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          // Ignore taps on bottom message area
          final double screenHeight = MediaQuery.of(context).size.height;
          final double dy = details.globalPosition.dy;
          
          if (dy > screenHeight - 100) {
            return; // Tap is in message area, ignore
          }

          final double screenWidth = MediaQuery.of(context).size.width;
          final double dx = details.globalPosition.dx;

          // If tap on middle 30% of screen, toggle pause
          if (dy > screenHeight * 0.35 && dy < screenHeight * 0.65) {
            if (_animationController.isAnimating) {
              _isManuallyPaused = true;
              _pauseStory();
            } else {
              _isManuallyPaused = false;
              _resumeStory();
            }
          } else if (dx < screenWidth / 3) {
            // Tap on left third - previous story
            _previousStory();
          } else if (dx > screenWidth * 2 / 3) {
            // Tap on right third - next story
            _nextStory();
          }
        },
        onLongPressStart: (_) {
          _isManuallyPaused = true;
          _pauseStory();
        },
        onLongPressEnd: (_) {
          _isManuallyPaused = false;
          _resumeStory();
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.stories[index].imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        value: index == _currentIndex
                            ? _animationController.value
                            : index < _currentIndex
                                ? 1.0
                                : 0.0,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 55,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: widget.stories[_currentIndex].avatarUrl != null
                        ? NetworkImage(widget.stories[_currentIndex].avatarUrl!)
                        : null,
                    child: widget.stories[_currentIndex].avatarUrl == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stories[_currentIndex].username ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          widget.stories[_currentIndex].timeAgo,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type message...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSendingMessage
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Icon(Icons.send, color: Colors.black),
                      onPressed: _isSendingMessage ? null : _sendMessageToChat,
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

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
}