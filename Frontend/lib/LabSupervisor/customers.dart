import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_lab/LabSupervisor/labHome.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/main.dart';
import 'package:test_lab/widget/loading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


List customers = []; //list of enrolled customers
List requests = [];  //list of requested customers


class Customers extends StatefulWidget {
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {

  bool loading = false;
  Future reqcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "pending",
      "tb": "lab_patients",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    requests = data['data'];
    print(requests);
    setState(() {
      loading = false;
    });
  }

  Future getcustomers() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "accepted",
      "tb": "lab_patients",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    customers = data['data'];
    print(customers);
    return reqcustomers();
  }

  @override
  void initState() {
    getcustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: Colors.blue,
            //indicatorSize: TabBarIndicatorSize.label,

            tabs: [
              Tab(
                  child: Text(
                    'Requests',
                    style: GoogleFonts.montserrat(color: Colors.black,fontSize: 15,),

                  )
              ),
              Tab(
                  child: Text(
                    'Enrolled',
                    style: GoogleFonts.montserrat(color: Colors.black,fontSize: 15,),

                  )
              ),
            ],
          ),
          title: Text(
            'Customers',
            style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,

        ),
        body: TabBarView(
          children: [
            RCustomers(),
            ECustomers(),

          ],
        ),

      ),
    );
  }
}


class ECustomers extends StatefulWidget {
  @override
  _ECustomersState createState() => _ECustomersState();
}

class _ECustomersState extends State<ECustomers> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: customers.length == 0 ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "\nEnrolled customers (${customers.length})",
                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                ),
              ],
            ),
          ),
          Spacer(),
          Center(
            child: Text(
              "\nNo customers enrolled..\n\nInvite your customers by sharing \nyour lab code.",
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
                    "\nEnrolled customers (${customers.length})",
                    style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                  ),
                ],
              ),
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: customers.length,
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
                      leading: CircleAvatar(
                        radius: 22,
                        child: Text(
                          customers[index]['patient_name'][0],
                          style: GoogleFonts.montserrat(fontSize: 20),
                        ),
                      ),

                      title: Text(
                        customers[index]['patient_name'],
                        style: GoogleFonts.montserrat(color: Colors.black54 ,  fontSize: 22),
                      ),
                      subtitle: Text(
                        '${customers[index]['mobile']}',
                        style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                      ),

                    ),
                  );
                }
            ),
            SizedBox(height: 70,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final box = context.findRenderObject() as RenderBox;


          await Share.share("You have been invited by ${user[0]['name']} to join test lab ${user[0]['lab_name']}\n\nEnroll to patho using:\n$invitelink\n\nJoining ID - ${user[0]['lab_id']} ",
              subject: user[0]['lab_id'],
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        },
        label:  Text(
            'Invite customers',
            style: GoogleFonts.montserrat(color: Colors.white,  fontSize: 16),
        ),
        icon: const Icon(Icons.share),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}

class RCustomers extends StatefulWidget {
  @override
  _RCustomersState createState() => _RCustomersState();
}

class _RCustomersState extends State<RCustomers> {

  Future updatereq(id,status) async{

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"updatereq.php"),body:{
      "patient_id" : id ,
      "approval" : status,
      "tb" : "lab_patients",
      "action" : "updatereq"


    });
    print(response.body);

    if(response.statusCode == 200){

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Customers()),
      );

    }

  }


  Future reqcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "pending",
      "tb": "lab_patients",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    setState(() {
      requests = data['data'];
    });
    
    print(requests);
  }

  Future getcustomers() async {

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "accepted",
      "tb": "lab_patients",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    setState(() {
      customers = data['data'];
    });
    
    print(customers);
    return reqcustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: requests.length == 0 ? RefreshIndicator(
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
                        "\nCustomer Join Request (${requests.length})",
                        style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Center(
                  child: Text(
                    "\nNo join requests made..\n\nInvite your customers by sharing \nyour lab code.",
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
                        "\nCustomer Join Request (${requests.length})",
                        style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: requests.length,
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
                              leading: CircleAvatar(
                                radius: 22,
                                child: Text(
                                  requests[index]['patient_name'][0],
                                  style: GoogleFonts.montserrat(fontSize: 20),
                                ),
                              ),

                              title: Text(
                                requests[index]['patient_name'],
                                style: GoogleFonts.montserrat(color: Colors.black54 ,  fontSize: 22),
                              ),

                              subtitle: Text(
                                '${requests[index]['mobile']}',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                              ),
                            ),
                            ButtonBar(
                              children: <Widget>[

                                TextButton(
                                    onPressed: () {
                                       updatereq(requests[index]['patient_id'],'accepted');
                                    },

                                    child: Text(
                                      'Accept',
                                      style: GoogleFonts.montserrat(color: Color(0xFF00897b),fontSize: 16,),

                                    )
                                ),

                                TextButton(
                                    onPressed: () {
                                      updatereq(requests[index]['patient_id'],'declined');
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
                SizedBox(height: 70,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final box = context.findRenderObject() as RenderBox;


          await Share.share("You have been invited by ${user[0]['name']} to join test lab ${user[0]['lab_name']}\n\nEnroll to patho using:\n$invitelink\n\nJoining ID - ${user[0]['lab_id']} ",
              subject: user[0]['lab_id'],
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        },
        label:  Text(
          'Invite customers',
          style: GoogleFonts.montserrat(color: Colors.white,  fontSize: 16),
        ),
        icon: const Icon(Icons.share),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}
