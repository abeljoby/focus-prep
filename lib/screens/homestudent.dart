import 'package:ccwassist/screens/createtest.dart';
import 'package:ccwassist/screens/homewrapper.dart';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:ccwassist/screens/teacherclassroom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upcomingtests.dart';
import 'profile.dart';
import 'testhistory.dart';

class HomeStudent extends StatefulWidget {
  final Map data;
  const HomeStudent({super.key, required this.data});

  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  final user = FirebaseAuth.instance.currentUser!;
  late Map userDetails = {};
  late String name = "";

  @override 
  void initState() {
    userDetails = widget.data;
    print(userDetails);
    // clearUserDetails();
    storeUserDetails();
    super.initState();
  }

  void clearUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  void storeUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("email", userDetails["email"]);
      prefs.setString("ktuID", userDetails["ktuID"]);
      prefs.setString("name", userDetails["name"]);
      prefs.setString("userType", userDetails["userType"]);
      name = userDetails["name"];
    });
  }

  logout() async {
    clearUserDetails();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeWrapper()),ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const ProfilePage())));
              },
              icon: const Icon(Icons.person_rounded,color: Colors.black,size: 30,),
              tooltip:'View Profile'),
        ],
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Image(image: AssetImage('images/ritcsdept.jpg')),
              const SizedBox(height: 20),
              Text('Welcome, ${name}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: ((context) => const CreateTest())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Create New Test',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                padding: const EdgeInsets.all(15.0),
                child: Material(
                  color: Colors.amber,
                  elevation: 7.0,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox( // Set specific height and width
                    height: 80.0,
                    width: 150.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder: ((context) => const Classroom())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Classrooms',
                            style: TextStyle(fontSize: 19.0),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const UpcomingTests())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Upcoming Tests',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const ScheduledTests())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Scheduled Tests',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),    
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Material(
                  color: Colors.amber,
                  elevation: 7.0,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox( // Set specific height and width
                    height: 80.0,
                    width: 345.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  const TestHistory())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Test History',
                            style: TextStyle(fontSize: 19.0),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/joinclass');
        },
        label: Text('Join classroom'),
        // shape: const CircleBorder(),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        icon: const Icon(Icons.add),
      ),
    );
  }
}
