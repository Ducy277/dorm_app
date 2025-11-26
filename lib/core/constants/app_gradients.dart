import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradient chung cho cA�c khu v��c hero/header.
class AppGradients {
  AppGradients._();

  static const LinearGradient heroBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.heroStart,
      AppColors.heroEnd,
    ],
  );
}
