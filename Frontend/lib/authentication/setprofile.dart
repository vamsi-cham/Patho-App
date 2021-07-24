import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:test_lab/Customer/joinlab.dart';
import '../LabSupervisor/setlab.dart';
import 'package:test_lab/api/ApiUrl.dart';




class SetProfile extends StatefulWidget {
  final String mobile;


  SetProfile({Key key, @required this.mobile}) : super(key: key);
  @override
  _SetProfileState createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {

  int selectedIndex = -1; //for choosing the user type
  String name='';
  var role;
  bool loading = false;

  Future setProfile() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "setprofile.php"), body: {
      "mobile": widget.mobile,
      "role": role,
      "name": name,
      "tb": "user",
      "action": "setprofile"
    });

    if (response.statusCode == 200){
          if (role == "labSupervisor") {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SetLab(mobile: widget.mobile, name: name,);
                },
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return JoinLab(mobile: widget.mobile,name: name,);
                },
              ),
            );
          }
    }
     // print(user);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height ) / 10;
    final double itemWidth = size.width / 6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "\nThis is how lab supervisor & customers on our app will get to know you",
                  style: GoogleFonts.montserrat(
                    color: Colors.blueGrey,
                    fontSize: 14.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "You are a",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(

                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: (itemWidth / itemHeight),
                  primary: false,
                  crossAxisCount: 2,
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                        Card(
                        color: selectedIndex == 0 ? Colors.lightBlueAccent[100] : Colors.white ,
                          shape: selectedIndex == 0 ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.green),
                          ) : null ,
                          elevation: 2,

                          child: InkWell(
                            onTap: () {
                              setState(() => selectedIndex=0);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:<Widget> [
                                Image.asset('assets/lab1.png',height: 120,),
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 1.2,
                                  decoration: (selectedIndex == 0) ? BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blue,
                                        ],
                                      ),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10))) : BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blueGrey,
                                          Colors.blueGrey,
                                        ],
                                      ),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                                  child:  Center(
                                    child: Text(
                                      'Lab supervisor',
                                      style: GoogleFonts.montserrat(color: Colors.white,fontSize: 17,),
                                    ),
                                  ) ,
                                ),

                              ],
                            ),
                          ),
                        ),
                    Card(
                      color: selectedIndex == 1 ? Colors.lightBlueAccent[100] : Colors.white ,
                      shape: selectedIndex == 1 ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.green),
                      ) : null ,
                      elevation: 2,

                      child: InkWell(
                        onTap: () {
                          setState(() => selectedIndex=1);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:<Widget> [
                            //SvgPicture.asset('assets/medical-doctor.svg',height: 100,),
                            Image.asset('assets/patient.png',height: 120,),
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 1.2,
                              decoration: (selectedIndex == 1) ? BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      Colors.blue,
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))) : BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueGrey,
                                      Colors.blueGrey,
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              child:  Center(
                                child: Text(
                                  'Customer',
                                  style: GoogleFonts.montserrat(color: Colors.white,fontSize: 17,),
                                ),
                              ) ,
                            ),
                          ],
                        ),
                      ),
                    ),
                     ],
                  ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "Name",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                //color: Colors.blue,
                width: MediaQuery.of(context).size.width / 1.2,
                height: 50,
                decoration: BoxDecoration(
                    //borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Colors.white,
                    //boxShadow: [
                     // BoxShadow(color: Colors.black12, blurRadius: 5)
                    //]
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
                    hintText: 'Enter your name',
                  ),
                  onChanged: (value){
                    setState(() {
                      name = value;
                    });
                  },
                ),

              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: (selectedIndex != -1 && name.isNotEmpty) ? () async {

                    if(selectedIndex == 0){
                      role = "labSupervisor";
                    }
                    if(selectedIndex == 1){
                      role = "Customer";
                    }
                    setProfile();

                } : null ,
                child: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: (selectedIndex != -1 && name.isNotEmpty) ? BoxDecoration(
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
                  child: (selectedIndex != -1 && name.isNotEmpty) ? Center(
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
              //Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
