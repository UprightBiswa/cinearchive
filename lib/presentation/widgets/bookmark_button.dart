import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    required this.isBookmarked,
    required this.onPressed,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}
