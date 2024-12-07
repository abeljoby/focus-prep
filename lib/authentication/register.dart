import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late Image image1;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  String userType = "Student";

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    image1 = Image.asset("images/ritgate.jpg");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image1.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image1,
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: buildStudentFields(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStudentFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            controller: name,
            decoration: InputDecoration(labelText: 'Name',border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email ID';
              }
              return null;
            },
            controller: email,
            decoration: InputDecoration(labelText: 'Email ID',border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            controller: password,
            decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value != password.text) {
                return 'The passwords entered do not match';
              }
              return null;
            },
            controller: confirmpassword,
            decoration: InputDecoration(labelText: 'Confirm Password',border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                _register(context,email.text,password.text);
                // Handle student registration logic
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 50),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String generateCode(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  void _register(BuildContext context, String mail, String pass) async {
    String ktuid = generateCode(10);
    if (_formKey.currentState!.validate()) {
      var studentSnapshot = await FirebaseFirestore.instance.collection("users").where("ktuID",isEqualTo: ktuid).get();
      if(studentSnapshot.docs.isEmpty) {
        try {
          final cred = await _auth.createUserWithEmailAndPassword(email: mail,password: pass);
          final user = <String, dynamic>{
            "email": email.text,
            "ktuID": ktuid,
            "name": name.text,
            "uid": cred.user?.uid,
            "userType": userType
          };
          db.collection("users").add(user).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
          Navigator.pop(context);
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An account already exists with the same KTU ID."),
          ),
        );
      }
    }
  }
}