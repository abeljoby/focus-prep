import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class CreateClassroom extends StatefulWidget {
  const CreateClassroom({super.key});
  @override
  CreateClassroomState createState() => CreateClassroomState();
}

class CreateClassroomState extends State<CreateClassroom> {
  String? ClassName;
  String? classroomCode;

  FirebaseFirestore db = FirebaseFirestore.instance;

  late String? name = '';
  late String? ktuID = '';
  
  @override
  void initState() {
    loadUserDetails();
    super.initState();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
    });
  }

  final _formKey = GlobalKey<FormState>();

  String generateCode(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create classroom', style: TextStyle(color: Colors.yellow,)),
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Image(image: AssetImage("images/classroom.jpg")),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a classroom name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        ClassName = value;
                      });
                    },
                  ),
                  const SizedBox(height:20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          classroomCode = generateCode(6);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Classroom created.')),
                          );
                          final classroom = <String, dynamic>{
                            "Name": ClassName,
                            "Code": classroomCode,
                            "Teacher": {"Name":name,"ktuID":ktuID},
                            "Students": [],
                            "ktuID": ktuID,
                          };
                          db.collection("classrooms").doc(classroomCode).set(classroom);
                          final student = <String, dynamic>{
                            "Name": name,
                            "ktuID": ktuID,
                          };
                          db.collection("classrooms").doc(classroomCode).update({"Students": FieldValue.arrayUnion([student])});
                          Navigator.pop(context);
                          Future.delayed(Duration.zero, () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Classroom created'),
                                  content: Text('You have created a classroom\nCode: $classroomCode'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 50),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
