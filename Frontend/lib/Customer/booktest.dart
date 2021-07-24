import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:test_lab/Customer/customerHome.dart';
import 'dart:convert';

import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/widget/loading.dart';

class BookTest extends StatefulWidget {

  final String category;

  BookTest({Key key, @required this.category}) : super(key: key);

  @override
  _BookTestState createState() => _BookTestState();
}

class _BookTestState extends State<BookTest> {


  String name = '';
  String mobile = '';
  String address = '';
  String chosenlab = '';
  int chosenlabid ;

  bool loading = false;
  var filteredlabs = []; //filters enrolled labs by chosen category
  var chooselab=[]; //dropdownlist for choosing lab;

  Future filterlabs() async{
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "filterlabs.php"), body: {
      "mobile": labs[0]['mobile'],
      "category": widget.category,
      "approval": "accepted",
      "tb": "lab_patients",
      "action": "filterlabs"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    filteredlabs = data['data'];
    print(filteredlabs);
    chooselab = filteredlabs
        .map((lablist) => (lablist['lab_name']))
        .toList();
    print(chooselab);
    setState(() {
      loading = false;
    });

  }
  @override
  void initState() {
    filterlabs();
    super.initState();
  }

  Future booktest() async{

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "booktest.php"), body: {
      "test_type": widget.category,
      "customer_mobile": labs[0]['mobile'],
      "lab_id": filteredlabs[chosenlabid]['lab_id'],
      "name": name,
      "mobile": mobile,
      "address": address,
      "action": "booktest",
      "tb": "test_bookings",

    });

    if(response.statusCode==200) {
      print("success");
      Fluttertoast.showToast(
          msg: "Booked successfully" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.of(context).pushAndRemoveUntil(
        // the new route
        MaterialPageRoute(
          builder: (BuildContext context) => CustomerHome(mobile:labs[0]['mobile'] ),
        ),

        // this function should return true when we're done removing routes
        // but because we want to remove all other screens, we make it
        // always return false
            (Route route) => false,
      );
    }

  }

  @override
  Widget build(BuildContext context) {

    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Test',
          style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              //print(widget.category);
              Navigator.of(context).pop();
            }
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: filteredlabs.length == 0 ? Center(
        child: Text(
          "No enrolled labs with this category",
          style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ) : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:<Widget> [
                Row(
                  children: [
                    Text(
                      "Book a ${widget.category} test",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text(
                  "\nChoose a lab\n",
                  style: GoogleFonts.montserrat(
                    color: Colors.blueGrey,
                    fontSize: 17.0,
                  ),
                ),
                Container(

                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.grey)),
                      hintText: 'choose a lab',
                    ),
                      items:
                      chooselab.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text('$type'),
                        );
                      }).toList(),

                      onChanged: (val) {
                        setState(() {
                          chosenlab = val;
                          chosenlabid = chooselab.indexOf(chosenlab);
                          print(chosenlabid);
                        });
                      }),
                  ),
                Text(
                  "\nEnter your details",
                  style: GoogleFonts.montserrat(
                    color: Colors.blueGrey,
                    fontSize: 17.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        " Name",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 14.0,
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
                      hintText: 'Patient Name',
                    ),
                    onChanged: (value){
                      setState(() {
                        name = value;
                      });
                    },
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        " Phone(+91)",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 14.0,
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
                      hintText: 'Mobile Number',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value){
                      setState(() {
                        mobile = value;
                      });
                    },
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        " Address",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 14.0,
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
                      hintText: 'Enter your address',
                    ),
                    onChanged: (value){
                      setState(() {
                        address = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30,),
                InkWell(
                  onTap: (name.isNotEmpty && mobile.length >=10 && address.isNotEmpty && chosenlab.isNotEmpty) ? () async {

                    booktest();


                  } : null ,
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: (name.isNotEmpty && mobile.length >=10  && address.isNotEmpty&& chosenlab.isNotEmpty) ? BoxDecoration(
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
                    child: (name.isNotEmpty && mobile.length >=10  && address.isNotEmpty&& chosenlab.isNotEmpty) ? Center(
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
