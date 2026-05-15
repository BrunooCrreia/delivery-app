import 'package:flutter/material.dart';

class RegisterProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const RegisterProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentPage + 1) / totalPages,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }
}