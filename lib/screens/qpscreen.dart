import 'dart:async';
import 'package:ccwassist/screens/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  final String email;
  const TestScreen({super.key, required this.id, required this.data, required this.email});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Map<String,dynamic> testData = {};
  late List<String> answers = [];
  late String testID = "";
  late String emailID = "";
  late AnimationController _controller;
  late int noOfQuestions = 0;
  late List<Map<String,dynamic>> questionPaper = [];
  late List<int> result = [];

  late String? name = '';
  late String? batch = '';
  late String? ktuID = '';
  late String? email = '';
  late String? dept = '';

  // Timer? timer;
  // int seconds = 60;
  int levelClock = 180;
  // create an index to loop through _questions
  int index = 0;
  // create a score variable
  int score = 0;
  // create a boolean value to check if the user has clicked
  bool isPressed = false;
  //answers option
  // create a function to display the next question
  bool isAlreadyanswers = false;
  List<String> optionList = ['Option1','Option2','Option3','Option4'];

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
      email = prefs.getString("email");
      dept = prefs.getString("dept");
      batch = prefs.getString("batch");
    });
  }

  Future<List<Map<String,dynamic>>> getQuestionPaper(testID) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = 
    await FirebaseFirestore.instance.collection("tests")
    .doc(testID)
    .collection("question-paper")
    .orderBy("qno")
    .get();
    List<Map<String,dynamic>> _questions = snapshot.docs.map((q) => q.data()).toList();
    return _questions;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loadUserDetails();
    super.initState();
    testData = widget.data;
    testID = widget.id;
    emailID = widget.email;
    answers = List.generate(testData['Questions'], (index) => 'NV');
    // startTimer();
    switch (testData["Duration"]) {
      case "15 min":
        levelClock = 900;
        break;
      case "30 min": 
        levelClock = 1800;
        break;
      case "60 min":
        levelClock = 3600;
        break;
    }
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
        );
    _controller.forward();
  }

  void nextQuestion(int questionLength) {
    print(index);
    print(questionLength);
    if (index == questionLength - 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Submission"),
          content: const Text("You have reached the last question. Do you want to submit your answers and end the test?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                result = checkAnswers(questionPaper, answers);
                final resultDoc = {
                  "Answers": answers,
                  "Result": result,
                };
                FirebaseFirestore.instance
                    .collection("tests")
                    .doc(testID)
                    .collection("results")
                    .doc(ktuID)
                    .set(resultDoc);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      id: testID,
                      data: testData,
                      ans: answers,
                      res: result,
                      email: emailID,
                    ),
                  ),
                  ModalRoute.withName('/'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test completed and submitted.')),
                );
              },
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        index++;
        isPressed = false;
        isAlreadyanswers = false;
        answers[index] = '';
      }); 
    }
  }

  void previousQuestion(int questionLength) {
    if (index == 0) {
    } else {
      setState(() {
        index--;
        isPressed = false;
        isAlreadyanswers = false;
        // answers = "";
      });
    }
  }

  // create a function for changing color
  void checkAnswerAndUpdate(bool value) {
    if (isAlreadyanswers) {
      return;
    } else {
      if (value == true) {
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadyanswers = true;
      });
    }
  }

  // create a function to start over
  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadyanswers = false;
    });
    Navigator.pop(context);
  }

  checkAnswers (List<Map<String,dynamic>> questionpaper,List<String> ans) {
    int correct = 0;
    int answered = 0;
    int unanswered = 0;
    int unvisited = 0;
    // int reviewed = 0;
    for (var ques in questionpaper) {
      if(ques['CorrectOption'] == ans[ques['qno']-1]) {
        correct++;
        answered++;
      }
      else if (ans[ques['qno']-1] == '') {
        unanswered++;
      }
      // else if (ans[ques['qno']-1] == 'R') {
      //   reviewed++;
      // }
      else if (ans[ques['qno']-1] == 'NV') {
        unvisited++;
      }
      else {
        answered++;
      }
    }
    return [correct,answered,unanswered,unvisited];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '${testData['Topic']}',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.amber,
        leading: IconButton(onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        }, icon: const Icon(Icons.menu)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      height: 80,
                      width: double.infinity,
                      color: Colors.indigo[800],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Countdown(
                            animation: StepTween(
                              begin: levelClock,
                              end: 0,
                            ).animate(_controller),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Submission"),
                                  content: const Text("Are you sure you want to submit?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        result = checkAnswers(questionPaper, answers);
                                        final resultDoc = {
                                          "Answers": answers,
                                          "Result": result,
                                        };
                                        FirebaseFirestore.instance
                                            .collection("tests")
                                            .doc(testID)
                                            .collection("results")
                                            .doc(ktuID)
                                            .set(resultDoc);
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => ResultPage(
                                              id: testID,
                                              data: testData,
                                              ans: answers,
                                              res: result,
                                              email: emailID,
                                            ),
                                          ),
                                          ModalRoute.withName('/'),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Test completed and submitted.')),
                                        );
                                      },
                                      child: const Text('SUBMIT'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("SUBMIT", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: getQuestionPaper(testID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError || snapshot.data == null) {
                            return Center(child: Text("Error fetching the data"));
                          } else {
                            questionPaper = snapshot.data as List<Map<String, dynamic>>;
                            noOfQuestions = questionPaper.length;
                            return QuizQuestionWidget(
                              index: index,
                              noOfQuestions: noOfQuestions,
                              questionPaper: questionPaper,
                              answers: answers,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.grey,
              ),
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.amber,
                child: Center(
                  child: Text(
                    testData['Topic'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              // Container(
              //   height: 80, // Adjust the height as needed
              //   color:
              //       Colors.indigo.shade700, // Background color for the header
              //   child: Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Row(
              //           children: [
              //             ElevatedButton(
              //               onPressed: () {
              //                 // Handle "Question Paper" button press
              //               },
              //               style: ElevatedButton.styleFrom(
              //                   fixedSize: const Size(150, 50)),
              //               child: const Text('Question Paper'),
              //             ),
              //             ElevatedButton(
              //               onPressed: () {
              //                 // Handle "Instructions" button press
              //               },
              //               style: ElevatedButton.styleFrom(
              //                   fixedSize: const Size(150, 50)),
              //               child: const Text('Instructions'),
              //             ),
              //           ],
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              const ListTile(
                title: Text(
                  'Questions',
                ),
                //    subtitle: Text('Legend:'),
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green),
                title: Text('Answered'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.red),
                title: Text('Not Answered'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey),
                title: Text('Not Visited'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              // const ListTile(
              //   leading: CircleAvatar(backgroundColor: Colors.purpleAccent),
              //   title: Text('Marked for review'),
              //   dense: true, // Set dense to true for compact spacing
              //   visualDensity: VisualDensity(
              //       vertical: -4), // Adjust the vertical density
              // ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                    noOfQuestions,
                    (index) => questionBox(
                        index + 1)), // Disable GridView's scrolling
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo.shade800,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (index > 0) {
                  previousQuestion(noOfQuestions);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This is the first question.')),
                  );
                }
              },
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       answers[index] = 'R';
            //       nextQuestion(noOfQuestions);
            //     });
            //   },
            //   child: Text('Review'),
            // ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  nextQuestion(noOfQuestions);
                });
              },
              style: ElevatedButton.styleFrom(
                // fixedSize: const Size(90, 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('SAVE',style: TextStyle(fontSize: 16),),
            ),
            IconButton(
              onPressed: () {
                if (index < noOfQuestions - 1) {
                  nextQuestion(noOfQuestions);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This is the last question.')),
                  );
                }
              },
              icon: Icon(Icons.arrow_forward),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );        
  }

  Widget questionBox(int number) {
    Color color = Colors.grey;
    if (answers[number-1] == '') {
      color = Colors.red; // Not Answered
    // } else if (answers[number-1] == 'R') {
    //   color = Colors.purpleAccent; // Marked for Review
    } else if (answers[number-1] == 'NV'){
      color = Colors.grey; // Not Visited
    } else /* if ((answers[number-1] != '')&&(answers[number-1] != 'NV')&&(answers[number-1] != 'R')) */{
      color = Colors.green; // Answered
    }
    return InkWell(
      onTap: () {
        // Handle circle click
        setState(() {
          index = number - 1;
          answers[index] = '';
      }); 
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(number.toString())),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({final Key key = const Key(""), required this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      "$timerText",
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
      ),
    );
  }
}

class QuizQuestionWidget extends StatefulWidget {
  final int index;
  final int noOfQuestions;
  final List<Map<String, dynamic>> questionPaper;
  final List<String> answers;

  const QuizQuestionWidget({
    Key? key,
    required this.index,
    required this.noOfQuestions,
    required this.questionPaper,
    required this.answers,
  }) : super(key: key);

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.index + 1}/${widget.noOfQuestions}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.questionPaper[widget.index]["Question"] ?? ''),
            const SizedBox(height: 20),
            Column(
              children: [
                RadioListTile(
                  title: Text(widget.questionPaper[widget.index]['Option1'] ?? ''),
                  value: 'Option1',
                  groupValue: widget.answers[widget.index],
                  onChanged: (val) {
                    setState(() {
                      widget.answers[widget.index] = val!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text(widget.questionPaper[widget.index]['Option2'] ?? ''),
                  value: 'Option2',
                  groupValue: widget.answers[widget.index],
                  onChanged: (val) {
                    setState(() {
                      widget.answers[widget.index] = val!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text(widget.questionPaper[widget.index]['Option3'] ?? ''),
                  value: 'Option3',
                  groupValue: widget.answers[widget.index],
                  onChanged: (val) {
                    setState(() {
                      widget.answers[widget.index] = val!;
                    });
                  },
                ),
                RadioListTile(
                  title: Text(widget.questionPaper[widget.index]['Option4'] ?? ''),
                  value: 'Option4',
                  groupValue: widget.answers[widget.index],
                  onChanged: (val) {
                    setState(() {
                      widget.answers[widget.index] = val!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}