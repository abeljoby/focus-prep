import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:ccwassist/env/env.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:ccwassist/firebase_options.dart';
import 'package:ccwassist/screens/joinclassroom.dart';
import 'package:ccwassist/screens/createclassroom.dart';
import 'package:ccwassist/screens/splashscreen.dart';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:ccwassist/screens/testhistory.dart';
import 'package:ccwassist/screens/createtest.dart';
import 'package:ccwassist/screens/qbank.dart';
import 'package:ccwassist/screens/homewrapper.dart';
import 'package:ccwassist/screens/first.dart';
import 'package:ccwassist/screens/addquestion.dart';
import 'package:ccwassist/screens/upcomingtests.dart';
import 'package:ccwassist/screens/profile.dart';
import 'package:ccwassist/authentication/login.dart';
import 'package:ccwassist/authentication/register.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // InitialBindings().dependencies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // lib/main.dart
  OpenAI.apiKey = Env.OPEN_AI_API_KEY;
  OpenAI.requestsTimeOut = Duration(seconds: 60);
  OpenAI.showLogs = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Focus Prep",
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        // appBarTheme: AppBarTheme(
        //   color: Colors.amber,
        // ),
        // textTheme: TextTheme(
        //   displayLarge: const TextStyle(
        //     fontSize: 72,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   // ···
        //   titleLarge: GoogleFonts.oswald(
        //     fontSize: 30,
        //     fontStyle: FontStyle.italic,
        //   ),
        //   bodyMedium: GoogleFonts.merriweather(),
        //   displaySmall: GoogleFonts.pacifico(),
        // ),
      ),
      routes: {
        '/': (context) => const HomeWrapper(),
        '/first': (context) => const First(),
        '/login': (context) => LoginPage(),
        '/register':(context) => RegistrationPage(),
        // '/homestudent':(context) => HomeStudent(),
        '/profilepage':(context) => const ProfilePage(),
        // '/hometeacher':(context) => HomeTeacher(),
        // '/question':(context) => QuestionPage(),
        '/qbank':(context) => const QBank(),
        '/qform':(context) => const QuestionForm(),
        '/createtest':(context) => const CreateTest(),
        '/joinclass':(context) => const JoinClassroom(),
        '/createclass':(context) => const CreateClassroom(),        // '/qp':(context) => const QuestionPa(),
        '/scheduledtests' :(context) => const ScheduledTests(),
        '/upcomingtests' :(context) => const UpcomingTests(),
        '/testhistory' :(context) => const TestHistory(),
        // '/result':(context) =>  ResultPage(),
        // '/qtest':(context) => const HomeScreen(),
        '/splash' :(context) => const SplashScreen(),
      },
      initialRoute: '/splash',
    );
  }
}

