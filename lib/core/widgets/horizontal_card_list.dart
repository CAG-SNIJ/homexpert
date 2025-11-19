import 'package:flutter/material.dart';

/// A reusable horizontal scrolling card list widget
/// Can be used anywhere in the app for displaying cards in a horizontal scroll
class HorizontalCardList extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double? maxWidth;

  const HorizontalCardList({
    super.key,
    required this.children,
    this.height = 280,
    this.padding,
    this.spacing = 20,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: maxWidth != null
            ? BoxConstraints(maxWidth: maxWidth!)
            : const BoxConstraints(),
        child: SizedBox(
          height: height,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            children: _buildChildrenWithSpacing(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    if (children.isEmpty) return [];
    
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}

