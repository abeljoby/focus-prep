import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:ccwassist/env/env.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
import 'package:ccwassist/screens/feedback.dart';
import 'package:ccwassist/authentication/login.dart';
import 'package:ccwassist/authentication/register.dart';


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

  // Future<List<Map<String, dynamic>>> generateQuestions({
  //   required String topic,
  //   required int numberOfQuestions,
  // }) async {
  //   final userMessage = OpenAIChatCompletionChoiceMessageModel(
  //     content: [
  //       OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //         // "Hello, I am a chatbot created by OpenAI. How are you today?",
  //         '''
  //         Generate a quiz on the topic "$topic" with $numberOfQuestions questions. Use the following JSON format:
  //         {
  //           "qno": 1,
  //           "Question": "Your question here",
  //           "Option1": "Option 1 text",
  //           "Option2": "Option 2 text",
  //           "Option3": "Option 3 text",
  //           "Option4": "Option 4 text",
  //           "CorrectOption": "Option1/Option2/Option3/Option4"
  //         }
  //         '''
  //       ),
  //     ],
  //     role: OpenAIChatMessageRole.user,
  //   );

  //   final systemMessage = OpenAIChatCompletionChoiceMessageModel(
  //     content: [
  //     OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //       "You are a quiz generator.",
  //     ),
  //     ],
  //     role: OpenAIChatMessageRole.assistant,
  //   );

  //   final requestMessages = [
  //     systemMessage,
  //     userMessage,
  //   ];

  //   OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
  //     model: "gpt-4o-mini",
  //     responseFormat: {"type": "json_object"},
  //     // seed: 6,
  //     messages: requestMessages,
  //     // temperature: 0.2,
  //     maxTokens: 1000,
  //   );

  //   // print(chatCompletion.choices.first.message); // ...
  //   print(chatCompletion.systemFingerprint); // ...
  //   print(chatCompletion.usage.promptTokens); // ...
  //   print(chatCompletion.id); // ...

  //   final content = chatCompletion.choices.first.message.content?.first.text;

  //   final Map<String, dynamic> decodedJson = jsonDecode(content!);

  //   // Extract the 'quiz' array
  //   final List<dynamic> quizArray = decodedJson['quiz'];

  //   // Convert to a list of maps for easier access
  //   final questions = quizArray.cast<Map<String, dynamic>>();

  //   // for (var question in questions) {
  //   //   print('Question ${question["qno"]}: ${question["Question"]}');
  //   //   print('Options:');
  //   //   print('1. ${question["Option1"]}');
  //   //   print('2. ${question["Option2"]}');
  //   //   print('3. ${question["Option3"]}');
  //   //   print('4. ${question["Option4"]}');
  //   //   print('Correct Option: ${question["CorrectOption"]}');
  //   //   print('---');
  //   // }

  //   // Convert the response string into a list of maps
  //   return questions;
  // }

  // final questions = generateQuestions(topic: "Fundamentals of Machine Learning", numberOfQuestions: 10,);
  // print(questions);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added 'Key?' and 'super(key: key)'

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Demo App",
      routes: {
        '/': (context) => const HomeWrapper(),
        '/first': (context) => const First(),
        '/login': (context) => LoginPage(),
        '/register':(context) => RegistrationPage(),
        // '/homestudent':(context) => HomeStudent(),
        '/profilepage':(context) => const ProfilePage(),
        '/feedbackpage':(context) => const FeedbackPage(),
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

