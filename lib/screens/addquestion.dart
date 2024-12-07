import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionForm extends StatefulWidget {
  const QuestionForm({super.key});
  @override
  QuestionFormState createState() => QuestionFormState();
}

class QuestionFormState extends State<QuestionForm> {
  String? Option1;
  String? Option2;
  String? Option3;
  String? Option4;
  String? CorrectOption;
  String? Question;
  String? selecteddifficulty;
  String? selectedtopic;

  final difficulties = {"Easy":"Moderate","Moderate":"Hard","Hard":"Very Difficult"};

  bool isRadioSelected = false;

  final _formKey = GlobalKey<FormState>();

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add question', style: TextStyle(color: Colors.amber,)),
        iconTheme: const IconThemeData(
          color: Colors.amber, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: 
        Form(key: _formKey,
        child: SizedBox(height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter topic',
              ),
              // maxLines: 5,
              onChanged: (String? newValue) {
                setState(() {
                  selectedtopic = newValue;
                });
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter question',
              ),
              maxLines: 3,
              onChanged: (String? newValue) {
                setState(() {
                  Question = newValue;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              validator: (value) {
                if (value == null || value.isEmpty || value == 'Select') {
                  return 'Please select a difficulty';
                }
                return null;
              },
              hint: const Text("Select"),
              // value: Course,
              items: difficulties.keys
                .map((e) => DropdownMenuItem(value: difficulties[e], child: Text(e)))
                .toList(),
              onChanged: (newValue) {
                setState(() {
                  selecteddifficulty = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            RadioListTile<String?>(
              title: SizedBox(width: 300, child: TextFormField(
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Option 1',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    Option1 = newValue;
                  });
                },
              )),
              value: "Option1", groupValue: CorrectOption,
              onChanged: (String? value) {
                setState(() {
                  isRadioSelected = true;
                  CorrectOption = value;
                });
              },
            ),
            RadioListTile<String?>(
              title: SizedBox(width: 300, child: TextFormField(
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Option 2',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    Option2 = newValue;
                  });
                },
              )),
              value: "Option2", groupValue: CorrectOption,
              onChanged: (String? value) {
                setState(() {
                  isRadioSelected = true;
                  CorrectOption = value;
                });
              }
            ),
            RadioListTile<String?>(
              title: SizedBox(width: 300, child: TextFormField(
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Option 3',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    Option3 = newValue;
                  });
                },
              )),
              value: "Option3", groupValue: CorrectOption,
              onChanged: (String? value) {
                setState(() {
                  isRadioSelected = true;
                  CorrectOption = value;
                });
              }
            ),
            RadioListTile<String?>(
              title: SizedBox(width: 300, child: TextFormField(
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Option 4',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    Option4 = newValue;
                  });
                },
              )),
              value: "Option4", groupValue: CorrectOption,
              onChanged: (String? value) {
                setState(() {
                  isRadioSelected = true;
                  CorrectOption = value;
                });
              }
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                fixedSize: MaterialStateProperty.all(const Size(200, 80))
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (isRadioSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to question bank.')),
                    );
                    final question = <String, dynamic>{
                      "Question": Question,
                      "Topic": selectedtopic,
                      "CorrectOption": CorrectOption,
                      "Option1": Option1,
                      "Option2": Option2,
                      "Option3": Option3,
                      "Option4": Option4,
                      "Difficulty": selecteddifficulty,
                    };
                    db.collection("questions").add(question).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
                    Navigator.popAndPushNamed(context, '/currentRoute');
                  }
                  else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select a correct option.')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
        ]
              ),
            ),
          ),
        ),
      )
    );
  }
}
