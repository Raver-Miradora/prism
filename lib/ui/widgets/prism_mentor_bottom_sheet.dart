import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/prism_mentor_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────────────────────────────────────

enum _BubbleType { user, typing, ai }

class _ChatMessage {
  final _BubbleType type;
  final String text;
  bool hasAnimated = false; // State flag to prevent re-triggering animations on scroll
  _ChatMessage({required this.type, this.text = ''});
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom sheet
// ──────────────────────────────────────────────────────────────────────────────

class PrismMentorBottomSheet extends StatefulWidget {
  const PrismMentorBottomSheet({super.key});

  @override
  State<PrismMentorBottomSheet> createState() => _PrismMentorBottomSheetState();
}

class _PrismMentorBottomSheetState extends State<PrismMentorBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  // Pulsing animation for the header icon
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Greet the intern with animated pop
    _messages.add(_ChatMessage(
      type: _BubbleType.ai,
      text: "👋 Hello! I am your **PRISM Mentor**. I can help with **LGU rules**, **DTR procedures**, and **OJT Academy modules**. What would you like to know about?",
    ));

    // Initialize discovery suggestions
    _currentSuggestions = PrismMentorService.getSuggestions("hi");
    
    // Slight delay to show suggestions after the first bubble reveals
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSuggestions = true);
    });
  }

  // ── Sending logic ──────────────────────────────────────────────────────────

  void _sendMessage({String? customText}) {
    final text = customText ?? _inputController.text.trim();
    if (text.isEmpty || _isThinking) return;

    setState(() {
      _messages.add(_ChatMessage(type: _BubbleType.user, text: text));
      _messages.add(_ChatMessage(type: _BubbleType.typing)); // dots placeholder
      _isThinking = true;
      _showSuggestions = false; // Hide old suggestions when new query starts
    });
    if (customText == null) _inputController.clear();
    _scrollToBottom();

    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final response = PrismMentorService.getResponse(text);
      final suggestions = PrismMentorService.getSuggestions(text);

      setState(() {
        // Remove the typing-indicator bubble
        _messages.removeWhere((m) => m.type == _BubbleType.typing);
        // Add the real AI bubble — typewriter kicks in automatically
        _messages.add(_ChatMessage(type: _BubbleType.ai, text: response));
        _currentSuggestions = suggestions;
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final pos = _scrollController.position;
      final isAtBottom = pos.pixels >= pos.maxScrollExtent - 100;

      // Smart Snap: Only scroll automatically if the user is already near the bottom
      // or if we explicitly force it (e.g. sending a new message).
      if (isAtBottom || force) {
        _scrollController.animateTo(
          pos.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(colors),
          Expanded(child: _buildMessageList(colors)),
          _buildSuggestions(colors),
          _buildInputArea(colors),
        ],
      ),
    );
  }

  // ── Suggestions (V2 Feature) ───────────────────────────────────────────────

  List<String> _currentSuggestions = [];
  bool _showSuggestions = false;

  Widget _buildSuggestions(ColorScheme colors) {
    if (_currentSuggestions.isEmpty) return const SizedBox.shrink();
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: _showSuggestions ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: _showSuggestions 
          ? Container(
              height: 44,
              padding: const EdgeInsets.only(bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _currentSuggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          suggestion,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                        ),
                        backgroundColor: colors.primary.withValues(alpha: 0.08),
                        side: BorderSide(color: colors.primary.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => _sendMessage(customText: suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : const SizedBox.shrink(),
      ),
    );
  }

  // ── Header with pulsing icon ───────────────────────────────────────────────

  Widget _buildHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Pulsing and Rotating avatar
          ScaleTransition(
            scale: _pulseAnim,
            child: AnimatedRotation(
              turns: _isThinking ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              curve: Curves.linear,
              onEnd: () {
                // Keep rotating if still thinking
                if (_isThinking) {
                  // This is a bit hacky for a linear repeat in AnimatedRotation, 
                  // but for a "thinking" state it works well.
                }
              },
              child: CircleAvatar(
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(Icons.smart_toy_rounded, color: colors.primary, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRISM MENTOR',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isThinking ? 'Thinking...' : 'Expert AI Assistant',
                    key: ValueKey(_isThinking),
                    style: TextStyle(
                      fontSize: 11,
                      color: _isThinking ? colors.primary.withValues(alpha: 0.7) : colors.onSurfaceVariant,
                      fontStyle: _isThinking ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── Message list ───────────────────────────────────────────────────────────

  Widget _buildMessageList(ColorScheme colors) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _PopAnimation(
          message: msg,
          child: _buildBubble(msg, index, colors),
        );
      },
    );
  }

  Widget _buildBubble(_ChatMessage msg, int index, ColorScheme colors) {
    switch (msg.type) {
      case _BubbleType.user:
        return _UserBubble(text: msg.text, colors: colors);
      case _BubbleType.typing:
        return _TypingIndicatorBubble(colors: colors);
      case _BubbleType.ai:
        return _AiBubble(
          msg: msg,
          colors: colors,
          onCharacterRevealed: () => _scrollToBottom(force: false),
          onFinished: () {
            if (mounted && index == _messages.length - 1) {
              setState(() => _showSuggestions = true);
            }
          },
        );
    }
  }

  // ── Input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea(ColorScheme colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                enabled: !_isThinking,
                decoration: InputDecoration(
                  hintText: _isThinking ? 'Mentor is typing...' : 'Ask about procedures...',
                  hintStyle: TextStyle(fontSize: 14, color: colors.outline),
                  filled: true,
                  fillColor: colors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isThinking ? 0.4 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: colors.onPrimary),
                  onPressed: _isThinking ? null : () => _sendMessage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Entry Animation Wrapper
// ──────────────────────────────────────────────────────────────────────────────

class _PopAnimation extends StatelessWidget {
  final Widget child;
  final _ChatMessage message;
  const _PopAnimation({required this.child, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.hasAnimated) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      onEnd: () => message.hasAnimated = true,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + (value * 0.2), // 0.8 to 1.0
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// User bubble
// ──────────────────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  final ColorScheme colors;
  const _UserBubble({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: colors.onPrimary, height: 1.4),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Typing indicator — three bouncing dots
// ──────────────────────────────────────────────────────────────────────────────

class _TypingIndicatorBubble extends StatefulWidget {
  final ColorScheme colors;
  const _TypingIndicatorBubble({required this.colors});

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotCtrl;
  late final List<Animation<double>> _dotAnim;

  @override
  void initState() {
    super.initState();
    _dotCtrl = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      ),
    );
    _dotAnim = _dotCtrl.map((c) {
      return Tween<double>(begin: 0.0, end: -6.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger each dot by 150 ms
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _dotCtrl[i].repeat(reverse: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: widget.colors.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _dotAnim[i],
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _dotAnim[i].value),
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.colors.onSurfaceVariant.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _dotCtrl) {
      c.dispose();
    }
    super.dispose();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AI bubble with typewriter reveal and RichText Support (V2)
// ──────────────────────────────────────────────────────────────────────────────

class _AiBubble extends StatefulWidget {
  final _ChatMessage msg;
  final ColorScheme colors;
  final VoidCallback onCharacterRevealed;
  final VoidCallback onFinished;
  const _AiBubble({
    required this.msg,
    required this.colors,
    required this.onCharacterRevealed,
    required this.onFinished,
  });

  @override
  State<_AiBubble> createState() => _AiBubbleState();
}

class _AiBubbleState extends State<_AiBubble> {
  String _displayed = '';
  Timer? _timer;
  int _index = 0;

  static const _charsPerTick = 2;
  static const _tickInterval = Duration(milliseconds: 15);

  @override
  void initState() {
    super.initState();
    if (widget.msg.hasAnimated) {
      _displayed = widget.msg.text;
      _index = widget.msg.text.length;
    } else {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer = Timer.periodic(_tickInterval, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = (_index + _charsPerTick).clamp(0, widget.msg.text.length);
      setState(() {
        _displayed = widget.msg.text.substring(0, next);
        _index = next;
      });
      widget.onCharacterRevealed();
      if (_index >= widget.msg.text.length) {
        t.cancel();
        widget.msg.hasAnimated = true;
        widget.onFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: widget.colors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.smart_toy_rounded, size: 14, color: widget.colors.primary),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14, right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: widget.colors.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildRichText(_displayed),
            ),
          ),
        ],
      ),
    );
  }

  /// Markdown-Lite: Parses **bold** and *italics*
  Widget _buildRichText(String text) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|([^*]+)');
    final matches = regExp.allMatches(text);

    for (var match in matches) {
      if (match.group(1) != null) {
        // Bold
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ));
      } else if (match.group(2) != null) {
        // Italic
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        // Plain
        spans.add(TextSpan(text: match.group(3)));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 14,
          color: widget.colors.onSurface,
          height: 1.4,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
