import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/aegis_theme.dart';
import 'core/theme/aegis_colors.dart';
import 'widgets/aegis_navigation.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/feed/feed_screen.dart';
import 'screens/briefs/briefs_screen.dart';
import 'screens/alerts/alerts_screen.dart';
import 'widgets/live_risk_map_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env file doesn't exist, continue without it
    debugPrint('Warning: .env file not found. Using default configuration.');
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AegisColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AegisApp());
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.zero, // Prevent negative ViewInsets
      ),
      child: MaterialApp(
        title: 'AEGIS Intelligence v2.0',
        debugShowCheckedModeBanner: false,
        theme: AegisTheme.dark,
        home: const AegisShell(),
      ),
    );
  }
}

/// Main shell with AppBar + BottomNav + screen switching.
class AegisShell extends StatefulWidget {
  const AegisShell({super.key});

  @override
  State<AegisShell> createState() => _AegisShellState();
}

class _AegisShellState extends State<AegisShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    LiveRiskMapScreen(),
    FeedScreen(),
    BriefsScreen(),
    AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AegisColors.background,
      appBar: const AegisAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AegisBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
