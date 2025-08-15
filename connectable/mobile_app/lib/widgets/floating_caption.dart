import 'package:flutter/material.dart';

class FloatingCaption extends StatefulWidget {
  final String text;
  const FloatingCaption({super.key, required this.text});

  @override
  State<FloatingCaption> createState() => _FloatingCaptionState();
}

class _FloatingCaptionState extends State<FloatingCaption> {
  Offset _pos = const Offset(24, 80);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _pos.dx,
          top: _pos.dy,
          child: Draggable(
            feedback: _buildChip(context, opacity: 0.85),
            childWhenDragging: _buildChip(context, opacity: 0.3),
            onDragEnd: (d) => setState(() => _pos = d.offset),
            child: _buildChip(context, opacity: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext ctx, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(ctx).colorScheme.primary, width: 2),
          boxShadow: const [BoxShadow(blurRadius: 10, spreadRadius: 1)],
        ),
        child: Text(
          widget.text.isEmpty ? '...' : widget.text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
