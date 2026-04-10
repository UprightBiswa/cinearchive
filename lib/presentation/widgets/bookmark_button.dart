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
    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: isBookmarked ? const Color(0xFF003F74) : Colors.white.withOpacity(0.82),
        foregroundColor: isBookmarked ? Colors.white : const Color(0xFF003F74),
      ),
      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}
