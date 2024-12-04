import 'package:ccwassist/screens/generatepaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTest extends StatefulWidget {
  const CreateTest({super.key});
  @override
  State<CreateTest> createState() => _CreateTestState();
}

class _CreateTestState extends State<CreateTest> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  final durations = ['15 min','30 min', '60 min'];
  final departments = {'CSE':'Computer Science and Engineering', 'ECE':'Electronics and Communications Engineering','EEE':'Electrical and Electronics Engineering', 'ME':'Mechanical Engineering', 'CE':'Civil Engineering'};
  List<String> courses = [];
  // final courses = {'DMS':'Discrete Mathematical Structures', 'DS':'Data Structures','COA':'Computer Organization and Architecture', 'DBMS':'Database Management Systems', 'OS':'Operating Systems', 'FLAT':'Formal Languages and Automata Theory'};
  String? selectedduration;
  String? selecteddept;
  String? selectedtopic;
  String? selectedcourse;
  int? questions = 0;
  bool quizStart = true;
  List<String> selectedmodules = [];
  List<String> classrooms = [];

  final _formKey = GlobalKey<FormState>();

  FirebaseFirestore db = FirebaseFirestore.instance;

  late String? name = '';
  late String? ktuID = '';
  
  @override
  void initState() {
    loadUserDetails();
    loadClassrooms();
    super.initState();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
    });
  }

  void loadClassrooms() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('classrooms')
        .where('Teacher.ktuID', isEqualTo: ktuID)
        .get();
    setState(() {
      classrooms = querySnapshot.docs.map((doc) => doc['Name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
        // leading: IconButton(onPressed: (){}, icon: const Icon(Icons.menu)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                // const Image(image: AssetImage("images/objectivetest.jpg")),
                const SizedBox(height:10),
                SegmentedButton(
                  segments: const <ButtonSegment>[
                    ButtonSegment(
                      value: true,
                      label: Text('Start now'),
                      icon: Icon(Icons.timer_outlined)),
                    ButtonSegment(
                      value: false,
                      label: Text('Schedule'),
                      icon: Icon(Icons.calendar_month)),
                  ],
                  selected: {quizStart},
                  onSelectionChanged: (Set newSelection) {
                    setState(() {
                      // By default there is only a single segment that can be
                      // selected at one time, so its value is always the first
                      // item in the selected set.
                      quizStart = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height:20),
                quizStart ? Container():
                Column(
                  children: [
                    TextFormField(
                      controller: dateInput,
                      decoration: InputDecoration(
                        // icon: Icon(Icons.calendar_today),
                        labelText: "Enter Date",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2100)
                        );
                        if (pickedDate != null) {
                          // print(pickedDate);
                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                          // print(formattedDate);
                          setState(() {
                            dateInput.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {}
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'Select') {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height:20),
                    TextFormField(
                      controller: timeInput,
                      decoration: InputDecoration(
                        // icon: Icon(Icons.access_time),
                        labelText: "Enter Start Time",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 0, minute: 0)
                        );
                        if (pickedTime != null) {
                          setState(() {
                            timeInput.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}'; //set output date to TextField value.
                          });
                        } else {}
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'Select') {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height:20),
                  ],
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Duration",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  items: durations
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    selectedduration = val;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Select') {
                      return 'Please select a duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height:20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Topic',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      selectedtopic = value;
                    });
                  },
                ),
                const SizedBox(height:20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of questions';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Number of Questions',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onChanged: (value) {
                      questions = int.parse(value);
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final test = <String, dynamic>{
                        "Questions": questions,
                        "Course": selectedcourse,
                        "Modules": selectedmodules,
                        "StartDate": dateInput.text,
                        "StartTime": timeInput.text,
                        "Duration": selectedduration,
                        "Department": selecteddept,
                        "Topic": selectedtopic,
                        // "Batch": "2023-24"
                      };
                      Navigator.push(context,MaterialPageRoute(builder: ((context) => GenerateQuestionPaper(data: test))));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generated question paper.')),
                      );
                      //db.collection("tests").add(test).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 60), // Specify the width and height
                    backgroundColor: Colors.amber, // Background color
                    foregroundColor: Colors.black, // Text color
                  ),
                  child: const Text('Generate Question Paper',style: TextStyle(fontSize: 20),),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
