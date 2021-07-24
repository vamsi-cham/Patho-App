import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/Customer/Caccount.dart';
import 'package:test_lab/Customer/categories.dart';
import 'package:test_lab/Customer/mylabs.dart';
import 'dart:convert';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/widget/loading.dart';

List labs = [];

class CustomerHome extends StatefulWidget {
  final String mobile;

  // receive data from the FirstScreen as a parameter
  CustomerHome({Key key, @required this.mobile}) : super(key: key);
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {

  bool loading = false;

  Future getprofileInfo() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "login.php"), body: {
      "mobile": widget.mobile,
      "tb": "lab_patients",
      "action": "login"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    labs = data['data'];
    print(labs);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setString('Mobile', labs[0]['mobile']);
    prefs?.setString('Role', "Customer");
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    getprofileInfo();
    super.initState();
  }

  int pageIndex = 1;
  List<Widget> pageList = <Widget>[

    Categories(),
    MyLabs(),
    Caccount(),

    // Profile(),

  ];

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : SafeArea(
      child: Scaffold(
        body: pageList[pageIndex],
        bottomNavigationBar: CurvedNavigationBar(
          height: 45,
          index: pageIndex,
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          items: [

            (Icon(Icons.calendar_today_rounded, color: Colors.blue,size: 20,)),
            (Icon(Icons.home, color: Colors.blue,size: 20,)),
            //(Icon(Icons.microwave_sharp, color: Colors.blueGrey,)),
            //(Icon(Icons.person,color: Colors.blueGrey,) ),
            CircleAvatar(
              radius: 15,
              backgroundImage:
              NetworkImage("https://images.unsplash.com/photo-1612277795421-9bc7706a4a34?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80") ,
            ),

          ],
        ),
      ),
    );
  }
}
