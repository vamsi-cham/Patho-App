import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/Customer/customerHome.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_lab/authentication/login.dart';

class Caccount extends StatefulWidget {
  @override
  _CaccountState createState() => _CaccountState();
}

class _CaccountState extends State<Caccount> {
  String name = labs[0]['patient_name'];
  String mobile = labs[0]['mobile'];
  var phone =  labs[0]['mobile'];

  Future checkuser() async{

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"checkuser.php"),body:{

      "mobile" :mobile,
      "action" : "checkuser",
      "tb":"user",

    });
    var data = json.decode(response.body);
    //print(data);

    if(data['status']==200){  //This means the user is already registered with this number.
      Fluttertoast.showToast(
          msg: "Account is already registered with this mobile number" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    if(data['status']==201){  //This means the user is not registered with this number

      return updateuser();  //This updates user table in the db
    }

  }

  Future updateuser() async {  //This updates user table in the db

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"updateuser.php"),body:{
      "phone" : phone,
      "name" : name,
      "mobile" : mobile,
      "tb" : "user",
      "action" : "updateuser"


    });
    print(response.body);

    if(response.statusCode==200) {

      return updatelabpatient(); //After updating user table then it updates labSupervisor table
      // print(user);

    }
  }

  Future updatelabpatient() async {  //This updates lab_patients table in the db

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"updatelabpatient.php"),body:{
      "phone" : phone ,
      "name" : name,
      "mobile" : mobile,
      "tb" : "lab_patients",
      "action" : "updatelabpatient"


    });
    print(response.body);

    if(response.statusCode==200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return CustomerHome(mobile: mobile);
          },
        ),
      );

      Fluttertoast.showToast(
          msg: "updated successfully" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
      // print(user);

    }
  }

  Future<void> _showMyDialog(BuildContext context) async {


    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.montserrat(color: Colors.blue,fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //Text('This is a demo alert dialog.'),
                Text(
                  'Are you sure to logout ?',
                  style: GoogleFonts.montserrat(color: Colors.black,fontSize: 20),


                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Yes',
                style: GoogleFonts.montserrat(color: Colors.blue),


              ),
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs?.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  // the new route
                  MaterialPageRoute(
                    builder: (BuildContext context) => Login(),
                  ),

                  // this function should return true when we're done removing routes
                  // but because we want to remove all other screens, we make it
                  // always return false
                      (Route route) => false,
                );
                Fluttertoast.showToast(
                    msg: "You are logged out" ,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 4,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: GoogleFonts.montserrat(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.logout),color: Colors.blue,iconSize: 24, onPressed: () {
            _showMyDialog(context);
          }),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,

      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //Spacer(),

              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage("https://images.unsplash.com/photo-1612277795421-9bc7706a4a34?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80") ,
                ),
              ),

              Text(
                "\n\nName\n",
                style: GoogleFonts.montserrat(
                  color: Colors.blueGrey,
                  fontSize: 15.0,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: 45,
                padding:
                EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5)
                    ]),
                child: TextFormField(


                  initialValue: name,
                  decoration: InputDecoration(
                    border: InputBorder.none,

                    hintText: 'Name',
                    icon: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  onChanged: (value){
                    setState(() {
                      name = value;
                    });
                  },


                ),
              ),
              Text(
                "\nPhone number\n",
                style: GoogleFonts.montserrat(
                  color: Colors.blueGrey,
                  fontSize: 15.0,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: 45,
                padding:
                EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5)
                    ]),
                child: TextFormField(


                  initialValue: mobile,
                  decoration: InputDecoration(
                    border: InputBorder.none,

                    hintText: 'Mobile number',

                    icon: Icon(
                      Icons.phone,
                      color: Colors.blue,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value){
                    setState(() {
                      mobile = value;
                    });
                  },


                ),
              ),

              SizedBox(
                height: 40,
              ),

              InkWell(
                onTap: (name.isNotEmpty && mobile.length>=10 ) ? () async {

                  if(phone == mobile){

                    updateuser(); //This updates user table in the db

                  }else{  //if the user tries to update his mobile number,it first checks there is any account with this number.
                    checkuser();
                  }
                }:null,
                child: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width / 3.0,
                  decoration: (name.isNotEmpty && mobile.length>=10 ) ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.blue,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50))) : BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[50],
                          Colors.grey[50],
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: (name.isNotEmpty && mobile.length>=10 ) ? Center(
                    child: Text(
                      'Save'.toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.white,fontSize: 16,),
                    ),
                  ) :  Center(
                    child: Text(
                      'Save'.toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 16,),
                    ),
                  ),
                ),
              ),

              // Spacer(flex: 3,),
            ],
          ),
        ),
      ),


    );
  }
}

