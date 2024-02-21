import 'package:expo_demo/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{


  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  //lock into portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((_) => {
  runApp(const MyApp())
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,
        primary: const Color(0xffe4cb9c),
        secondary: const Color(0xff231c3b),
        tertiary: const Color(0xfff3833c)),

        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

