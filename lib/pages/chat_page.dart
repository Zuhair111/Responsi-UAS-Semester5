import 'package:flutter/material.dart';
import 'package:responsi/services/chat_service.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'post_detail_page.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUsername;
  final String? otherUserAvatar;

  const ChatPage({
    Key? key,
    required this.otherUserId,
    required this.otherUsername,
    this.otherUserAvatar,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _conversationId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      _currentUserId = _authService.currentUser?.id;

      // Get or create conversation
      final conversationId = await _chatService.getOrCreateConversation(widget.otherUserId);

      if (conversationId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load chat')),
          );
        }
        return;
      }

      setState(() {
        _conversationId = conversationId;
      });

      // Load messages
      await _loadMessages();

      // Mark messages as read
      await _chatService.markMessagesAsRead(conversationId);

      // Subscribe to new messages
      _chatService.subscribeToMessages(conversationId, (newMessage) {
        if (mounted) {
          _loadMessages();
          _chatService.markMessagesAsRead(conversationId);
        }
      });
    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;

    final messages = await _chatService.getMessages(_conversationId!);
    setState(() {
      _messages = messages;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _conversationId == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final success = await _chatService.sendMessage(
        _conversationId!,
        widget.otherUserId,
        content,
      );

      if (success) {
        _messageController.clear();
        await _loadMessages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message')),
          );
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final senderId = message['sender_id'] as String;
    final isMine = senderId == _currentUserId;
    final content = message['content'] as String;
    final messageType = message['message_type'] as String? ?? 'text';
    final createdAt = DateTime.parse(message['created_at'] as String);
    final isRead = message['is_read'] as bool;
    final post = message['post'] as Map<String, dynamic>?;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Shared post preview
            if (messageType == 'post' && post != null) ...[
              GestureDetector(
                onTap: () {
                  final postId = message['post_id'] as String?;
                  if (postId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(
                          postId: postId,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMine ? Colors.blue[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo,
                            size: 16,
                            color: isMine ? Colors.white70 : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Shared a post',
                            style: TextStyle(
                              color: isMine ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (post['image_url'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['image_url'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[400],
                                child: Icon(Icons.broken_image, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      if (post['content'] != null && (post['content'] as String).isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          post['content'],
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4),
            ],
            
            // Story reply preview
            if (messageType == 'story') ...[
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMine ? Colors.blue[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 16,
                          color: isMine ? Colors.white70 : Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Replied to story',
                          style: TextStyle(
                            color: isMine ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (message['story_image_url'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message['story_image_url'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[400],
                              child: Icon(Icons.broken_image, color: Colors.white),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 4),
            ],
            
            // Regular text message or story reply message
            if (messageType == 'text' || messageType == 'story')
              Text(
                content,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeago.format(createdAt, locale: 'en_short'),
                  style: TextStyle(
                    color: isMine ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                if (isMine) ...[
                  SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? Colors.lightBlue : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUserAvatar != null && widget.otherUserAvatar!.isNotEmpty
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: widget.otherUserAvatar == null || widget.otherUserAvatar!.isEmpty
                  ? Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            SizedBox(width: 10),
            Text(
              widget.otherUsername,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.orange))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Send a message to start chatting',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessage(_messages[index]);
                        },
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendMessage,
                            padding: EdgeInsets.zero,
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
