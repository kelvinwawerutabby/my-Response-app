import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form001/emergency_class.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentindex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [HomePage(), AccountPage()][currentindex],
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: currentindex,
          onTap: ((value) => setState(() => currentindex = value)),
          items: ['Home', 'Account']
              .map((e) => BottomNavigationBarItem(
                    icon: Text(e),
                  ))
              .toList()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Emergencies')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return SizedBox(
                    height: 200,
                    width: 200,
                    child: GridTile(
                      header: Text(data['description']),
                      child: Image.network(
                        data['image'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      footer: Text(data['numberOfPeople'].toString()),
                    ),
                  );
                }).toList(),
              );
            },
          )),
          Center(
            child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyPage(),
                    ),
                  );
                },
                color: Colors.red,
                child: Text('Report an emergency')),
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Account'),
      ),
    );
  }
}

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  @override
  Widget build(BuildContext context) {
    var _descriptionController = TextEditingController();
    var _numberOfPeopleController = TextEditingController();
    bool loading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an emergency'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                maxLines: 5,
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _numberOfPeopleController,
                decoration: InputDecoration(
                  labelText: 'Number of people affected',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                color: Colors.green,
                onPressed: () async {
                  try {
                    await EmergencyClass().createAnEmergency(
                      description: _descriptionController.text,
                      numberOfPeople: int.parse(_numberOfPeopleController.text),
                    );
                    Navigator.pop(context);
                  } on FirebaseException catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text(e.message!),
                          );
                        });
                  }
                },
                child: Text('Report'),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
