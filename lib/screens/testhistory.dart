import 'package:ccwassist/screens/studentresult.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHistory extends StatefulWidget {
  const TestHistory({super.key});

  @override
  State<TestHistory> createState() => _TestHistoryState();
}

class _TestHistoryState extends State<TestHistory> {

  late String currentDate = '';
  late String? name = '';
  late String? batch = '';
  late String? ktuID = '';
  late String? email = '';
  late String? dept = '';
  late Stream<QuerySnapshot> _testStream;
  
  @override
  void initState() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    currentDate = formatter.format(now);
    loadUserDetails();
    super.initState();
    // fetchData();
    _testStream = FirebaseFirestore.instance.collection('tests').where('StartDate',isLessThanOrEqualTo: currentDate).orderBy('StartDate',descending: true).orderBy('StartTime',descending: true).snapshots();
  }

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

  Future<bool> fetchResult(String? id, String? ktuid) async {
    try {
    // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('tests');
      var doc = await collectionRef.doc(id).collection('results').doc(ktuid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildTestSection({
    required Map<String, dynamic> data,
    required String id
  }) {

    String dateHeading = "";

    if(data["StartDate"] != "") {
      String dateString = data["StartDate"];
      // Parse the date string
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTime = dateFormat.parse(dateString);

      // Get Day of week as string
      DateFormat dayOfWeekFormat = DateFormat("EEEE"); // EEEE for full weekday name
      String dayOfWeek = dayOfWeekFormat.format(dateTime);

      // Format the date with desired output format
      DateFormat monthYearFormat = DateFormat("d MMMM yyyy"); // d for day with no leading zero, MMMM for full month name
      String formattedDate = monthYearFormat.format(dateTime);

      // Combine day of week and formatted date
      dateHeading = "$dayOfWeek, $formattedDate";
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
          width: double.infinity,
          color: Colors.black,
          child: Text(dateHeading, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              (data.containsKey("Topic") && data["Topic"] != "")?Text('Topic: ${data["Topic"]}', style: TextStyle(fontWeight: FontWeight.bold),):const SizedBox.shrink(),
              // (data.containsKey("Classroom") && data["Classroom"] != "")?Text('Classroom: ${data["Classroom"]}'):Text('Self-study test'),
              Text('${data["Questions"]} questions'),
              Text(data['StartDate']),
              Text(data['StartTime']),
              // Text(data['Course'],style: TextStyle(fontWeight: FontWeight.bold)),
              // Text("Modules ${data["Modules"].toString().substring(1, data["Modules"].toString().length - 1)}"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder(
                    future: fetchResult(id,ktuID),
                    builder: (context, snapshot){
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData && snapshot.data!) {
                        return ElevatedButton(
                          onPressed: () {
                            // Handle edit test action
                            Navigator.push(context,MaterialPageRoute(builder: ((context) => StudentResult(data: data,testid: id,ktuid: ktuID!,name: name!))));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black
                          ),
                          child: const Text('View Result'),
                        );
                      } else {
                        return const Text('Did not attend test', style: TextStyle(fontWeight: FontWeight.bold));
                      }
                    },
                  )
                ],
              ),
              // const Divider(), // Add a divider
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: _testStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
          }
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return _buildTestSection(data: data, id: document.id);
            }).toList(),
          );
        },
      ),
    );
  }
}