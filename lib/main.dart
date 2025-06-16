import 'package:dhan_mitra_final/pages/introduction_pages/splash_screen.dart';
import 'package:dhan_mitra_final/providers/app_state.dart';
import 'package:dhan_mitra_final/providers/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/lightmode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
   
   
    
    
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Initialization failed: $e');
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AppState()..loadGroups()),
        ChangeNotifierProvider(create: (_) => DashboardState())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightmode, //my default theme
      // darkTheme: darkmode,//darktheme
      // themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
