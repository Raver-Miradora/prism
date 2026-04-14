import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/prism_mentor_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Data model
// ──────────────────────────────────────────────────────────────────────────────

enum _BubbleType { user, typing, ai }

class _ChatMessage {
  final _BubbleType type;
  // For [ai] bubbles: full text — the typewriter widget handles reveal.
  // For [typing] bubbles: ignored.
  final String text;
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

    // Greet the intern
    _messages.add(_ChatMessage(
      type: _BubbleType.ai,
      text:
          "Hello! I am your offline PRISM Mentor. I can help with basic LGU procedures like dress codes, transmittal formats, or timesheet rules. What do you need help with?",
    ));
  }

  // ── Sending logic ──────────────────────────────────────────────────────────

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isThinking) return;

    setState(() {
      _messages.add(_ChatMessage(type: _BubbleType.user, text: text));
      _messages.add(_ChatMessage(type: _BubbleType.typing)); // dots placeholder
      _isThinking = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final response = PrismMentorService.getResponse(text);

      setState(() {
        // Remove the typing-indicator bubble
        _messages.removeWhere((m) => m.type == _BubbleType.typing);
        // Add the real AI bubble — typewriter kicks in automatically
        _messages.add(_ChatMessage(type: _BubbleType.ai, text: response));
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
          _buildInputArea(colors),
        ],
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
          // Pulsing avatar
          ScaleTransition(
            scale: _pulseAnim,
            child: CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Icon(Icons.auto_awesome, color: colors.primary, size: 20),
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
                    _isThinking ? 'Thinking...' : 'Offline AI Assistant',
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
        switch (msg.type) {
          case _BubbleType.user:
            return _UserBubble(text: msg.text, colors: colors);
          case _BubbleType.typing:
            return _TypingIndicatorBubble(colors: colors);
          case _BubbleType.ai:
            return _AiBubble(
              text: msg.text,
              colors: colors,
              onCharacterRevealed: _scrollToBottom,
            );
        }
      },
    );
  }

  // ── Input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea(ColorScheme colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                enabled: !_isThinking,
                decoration: InputDecoration(
                  hintText: _isThinking ? 'Mentor is typing...' : 'Ask about standard procedures...',
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
                  onPressed: _isThinking ? null : _sendMessage,
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
// AI bubble with typewriter reveal
// ──────────────────────────────────────────────────────────────────────────────

class _AiBubble extends StatefulWidget {
  final String text;
  final ColorScheme colors;
  final VoidCallback onCharacterRevealed;
  const _AiBubble({
    required this.text,
    required this.colors,
    required this.onCharacterRevealed,
  });

  @override
  State<_AiBubble> createState() => _AiBubbleState();
}

class _AiBubbleState extends State<_AiBubble> {
  String _displayed = '';
  Timer? _timer;
  int _index = 0;

  // Characters per tick — higher = faster typing feel
  static const _charsPerTick = 2;
  static const _tickInterval = Duration(milliseconds: 20);

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer = Timer.periodic(_tickInterval, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = (_index + _charsPerTick).clamp(0, widget.text.length);
      setState(() {
        _displayed = widget.text.substring(0, next);
        _index = next;
      });
      widget.onCharacterRevealed();
      if (_index >= widget.text.length) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
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
        child: Text(
          _displayed,
          style: TextStyle(
            fontSize: 14,
            color: widget.colors.onSurface,
            height: 1.4,
          ),
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
