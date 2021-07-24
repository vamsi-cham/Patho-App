import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/Customer/customerHome.dart';
import 'package:test_lab/Customer/downloadreport.dart';
import 'package:test_lab/Customer/joinlab.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyLabs extends StatefulWidget {
  @override
  _MyLabsState createState() => _MyLabsState();
}

var mobile = labs[0]['mobile']; // mobile number of customer
var name = labs[0]['patient_name']; //name of customer

final List<String> imgList = [
  'https://images.unsplash.com/photo-1581594549595-35f6edc7b762?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
  'https://images.unsplash.com/photo-1600682231206-721e1bcba5ec?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGVzdCUyMGxhYnxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
  'https://images.unsplash.com/photo-1598300188480-626f2f79ab8d?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHRlc3QlMjBsYWJ8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
  'https://images.unsplash.com/photo-1557825835-70d97c4aa567?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1050&q=80',

];

final List<String> imgdes = [

  'Enroll lab - Get reports online',
  'Download Reports',
  'Book tests - In enrolled labs',
  'Create lab - Upload your customers report',
];

class _MyLabsState extends State<MyLabs> {

  Future getprofileInfo() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "login.php"), body: {
      "mobile": mobile,
      "tb": "lab_patients",
      "action": "login"
    });

    var data = json.decode(response.body);

    setState(() {
      labs = data['data'];
    });

    print(labs);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setString('Mobile', labs[0]['mobile']);
    prefs?.setString('Role', "Customer");

  }

  final List<Widget> imageSliders = imgList.map((item) => Container(
    child: Container(
      margin: EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '${imgdes[imgList.indexOf(item)]}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    ),
  )).toList();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: getprofileInfo,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    IconButton(icon: Icon(Icons.help),color: Colors.blue,iconSize: 24, onPressed: () {}),
                  ],
                ),
                Container(
                    child: Column(children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                         // enlargeStrategy: CenterPageEnlargeStrategy.height,
                        ),
                        items: imageSliders,
                      ),
                    ],)
                ),

                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/patient.png"),
                      //fit: BoxFit.cover,
                    ),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Get enrolled in test labs to\n get your lab reports",
                    style: GoogleFonts.montserrat(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Your Labs",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(),
                    TextButton.icon(
                        onPressed: () async{
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => JoinLab(mobile: mobile, name: name)),
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          size: 19,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Enroll Lab',
                          style: GoogleFonts.montserrat(color: Colors.blue,fontSize: 16,),

                        )
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: labs.length,
                        itemBuilder: (BuildContext context,int index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              // if you need this
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Row(
                                    children: [
                                      labs[index]['approval'] == "accepted" ?Text(
                                        '${labs[index]['lab_name']}  [ ${labs[index]['lab_id']} ]',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black, fontSize: 16,),

                                      ):Text(
                                        'Lab ID - ${labs[index]['lab_id']}',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black, fontSize: 15,),

                                      ),
                                      Spacer(),
                                      IconButton(
                                          icon: Icon(Icons.arrow_forward_ios),
                                          color: Colors.blue,
                                          iconSize: 18,
                                          onPressed: labs[index]['approval'] == "accepted" ? () {
                                            print(labs[index]['report']);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => DownloadReport(filename: labs[index]['report'],)),
                                            );

                                          }:null,
                                          )
                                    ],
                                  ),
                                  subtitle: labs[index]['approval'] == "pending" ? Text(
                                    'Approval Pending',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey, fontSize: 14,),
                                  ): labs[index]['approval'] == "accepted" ?Text(
                                    '${labs[index]['lab_type']}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey, fontSize: 14,),
                                  ) : Text(
                                    'Request declined',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey, fontSize: 14,),
                                  ),
                                ),

                                Visibility(
                                visible: (labs[index]['approval'] == "accepted"),
                                child: (labs[index]['report'] == "not uploaded" ) ? Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'No report uploaded yet',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey, fontSize: 14,),
                                      ),
                                    ),
                                  ],
                                 ) : Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Report uploaded',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey, fontSize: 14,),
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ],
                            ),
                          );
                        }
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
