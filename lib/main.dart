import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/login_screen.dart';
import './screens/singup_screen.dart';

import './providers/user_provider.dart';
import './responsive/mobile_screen_layout.dart';
import './responsive/web_screen_layout.dart';
import './utils/colors.dart';
import './responsive/responsive_layout_screeen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAJbofgJRdGLawE8-NPnAzY7eD9o4URgiA',
        appId: '1:229140998783:web:829b63e3d20f36daeead4a',
        messagingSenderId: '229140998783',
        projectId: 'instagram-flutter-clone-7fbab',
        storageBucket: 'instagram-flutter-clone-7fbab.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Colne ',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        home: StreamBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            return const LoginScreen();
          },
          stream: FirebaseAuth.instance.authStateChanges(),
        ),
      ),
    );
  }
}
