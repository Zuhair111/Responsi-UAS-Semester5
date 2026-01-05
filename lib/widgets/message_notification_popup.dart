import 'package:flutter/material.dart';

class MessageNotificationPopup {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required String senderName,
    required String message,
    String? avatarUrl,
    required VoidCallback onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing overlay if any
    _currentOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _MessageNotificationWidget(
        senderName: senderName,
        message: message,
        avatarUrl: avatarUrl,
        onTap: () {
          overlayEntry.remove();
          _currentOverlay = null;
          onTap();
        },
        onDismiss: () {
          overlayEntry.remove();
          _currentOverlay = null;
        },
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _MessageNotificationWidget extends StatefulWidget {
  final String senderName;
  final String message;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Duration duration;

  const _MessageNotificationWidget({
    required this.senderName,
    required this.message,
    required this.onTap,
    required this.onDismiss,
    required this.duration,
    this.avatarUrl,
  });

  @override
  State<_MessageNotificationWidget> createState() =>
      _MessageNotificationWidgetState();
}

class _MessageNotificationWidgetState
    extends State<_MessageNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GestureDetector(
                onTap: widget.onTap,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < -500) {
                    _dismiss();
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade50,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: widget.avatarUrl != null
                                      ? NetworkImage(widget.avatarUrl!)
                                      : null,
                                  backgroundColor: Colors.orange.shade100,
                                  child: widget.avatarUrl == null
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.orange,
                                          size: 28,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Message content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.message_rounded,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'New Message',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.senderName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                          height: 1.3,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tap to reply',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Close button
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                onPressed: _dismiss,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
