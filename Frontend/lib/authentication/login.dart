import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/Customer/customerHome.dart';
import 'package:test_lab/Customer/joinlab.dart';
import 'package:test_lab/LabSupervisor/labHome.dart';
import '../LabSupervisor/setlab.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/main.dart';
import 'setprofile.dart';
import 'package:test_lab/widget/loading.dart';
import 'package:twilio_phone_verify/twilio_phone_verify.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TwilioPhoneVerify _twilioPhoneVerify;


  @override
  void initState() {
    _twilioPhoneVerify = new TwilioPhoneVerify(
        accountSid: 'ACc30af0e21941aba21cc1508802f02293', // replace with Account SID
        authToken: '8227b507abae359955e830649b8189a4',  // replace with Auth Token
        serviceSid: 'VAb3c0d502c9c61e2dc9e6c84e5f671f4c' // replace with Service SID
    );
    super.initState();
  }


  String mobile = '';
  String otpPin = '';
  bool loading = false;
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: Colors.blue,
    ),
  );
  final BoxDecoration inPutDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: Colors.grey,
    ),
  );

  Future checkuser() async{

    print(mobile);

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"checkuser.php"),body:{

      "mobile" :mobile,
      "action" : "checkuser",
      "tb":"user",

    });
    var data = json.decode(response.body);
    //print(data);

    if(data['status']==200){  //This means the user is already registered with this number.
      return login();
    }
    if(data['status']==201){  //This means the user is not registered with this number

      return signup();
    }

  }

  Future signup() async{

    setState(() {
      loading = true;
    });

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"signup.php"),body:{

      "mobile" :mobile,
      "action" : "signup",
      "tb":"user",

    });

    if(response.statusCode==200){

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return SetProfile(mobile: mobile,);
            },
          ),
        );

      Fluttertoast.showToast(
          msg: "You account has been created , set your account" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    setState(() {
      loading = false;
    });
  }

  Future login() async{

    setState(() {
      loading = true;
    });

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"login.php"),body:{
      "mobile" : mobile,
      "tb" : "user",
      "action" : "login"

    });
    //print('addUser Response: ${response.body}');


    var data = json.decode(response.body);
    //print(data);

    if(data['status']==200){
      user = data['data'];
      print(user);

      if(user[0]['role'] == null){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return SetProfile(mobile: mobile,);
            },
          ),
        );
        print("set your account");
        Fluttertoast.showToast(
            msg: "set your account",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else {

        if(user[0]['role'] == "labSupervisor") {

          var response = await http.post(Uri.parse(ApiUrl.baseurl+"checkuser.php"),body:{

            "mobile" :mobile,
            "action" : "checkuser",
            "tb":"labSupervisor",

          });
          var data = json.decode(response.body);
          //print(data);

          if(data['status']==200){  //This means the user is already has his lab account.
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs?.setBool("isLoggedIn", true);
            Navigator.of(context).pushAndRemoveUntil(
              // the new route
              MaterialPageRoute(
                builder: (BuildContext context) => LabHome(mobile: mobile,),
              ),

              // this function should return true when we're done removing routes
              // but because we want to remove all other screens, we make it
              // always return false
                  (Route route) => false,
            );
            Fluttertoast.showToast(
                msg: "You are logged in successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          if(data['status']==201){  //This means the user is not created lab account

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SetLab(mobile: user[0]['mobile'], name: user[0]['name']);
                },
              ),
            );
          }


        }else{

          var response = await http.post(Uri.parse(ApiUrl.baseurl+"checkuser.php"),body:{

            "mobile" :mobile,
            "action" : "checkuser",
            "tb":"lab_patients",

          });
          var data = json.decode(response.body);
          print(data);

          if(data['status'] == 200){  //This means this customer joined at least one lab

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs?.setBool("isLoggedIn", true);

            Navigator.of(context).pushAndRemoveUntil(
              // the new route
              MaterialPageRoute(
                builder: (BuildContext context) => CustomerHome(mobile: mobile,),
              ),

              // this function should return true when we're done removing routes
              // but because we want to remove all other screens, we make it
              // always return false
                  (Route route) => false,
            );
            Fluttertoast.showToast(
                msg: "You are logged in successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0
            );

          }

          if(data['status'] == 201){ //This means customer didn't join at least one lab

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return JoinLab(mobile: user[0]['mobile'], name: user[0]['name']);
                },
              ),
            );

          }


        }
      }
    }
    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView(
              //padding: EdgeInsets.all(20.0),
              children: <Widget>[
                Container(
                  color: Colors.grey[50],
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Patho",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 35.0,
                          ),
                        ),
                        Text(
                          "         Share your testing reports through online now",
                          style: GoogleFonts.montserrat(
                            color: Colors.blueGrey,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),

                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,

                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    image: DecorationImage(
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),

                ),


                SizedBox(
                  height: 30,
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(
                          "      Get Started\n",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 25.0,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.4,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(25.0),
                                    topRight: const Radius.circular(25.0),
                                  ),
                                ),
                                child: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter stateSetter) {
                                     return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:<Widget> [

                                        Row(
                                          children: [
                                            Text(
                                              "         Get Started",
                                              style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "         Enter mobile number to continue",
                                              style: GoogleFonts.montserrat(
                                                color: Colors.blueGrey,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Container(
                                          //color: Colors.blue,
                                          width: MediaQuery.of(context).size.width / 1.2,
                                          height: 45,
                                          padding: EdgeInsets.only(
                                              top: 4, left: 16, right: 16, bottom: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(50)),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black12, blurRadius: 5)
                                            ],
                                          ),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              icon: Icon(
                                                Icons.phone,
                                                color: Colors.blue,
                                              ),
                                              hintText: '   phone number',
                                              prefix: Text('+91'),

                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value){
                                              stateSetter(() {
                                                mobile = value;
                                              });
                                            },


                                          ),
                                        ),
                                        InkWell(
                                          onTap: mobile.length >=10  ? () async {

                                            var twilioResponse = await _twilioPhoneVerify.sendSmsCode('+91$mobile');

                                            if (twilioResponse.successful)  {
                                              print("code sent");
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Padding(
                                                      padding: MediaQuery.of(context).viewInsets,
                                                      child: Container(
                                                          height: MediaQuery.of(context).size.height * 0.4,
                                                          decoration: new BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: new BorderRadius.only(
                                                              topLeft: const Radius.circular(25.0),
                                                              topRight: const Radius.circular(25.0),
                                                            ),
                                                          ),
                                                          child: StatefulBuilder(
                                                              builder: (BuildContext context, StateSetter stateSetter) {
                                                                return Column(
                                                                  children: <Widget> [
                                                                    SizedBox(height: 20,),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "        Enter OTP to verify your moblie",
                                                                          style: GoogleFonts.montserrat(
                                                                            color: Colors.black,
                                                                            fontSize: 16.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 20,),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "         OTP sent to +91 $mobile",
                                                                          style: GoogleFonts.montserrat(
                                                                            color: Colors.blueGrey,
                                                                            fontSize: 14.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.all(30.0),
                                                                      child: PinPut(
                                                                        fieldsCount: 6,
                                                                        textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                                                                        eachFieldWidth: 40.0,
                                                                        eachFieldHeight: 55.0,
                                                                        focusNode: _pinPutFocusNode,
                                                                        submittedFieldDecoration: inPutDecoration,
                                                                        selectedFieldDecoration: pinPutDecoration,
                                                                        followingFieldDecoration: inPutDecoration,
                                                                        pinAnimationType: PinAnimationType.fade,
                                                                        onChanged: (value){
                                                                          stateSetter(() {
                                                                            otpPin = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 30.0),
                                                                    InkWell(
                                                                      onTap: otpPin.length ==6 ? () async {

                                                                        print(otpPin);
                                                                        var twilioResponse = await _twilioPhoneVerify.verifySmsCode(phone: '+91$mobile',code: otpPin  );

                                                                        if (twilioResponse.successful) {
                                                                          if (twilioResponse.verification.status == VerificationStatus.approved) {
                                                                            print("phone number verified");
                                                                            checkuser();
                                                                          } else {
                                                                            print('Invalid code');
                                                                            Fluttertoast.showToast(
                                                                                msg: "Invalid OTP",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.CENTER,
                                                                                timeInSecForIosWeb: 4,
                                                                                backgroundColor: Colors.white,
                                                                                textColor: Colors.red,
                                                                                fontSize: 16.0
                                                                            );
                                                                          }

                                                                        }else {
                                                                          Fluttertoast.showToast(
                                                                              msg: twilioResponse.errorMessage,
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 4,
                                                                              backgroundColor: Colors.blue,
                                                                              textColor: Colors.white,
                                                                              fontSize: 16.0
                                                                          );
                                                                          print(twilioResponse.errorMessage);
                                                                        }
                                                                      }: null,
                                                                      child: Container(
                                                                        height: 45,
                                                                        width: MediaQuery.of(context).size.width / 1.2,
                                                                        decoration: otpPin.length>5 ? BoxDecoration(
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
                                                                        child: otpPin.length == 6 ? Center(
                                                                          child: Text(
                                                                            'Continue',
                                                                            style: GoogleFonts.montserrat(color: Colors.white,fontSize: 19,),
                                                                          ),
                                                                        ) : Center(
                                                                          child: Text(
                                                                            'Continue',
                                                                            style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 19,),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }
                                                          )
                                                      ),
                                                    );
                                                  }
                                              );
                                            }else {
                                              Fluttertoast.showToast(
                                                  msg: twilioResponse.errorMessage,
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 4,
                                                  backgroundColor: Colors.blue,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                              print(twilioResponse.errorMessage);
                                            }

                                          } : null,
                                          child: Container(
                                            height: 45,
                                            width: MediaQuery.of(context).size.width / 1.2,
                                            decoration: mobile.length >=10  ?  BoxDecoration(
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
                                            child:  mobile.length >=10  ? Center(
                                              child: Text(
                                                'Send OTP',
                                                style: GoogleFonts.montserrat(color: Colors.white,fontSize: 16,),
                                              ),
                                            ): Center(
                                              child: Text(
                                                'Send OTP',
                                                style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 16,),
                                              ),
                                            ),
                                          ) ,
                                        ),
                                      ],
                                    );
                                  } )
                              ),
                            );
                              }
                              );
                          },
                      child: Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.blue,
                              ],
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(50))),
                        child: Center(
                          child: Text(
                            'Login with phone number',
                            style: GoogleFonts.montserrat(color: Colors.white,fontSize: 19,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}