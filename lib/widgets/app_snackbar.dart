import 'package:flutter/material.dart';
import '../config/constants.dart';

void showAppSnackBar(BuildContext context, String message, {Color? backgroundColor, Duration? duration}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? AppColors.grisOscuro,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: duration ?? const Duration(seconds: 2),
    ),
  );
}
