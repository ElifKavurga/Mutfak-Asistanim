import 'package:flutter/material.dart';

import 'screens/add_recipe_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/ai_camera_screen.dart';
import 'screens/discover_recipes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_profile_screen.dart';
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
        AddRecipeScreen.routeName: (context) => const AddRecipeScreen(),
        AddProductScreen.routeName: (context) => const AddProductScreen(),
        AiCameraScreen.routeName: (context) => const AiCameraScreen(),
        DiscoverRecipesScreen.routeName: (context) =>
            const DiscoverRecipesScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        InventoryScreen.routeName: (context) => const InventoryScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        PlanScreen.routeName: (context) => const PlanScreen(),
        ProductDetailScreen.routeName: (context) => const ProductDetailScreen(),
        RecipeDetailScreen.routeName: (context) => const RecipeDetailScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        ShoppingListScreen.routeName: (context) => const ShoppingListScreen(),
        StatsProfileScreen.routeName: (context) => const StatsProfileScreen(),
      },
    );
  }
}
