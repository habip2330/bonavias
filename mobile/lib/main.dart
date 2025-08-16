import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'config/theme.dart';
import 'screens/login/login_page.dart';
import 'screens/login/reset_password_page.dart';
import 'screens/home/home_page.dart';
import 'screens/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'services/database_service.dart';
import 'services/fcm_service.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart' as splash;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sistem UI ayarlarını uygulama başında ayarla
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase başarıyla başlatıldı');
    
    // FCM Background handler'ı ayarla
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    print('✅ FCM Background handler ayarlandı');
  } catch (e) {
    print('❌ Firebase başlatma hatası: $e');
    // Firebase başlatılamazsa bile uygulamayı çalıştır
  }

  // Facebook Auth başlatma (Web için)
  try {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "1533443711394339", // Yeni Facebook App ID
      cookie: true,
      xfbml: true,
      version: "v23.0",
    );
    print('✅ Facebook Auth başarıyla başlatıldı');
  } catch (e) {
    print('❌ Facebook Auth başlatma hatası: $e');
    // Facebook Auth başlatılamazsa bile uygulamayı çalıştır
  }
  
  runApp(
    ScreenUtilInit(
      designSize: Size(390, 844), // iPhone 12 Pro Max referans alınarak
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonavias',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const splash.SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MainNavigationPage(),
        '/login': (context) => const LoginPage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/reset-password': (context) => const ResetPasswordPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
    );
  }
}


