import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KitchenAssistantApp());
}

class KitchenAssistantApp extends StatelessWidget {
  const KitchenAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MutfakAsistanim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
      },
    );
  }
}
