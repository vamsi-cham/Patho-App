import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/LabSupervisor/Laccount.dart';
import 'package:test_lab/LabSupervisor/home.dart';
import 'package:test_lab/LabSupervisor/laborders.dart';
import 'dart:convert';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/main.dart';
import 'package:test_lab/widget/loading.dart';

var invitelink;

class LabHome extends StatefulWidget {
  final String mobile;

  // receive data from the FirstScreen as a parameter
  LabHome({Key key, @required this.mobile}) : super(key: key);
  @override
  _LabHomeState createState() => _LabHomeState();
}

class _LabHomeState extends State<LabHome> {

  bool loading = false;

  Future getinvitelink() async{
    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getinvitelink.php"), body: {
      "tb": "invitelink",
      "action": "getinvitelink"
    });
    var data = json.decode(response.body);
    invitelink = data['data'][0]['link'];
    print(invitelink);
    setState(() {
      loading = false;
    });
  }

  Future getprofileInfo() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "login.php"), body: {
      "mobile": widget.mobile,
      "tb": "labSupervisor",
      "action": "login"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    user = data['data'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setString('Mobile', user[0]['mobile']);
    prefs?.setString('Role', "labSupervisor");
    print(user);

    getinvitelink();

  }

  @override
  void initState() {
    getprofileInfo();
    super.initState();
  }

  int pageIndex = 1;
  List<Widget> pageList = <Widget>[

    LabOrders(),
    Home(),
    LabAccount(),

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
            (Icon(Icons.local_hospital, color: Colors.blue,size: 20,)),
            (Icon(Icons.home, color: Colors.blue,size: 20,)),
            //(Icon(Icons.microwave_sharp, color: Colors.blueGrey,)),
            //(Icon(Icons.person,color: Colors.blueGrey,) ),
            CircleAvatar(
             radius: 20,
              backgroundImage: NetworkImage("https://images.unsplash.com/photo-1511174511562-5f7f18b874f8?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80") ,
            ),

          ],
        ),
      ),
    );
  }
}