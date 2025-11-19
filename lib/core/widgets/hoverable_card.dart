import 'package:flutter/material.dart';

/// A reusable hoverable card widget with elevation and shadow effects
/// Can be used anywhere in the app for interactive cards
class HoverableCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double borderRadius;
  final double hoverElevation;
  final Color? shadowColor;
  final double normalShadowOpacity;
  final double hoverShadowOpacity;
  final Duration animationDuration;

  const HoverableCard({
    super.key,
    required this.child,
    this.width = 300,
    this.borderRadius = 12,
    this.hoverElevation = 8.0,
    this.shadowColor,
    this.normalShadowOpacity = 0.1,
    this.hoverShadowOpacity = 0.25,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        width: widget.width,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -widget.hoverElevation : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: (widget.shadowColor ?? Colors.black)
                  .withOpacity(_isHovered ? widget.hoverShadowOpacity : widget.normalShadowOpacity),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? widget.hoverElevation : 4),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.child,
        ),
      ),
    );
  }
}

