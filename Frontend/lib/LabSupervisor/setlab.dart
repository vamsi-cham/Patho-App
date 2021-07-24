import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lab/LabSupervisor/labHome.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/widget/loading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SetLab extends StatefulWidget {

  final String mobile;
  final String name;

  // receive data from the FirstScreen as a parameter
  SetLab({Key key, @required this.mobile , @required this.name}) : super(key: key);

  @override
  _SetLabState createState() => _SetLabState();
}

List testtype = []; //This list maintains all test categories which will be fetched from db.
List selectedtesttype =[]; //This list maintains selected categories by the lab supervisor.
List testsubtype = []; //This list maintains all test sub categories which will be fetched from db.
List selectedsubtest = []; //This list maintains selected sub categories by the lab supervisor.
List filteredsublist = []; //This list maintains filtered sub categories while changing the categories.

var _lablists;
var _labsublists;

class _SetLabState extends State<SetLab> {

  Future fetchcategory() async {

    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "fetchtests.php"), body: {

      "action": "fetchtests",
      "tb": "category",

    });

    var data = json.decode(response.body);

    print(data);

    if(response.statusCode == 200){
      testtype=data['data'];

      _lablists = testtype
          .map((lablist) => MultiSelectItem(lablist, lablist['category']))
          .toList();
      return fetchsubcategory();
    }

  }
  Future fetchsubcategory() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "fetchtests.php"), body: {

      "action": "fetchtests",
      "tb": "subcategory",

    });

    var data = json.decode(response.body);

    print(data);

    if(response.statusCode == 200){
      testsubtype=data['data'];
      _labsublists = testsubtype
          .map((lablist) => MultiSelectItem(lablist, lablist['subcategory']))
          .toList();

    }

    setState(() {
      loading = false;
    });

  }

  @override
  void initState() {
    fetchcategory();
    super.initState();
  }

  String labname = '';
  String labtype = '';
  bool loading = false;

  Future setlab() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "setlab.php"), body: {

      "name"  : widget.name,
      "mobile": widget.mobile,
      "lab_name": labname,
      "lab_type" : labtype,
      "action": "setlab",
      "tb": "labSupervisor",

    });

    if(response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isLoggedIn", true);
      Navigator.of(context).pushAndRemoveUntil(
        // the new route
        MaterialPageRoute(
          builder: (BuildContext context) => LabHome(mobile: widget.mobile,),
        ),

        // this function should return true when we're done removing routes
        // but because we want to remove all other screens, we make it
        // always return false
            (Route route) => false,
      );
    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Loading();
    } else {
      return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:<Widget> [
                Text(
                  "\nCreate your Lab",
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 27.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "\nLab name",
                    style: GoogleFonts.montserrat(
                      color: Colors.blueGrey,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Container(

                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          borderSide: BorderSide(color: Colors.grey)),
                      hintText: 'Enter your lab name',
                    ),
                    onChanged: (value){
                      setState(() {
                        labname = value;
                      });
                    },
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "\nLab tests",
                    style: GoogleFonts.montserrat(
                      color: Colors.blueGrey,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                MultiSelectDialogField(
                  items: _lablists,
                  title: Text(
                      "Lab test type",
                    style: GoogleFonts.montserrat(),
                  ),
                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                   // color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  buttonIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                  ),
                  buttonText: Text(
                    "Your lab type",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                    ),
                  ),
                  onConfirm: (results) {
                    selectedtesttype = results;
                    print(selectedtesttype);
                    setState(() {
                      filteredsublist = [];
                      print(_labsublists.length);
                      int i=0;
                      while(i<testsubtype.length){

                        int j=0;
                        while(j<selectedtesttype.length){

                          if(testsubtype[i]['sc_id']==selectedtesttype[j]['id']){
                            filteredsublist.add(testsubtype[i]);
                            break;
                          }
                          j++;
                        }

                        i++;
                      }
                      print(filteredsublist);
                      _labsublists = filteredsublist
                          .map((lablist) => MultiSelectItem(lablist, lablist['subcategory']))
                          .toList();
                    });
                  },
                ),
                SizedBox(height: 20,),
                Visibility(
                  visible: (filteredsublist.length != 0),
                  child: MultiSelectDialogField(
                    items : _labsublists,
                    title: Text(
                      "Select tests",
                      style: GoogleFonts.montserrat(),
                    ),
                    selectedColor: Colors.blue,
                    decoration: BoxDecoration(
                      // color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue,
                    ),
                    buttonText: Text(
                      "Select tests",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      selectedsubtest = results;
                      print(selectedsubtest);
                      labtype = "";
                       int i=0;
                       while(i<selectedsubtest.length){
                         if(i==0) labtype = labtype + selectedsubtest[i]['subcategory']+"," ;
                         else if(i==selectedsubtest.length-1) labtype = labtype +" "+ selectedsubtest[i]['subcategory'] ;
                         else labtype = labtype +" "+ selectedsubtest[i]['subcategory']+"," ;
                         i++;
                       }
                       print(labtype);
                      //_selectedAnimals = results;
                    } ,
                    chipDisplay: MultiSelectChipDisplay(
                      icon: Icon(Icons.remove_circle_outline),
                      onTap: (value) {
                        setState(() {
                          selectedsubtest.remove(value);
                        });
                        print(selectedsubtest);
                        labtype = "";
                        int i=0;
                        while(i<selectedsubtest.length){

                          if(i==0) labtype = labtype + selectedsubtest[i]['subcategory']+"," ;
                          else if(i==selectedsubtest.length-1) labtype = labtype +" "+ selectedsubtest[i]['subcategory'] ;
                          else labtype = labtype +" "+ selectedsubtest[i]['subcategory']+"," ;
                          i++;
                        }
                        print(labtype);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 70,),
                InkWell(
                  onTap: (labtype.isNotEmpty && labname.isNotEmpty) ? () async {

                    setlab();

                  } : null ,
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: (labtype.isNotEmpty && labname.isNotEmpty) ? BoxDecoration(
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
                    child: (labtype.isNotEmpty && labname.isNotEmpty) ? Center(
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
}
