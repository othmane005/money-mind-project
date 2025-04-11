
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/categories_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMind',
      theme: AppTheme.getTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/categories': (context) => const CategoriesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
