import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccwassist/screens/correctedqp.dart';

class ResultPage extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  final String email;
  final List<String> ans;
  final List<int> res;
  const ResultPage({super.key,required this.id,required this.data,required this.ans,required this.res,required this.email});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late int correct = 0;
  late int answered = 0;
  late int unanswered = 0;
  late int unvisited = 0;
  // late int reviewed = 0;

  late Map<String,dynamic> testData = {};
  late String testID = '';
  late List<String> answers = [];
  late String emailID = '';
  late List<int> result = [];

  @override
  void initState() {
    testID = widget.id;
    testData = widget.data;
    answers = widget.ans;
    result = widget.res;
    emailID = widget.email;
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: getQuestionPaper(testID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text('')),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: Text('CCW Test')),
              body: Center(child: Text("Error fetching the data")),
            );
          } else if (snapshot.hasData){
            var questionPaper = snapshot.data as List<Map<String,dynamic>>;
            correct = result[0];
            answered = result[1];
            unanswered = result[2];
            unvisited = result[3];
            // reviewed = result[4];
            var noOfQuestions = questionPaper.length;
            return Center(
              child: Column(
                children: [
                  // SizedBox(
                  //   height: 55,
                  //   width: double.infinity,
                  //   child: ColoredBox(
                  //     color: Colors.indigo,
                  //     child: Center(
                  //       child: Text(
                  //         testData['Topic'],
                  //         style: TextStyle(fontSize: 20, color: Colors.white),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    // height: 100,
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      'Topic: ${testData['Topic']}',
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        'Marks : $correct/$noOfQuestions',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const ListTile(
                    title: Text(
                      'No of Questions',
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('$answered')),
                    title: const Text('Answered'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text('$unanswered')),
                    title: const Text('Not Answered'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text('$unvisited')),
                    title: const Text('Not Visited'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  // ListTile(
                  //   leading: CircleAvatar(
                  //       backgroundColor: Colors.purpleAccent,
                  //       child: Text('$reviewed')),
                  //   title: const Text('Marked for review'),
                  //   dense: true, // Set dense to true for compact spacing
                  // ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                        color: Colors.amber,
                        shadowColor: Colors.black,
                        elevation: 7,
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Solutions'),
                              subtitle:
                                  const Text('Question Paper Analysis and Solutions'),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: ((context) => CorrectedQuestionPaper(data: testData,id: testID,ans: answers,res: result,))));
                              },
                            )
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                        color: Colors.black,
                        shadowColor: Colors.black,
                        elevation: 7,
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Return to home page',textAlign: TextAlign.center,style: TextStyle(color: Colors.amber),),
                              // subtitle:
                              //     const Text('Return to home page'),
                              onTap: () {
                                Navigator.popAndPushNamed(context, '/');
                              },
                            )
                          ],
                        )),
                  ),
                ],
              ),
            );
          }
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20.0),
                  Text(
                    'Please Wait while Results are loading..',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.none,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}
