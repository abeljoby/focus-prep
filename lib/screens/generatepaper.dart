// // ignore_for_file: prefer_const_constructors

// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:ccwassist/screens/qpscreen.dart';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GenerateQuestionPaper extends StatefulWidget {
  final Map<String, dynamic> data;
  final String email;
  const GenerateQuestionPaper({super.key, required this.data, required this.email});

  @override
  State<GenerateQuestionPaper> createState() => _GeneratePaperState();
}

class _GeneratePaperState extends State<GenerateQuestionPaper> {
  late Map<String,dynamic> dataCopy;
  late String email;
  List<Map<String,dynamic>> questionPaper = [];

  Future<List<Map<String, dynamic>>> generateAIQuestions(Map<String,dynamic> dataCopy) async {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          // "Hello, I am a chatbot created by OpenAI. How are you today?",
          '''
          Generate a quiz on the topic "${dataCopy["Topic"]}" with ${dataCopy["Questions"]} ${dataCopy["Difficulty"]} questions. The difficulty level should be ${dataCopy["Difficulty"]}. The response must be a JSON object with a single key named "Quiz" (case-sensitive). The value of "Quiz" should be an array of objects. Each object should have the following fields:
          {
            "qno": 1,
            "Question": "Your question here",
            "Option1": "Option 1 text",
            "Option2": "Option 2 text",
            "Option3": "Option 3 text",
            "Option4": "Option 4 text",
            "CorrectOption": "Option1/Option2/Option3/Option4"
          }
          '''
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "You are a quiz generator.",
      ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      maxTokens: 2500,
    );

    // print(chatCompletion.choices.first.message); // ...
    // print(chatCompletion.systemFingerprint); // ...
    // print(chatCompletion.usage.promptTokens); // ...
    // print(chatCompletion.usage.totalTokens);
    // print(chatCompletion.id); // ...

    final content = chatCompletion.choices.first.message.content?.first.text;
    final Map<String, dynamic> decodedJson = jsonDecode(content!);
    // print(decodedJson);
    // Extract the 'quiz' array
    final List<dynamic> quizArray = decodedJson['Quiz'];

    // Convert to a list of maps for easier access
    final questions = quizArray.cast<Map<String, dynamic>>();

    // Convert the response string into a list of maps
    return questions;
  }

  Map<String,dynamic> parseQuestion(QueryDocumentSnapshot<Map<String, dynamic>> q) {
    Map<String,dynamic> qdoc = q.data();
    qdoc["reference"] = q.reference.id;
    return qdoc;
  }

  @override
  void initState() {
    super.initState();
    dataCopy = widget.data;
    print(dataCopy);
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper', style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Container for additional details (date, time, etc.)
          Container(
            // height: 135,
            width: double.infinity,
            decoration: const BoxDecoration(color:Color.fromARGB(255, 217, 217, 217),border: Border(bottom: BorderSide(color:Color.fromARGB(255,192,192,192),width: 5))),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Topic: ${dataCopy["Topic"]}\n${dataCopy["Questions"]} questions\nDuration: ${dataCopy["Duration"]}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 16)),                // Add more details as needed
              ],
            ),
          ),
          // Scrollable list of questions
          Expanded(
            child: FutureBuilder(
              future: generateAIQuestions(dataCopy),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  questionPaper = snapshot.data as List<Map<String,dynamic>>;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: questionPaper.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String,dynamic> ques = questionPaper.elementAt(index);
                      // Create a container for each element
                      return QuestionCard(index: index,ques: ques,data: dataCopy,getQuestionPaper: () => questionPaper,);
                    }
                  );
                }
                // while waiting for data to arrive, show a spinning indicator
                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the Row doesn't take up the full width
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Text(
                        "Generating questions",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(width: 10), // Adds space between the text and the progress indicator
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              }
            )
          ),
          Container(
            // color: Colors.amber,
            decoration: const BoxDecoration(color:Color.fromARGB(255, 217, 217, 217),border: Border(top: BorderSide(color:Color.fromARGB(255,192,192,192),width: 5))),
            padding: EdgeInsets.all(15),
            // height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                (dataCopy["QuizStart"])?
                ElevatedButton(
                  onPressed: () async {
                    DocumentReference<Map<String,dynamic>> testref = await FirebaseFirestore.instance.collection("tests").add(dataCopy);
                    String testid = testref.id;
                    for (int index = 1; index <= questionPaper.length; index++) {
                      questionPaper.elementAt(index-1)["qno"] = index;
                      FirebaseFirestore.instance.collection("tests").doc(testid).collection("question-paper").doc("$index").set(questionPaper.elementAt(index-1)).then((value) => null);
                    }
                    print(testid);
                    print(dataCopy);
                    print(email);
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: ((context) => TestScreen(id: testid,data: dataCopy,email: email))),ModalRoute.withName('/'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    fixedSize: const Size(150, 50)
                  ),
                  child: const Text('Start test',style: TextStyle(fontSize: 18),),
                ):
                ElevatedButton(
                  onPressed: () async {
                    DocumentReference<Map<String,dynamic>> testref = await FirebaseFirestore.instance.collection("tests").add(dataCopy);
                    String testid = testref.id;
                    for (int index = 1; index <= questionPaper.length; index++) {
                      questionPaper.elementAt(index-1)["qno"] = index;
                      FirebaseFirestore.instance.collection("tests").doc(testid).collection("question-paper").doc("$index").set(questionPaper.elementAt(index-1)).then((value) => null);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added test to schedule.'))
                    );
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: ((context) => const ScheduledTests())),ModalRoute.withName('/'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    fixedSize: const Size(150, 50)
                  ),
                  child: const Text('Create test',style: TextStyle(fontSize: 18),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> ques;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> Function() getQuestionPaper;

  const QuestionCard({
    super.key,
    required this.index,
    required this.ques,
    required this.data,
    required this.getQuestionPaper,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late Map<String,dynamic> data;
  late Map<String,dynamic> ques;
  late int index;

  Future<Map<String,dynamic>> generateReplacementQuestion(Map<String,dynamic> dataCopy, int qno) async {
    final replaceMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          // "Hello, I am a chatbot created by OpenAI. How are you today?",
          '''
          Generate a question on the topic "${dataCopy["Topic"]}". The difficulty level should be ${dataCopy["Difficulty"]}. The response must be a JSON object with the following fields:
          {
            "qno": $qno,
            "Question": "Your question here",
            "Option1": "Option 1 text",
            "Option2": "Option 2 text",
            "Option3": "Option 3 text",
            "Option4": "Option 4 text",
            "CorrectOption": "Option1/Option2/Option3/Option4"
          }
          '''
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "You are a quiz generator.",
      ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final requestMessages = [
      systemMessage,
      replaceMessage,
    ];

    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      maxTokens: 1000,
    );

    // print(chatCompletion.choices.first.message); // ...
    print(chatCompletion.systemFingerprint); // ...
    print(chatCompletion.usage.promptTokens); // ...
    print(chatCompletion.usage.totalTokens);
    print(chatCompletion.id); // ...

    final content = chatCompletion.choices.first.message.content?.first.text;
    final Map<String, dynamic> decodedJson = jsonDecode(content!);
    print(decodedJson);
    // Extract the 'quiz' array

    // Convert to a list of maps for easier access
    final question = decodedJson;

    // Convert the response string into a list of maps
    return question;
  }
  
  @override
  void initState() {
    super.initState();
    ques = widget.ques;
    index = widget.index;
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index + 1}. ${ques['Question']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 3, // Limits the number of lines
                  overflow: TextOverflow.ellipsis, // Adds ellipsis when text overflows
                ),
                const SizedBox(height: 8),
                Text("1. ${ques['Option1']}"),
                Text("2. ${ques['Option2']}"),
                Text("3. ${ques['Option3']}"),
                Text("4. ${ques['Option4']}"),
                const SizedBox(height: 8),
                (data["QuizStart"])?const SizedBox.shrink():
                Text(
                  "Correct Option: ${ques['CorrectOption'].substring(6)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Divider(), // Add a divider
              ],
            ),
          ),
          (data["QuizStart"])?const SizedBox.shrink():
          IconButton(
            onPressed: () async {
              Map<String,dynamic> newQuestion = await generateReplacementQuestion(data, index+1);
              setState(() {
                ques = newQuestion;
                List<Map<String, dynamic>> questionPaper = widget.getQuestionPaper();
                questionPaper[index] = newQuestion;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Regenerated question ${index+1}.')),
              );
            },
            // shape: const CircleBorder(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
              foregroundColor: MaterialStateProperty.all(Colors.yellow),
            ),
            icon: const Icon(Icons.replay_outlined),
          ),
        ],
      ),
    );
  }
}