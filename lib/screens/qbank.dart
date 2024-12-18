import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QBank extends StatefulWidget {
  const QBank({super.key});
  @override
  State<QBank> createState() => QBankState();
}

class QBankState extends State<QBank> {
  final Stream<QuerySnapshot> _questionStream = FirebaseFirestore.instance.collection('questions').orderBy("Topic").snapshots();

  deleteUser(String docID) async {
    FirebaseFirestore.instance.collection('questions').doc(docID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank',style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/qform');
        },
        label: Text('Add question'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        icon: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // Container(
        //   decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        //   padding: const EdgeInsets.all(20),
        //   child: DropdownButtonFormField<String>(
        //     // hint: const Text("Select"),
        //     value: _selectedOption,
        //     items: courses.keys.map((String key) {
        //       return DropdownMenuItem <String>(
        //         value: key,
        //         child: Text(key)
        //       );
        //     }).toList(),
        //     onChanged: (String? newValue) {
        //       setState(() {
        //         _selectedOption = newValue;
        //       });
        //     },
        //     decoration: const InputDecoration(
        //       labelText: 'Topic',
        //       border: OutlineInputBorder(),
        //     ),
        //   ),
        // ),
        Expanded(child: Container(
          // padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _questionStream,
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
                  if((data["Question"] == null)||(data["Option1"] == null)||(data["Option2"] == null)||(data["Option3"] == null)||(data["Option4"] == null)||(data["CorrectOption"] == null)) {
                    print(document.id);
                  }
                  if((data["Question"] == null)||(data["Option1"] == null)||(data["Option2"] == null)||(data["Option3"] == null)||(data["Option4"] == null)||(data["CorrectOption"] == null)) {
                    return SizedBox.shrink();
                  }
                  else {
                  return Container(
                    // padding: const EdgeInsets.only(top: 0,bottom: 8,left: 4,right: 4),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ExpansionTile(
                          // expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          shape: const Border(),
                          initiallyExpanded: false,
                          title: Text("${data['Topic']}\n${data['Question']}", style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2,overflow: TextOverflow.ellipsis),
                          // trailing: InkWell(
                          //   child: Text("Classroom Code: ${classData['Code']}",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          //   onTap: () {
                          //     Clipboard.setData(ClipboardData(text: "${classData['Code']}"))
                          //     .then((_) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(content: Text('Classroom code copied to your clipboard.')));
                          //     });
                          //   },
                          // ),
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text("${data['Topic']}\n${data['Question']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    // const SizedBox(height: 8),
                                    Text("${data['Question']}\n"),
                                    Text("1. ${data['Option1']}"),
                                    Text("2. ${data['Option2']}"),
                                    Text("3. ${data['Option3']}"),
                                    Text("4. ${data['Option4']}"),
                                    const SizedBox(height: 8),
                                    Text("Correct Option: ${data['CorrectOption'].substring(6)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // ElevatedButton(
                                        //   onPressed: () {
                                        //     // Handle edit test action
                                        //   },
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: Colors.indigo,
                                        //     foregroundColor: Colors.white
                                        //   ),
                                        //   child: const Text('Edit'),
                                        // ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Handle delete test action
                                            setState(() {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: Text('Confirm delete'),
                                                  content: Text('Are you sure you want to delete this question?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context, rootNavigator: true)
                                                            .pop(false);
                                                      },
                                                      child: Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context, rootNavigator: true)
                                                            .pop(true);
                                                        deleteUser(document.id);
                                                      },
                                                      child: Text('Yes'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            )
                          ]
                        )
                      ),
                    ),
                  );
                  }
                }).toList(),
              );
            },
          ),
        )),
        ]
      )
    );
  }
}
