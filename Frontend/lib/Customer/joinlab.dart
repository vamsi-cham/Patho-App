import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/Customer/customerHome.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'dart:convert';


class JoinLab extends StatefulWidget {
  final String mobile;
  final String name;

  // receive data from the FirstScreen as a parameter
  JoinLab({Key key, @required this.mobile , @required this.name}) : super(key: key);
  @override
  _JoinLabState createState() => _JoinLabState();
}

class _JoinLabState extends State<JoinLab> {

  var labid = '';
  var labname;
  var labtype;

  Future checklabid() async{   //This checks lab exists or not
    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "checklabid.php"), body: {
      "lab_id": labid,
      "action": "checklabid",
      "tb": "labSupervisor",

    });
    var data = json.decode(response.body);

    print(data);


    if(data['status']==200){

      labname=data['data'][0]['lab_name'];
      labtype=data['data'][0]['lab_type'];

      print("valid lab id");
      return checkenrollment();


    }
    if(data['status']==201){
      print("invalid lab id");
      Fluttertoast.showToast(
          msg: "Unable to find the lab",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return ;
    }
  }

  Future checkenrollment() async{   //This checks the customer was already enrolled or not.
    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "checkenrollment.php"), body: {
      "lab_id": labid,
      "mobile": widget.mobile,
      "action": "checkenrollment",
      "tb": "lab_patients",

    });
    var data = json.decode(response.body);

    print(data);


    if(data['status']==200){

      print("Already enrolled");
      Fluttertoast.showToast(
          msg: "you have already enrolled in this lab",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return ;

    }
    if(data['status']==201){

      print("Not already enrolled");
      return invitepatient();

    }
  }

  Future invitepatient() async{
    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "addpatient.php"), body: {
      "lab_id": labid,
      "lab_name": labname,
      "lab_type": labtype,
      "patient_name": widget.name,
      "mobile": widget.mobile,
      "action": "addpatient",
      "tb": "lab_patients",

    });
    if(response.statusCode==200){

      print("joined successfully");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isLoggedIn", true);

      Navigator.of(context).pushAndRemoveUntil(
        // the new route
        MaterialPageRoute(
          builder: (BuildContext context) => CustomerHome(mobile: widget.mobile,),
        ),

        // this function should return true when we're done removing routes
        // but because we want to remove all other screens, we make it
        // always return false
            (Route route) => false,
      );
      //return getpatientId();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:<Widget> [
                Row(
                  children: [
                    Text(
                      "Enroll in your first test lab",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 27.0,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text(
                  "\nAsk your lab supervisor to share the lab ID with you.\n",
                  style: GoogleFonts.montserrat(
                    color: Colors.blueGrey,
                    fontSize: 14.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "\nEnter test lab ID\n",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(

                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.grey)),
                      hintText: 'Get lab ID from your lab supervisor',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value){
                      setState(() {
                        labid = value;
                      });
                    },
                  ),

                ),
                SizedBox(height: 30,),
                InkWell(
                  onTap: (labid.length > 7) ? () async {

                    checklabid();

                  } : null ,
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: (labid.length > 7) ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blue,
                          ],
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(50))) : BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[50],
                            Colors.grey[50],
                          ],
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(50))),
                    child: (labid.length > 7) ? Center(
                      child: Text(
                        'Continue',
                        style: GoogleFonts.montserrat(color: Colors.white,fontSize: 19,),
                      ),
                    ) :  Center(
                      child: Text(
                        'Continue',
                        style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 19,),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
