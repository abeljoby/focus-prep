import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccwassist/screens/homewrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? name = '';
  late String? ktuID = '';
  late String? email = '';
  late String? type = '';

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
      email = prefs.getString("email");
      type = prefs.getString("userType");
    });
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    loadUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
            ),
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person,size: 60),
            ),
            const SizedBox(
              height: 20,
            ),
            Text("$name",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            const SizedBox(
              height: 80,
            ),
            ListTile(
              title: Text("User ID: $ktuID",
                style: TextStyle(fontSize: 15),
              ),
              textColor: Colors.black,
            ),
      //      const Divider(),
          //  const Divider(),
            // const ListTile(
            //   title: Text("Username : 21BR14377",
            //     style: TextStyle(fontSize: 15),
            //   ),
            //   textColor: Colors.black,
            // ),
          //  const Divider(),
            ListTile(
              title: Text("Email ID: $email",
                style: TextStyle(fontSize: 15),
              ),
              textColor: Colors.black,
            ),
            // const Divider(),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(onPressed: () {
              logout();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeWrapper()),ModalRoute.withName('/'));
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                fixedSize: const Size(200, 50),
              ),
              child: const Text('Logout',style: TextStyle(fontSize:20 ))
            )
          ],
        ),
      )
      
    );
  }
}