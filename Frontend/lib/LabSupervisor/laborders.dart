import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/main.dart';

List pendingorders=[];
List confirmedorders=[];

class LabOrders extends StatefulWidget {
  @override
  _LabOrdersState createState() => _LabOrdersState();
}

class _LabOrdersState extends State<LabOrders> {

  Future reqcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "pending",
      "tb": "test_bookings",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);
    setState(() {
      pendingorders = data['data'];
    });
    print(pendingorders);

  }

  Future getcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "accepted",
      "tb": "test_bookings",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);
     setState(() {
       confirmedorders = data['data'];
     });

    print(confirmedorders);
    return reqcustomers();
  }

  @override
  void initState() {
    getcustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: Colors.blue,
            //indicatorSize: TabBarIndicatorSize.label,

            tabs: [
              Tab(
                  child: Text(
                    'New Requests',
                    style: GoogleFonts.montserrat(color: Colors.black,fontSize: 15,),

                  )
              ),
              Tab(
                  child: Text(
                    'Confirmed orders',
                    style: GoogleFonts.montserrat(color: Colors.black,fontSize: 15,),

                  )
              ),
            ],
          ),
          title: Text(
            'Orders',
            style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,

        ),
        body: TabBarView(
          children: [
            PendingOrders(),
            ConfirmedOrders(),

          ],
        ),

      ),
    );
  }
}

class PendingOrders extends StatefulWidget {
  @override
  _PendingOrdersState createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  Future updatereq(id,status) async{

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"updatereq.php"),body:{
      "patient_id" : id ,
      "approval" : status,
      "tb" : "test_bookings",
      "action" : "updatereq"


    });
    print(response.body);

    if(response.statusCode == 200){

      getcustomers();

    }

  }
  Future reqcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "pending",
      "tb": "test_bookings",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);
    setState(() {
      pendingorders = data['data'];
    });
    print(pendingorders);

  }

  Future getcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "accepted",
      "tb": "test_bookings",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);
    setState(() {
      confirmedorders = data['data'];
    });

    print(confirmedorders);
    return reqcustomers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pendingorders.length == 0 ? RefreshIndicator(
        onRefresh: getcustomers,
        child: Stack(
          children: <Widget>[
            ListView(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "New Requests (${pendingorders.length})",
                        style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Spacer(),
                Center(
                  child: Text(
                    "No order requests..",
                    style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ) : RefreshIndicator(
        onRefresh: getcustomers,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "New Requests (${pendingorders.length})",
                        style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: pendingorders.length,
                    itemBuilder: (BuildContext context,int index){

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // if you need this
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        color: Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                        child: Column(
                          children: [
                            ListTile(

                              title: Text(
                                pendingorders[index]['name'],
                                style: GoogleFonts.montserrat(color: Colors.black54 ,  fontSize: 22),
                              ),

                              subtitle: Text(
                                '${pendingorders[index]['test_type']}',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                              ),
                            ),
                            ButtonBar(
                              children: <Widget>[

                                TextButton(
                                    onPressed: () {
                                      updatereq(pendingorders[index]['patient_id'],'accepted');
                                    },

                                    child: Text(
                                      'Accept',
                                      style: GoogleFonts.montserrat(color: Color(0xFF00897b),fontSize: 16,),

                                    )
                                ),

                                TextButton(
                                    onPressed: () {
                                      updatereq(pendingorders[index]['patient_id'],'declined');
                                    },
                                    child: Text(
                                      'Decline',
                                      style: GoogleFonts.montserrat(color: Colors.red,fontSize: 15,),

                                    )
                                ),

                              ],
                            ),
                          ],
                        ),
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmedOrders extends StatefulWidget {
  @override
  _ConfirmedOrdersState createState() => _ConfirmedOrdersState();
}

class _ConfirmedOrdersState extends State<ConfirmedOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: confirmedorders.length == 0 ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Confirmed Orders (${confirmedorders.length})",
                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                ),
              ],
            ),
          ),
          Spacer(),
          Center(
            child: Text(
              "No confirmed orders yet..",
              style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
        ],
      ) : SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Confirmed Orders (${confirmedorders.length})",
                    style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                  ),
                ],
              ),
            ),
            Divider(),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: confirmedorders.length,
                itemBuilder: (BuildContext context,int index){

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // if you need this
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    //elevation: 4,
                    margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                    child: ListTile(

                      title: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text(
                                'Test type - ${confirmedorders[index]['test_type']}',
                                style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text(
                                'Customer Name - ${confirmedorders[index]['name']}',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text(
                                'Mobile Number - ${confirmedorders[index]['mobile']}',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text(
                                'Address - ${confirmedorders[index]['address']}',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),

                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
