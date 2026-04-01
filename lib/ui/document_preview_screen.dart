import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A universal preview screen inserted before final PDF compilation to allow
/// last-minute reviews and edits of assembled textual data.
class DocumentPreviewScreen extends ConsumerStatefulWidget {
  final String title;
  final String? initialContent;
  final Future<void> Function(BuildContext context, String? finalizedText) onApprove;

  const DocumentPreviewScreen({
    super.key,
    required this.title,
    this.initialContent,
    required this.onApprove,
  });

  @override
  ConsumerState<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends ConsumerState<DocumentPreviewScreen> {
  late TextEditingController _controller;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: colors.surfaceContainerHigh,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DOCUMENT REVIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.initialContent != null)
                Text(
                  'Make any final adjustments to your monthly accomplishments before locking them into the PDF.',
                  style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
                )
              else
                Text(
                  'Your Daily Time Record (DTR) matrix is fully assembled and verified. Proceed to generate the standardized PDF.',
                  style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
                ),
              
              const SizedBox(height: 24),
              Expanded(
                child: widget.initialContent != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.outlineVariant.withAlpha(50)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(fontSize: 14, color: colors.onSurface, height: 1.5),
                          decoration: const InputDecoration(
                            hintText: 'Review your synthesized notes...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(24),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.outlineVariant.withAlpha(50)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user, size: 64, color: colors.primary.withAlpha(100)),
                              const SizedBox(height: 16),
                              Text(
                                'DTR Matrix Ready',
                                style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              
              GestureDetector(
                onTap: _isGenerating ? null : () async {
                  setState(() => _isGenerating = true);
                  try {
                    await widget.onApprove(context, widget.initialContent != null ? _controller.text : null);
                  } finally {
                    if (mounted) {
                      setState(() => _isGenerating = false);
                      Navigator.pop(context);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: _isGenerating ? colors.surfaceContainerHighest : colors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isGenerating ? [] : [
                      BoxShadow(color: colors.primary.withAlpha(80), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      else
                        const Icon(Icons.picture_as_pdf, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        _isGenerating ? 'Rendering PDF...' : 'Approve & Save PDF to Device',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
