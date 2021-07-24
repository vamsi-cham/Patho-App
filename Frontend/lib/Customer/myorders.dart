import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:test_lab/Customer/customerHome.dart';
import 'dart:convert';

import 'package:test_lab/api/ApiUrl.dart';


class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {

  var orders = [];

  Future getmyorders() async{


    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getmyorders.php"), body: {
      "mobile": labs[0]['mobile'],
      "tb": "test_bookings",
      "action": "getmyorders"
    });
    //print('addUser Response: ${response.body}');
    //print(response.body);
    var data = json.decode(response.body);

    setState(() {
      orders = data['data'];
    });

    print(orders);

  }

  @override
  void initState() {
    getmyorders();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
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
      body: orders.length == 0 ? Center(
        child: Text(
          "No orders booked yet..",
          style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ) : RefreshIndicator(
        onRefresh: getmyorders,
        child: SingleChildScrollView(
          physics:const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "Orders (${orders.length})",
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
                  itemCount: orders.length,
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
                                  'Test type - ',
                                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 15),
                                ),
                                Text(
                                  orders[index]['test_type'],
                                  style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(
                                  'Lab ID - ',
                                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 15),
                                ),
                                Text(
                                  orders[index]['lab_id'],
                                  style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Booked time - ',
                                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 15),
                                ),
                                Text(
                                  '${orders[index]['booked_time']}',
                                  style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(
                                  'Booking status - ',
                                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 15),
                                ),
                                Text(
                                  '${orders[index]['approval']}',
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
      ),
    );
  }
}
